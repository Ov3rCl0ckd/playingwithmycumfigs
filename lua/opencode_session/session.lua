-- lua/opencode_session/session.lua
local M = {}

local project = require("opencode_session.project")
local db = require("opencode_session.db")

local current_session_id

function M.start_session()
  local project_root = project.get_project_root()
  if not project_root then
    vim.notify("Not in a project, cannot start session.", vim.log.levels.WARN)
    return
  end
  current_session_id = project_root .. "-" .. os.time()
  db.set_active_session(project_root, current_session_id)
  vim.notify("Started new opencode session: " .. current_session_id)
end

function M.resume_or_start_session()
  local project_root = project.get_project_root()
  if not project_root then
    return -- Not in a project, do nothing
  end

  local last_session = db.get_active_session(project_root)
  if last_session then
    current_session_id = last_session
    vim.notify("Resumed opencode session: " .. current_session_id)
  else
    M.start_session()
  end
end

function M.get_current_session_id()
  return current_session_id
end

function M.save_message(role, content)
  local project_root = project.get_project_root()
  if not project_root or not current_session_id then
    vim.notify("Not in a valid session.", vim.log.levels.ERROR)
    return
  end
  db.add_message(project_root, current_session_id, role, content)
end

function M.load_history()
  local project_root = project.get_project_root()
  if not project_root or not current_session_id then
    vim.notify("Not in a valid session.", vim.log.levels.ERROR)
    return {}
  end
  return db.get_session_messages(project_root, current_session_id)
end

return M
