-- plugin/opencode_session.lua

local project = require("opencode_session.project")
local db = require("opencode_session.db")
local session = require("opencode_session.session")
local prompts = require("opencode_session.prompts")

print("opencode_session.nvim loaded")

-- More to come here

-- 1. Define DB Path
local db_dir = vim.fn.expand("~/.local/share/opencode")
local db_path = db_dir .. "/opencode.db"

-- Ensure the directory exists
if vim.fn.isdirectory(db_dir) == 0 then
  vim.fn.mkdir(db_dir, "p")
end

-- Initialize the plugin
local function initialize()
  -- Setup project detection
  project.setup(vim.g.opencode_opts)

  local db_exists = vim.fn.filereadable(db_path) == 1
  if db.open(db_path) then
    db.setup()
    if not db_exists then
      vim.notify("Opencode database initialized at " .. db_path)
    end
  else
    vim.notify("Opencode failed to initialize database.", vim.log.levels.ERROR)
  end
  session.resume_or_start_session()
end

-- 3. Add User Commands
vim.api.nvim_create_user_command("SessionStart", session.start_session, {})

vim.api.nvim_create_user_command("SessionSaveMessage", function(args)
  if not args.fargs or #args.fargs < 2 then
    vim.notify("Usage: SessionSaveMessage <role> <content>", vim.log.levels.ERROR)
    return
  end
  session.save_message(args.fargs[1], table.concat(args.fargs, " ", 2))
  vim.notify("Message saved.")
end, {nargs = "+"})

vim.api.nvim_create_user_command("SessionLoadHistory", function()
  local history = session.load_history()
  print("Session History:")
  for _, msg in ipairs(history) do
    print(string.format("- [%s]: %s", msg.role, msg.content))
  end
end, {})

-- Initialize the plugin
initialize()

-- Autocommands to manage prompt files
local group = vim.api.nvim_create_augroup("OpencodeSessionPrompts", { clear = true })
local function manage_prompts()
  if project.get_project_root() then
    prompts.setup()
  else
    prompts.teardown()
  end
end

vim.api.nvim_create_autocmd("VimEnter", {
  group = group,
  callback = manage_prompts,
})
vim.api.nvim_create_autocmd("DirChanged", {
  group = group,
  callback = manage_prompts,
})
