vim.cmd [[packadd express_line.nvim]]

-- TODO: Need to add those sweet sweet lsp workspace diagnostic counts

require("plenary.reload").reload_module("el")
require("el").reset_windows()

local builtin = require "el.builtin"
local extensions = require "el.extensions"
local sections = require "el.sections"
local subscribe = require "el.subscribe"
local lsp_statusline = require "el.plugins.lsp_status"
local helper = require "el.helper"
local lsp_status = require "lsp-status"
local config = require("config.lspstatus")

local aliases = {pyls_ms = 'MPLS'}

local function show_lsp_status(_, _)
  local buf_messages = lsp_status.messages()
  -- print(vim.inspect(ipairs(buf_messages)))
  local msgs = {}
  local has_progress = false

  for _, msg in ipairs(buf_messages) do
    local name = aliases[msg.name] or msg.name
    local contents = ''
    if msg.progress then
      has_progress = true
      contents = msg.title
      -- if msg.message then contents = contents .. ' ' .. msg.message end

      -- this percentage format string escapes a percent sign once to show a percentage and one more
      -- time to prevent errors in vim statusline's because of it's treatment of % chars
      if msg.percentage then contents = contents .. string.format(" (%.0f%%%%)", msg.percentage) end

      if msg.spinner then
        contents = contents .. ' ' .. config.spinner_frames[(msg.spinner % #config.spinner_frames) + 1]
      end
    else
      contents = msg.content
    end

    table.insert(msgs, contents)
  end

  -- errors, warnigns ...

  local diag = lsp_status.diagnostics()
  if diag.hints > 0 then
    table.insert(msgs, tostring(diag.hints) .. config.indicator_hint)
  end
  if diag.warnings > 0 then
    table.insert(msgs, tostring(diag.warnings) .. config.indicator_warnings)
  end
  if diag.errors > 0 then
    table.insert(msgs, tostring(diag.errors) .. config.indicator_errors)
  end
  if diag.hints == 0 and diag.warnings == 0 and diag.errors == 0 and has_progress == false then
    table.insert(msgs, "[OK]")
  end

  return table.concat(msgs, config.component_separator)
end


-- TODO: Spinning planet extension. Integrated w/ telescope.
-- ◐ ◓ ◑ ◒
-- 🌛︎🌝︎🌜︎🌚︎
-- Show telescope icon / emoji when you open it as well

local git_icon = subscribe.buf_autocmd("el_file_icon", "BufRead", function(_, bufnr)
  local icon = extensions.file_icon(_, bufnr)
  if icon then
    return icon .. " "
  end

  return ""
end)

local git_branch = subscribe.buf_autocmd("el_git_branch", "BufEnter", function(window, buffer)
  local branch = extensions.git_branch(window, buffer)
  if branch then
    return " " .. extensions.git_icon() .. " " .. branch
  end
end)

local git_changes = subscribe.buf_autocmd("el_git_changes", "BufWritePost", function(window, buffer)
  return extensions.git_changes(window, buffer)
end)

local show_current_func = function(window, buffer)
  if buffer.filetype == "lua" then
    return ""
  end

  return lsp_statusline.current_function(window, buffer)
end

require("el").setup {
  generator = function(_, _)
    return {
      extensions.gen_mode {
        format_string = " %s ",
      },
      git_branch,
      git_changes,
      " ",
      sections.split,
      git_icon,
      sections.maximum_width(builtin.responsive_file(140, 90), 0.30),
      sections.collapse_builtin {
        " ",
        builtin.modified_flag,
      },
      sections.split,
      show_current_func,
      show_lsp_status,
      builtin.filetype,
      "[",
      builtin.line_with_width(3),
      ":",
      builtin.column_with_width(2),
      "]",
      sections.collapse_builtin {
        "[",
        builtin.help_list,
        builtin.readonly_list,
        "]",
      },
    }
  end,
}
