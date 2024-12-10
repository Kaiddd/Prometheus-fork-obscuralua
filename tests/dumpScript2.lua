-- Open the file in write mode
local filename = "dump.txt" -- Make this configurable
local file, err = io.open(filename, "w")

if not file then
    print("Could not open file: ", err)
    return
end

-- Try to set a hook that dumps the constants
local status, err = pcall(function()
    debug.sethook(function()
        local i = 1
        while true do
            local name, value = debug.getlocal(2, i)
            if not name then break end
            -- Handle more types
            if type(value) == "number" or type(value) == "string" or type(value) == "boolean" then
                -- Write to the file instead of printing
                file:write("Constant: ", name, " ", tostring(value), "\n")
            elseif type(value) == "table" then
                file:write("Table: ", name, "\n")
                for k, v in pairs(value) do
                    file:write("  ", tostring(k), ": ", tostring(v), "\n")
                end
            end
            i = i + 1
        end
        -- Do not close the file here
    end, "c")
end)

if not status then
    print("Could not set debug hook: ", err)
    return
end

-- You can close the file here if you know the program is done with it
-- file:close()