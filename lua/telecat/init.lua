-- File: ~/.config/nvim/lua/plugins/my-local-plugin/init.lua

local function get_filetype(filename)
  local ft = vim.filetype.match({ filename = filename })
  return ft or "text"
end

local function generate_tree(path, prefix)
  prefix = prefix or ""
  local result = {}
  local handle = vim.uv.fs_scandir(path)
  if not handle then return result end
  while true do
    local name, type = vim.uv.fs_scandir_next(handle)
    if not name then break end
    table.insert(result, prefix .. "├── " .. name)
    if type == "directory" then
      local subdir_tree = generate_tree(path .. "/" .. name, prefix .. "│   ")
      for _, item in ipairs(subdir_tree) do
        table.insert(result, item)
      end
    end
  end
  if #result > 0 then
    result[#result] = result[#result]:gsub("├──", "└──")
  end
  return result
end

local function join_selected_files(prompt_bufnr)
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local picker = action_state.get_current_picker(prompt_bufnr)
  local selections = picker:get_multi_selection()
  if #selections == 0 then
    local entry = action_state.get_selected_entry()
    if entry then
      selections = {entry}
    end
  end
  actions.close(prompt_bufnr)
  if #selections > 0 then
    vim.cmd('enew')
    local bufnr = vim.api.nvim_get_current_buf()
    local content = {}
    local cwd = vim.fn.getcwd()
    table.insert(content, "# Directory Tree")
    table.insert(content, "```")
    table.insert(content, cwd)
    local tree = generate_tree(cwd)
    for _, line in ipairs(tree) do
      table.insert(content, line)
    end
    table.insert(content, "```")
    table.insert(content, "")
    for i, selection in ipairs(selections) do
      local file_path = selection.path
      if vim.fn.filereadable(file_path) then
        local filetype = get_filetype(file_path)
        table.insert(content, "# File: " .. file_path)
        table.insert(content, "```" .. filetype)
        local file_content = vim.fn.readfile(file_path)
        for _, line in ipairs(file_content) do
          table.insert(content, line)
        end
        table.insert(content, "```")
        if i < #selections then
          table.insert(content, "")
        end
      else
        table.insert(content, "Warning: Unable to read file " .. file_path)
      end
    end
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, content)
    vim.bo[bufnr].filetype = 'markdown'
  end
end

return {
    get_filetype,
    generate_tree,
    join_selected_files
}
