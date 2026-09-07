return {
  'willothy/wezterm.nvim',
  config = true,
  keys = {
    -- Splitting panes
    { "<Leader>wv", function() require('wezterm').split_pane.vertical() end, desc = "WezTerm split vertical" },
    { "<Leader>ws", function() require('wezterm').split_pane.horizontal() end, desc = "WezTerm split horizontal" },
    { "<Leader>wz", function() require('wezterm').zoom_pane() end, desc = "WezTerm zoom pane (toggle)" },
    
    -- Navigating tabs
    { "<Leader>wn", function() require('wezterm').switch_tab.relative(1) end, desc = "WezTerm next tab" },
    { "<Leader>wp", function() require('wezterm').switch_tab.relative(-1) end, desc = "WezTerm prev tab" },
    
    -- Navigating panes (using vim directions h, j, k, l)
    { "<Leader>wh", function() require('wezterm').switch_pane.direction("Left") end, desc = "WezTerm pane left" },
    { "<Leader>wj", function() require('wezterm').switch_pane.direction("Down") end, desc = "WezTerm pane down" },
    { "<Leader>wk", function() require('wezterm').switch_pane.direction("Up") end, desc = "WezTerm pane up" },
    { "<Leader>wl", function() require('wezterm').switch_pane.direction("Right") end, desc = "WezTerm pane right" },
  }
}
