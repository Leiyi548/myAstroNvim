local action_state = require "telescope.actions.state"
return {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      enabled = vim.fn.executable "make" == 1,
      config = function() end,
    },
    {
      "Leiyi548/project.nvim",
      opts = {
        -- Manual mode doesn't automatically change your root directory, so you have
        -- the option to manually do so using `:ProjectRoot` command.
        manual_mode = true,
        -- Methods of detecting the root directory. **"lsp"** uses the native neovim
        -- lsp, while **"pattern"** uses vim-rooter like glob pattern matching. Here
        -- order matters: if one is not detected, the other is used as fallback. You
        -- can also delete or rearangne the detection methods.
        detection_methods = { "pattern" },
        -- All the patterns used to detect root dir, when **"pattern"** is in
        -- detection_methods
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },
      },
      event = "VeryLazy",
      config = function(_, opts) require("project_nvim").setup(opts) end,
      keys = {
        { "<leader>pr", "<Cmd>ProjectRoot<CR>", desc = "ProjectRoot" },
        { "<leader>pa", "<Cmd>AddCurrentDirAsProject<CR>", desc = "Add current dir as Project" },
        { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
        { "<leader>fo", "<Cmd>Telescope oil<CR>", desc = "oil Projects" },
        { "<leader>bp", "<Cmd>Telescope projectBrowser<CR>", desc = "file_browser Projects" },
        { "<leader>fg", "<Cmd>Telescope projectGrep<CR>", desc = "projectGrep" },
      },
      -- },
    },
    keys = {
      { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader><space>", false },
      -- git
      { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
      { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },
      -- search
      { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
      { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
      { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
      { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
      { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
      { "<leader>sg", false },
      { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
      { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
      { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
      { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
      { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
      { "<leader>sr", "<cmd>Telescope resume<cr>", desc = "Resume" },
      {
        "<leader>ss",
        function() require("telescope.builtin").lsp_document_symbols {} end,
        desc = "Goto Symbol",
      },
      {
        "<leader>sS",
        function() require("telescope.builtin").lsp_dynamic_workspace_symbols {} end,
        desc = "Goto Symbol (Workspace)",
      },
    },
    opts = function()
      local actions = require "telescope.actions"

      local open_with_trouble = function(...) return require("trouble.sources.telescope").open(...) end

      local open_selected_with_trouble = function(...)
        return require("trouble.providers.telescope").open_selected_with_trouble(...)
      end

      local function flash(prompt_bufnr)
        require("flash").jump {
          pattern = "^",
          label = { after = { 0, 0 } },
          search = {
            mode = "search",
            exclude = {
              function(win) return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults" end,
            },
          },
          action = function(match)
            local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
            picker:set_selection(match.pos[1] - 1)
          end,
        }
      end

      return {
        defaults = {
          prompt_prefix = " ",
          layout_strategy = "vertical",
          -- selection_caret = " ",
          selection_caret = " ",
          path_display = {
            filename_first = {
              reverse_directories = false,
            },
          },
          -- sorting_strategy = "ascending", -- 按照升序排序
          dynamic_preview_title = true,
          layout_config = {
            horizontal = { prompt_position = "bottom", preview_width = 0.6, preview_cutoff = 0 },
            vertical = { prompt_position = "bottom", mirror = false, preview_cutoff = 0 },
            -- make telescope full width
            width = { padding = 0 },
            height = { padding = 0 },
          },
          -- open files in the first window that is an actual file.
          -- use the current window if no other window is available.
          get_selection_window = function()
            local wins = vim.api.nvim_list_wins()
            table.insert(wins, 1, vim.api.nvim_get_current_win())
            for _, win in ipairs(wins) do
              local buf = vim.api.nvim_win_get_buf(win)
              if vim.bo[buf].buftype == "" then return win end
            end
            return 0
          end,
          mappings = {
            i = {
              ["<c-s>"] = flash,
              ["<a-t>"] = open_selected_with_trouble,
              ["<C-q>"] = actions.add_to_qflist,
              ["<C-Down>"] = actions.cycle_history_next,
              ["<C-Up>"] = actions.cycle_history_prev,
              ["<Esc>"] = false,
            },
            n = {
              ["<Esc>"] = false,
              ["<C-c>"] = actions.close,
              ["<c-k>"] = open_with_trouble,
              ["<C-q>"] = function(...)
                actions.smart_send_to_qflist(...)
                actions.open_qflist(...)
              end,
              ["q"] = actions.close,
              ["<c-s>"] = flash,
            },
          },
        },
        pickers = {
          git_status = {
            layout_strategy = "vertical",
            git_icons = {
              added = "",
              changed = "",
              copied = ">",
              deleted = "",
              renamed = "➡",
              unmerged = "",
              untracked = "?",
            },
          },
          buffers = {
            sort_lastused = true,
            sort_mru = true,
            ignore_current_buffer = false,
            theme = "dropdown",
            previewer = false,
            mappings = {
              i = { ["<C-d>"] = actions.delete_buffer },
              n = {
                ["d"] = actions.delete_buffer,
                ["<C-d>"] = actions.delete_buffer,
              },
            },
          },
          current_buffer_fuzzy_find = {
            skip_empty_lines = true,
            layout_strategy = "vertical",
            previewer = true,
            mappings = {
              i = {
                ["<C-y>"] = function(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  actions.close(prompt_bufnr)
                  vim.fn.setreg("*", selection.text)
                  vim.notify("复制成功：" .. selection.text)
                end,
              },
            },
          },
          git_commits = {
            layout_strategy = "vertical",
            mappings = {
              i = {
                -- checkout commit
                -- ["<C-o>"] = actions.git_checkout,
                -- 复制 commit 信息
                ["<cr>"] = function(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  if selection == nil then
                    vim.notify "没有可以选择的 commit"
                  else
                    actions.close(prompt_bufnr)
                    -- yanks the additions from the currently selected undo state into the default register
                    vim.fn.setreg("*", selection.msg)
                    vim.notify(selection.msg)
                  end
                end,
                -- 复制 commit hash 值
                ["<C-y>"] = function(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  if selection == nil then
                    vim.notify "没有可以选择的 commit"
                  else
                    actions.close(prompt_bufnr)
                    -- yanks the additions from the currently selected undo state into the default register
                    vim.fn.setreg("*", selection.value)
                    vim.notify(selection.value)
                  end
                end,
              },
              n = {
                -- checkout commit
                ["<C-o>"] = actions.git_checkout,
                -- 复制 commit 信息
                ["<cr>"] = function(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  if selection == nil then
                    vim.notify "没有可以选择的 commit"
                  else
                    actions.close(prompt_bufnr)
                    vim.fn.setreg("*", selection.msg)
                    vim.notify(selection.msg)
                  end
                end,
                -- 复制 commit hash 值
                ["<C-v>"] = function(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  if selection == nil then
                    vim.notify "没有可以选择的 commit"
                  else
                    actions.close(prompt_bufnr)
                    vim.fn.setreg("*", selection.value)
                    vim.notify(selection.value)
                  end
                end,
              },
            },
          },
        },
      }
    end,
  },
}
