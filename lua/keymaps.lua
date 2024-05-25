local map = vim.keymap.set

-- del keymap
vim.keymap.del("n", "<C-j>")
vim.keymap.del("n", "<C-k>")
vim.keymap.del("n", "<C-h>")
vim.keymap.del("n", "<C-l>")
vim.keymap.del("n", "<leader>pa")
vim.keymap.del("n", "<leader>pi")
vim.keymap.del("n", "<leader>pm")
vim.keymap.del("n", "<leader>pM")
vim.keymap.del("n", "<leader>ps")
vim.keymap.del("n", "<leader>pS")
vim.keymap.del("n", "<leader>pu")
vim.keymap.del("n", "<leader>pU")

-- change window origin keymap
map("n", "<C-w>x", "<C-w>s", { desc = "横向分屏当前 buffer" })
map("n", "<C-w>s", "<C-w>x", { desc = "跟下一个窗口进行交换" })

-- lazy
map("n", "<leader>lz", "<cmd>Lazy<cr>", { desc = "Open Lazy dashboard" })

-- Home End
map({ "n", "x", "o" }, "<S-h>", "0", { desc = "Home" })
map({ "n", "x", "o" }, "<S-l>", "$", { desc = "End" })

-- message
map("n", "<leader>snm", "<cmd>message<cr>", { desc = "message" })

-- add empty lines before and after cursor line
map("n", "gO", "<cmd>call append(line('.') - 1, repeat([''], v:count1))<cr>", { desc = "Put empty line above" })
map("n", "go", "<cmd>call append(line('.'),     repeat([''], v:count1))<cr>", { desc = "Put empty line below" })

-- textobject
map({ "x", "o" }, "il", ":<c-u>normal! g_v^<cr>", { desc = "select current line not include whitespace" })
map({ "x", "o" }, "al", ":<c-u>normal! $v0<cr>", { desc = "select current line include whitespace" })

-- toggle cmp_im
map(
  { "n", "x", "i", "c" },
  "<C-.>",
  function() vim.notify(string.format("虎码%s", require("cmp_im").toggle() and "启动" or "退出")) end
)
map({ "n", "x", "i" }, "<C-,>", function() require("cmp_im").toggle_chinese_symbol() end)

-- Telescope
map("n", "<leader>ff", function() require("utils.fancy_telescope").findProjectFile() end, { desc = "Find file" })
map(
  { "n", "i", "x" },
  "<C-p>",
  function() require("utils.fancy_telescope").findProjectFile() end,
  { desc = "Find file" }
)
map("n", "<leader>fr", function() require("utils.fancy_telescope").findRecentFile() end, { desc = "Find Recent File" })
map("n", "<leader>fc", function() require("utils.fancy_telescope").findConfigFile() end, { desc = "Find Config File" })
map(
  "n",
  "<leader>sf",
  function() require("utils.fancy_telescope").grep_string_by_filetype() end,
  { desc = "Grep string by filetype" }
)
map(
  "n",
  "<leader>sg",
  function() require("utils.fancy_telescope").live_grep_project() end,
  { desc = "Grep string project" }
)
map(
  "n",
  "<leader>fw",
  function() require("utils.fancy_telescope").live_grep_project() end,
  { desc = "Grep string project" }
)
map("n", "<leader>gf", "<cmd>Telescope git_files<cr>", { desc = "Telescope git_files" })
map("n", "<leader>fh", "<cmd>Telescope highlights<cr>", { desc = "Telescope git_files" })
map("n", "<leader>bf", "<cmd>Telescope buffers<cr>", { desc = "Telescope buffers" })
map("n", "<leader>bb", "<cmd>Telescope buffers<cr>", { desc = "Telescope buffers" })
map("n", "<leader>sq", "<cmd>Telescope quickfix<cr>", { desc = "Telescope quickfix" })

-- fugitive
map("n", "<leader>gt", "<cmd>G<cr>", { desc = "[G]it s[t]atus(fugitive)" })
map("n", "<leader>gT", "<cmd>tab G<cr>", { desc = "Open fugitive in new tab" })
map("n", "<leader>gl", "<cmd>Git log<cr>", { desc = "Open Git Log" })
