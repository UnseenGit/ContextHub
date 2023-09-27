local function LoadModule(ModuleName, ...)
    local request = request or syn.request
    local Http = game:GetService("HttpService")
    local function fileagecheck(path, age)
        age = age or 1
        if not isfile(path) then return false end
        local Files = isfile("fileages.json") and Http:JSONDecode(readfile("fileages.json")) or {}
        return ((Files[path] or 0) + age) > os.time()
    end
    local function write(path, content)
        local Files = isfile("fileages.json") and Http:JSONDecode(readfile("fileages.json")) or {}
        Files[path] = os.time()
        writefile("fileages.json",Http:JSONEncode(Files))
        writefile(path, content)
    end
    if not isfolder("Modules") then makefolder("Modules") end
    local __MODULES do 
        if ModuleTable then __MODULES = ModuleTable end 
        if fileagecheck("Modules/ModuleInfo.json", 900) then 
            __MODULES = Http:JSONDecode(readfile("Modules/ModuleInfo.json"))
        else
            print("request")
            local tmp = request{
                Url = "https://github.com/UnseenGit/ContextHub/raw/main/Modules/ModuleInfo.json",
                Method = "GET"
            }.Body or ""
            write("Modules/ModuleInfo.json", tmp)
            __MODULES = Http:JSONDecode(tmp)
        end
    end
    local Module = __MODULES[ModuleName]
    local Getters = {
        web = function(Source)
            print("request")
            return request{
                Url = Source,
                Method = "GET"
            }.Body or error("Couldn't Get!",ModuleName,Source)
        end,
        file = function(Source)
            return isfile(Source) and readfile(Source) or error("Couldn't Get!",ModuleName,Source)
        end
    }
    local Parsers = {
        lua = function(Source, ...)
            local Block, err = loadstring(Source)
            if err then
                error("Couldn't Parse!",ModuleName)
            end
            return Block(...)
        end,
        json = function(Source)
            return Http:JSONDecode(Source)
        end
    }
    local getM, parseM = table.unpack(string.split(Module.Type:lower(), "/"))
    local ModulePath = `Modules/{ModuleName}.json`
    local Source
    if not fileagecheck(ModulePath, 1800) then
        Source = Getters[getM](Module.Source)
        write(ModulePath, Source)
    else
        Source = readfile(ModulePath)
    end
    return Parsers[parseM](Source, ...)
end
local Util = LoadModule("Util")
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