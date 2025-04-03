local yazi = require('yazi')

local configuration = {
  open_for_directories = true,
}
yazi.setup(configuration)

vim.keymap.set("n", "<leader>-", function()
  yazi.yazi()
end)
