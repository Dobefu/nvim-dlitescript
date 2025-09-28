---@class DLiteScriptFormatter
local M = {}

---@param config table
M.setup = function(config)
  local format_group = vim.api.nvim_create_augroup(
    "DLiteScriptFormat",
    { clear = true }
  )

  local function format_buffer()
    if vim.bo.filetype ~= "dlitescript" then
      return
    end

    local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    if filename == "" then
      return
    end

    local shell_cmd = config.format.cmd[3]:gsub("%$1", filename)

    vim.system({ "sh", "-c", shell_cmd }, { text = true }, function(result)
      if result.code ~= 0 or not result.stdout or result.stdout == "" then
        return
      end

      vim.schedule(function()
        local lines = vim.split(result.stdout, "\n")

        while #lines > 0 and lines[#lines] == "" do
          table.remove(lines)
        end

        vim.fn.writefile(lines, filename)

        -- Reload the buffer, to prevent warnings about external changes.
        vim.cmd("edit!")
      end)
    end)
  end

  if config.format.enable then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_group,
      pattern = "*.dl",
      callback = format_buffer,
      desc = "Format DLiteScript before save",
    })
  end
end

return M
