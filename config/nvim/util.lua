local M = {}

--- Creates a nested table from a list of keys.
-- @param keys A list of strings representing the nested keys.
-- @param value (optional) Value to assign at the deepest key.
-- @return A nested table with the keys nested accordingly.
function M.ntable(keys, value)
        local t = {}
        local current = t
        for i, key in ipairs(keys) do
                if i == #keys and value ~= nil then
                        current[key] = value
                else
                        current[key] = {}
                        current = current[key]
                end
        end
        return t
end

--- Deeply merges multiple tables into a new table (pure)
-- @param ... Tables to merge
-- @return New table containing merged keys
function M.deep_merge(...)
        local res = {}
        for _, t in ipairs({ ... }) do
                for k, v in pairs(t) do
                        if type(v) == "table" and type(res[k]) == "table" then
                                res[k] = M.deep_merge(res[k], v)
                        elseif type(v) == "table" then
                                res[k] = M.deep_merge(v)
                        else
                                res[k] = v
                        end
                end
        end
        return res
end

--- Returns a command table for a binary with a fallback.
-- Uses `bin` if found in PATH, otherwise runs `nix run fallback_bin`.
-- @param bin string: primary binary
-- @param fallback_bin string: nix package fallback
-- @param args table|nil: optional arguments to pass
-- @return table: command suitable for LSP `cmd`
function M.cmd_with_fallback(bin, fallback_bin, args)
        local path = vim.fn.exepath(bin)
        if path ~= "" then
                -- Use local binary + args
                return vim.list_extend({ path }, args or {})
        end
        -- Otherwise: nix run + bin + args
        local fallback = { "nix", "run", fallback_bin }
        if args and #args > 0 then
                table.insert(fallback, "--")
                vim.list_extend(fallback, args)
        end
        return fallback
end

return M
