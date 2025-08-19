---@class DLiteScript
local M = {}

local default_config = {
  highlight = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  fold = {
    enable = false,
  },
  auto_install = true,
  lsp = {
    enable = true,
    cmd = { 'dlitescript', 'lsp', '--stdio' },
    root_markers = { '.git' },
    settings = {},
  },
}

---@param opts table|nil
M.setup = function(opts)
  local config = vim.tbl_deep_extend("force", default_config, opts or {})

  local has_treesitter, ts_configs = pcall(require, "nvim-treesitter.configs")

  if not has_treesitter then
    vim.notify(
      "nvim-treesitter not found. Please install it to enable syntax highlighting.",
      vim.log.levels.WARN
    )

    return
  end

  local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
  parser_config.dlitescript = {
    install_info = {
      url = "https://github.com/Dobefu/tree-sitter-dlitescript",
      files = { "src/parser.c" },
      branch = "main",
    },
    filetype = "dlitescript",
  }

  ts_configs.setup {
    ensure_installed = config.auto_install and { "dlitescript" } or nil,
    highlight = {
      enable = config.highlight.enable,
    },
    indent = {
      enable = config.indent.enable,
    },
    fold = {
      enable = config.fold.enable,
    },
  }

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "dlitescript",
    callback = function()
      vim.opt_local.commentstring = "// %s"
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.expandtab = true
    end,
  })

  if config.lsp.enable then
    vim.lsp.config['dlitescript'] = {
      cmd = config.lsp.cmd,
      filetypes = { 'dlitescript' },
      root_markers = { '.git' },
      settings = config.lsp.settings,
      capabilities = vim.lsp.protocol.make_client_capabilities(),
    }

    vim.lsp.enable('dlitescript')
  end
end

return M
