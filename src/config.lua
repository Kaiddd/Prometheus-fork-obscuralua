local NAME     = "Prometheus";
local REVISION = "Private";
local VERSION  = "v0.2";
local BY       = "User319183";

local options = {
    ["--CI"] = function()
        local releaseName = string.gsub(string.format("%s %s %s", NAME, REVISION, VERSION), "%s", "-")
        print(releaseName)
    end,
    ["--FullVersion"] = function()
        print(VERSION)
    end
}

for _, currArg in ipairs(arg) do
    if options[currArg] then
        options[currArg]()
    end
end

-- Config Starts here
return {
    Name           = NAME,
    NameUpper      = string.upper(NAME),
    NameAndVersion = string.format("%s %s", NAME, VERSION),
    Version        = VERSION,
    Revision       = REVISION,
    IdentPrefix    = "__Prometheus__",
    SPACE          = " ",
    TAB            = "\t",
}