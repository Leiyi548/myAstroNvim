local conditions = require "heirline.conditions"
local utils = require "heirline.utils"

local Space = { provider = " " }

local FileNameBlock = {
  -- let's first set up some attributes needed by this component and its children
  init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
}
-- We can now define some children separately and add them later

local FileIcon = {
  init = function(self)
    local filename = self.filename
    local extension = vim.fn.fnamemodify(filename, ":e")
    self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
  end,
  provider = function(self) return self.icon and (self.icon .. " ") end,
  hl = function(self) return { fg = self.icon_color } end,
}

local FileName = {
  provider = function(self)
    -- first, trim the pattern relative to the current directory. For other
    -- options, see :h filename-modifers
    local filename = vim.fn.fnamemodify(self.filename, ":.")
    if filename == "" then return "[No Name]" end
    -- now, if the filename would occupy more than 1/4th of the available
    -- space, we trim the file path to its initials
    -- See Flexible Components section below for dynamic truncation
    if not conditions.width_percent_below(#filename, 0.25) then filename = vim.fn.pathshorten(filename) end
    return filename
  end,
  hl = { fg = utils.get_highlight("keyword").fg },
  on_click = {
    callback = function() require("mini.files").open(vim.api.nvim_buf_get_name(0), true) end,
    name = "heirline_filename",
  },
}

local FileFlags = {
  {
    condition = function() return vim.bo.modified end,
    provider = " ●",
    hl = { fg = "white" },
  },
  {
    condition = function() return not vim.bo.modifiable or vim.bo.readonly end,
    provider = "",
    hl = { fg = "orange" },
  },
}

-- Now, let's say that we want the filename color to change if the buffer is
-- modified. Of course, we could do that directly using the FileName.hl field,
-- but we'll see how easy it is to alter existing components using a "modifier"
-- component

local FileNameModifer = {
  hl = function()
    if vim.bo.modified then
      -- use `force` because we need to override the child's hl foreground
      return { fg = utils.get_highlight("keyword").fg, bold = true, force = true }
    end
  end,
}

-- let's add the children to our FileNameBlock component
FileNameBlock = utils.insert(
  FileNameBlock,
  FileIcon,
  utils.insert(FileNameModifer, FileName), -- a new table where FileName is a child of FileNameModifier
  FileFlags,
  { provider = "%<" } -- this means that the statusline is cut here when there's not enough space
)

local CloseButton = {
  condition = function(self) return not vim.bo.modified end,
  -- a small performance improvement:
  -- re register the component callback only on layout/buffer changes.
  update = { "WinNew", "WinClosed", "BufEnter" },
  { provider = " " },
  {
    provider = "",
    hl = { fg = "gray" },
    on_click = {
      minwid = function() return vim.api.nvim_get_current_win() end,
      callback = function(_, minwid) vim.api.nvim_win_close(minwid, true) end,
      name = "heirline_winbar_close_button",
    },
  },
}

-- Use it anywhere!
local WinBarFileName = utils.surround({ "", "" }, "bg", {
  hl = function()
    if not conditions.is_active() then return { fg = "fg", force = true } end
  end,
  FileNameBlock,
  Space,
  CloseButton,
})

local Git = {
  condition = conditions.is_git_repo,

  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
  end,

  hl = { fg = "orange" },

  { -- git branch name
    provider = function(self) return " " .. self.status_dict.head end,
    hl = { bold = true },
  },
  -- You could handle delimiters, icons and counts similar to Diagnostics
  {
    condition = function(self) return self.has_changes end,
    provider = "(",
  },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ("+" .. count)
    end,
    hl = { utils.get_highlight("GitSignsAdd").fg },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ("-" .. count)
    end,
    hl = { utils.get_highlight("GitSignsAdd").fg },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ("~" .. count)
    end,
    hl = { utils.get_highlight("GitSignsChange").fg },
  },
  {
    condition = function(self) return self.has_changes end,
    provider = ")",
  },
  on_click = {
    callback = function() vim.cmd "G" end,
    name = "heirline_fugitive",
  },
}

local ZhhIndicator = {
  {
    provider = "虎",
    hl = function()
      if require("cmp_im").getStatus() then
        return { fg = "#40C36D" }
      else
        return { fg = "#797D87" }
      end
    end,
    update = true,
    on_click = {
      callback = function() require("cmp_im").toggle() end,
      name = "heirline_zhh",
    },
  },
}

local ChineseSymbolIndicator = {
  {
    provider = "",
    hl = function()
      if require("cmp_im").getChineseSymbolStatus() then
        return { fg = "#40C36D" }
      else
        return { fg = "#797D87" }
      end
    end,
    update = true,
    on_click = {
      callback = function() require("cmp_im").toggle_chinese_symbol() end,
      name = "heirline_chinese_symbol",
    },
  },
}

