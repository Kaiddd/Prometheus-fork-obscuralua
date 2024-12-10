(function()
    local dumped = {}
    local rs, rg, gm, pr, ps, tp, gl = rawset, rawget, debug.getmetatable, io.open, pairs, type, debug.getlocal
    local maxDepth = 3

    local function shouldDump(name, obj)
        -- filter
        return true
    end

    local function dump(name, obj, depth)
        local file = pr("dump.txt", "a")
        if depth > maxDepth then
            file:write(string.rep("  ", depth) .. "\27[31mMax recursion depth reached\27[0m\n")
            file:close()
            return
        end
        local mt = gm(obj)
        if mt then
            local t = rg(mt, "__tostring")
            rs(mt, "__tostring", nil)
            file:write(string.rep("  ", depth) .. "\27[32m" .. tostring(name) .. "\27[0m = " .. tostring(obj) .. "\n")
            rs(mt, "__tostring", t)
        else
            file:write(string.rep("  ", depth) .. "\27[32m" .. tostring(name) .. "\27[0m = " .. tostring(obj) .. "\n")
        end
        if tp(obj) == "table" then
            for i, v in ps(obj) do
                if shouldDump(i, v) then
                    dump(i, v, depth + 1)
                end
            end
        end
        file:close()
    end

    dumped[dumped] = true
    dumped[dump] = true

    debug.sethook(function()
        local i = 1
        while true do
            local name, obj = gl(2, i)
            if not name then break end
            if obj ~= nil and not dumped[obj] and shouldDump(name, obj) then
                dumped[obj] = true
                dump(name, obj, 0)
            end
            i = i + 1
        end
    end, "", 1)
end)();