-- lua/opencode_session/db.lua
local M = {}

local SnacksDb = require("snacks.picker.util.db")
local db

function M.open(db_path)
  -- The snacks db module creates a kv store by default.
  -- We will use the exec method to create our own table.
  -- The 'new' function returns a db object.
  db = SnacksDb.new(db_path)
  if not db then
    vim.notify("Error opening database via snacks.", vim.log.levels.ERROR)
    return nil
  end
  return db
end

function M.setup()
  if not db then
    vim.notify("Database not open", vim.log.levels.ERROR)
    return
  end

  local create_table_sql = [[
  CREATE TABLE IF NOT EXISTS chat_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_path TEXT NOT NULL,
    session_id TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    role TEXT NOT NULL,
    content TEXT NOT NULL
  );
  CREATE TABLE IF NOT EXISTS active_sessions (
    project_path TEXT PRIMARY KEY,
    session_id TEXT NOT NULL
  );
  ]]

  -- Using pcall to catch potential errors from db:exec
  local ok, err = pcall(function()
    db:exec(create_table_sql)
  end)

  if not ok then
    vim.notify("Error creating table: " .. tostring(err), vim.log.levels.ERROR)
  end
end

function M.add_message(project_path, session_id, role, content)
  if not db then
    vim.notify("Database not open", vim.log.levels.ERROR)
    return
  end

  local insert_sql = [[
  INSERT INTO chat_history (project_path, session_id, timestamp, role, content)
  VALUES (?, ?, ?, ?, ?);
  ]]

  local ok, err = pcall(function()
    local stmt = db:prepare(insert_sql)
    local timestamp = os.time()
    -- 101 == SQLITE_DONE
    if stmt:exec({ project_path, session_id, timestamp, role, content }) ~= 101 then
      error("Failed to execute insert statement")
    end
    stmt:close()
  end)

  if not ok then
    vim.notify("Error inserting message: " .. tostring(err), vim.log.levels.ERROR)
  end
end

function M.get_session_messages(project_path, session_id)
  if not db then
    vim.notify("Database not open", vim.log.levels.ERROR)
    return {}
  end

  local select_sql = [[
  SELECT role, content FROM chat_history
  WHERE project_path = ? AND session_id = ?
  ORDER BY timestamp;
  ]]

  local messages = {}
  local ok, err = pcall(function()
    local stmt = db:prepare(select_sql)
    -- 100 == SQLITE_ROW
    if stmt:exec({ project_path, session_id }) == 100 then
      repeat
        local role = stmt:col("string", 0)
        local content = stmt:col("string", 1)
        table.insert(messages, { role = role, content = content })
      until stmt:step() ~= 100
    end
    stmt:close()
  end)

  if not ok then
    vim.notify("Error getting messages: " .. tostring(err), vim.log.levels.ERROR)
    return {}
  end

  return messages
end


function M.set_active_session(project_path, session_id)
  if not db then return end
  pcall(function()
    local stmt = db:prepare("INSERT OR REPLACE INTO active_sessions (project_path, session_id) VALUES (?, ?);")
    if stmt:exec({ project_path, session_id }) ~= 101 then -- 101 == SQLITE_DONE
      error("Failed to set active session")
    end
    stmt:close()
  end)
end

function M.get_active_session(project_path)
  if not db then return nil end
  local session_id
  pcall(function()
    local stmt = db:prepare("SELECT session_id FROM active_sessions WHERE project_path = ?;")
    if stmt:exec({ project_path }) == 100 then -- 100 == SQLITE_ROW
      session_id = stmt:col("string", 0)
    end
    stmt:close()
  end)
  return session_id
end

return M