local WorkDir = {
  provider = function()
    local icon = " "
    local cwd = vim.fn.getcwd(0)
    cwd = vim.fn.fnamemodify(cwd, ":~")
    if not conditions.width_percent_below(#cwd, 0.25) then cwd = vim.fn.pathshorten(cwd) end
    local trail = cwd:sub(-1) == "\\" and "" or "\\"
    return icon .. cwd .. trail
  end,
  hl = { fg = "white", bold = true },
  on_click = {
    callback = function() vim.cmd "AsyncRun explorer.exe ." end,
    name = "heirline_workdir",
  },
}

-- We're getting minimalist here!
local Ruler = {
  -- %l = current line number
  -- %L = number of lines in the buffer
  -- %c = column number
  -- %P = percentage through file of displayed window
  provider = " %7(%l/%3L%)%2c %P ",
}
local ScrollBar = {
  static = {
    sbar = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
  },
  provider = function(self)
    local curr_line = vim.api.nvim_win_get_cursor(0)[1]
    local lines = vim.api.nvim_buf_line_count(0)
    local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
    return string.rep(self.sbar[i], 2)
  end,
  hl = { fg = "#FBC422", bg = "bg" },
}

return {
  "rebelot/heirline.nvim",
  event = "BufEnter",
  dependencies = {
    {
      "AstroNvim/astrocore",
      opts = function(_, opts)
        local maps = opts.mappings
        maps.n["gbs"] = {
          function()
            require("astroui.status.heirline").buffer_picker(function(bufnr) vim.api.nvim_win_set_buf(0, bufnr) end)
          end,
          desc = "Select buffer from tabline",
        }
        maps.n["gbd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        }
        maps.n["gbx"] = {
          function()
            require("astroui.status.heirline").buffer_picker(function(bufnr)
              vim.cmd.split()
              vim.api.nvim_win_set_buf(0, bufnr)
            end)
          end,
          desc = "Horizontal split buffer from tabline",
        }
        maps.n["gbv"] = {
          function()
            require("astroui.status.heirline").buffer_picker(function(bufnr)
              vim.cmd.vsplit()
              vim.api.nvim_win_set_buf(0, bufnr)
            end)
          end,
          desc = "Vertical split buffer from tabline",
        }
      end,
    },
  },
  opts = function()
    local status = require "astroui.status"
    return {
      opts = {
        colors = require("astroui").config.status.setup_colors(),
        disable_winbar_cb = function(args)
          return not require("astrocore.buffer").is_valid(args.buf)
            or status.condition.buffer_matches({ buftype = { "terminal", "nofile" } }, args.buf)
        end,
      },
      statusline = { -- statusline
        hl = { fg = "fg", bg = "bg" },
        status.component.mode(),
        status.component.builder(Git),
        status.component.fill(),
        -- TODO: 点击用 windows11 系统默认的文件管理器打开目录
        status.component.builder(WorkDir),
        -- TODO: 点击用 windows11 系统默认的文件管理器打开目录
        status.component.builder(FileNameBlock),
        status.component.diagnostics(),
        status.component.fill(),
        status.component.lsp(),
        status.component.virtual_env(),
        status.component.builder(Space),
        status.component.builder(ChineseSymbolIndicator),
        status.component.builder(Space),
        status.component.builder(ZhhIndicator),
        status.component.builder(Ruler),
        status.component.builder(ScrollBar),
        -- status.component.nav(),
      },
      winbar = {
        WinBarFileName,
        status.component.breadcrumbs { hl = status.hl.get_attributes("winbar", true) },
      },
      tabline = { -- bufferline
        { -- automatic sidebar padding
          condition = function(self)
            self.winid = vim.api.nvim_tabpage_list_wins(0)[1]
            self.winwidth = vim.api.nvim_win_get_width(self.winid)
            return self.winwidth ~= vim.o.columns -- only apply to sidebars
              and not require("astrocore.buffer").is_valid(vim.api.nvim_win_get_buf(self.winid)) -- if buffer is not in tabline
          end,
          provider = function(self) return (" "):rep(self.winwidth + 1) end,
          hl = { bg = "tabline_bg" },
        },
        status.heirline.make_buflist(status.component.tabline_file_info()), -- component for each buffer tab
        status.component.fill { hl = { bg = "tabline_bg" } }, -- fill the rest of the tabline with background color
        { -- tab list
          condition = function() return #vim.api.nvim_list_tabpages() >= 2 end, -- only show tabs if there are more than one
          status.heirline.make_tablist { -- component for each tab
            provider = status.provider.tabnr(),
            hl = function(self) return status.hl.get_attributes(status.heirline.tab_type(self, "tab"), true) end,
          },
          { -- close button for current tab
            provider = status.provider.close_button { kind = "TabClose", padding = { left = 1, right = 1 } },
            hl = status.hl.get_attributes("tab_close", true),
            on_click = {
              callback = function() require("astrocore.buffer").close_tab() end,
              name = "heirline_tabline_close_tab_callback",
            },
          },
        },
      },
      statuscolumn = {
        init = function(self) self.bufnr = vim.api.nvim_get_current_buf() end,
        status.component.foldcolumn(),
        status.component.numbercolumn(),
        status.component.signcolumn(),
      },
    }
  end,
  config = function(...) require "astronvim.plugins.configs.heirline"(...) end,
}
