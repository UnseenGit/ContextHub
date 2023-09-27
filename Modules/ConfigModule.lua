
local Util = loadfile("Util.lua")()
local Module = {}
local function ValidateSettings(tbl, pattern)
    xpcall(function()
        for i, v in pairs(pattern) do
            if typeof(v) == "table" then
                if not tbl[i] then tbl[i] = {} end
                tbl[i] = ValidateSettings(tbl[i], v)
            elseif not tbl[i] and typeof(tbl[i]) ~= "boolean" then
                tbl[i] = v
            end
        end
    end,warn)
    return tbl
end
function Module:Create(FilePath, DefaultStruct)

    local Config = {} do
        if FilePath then
            if isfile(FilePath) then
                Config = ValidateSettings(Util.loadfile(FilePath), DefaultStruct)
                --[[for i, v in pairs(DefaultStruct) do
                    if typeof(v) == "table" then
                        Config[i] = ValidateSettings(Config[i], DefaultStruct)
                    elseif not Config[i] and typeof(Config[i]) ~= "boolean" then
                        Config[i] = v
                    end
                end]]
            elseif DefaultStruct then
                Util.writelua(FilePath, DefaultStruct)
                Config = DefaultStruct
            end
        else
            error("Config Module: No file provided!")
        end
    end

    local function CheckTable(tbl)
        local out = {}
        table.foreach(tbl,function(i,v)
            if typeof(v) == "table" and not typeof(i) == "function" then
                out[i]=CheckTable(v)
            elseif typeof(i) ~= "function" and typeof(v) ~= "function" then
                out[i]=v
            end
        end)
        return out
    end

    function Config:Write()
        xpcall(function()
            Util.writelua(FilePath, CheckTable(Config))
        end,warn)
    end

    function Config:Read()
        if isfile(FilePath) then
            Config = Util.loadfile(FilePath)
        else
            error("Config Module: File does not exist!")
        end
    end
    if DefaultStruct then
        return setmetatable(Config,{__index = DefaultStruct})
    else
        return Config
    end
end
return Module