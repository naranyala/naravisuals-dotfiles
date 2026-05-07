--Lua side : ast_plugin.lua

                 local M = {}

                           function M.get_scoped_symbols()
                               local file_path = vim.api.nvim_buf_get_name(
    0) local cursor = vim.api.nvim_win_get_cursor(0) local line =
    cursor[1] - 1 --Tree - sitter is 0 - indexed local col =
        cursor[2]

        -- Run the C utility with file path and cursor position vim.fn.jobstart(
            {"path/to/ast_extractor", file_path, tostring(line), tostring(col)},
            {
              on_stdout = vim.schedule_wrap(
                  function(_, data,
                           event) if data then-- data comes back as a list of
                      strings(lines) local json_output = table.concat(data, "")
                                                             local result =
                          vim.json
                              .decode(json_output)

                                  -- Use the parsed result to display symbols
                                      print("AST Node Info:", result.type, "->",
                                            result.text)-- M
                              .display_scope_info(result.symbols) end end),
              on_exit = function(code) if code ~=
                  0 then print("AST extractor failed.") end end,
              --Redirect stdin to null since we don't need to feed code in stdio = {"null", "pipe", "pipe"}
            }) end
