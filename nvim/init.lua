require("init")

vim.api.nvim_create_user_command('OpencodeQuota', function()
  local path = vim.fn.expand('~/.config/opencode/antigravity-accounts.json')
  local f = io.open(path, 'r')
  if not f then
    vim.notify("Could not open Opencode accounts file", vim.log.levels.ERROR)
    return
  end
  local content = f:read('*a')
  f:close()

  local ok, data = pcall(vim.json.decode, content)
  if not ok or not data.accounts or not data.accounts[1] then
    vim.notify("Failed to parse quota data", vim.log.levels.ERROR)
    return
  end

  local quota = data.accounts[1].cachedQuota
  if not quota then
    vim.notify("No quota data found. Run a prompt first.", vim.log.levels.WARN)
    return
  end

  local msg = string.format(
    "[ Opencode Quotas ]\n- Claude: %d%%\n- Gemini Flash: %d%%\n- Gemini Pro: %d%%",
    (quota["claude"] and quota["claude"].remainingFraction or 0) * 100,
    (quota["gemini-flash"] and quota["gemini-flash"].remainingFraction or 0) * 100,
    (quota["gemini-pro"] and quota["gemini-pro"].remainingFraction or 0) * 100
  )

  vim.notify(msg, vim.log.levels.INFO)
end, { desc = "Check Opencode Antigravity Quotas" })
