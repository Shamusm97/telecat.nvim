local M = {}
local utils = require('telecat')

function M.join_files()
  local builtin = require('telescope.builtin')
  builtin.find_files({
    attach_mappings = function(prompt_bufnr, map)
      require('telescope.actions').select_default:replace(function()
        utils.join_selected_files(prompt_bufnr)
      end)
      return true
    end,
  })
end

function M.setup(opts)
  opts = opts or {}
  vim.api.nvim_set_keymap('n', '<leader>tjf', '<cmd>lua require("plugins.llmutils").join_files()<CR>', { noremap = true, silent = true })
end

return M
