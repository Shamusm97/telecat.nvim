local M = {}
local utils = require('telecat.utils')

function M.join_files()
  local builtin = require('telescope.builtin')
  builtin.find_files({
    attach_mappings = function(prompt_bufnr, map)
      require('telescope.actions').select_default:replace(function()
        utils.Join_selected_files(prompt_bufnr)
      end)
      return true
    end,
  })
end

M.setup = function(opts)
  opts = opts or {}
  vim.api.nvim_set_keymap('n', '<leader>tcf', '<cmd>lua require("telecat").join_files()<CR>', { noremap = true, silent = true })
end

return M
