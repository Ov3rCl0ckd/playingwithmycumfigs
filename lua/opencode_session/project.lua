local M = {}

local config = {
  parent_dirs = {}
}

-- Normalize path separators to be consistent
local function normalize_path(path)
  return path:gsub("\\", "/")
end

function M.setup(opts)
  if opts and opts.project and opts.project.parent_dirs then
    config.parent_dirs = {}
    for _, dir in ipairs(opts.project.parent_dirs) do
      table.insert(config.parent_dirs, normalize_path(dir))
    end
  end
end

-- Find project root based on configured parent directories
local function find_project_root_from_parent_dirs(start_dir)
  local normalized_start_dir = normalize_path(start_dir)
  for _, parent_dir in ipairs(config.parent_dirs) do
    if normalized_start_dir:sub(1, #parent_dir) == parent_dir then
      -- Make sure it's not the parent directory itself
      if normalized_start_dir == parent_dir then
        return nil
      end
      local remaining = normalized_start_dir:sub(#parent_dir + 2) -- +2 for the slash
      local project_name = remaining:match("([^/]+)")
      if project_name then
        return parent_dir .. "/" .. project_name
      end
    end
  end
  return nil
end

-- Find project root by searching for a .git directory
function M.find_project_root_from_vcs(start_dir)
  local current_dir = start_dir
  while current_dir ~= nil and current_dir ~= "/" and current_dir ~= "" do
    if vim.fn.isdirectory(current_dir .. "/.git") then
      return current_dir
    end
    local parent = vim.fn.fnamemodify(current_dir, ":h")
    if parent == current_dir then -- Reached root
      return nil
    end
    current_dir = parent
  end
  return nil
end

function M.get_project_root()
  local cwd = vim.fn.resolve(vim.fn.getcwd())
  
  local root = find_project_root_from_parent_dirs(cwd)
  if root then
    return root
  end

  return M.find_project_root_from_vcs(cwd)
end

return M
