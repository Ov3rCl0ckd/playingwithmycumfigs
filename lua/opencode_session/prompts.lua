-- lua/opencode_session/prompts.lua
local M = {}

-- Get the path of the current file, and from there the plugin root
local plugin_path = debug.getinfo(1, "S").source:match("@(.+)[\\/]lua[\\/]opencode_session[\\/]prompts.lua")
local plugin_prompt_dir = plugin_path .. "/prompt"
local opencode_modes_dir = vim.fn.expand("~/.config/opencode/modes")

local prompt_files = {
  "Tutor.md",
  "docs.md",
  "review.md",
  "cop.md",
  "rabbit.md",
}

function M.setup()
  if vim.fn.isdirectory(opencode_modes_dir) == 0 then
    vim.fn.mkdir(opencode_modes_dir, "p")
  end

  for _, file in ipairs(prompt_files) do
    local source = plugin_prompt_dir .. "/" .. file
    local dest = opencode_modes_dir .. "/" .. file
    if vim.fn.filereadable(source) == 1 and vim.fn.filereadable(dest) == 0 then
      local lines = vim.fn.readfile(source)
      vim.fn.writefile(lines, dest)
    end
  end
end

function M.teardown()
  if vim.fn.isdirectory(opencode_modes_dir) == 0 then
    return
  end
  for _, file in ipairs(prompt_files) do
    local dest = opencode_modes_dir .. "/" .. file
    if vim.fn.filereadable(dest) == 1 then
      vim.fn.delete(dest)
    end
  end
end

return M
