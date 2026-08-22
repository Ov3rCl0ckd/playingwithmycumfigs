return {
  "sudo-tee/opencode.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "folke/snacks.nvim",
  },
  
  -- `config` is where we set up the plugin
  config = function()
    vim.o.autoread = true
    
    require('opencode').setup({
      -- Configuration options
      server = {
        url = "http://localhost:8000",
      },
      ask = {
        snacks = {
          icon = "󰚩 ",
          win = { border = "rounded" },
        },
      },
      select = {
        snacks = {
          layout = { preset = "vscode" },
          win = { border = "rounded" },
        },
      },
    })
  end,
}
