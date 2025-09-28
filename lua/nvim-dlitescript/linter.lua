---@class DLiteScriptLinter
local M = {}

---@param config table
---@param namespace integer
M.setup = function(config, namespace)
  local lint_group = vim.api.nvim_create_augroup(
    "DLiteScriptLint",
    { clear = true }
  )

  local function run_linter()
    if vim.bo.filetype ~= "dlitescript" then
      return
    end

    local bufnr = vim.api.nvim_get_current_buf()
    local filename = vim.api.nvim_buf_get_name(bufnr)
    local shell_cmd = config.lint.cmd[3]:gsub("%$1", filename)

    vim.system({ "sh", "-c", shell_cmd }, { text = true }, function(result)
      local diagnostics = {}

      if not result.stdout or result.stdout == "" then
        vim.schedule(function()
          vim.diagnostic.set(namespace, bufnr, diagnostics)
        end)

        return
      end

      local lines = vim.split(result.stdout, "\n")

      for _, line in ipairs(lines) do
        if line == "" or line:match("^Linting ") then
          goto continue
        end

        local pattern = "([^:]+):(%d+):(%d+):%s*(%w+):%s*(.+)%s*%((.+)%)"
        local file, line_num, col_num, severity, message, rule = line:match(pattern)

        if not file or not line_num or not col_num then
          goto continue
        end

        local severities = {
          error = vim.diagnostic.severity.ERROR,
          warning = vim.diagnostic.severity.WARN,
          info = vim.diagnostic.severity.INFO,
        }

        table.insert(diagnostics, {
          lnum = tonumber(line_num) - 1,
          col = tonumber(col_num) - 1,
          message = message,
          source = "dlitescript-lint",
          severity = severities[severity] or vim.diagnostic.severity.INFO,
          user_data = { rule = rule },
        })

        ::continue::
      end

      vim.schedule(function()
        vim.diagnostic.set(namespace, bufnr, diagnostics)
      end)
    end)
  end

  if config.lint.run_on_save then
    vim.api.nvim_create_autocmd("BufWritePost", {
      group = lint_group,
      pattern = "*.dl",
      callback = run_linter,
      desc = "Run DLiteScript linter on save",
    })
  end

  if config.lint.run_on_change then
    vim.api.nvim_create_autocmd("TextChanged", {
      group = lint_group,
      pattern = "*.dl",
      callback = run_linter,
      desc = "Run DLiteScript linter on change",
    })
  end

  vim.api.nvim_create_autocmd("BufEnter", {
    group = lint_group,
    pattern = "*.dl",
    callback = run_linter,
    desc = "Run DLiteScript linter on buffer enter",
  })
end

return M
