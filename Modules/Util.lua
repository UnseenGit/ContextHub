local module = {}
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local request = request or syn.request
local UserCache
local Sources = {}
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
    if not Module then return end
    local ModulePath = `Modules/{ModuleName}.json`
    local Getters = {
        web = function(Source)
            local MSRC = request{
                Url = Source,
                Method = "GET"
            }.Body or error("Couldn't Get!",ModuleName,Source)
            write(ModulePath, MSRC)
            return MSRC
        end,
        file = function(Source)
            return isfile(Source) and readfile(Source) or nil
        end
    }
    local Parsers = {
        lua = function(Source, ...)
            local Block, err = loadstring(Source)
            if err then
                error("Couldn't Parse!",ModuleName)
            end
            local Succ, Ret = pcall(Block, ...)
            if Succ then
                return Ret
            else
                error(ModuleName, Ret)
            end
        end,
        json = function(Source)
            return Http:JSONDecode(Source)
        end
    }
    local getM, parseM = table.unpack(string.split(Module.Type:lower(), "/"))
    local Source
    if not fileagecheck(ModulePath, 1800) then
        Source = Getters[getM](Module.Source)
    else
        Source = readfile(ModulePath)
    end
    if Source then return Parsers[parseM](Source, ...) end
end
repeat 
    wait()
until game:GetService("Players").LocalPlayer
local Mouse = Players.LocalPlayer:GetMouse()
function module.JSONDecode(arg)
    return game:GetService("HttpService"):JSONDecode(arg)
end
function module.loadfile(file: string, ...)
    if isfile(file) then
        local Block, err = loadfile(file)
        if Block then
            return Block(...)
        elseif err then
            error(file.." errored!: "..err)
        else
            error(file.." errored!")
        end
    else
        error(file.." does not exist!")
    end
end
function module.JSONEncode(arg)
    return game:GetService("HttpService"):JSONEncode(arg)
end
function module.writeJSON(path, arg)
    writefile(path, game:GetService("HttpService"):JSONEncode(arg))
end
function module.readJSON(arg)
    return game:GetService("HttpService"):JSONDecode(readfile(arg))
end
function module.JSONRequest(URL)
    return game:GetService("HttpService"):JSONDecode(request{
        Url = URL,
        Method = "GET"
    }.Body)
end
if isfile("UserCache.json") then 
    UserCache = module.readJSON("UserCache.json")
end
local ClassImages = LoadModule("ClassImages")
local RobloxClasses = LoadModule("RobloxClasses")
local DataTypeIconData = LoadModule("DataImages")
function module.GetClassTypes()
    local out = {}
    for ClassName in pairs(RobloxClasses) do
        table.insert(out, ClassName)
    end
    table.sort(out)
    return out
end
function module.GetMethods(Obj)
    local out = {}
    for i, v in pairs(RobloxClasses) do
        if Obj:IsA(i) then
            out[i]=v.Methods
        end
    end
    return out
end
function module.decompile(Script)
    if Sources[Script] then
        return Sources[Script]
    end
    Sources[Script] = decompile(Script)
    return Sources[Script]
end
function module.GetEvents(Obj)
    local out = {}
    for i, v in pairs(RobloxClasses) do
        if Obj:IsA(i) then
            out[i]=v.Events
        end
    end
    return out
end
function module.GetProperties(Obj)
    local out = {}
    for i, v in pairs(RobloxClasses) do
        if Obj:IsA(i) then
            out[i]=v.Properties
        end
    end
    return out
end
function module.GetPath(obj)
    local root = "game."
    local part = obj
    local iteration = 0
    while part.Parent ~= game and tostring(part.Parent) ~= "nil" do
        part = part.Parent
        iteration = iteration+1
        if iteration > 512 then
            root = "Nil Instance "
            break
        end
    end
    if typeof(part.Parent) == "nil" then
        root = "Nil Instance "
    end
    local appendStr = ""
    local prefix = ""
    local chars = "abcdefghijklmnopqrstuvwxyz123467890"
    for _, token in ipairs(tostring(obj:GetFullName()):split(".")) do
        local appendToken = prefix..token
        if (function() 
                for _, tokenchar in pairs(token:lower():split("")) do
                    if not table.find(chars:split(""), tokenchar) then
                        return true
                    end
                end
                return false
            end)() then
            appendToken = "[\"" .. token .. "\"]"
        end
        prefix = "."
        appendStr = appendStr .. appendToken
    end
    if obj:GetFullName() == "Game" then
        return "game"
    end
    if appendStr:sub(1,4):lower() ~= "game" then
        appendStr = root..appendStr
    end
    if appendStr:sub(1,4):lower() ~= "game" and appendStr:sub(1,1) == "G" then
        appendStr = "g"..appendStr:sub(2,#appendStr)
    end
    return appendStr
end
function module.GetModelMiddle(Model)
    local BoundingBox = Model:GetBoundingBox().p
    local ClosestPart
    local ClosestMag
    for _, v in pairs(Model:GetDescendants()) do
        if v:IsA("BasePart") then
            if not ClosestPart or (BoundingBox-v.CFrame.p).Magnitude < ClosestMag then
                ClosestPart = v
                ClosestMag = (BoundingBox-v.CFrame.p).Magnitude
            end
        end
    end
    return ClosestPart, ClosestMag
end
function module.require(ModuleScript)
    local ret
    if pcall(function() ret = require(ModuleScript) end) then
        return ret
    end
    if pcall(function() ret = getrenv().require(ModuleScript) end) then
        return ret
    end
    error("Failed to require!")
end
function module.CheckPropertyLocked(Object, Property)
    for Class, v in pairs(RobloxClasses) do
        local Props = v.Properties
        if Props[Property] and Object:IsA(Class) and table.find(Props[Property].Tags, "READ_ONLY") then
            return true
        end
    end
    return false
end
function module.TableToObject(src, sourcefunc, index, path, additionalsettings)
    local function New(x, index, path, sourcefunc)
        if not path then path = {} end
        local c
        c = x
        if typeof(x) == "table" then
            c={}
            local xpath = {}
            for i, v in pairs(path) do
                xpath[i]=v
            end
            table.insert( xpath, index)
            for i, v in pairs(x) do
                c[i]=module.TableToObject(v, sourcefunc, i, xpath)
            end
        end
        return {
                Content = c,
                GetRoot = sourcefunc,
                Path = path,
                Type = typeof(x),
                Index = index
            }
    end
    local out = New(src, index, path, sourcefunc)
    if additionalsettings then
        for i, v in pairs(additionalsettings) do
            out[i] = v
        end
    end
    return out
end
function module.GetPositionInCanvas(GuiObject, ScrollingFrame)
    local ScrollingFrameOffset = ScrollingFrame.AbsolutePosition*Vector2.new(-1,-1)
    return (GuiObject.AbsolutePosition+ScrollingFrameOffset)+ScrollingFrame.CanvasPosition
end
--thanks chatgpt for that part
local SyntaxColoring = {
    ["c586c0"] = {
        "and", "break", "do", "else", "elseif", "end", "for", "function",
        "if", "in", "not", "or", "repeat", "return", "then",
        "until", "while"
    },
    ["569cd6"] = {"local", "nil", "Enum", "true", "false", "game", "module", "__DEX", "shared", "_G", "_VERSION"},
    ["4ec9b0"] = {"Color3", "Axes", "BrickColor", "CFrame", "ColorSequenceKeypoint", "ColorSequence", "DateTime", "DockWidgetPluginGuiInfo", "Faces", "Instance", "NumberRange", "NumberSequenceKeypoint", "NumberSequence", "OverlapParams", "PathWaypoint", "PhysicalProperties", "Random", "Ray", "RaycastParams", "Rect", "Region3int16", "Region3", "TweenInfo", "UDim2", "UDim", "Vector2int16", "Vector2", "Vector3int16", "Vector3"},
    ["dcdcaa"] = {
        "new", "warn", "Angles", "fromEulerAnglesYXZ", "identity",
        "fromOrientation", "fromMatrix", "fromEulerAnglesXYZ", "fromEulerAngles",
        "lookAt", "fromAxisAngle", "gcinfo", "os", "clock", "difftime", "time",
        "date", "tick", "task", "defer", "cancel", "wait", "desynchronize",
        "synchronize", "delay", "spawn", "pairs", "assert", "rawlen", "tonumber",
        "fromHex", "fromHSV", "toHSV", "fromRGB", "Enum", "Delay", "Stats",
        "xpcall", "RotationCurveKey", "typeof", "coroutine", "resume", "running",
        "yield", "close", "status", "wrap", "create", "isyieldable",
        "FloatCurveKey", "PluginManager", "ypcall", "Font", "fromId", "fromEnum",
        "fromName", "NumberSequenceKeypoint", "Version", "xAxis", "zero", "one",
        "yAxis", "version", "Game", "stats", "string", "split", "match", "gmatch",
        "upper", "gsub", "format", "lower", "sub", "pack", "find", "char",
        "packsize", "reverse", "byte", "unpack", "rep", "len", "CellId",
        "UserSettings", "settings", "loadstring", "printidentity",
        "CatalogSearchParams", "fromOffset", "fromScale", "Wait", "require",
        "fromNormalId", "fromAxis", "zAxis", "FromAxis", "FromNormalId",
        "Vector3int16", "setmetatable", "next", "elapsedTime", "ipairs",
        "Workspace", "rawequal", "collectgarbage", "newproxy", "Spawn",
        "fromUnixTimestamp", "now", "fromIsoDate", "fromUnixTimestampMillis",
        "fromLocalTime", "fromUniversalTime", "utf8", "offset", "codepoint",
        "nfdnormalize", "codes", "graphemes", "nfcnormalize", "charpattern",
        "rawset", "tostring", "PluginDrag", "workspace", "math", "log", "ldexp",
        "rad", "cosh", "round", "random", "frexp", "tanh", "floor", "max", "sqrt",
        "modf", "huge", "pow", "atan", "tan", "cos", "pi", "noise", "log10", "sign",
        "acos", "abs", "clamp", "sinh", "asin", "min", "deg", "fmod", "randomseed",
        "atan2", "ceil", "sin", "exp", "bit32", "band", "extract", "bor", "bnot",
        "countrz", "bxor", "arshift", "rshift", "rrotate", "replace", "lshift",
        "lrotate", "btest", "countlz", "pcall", "getfenv", "type", "ElapsedTime",
        "select", "getmetatable", "rawget", "table", "getn", "foreachi", "foreach",
        "sort", "freeze", "clear", "move", "insert", "maxn", "isfrozen", "concat",
        "clone", "remove", "BrickColor", "Blue", "White", "Yellow", "Red", "Gray",
        "palette", "New", "Black", "Green", "DarkGray", "setfenv", "debug",
        "loadmodule", "traceback", "info", "dumpheap", "resetmemorycategory",
        "setmemorycategory", "profileend", "profilebegin", "error", "print"
    }
}
local PatternSyntaxColoring = {
    ["ce9178"] = {'%b""',"%b''"},
    
}
local SyntaxReplace = {
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ["\\\""] = "&quot;",
    ["\\\'"] = "&apos;"
    --["&"] = "&amp;"
    
}
function module.SyntaxHighlight(Text, selstart, selend, selcolor)
    Text=tostring(Text)
    local SelStartSymbol = "₼"
    local SelEndSymbol = "₣"
    if not selcolor then selcolor = "264f78" end
    local SelectionStart = '<stroke color="#'..selcolor..'" joins="miter" thickness="3">'
    local SelectionEnd = '</stroke>'
    if tonumber(selstart) and tonumber(selend) and selstart<selend then
        if selstart > 0 and selend > 0 then
            Text = Text:split("")
            table.insert(Text, selend, SelEndSymbol)
            table.insert(Text, selstart, SelStartSymbol)
            Text = table.concat(Text, "")
        end
    end
    for i, v in pairs(SyntaxReplace) do
        Text = Text:gsub(tostring(i),tostring(v))
    end
    --[[for Color, Array in pairs(PatternSyntaxColoring) do
        for _, Phrase in pairs(Array) do
            for match in string.gmatch(Text, Phrase) do
                pcall(function()
                    Text = Text:gsub(match, "<font color=\"#"..Color.."\">"..match.."</font>")
                end)
            end
        end
    end
    for Color, Array in pairs(SyntaxColoring) do
        for _, Phrase in pairs(Array) do
            Text = Text:gsub(Phrase, "<font color=\"#"..Color.."\">"..Phrase.."</font>")
        end
    end
    if Text:sub(1,2) == '"-' then Text = Text:sub(3, #Text) end]]
    local function findTagAfter(str)
        str=str:split("")
        for i = 1, #str do
            if str[i] == ">" then
                return true
            elseif str[i] == "<" then
                return false
            end
        end
        return false
    end
    local function findTagBefore(str)
        str=str:split("")
        for i = #str, 1, -1 do
            if str[i] == "<" then
                return true
            elseif str[i] == ">" then
                return false
            end
        end
        return false
    end
    for Color, Table in pairs(SyntaxColoring) do
        table.sort(SyntaxColoring[Color], function(a, b) return #a > #b end)
        for _, keyword in ipairs(Table) do
            local pattern = "%f[%a_]" .. keyword .. "%f[^%a_]"
            Text = Text:gsub(pattern, function(match)
                    --if findTagAfter(after) or findTagBefore(before) then return match end
                    return string.format("<font color=\฿#"..Color.."\฿>%s</font>", match)
            end)
        end
    end
    for Color, Table in pairs(PatternSyntaxColoring) do
        for _, operator in ipairs(Table) do
            local pattern = "%" .. operator
            Text = Text:gsub(operator, function(match)
                return string.format("<font color=\฿#"..Color.."\฿>%s</font>", match)
            end)
        end
    end
    Text = Text:gsub("฿",'"')
    local SStart, SEnd = string.find(Text, SelStartSymbol),string.find(Text, SelEndSymbol)
    if SStart and SEnd then
        Text = Text:split("")
        for i = SStart, SEnd do
            if Text[i] == "<" then
                Text[i] = SelectionEnd.."<"
            end
            if Text[i] == ">" then
                Text[i] = ">"..SelectionStart
            end
        end
        Text = table.concat(Text, "")
    end
    Text = Text:gsub(SelStartSymbol,SelectionStart)
    Text = Text:gsub(SelEndSymbol,SelectionEnd)
    return Text
end
function module.GetTextSize(GuiObject, Padding, HorizontalSize)
    if not HorizontalSize then HorizontalSize = 99999 end
    if not Padding then Padding = 0 end
    local TextSize = TextService:GetTextSize(
        GuiObject.ContentText, 
        GuiObject.TextSize,
        GuiObject.Font,
        Vector2.new(HorizontalSize, 99999)
    )
    if TextSize then
        TextSize=TextSize+Vector2.new(Padding,Padding)
        return TextSize.X, TextSize.Y
    end
end
function module.DatatypeToConstructor(v, prefix)
    if not prefix then prefix = "" end
    local nl = "\n"
    if v == nil then
        return "nil"
    elseif typeof(v) == "Vector3" then
        return "Vector3.new("..module.round(v.X, 4)..","..module.round(v.Y, 4)..","..module.round(v.Z, 4)..")"
    elseif typeof(v) == "Color3" then
        return "Color3.fromRGB("..math.round(v.R*255)..","..math.round(v.G*255)..","..math.round(v.B*255)..")"
    elseif typeof(v) == "BrickColor" then
        return "BrickColor.new(\""..v.Name.."\")"
    elseif typeof(v) == "Vector2" then
        return "Vector2.new("..v.X..","..v.Y..")"
    elseif typeof(v) == "UDim" then
        return "UDim.new("..v.Scale..","..v.Offset..")"
    elseif typeof(v) == "UDim2" then
        return "UDim2.new("..v.X.Scale..","..v.X.Offset..","..v.Y.Scale..","..v.Y.Offset..")"
    elseif typeof(v) == "NumberRange" then
        return "NumberRange.new("..v.Min..","..v.Max..")"
    elseif typeof(v) == "ColorSequenceKeypoint" then
        return "ColorSequenceKeypoint.new("..v.Time..","..v.Value..")"
    elseif typeof(v) == "NumberSequenceKeypoint" then
        return "NumberSequenceKeypoint.new("..v.Time..","..v.Value..")"
    elseif typeof(v) == "string" then
        return '"'..v:gsub(nl, "\\n"):gsub('"', '\\"')..'"'
    elseif typeof(v) == "number" then
        return v
    elseif typeof(v) == "boolean" then
        return tostring(v)
    elseif typeof(v) == "Instance" then
        return module.GetPath(v)
    elseif typeof(v) == "CFrame" then
        local tbl = {v:components()}
        local Deg = {v:ToOrientation()}
        local Deg = {
            module.round(math.deg(Deg[1], 3)) == 0 and 0 or "math.rad("..module.round(math.deg(Deg[1], 3))..")",
            module.round(math.deg(Deg[2], 3)) == 0 and 0 or "math.rad("..module.round(math.deg(Deg[2], 3))..")",
            module.round(math.deg(Deg[3], 3)) == 0 and 0 or "math.rad("..module.round(math.deg(Deg[3], 3))..")"}
        for i, v in pairs(tbl) do
            tbl[i] = tostring(module.round(v, 5))
        end
        return "CFrame.new("..table.concat(tbl, ",", 1,3)..")*CFrame.Angles("..table.concat(Deg, ",")..")"
    elseif typeof(v) == "EnumItem" then
        return tostring(v)
    elseif typeof(v) == "function" then
        local succ, func = pcall(function()
        local info = getinfo(v)
        local path = game
        local src = info.short_src
        for _,v2 in pairs(src:split(".")) do
            path = path[v2]
        end
        local source = decompile(path)
        return module.FindFunction(source,info.name,nil,path) end)
        if succ then
            return func
        else
            return "function() print(\"Failed to decompile!\") end"
        end
    elseif typeof(v) == "table" then
        local out = "{"
        local function append(...)
            for _, v in pairs({...}) do
                out = out..tostring(v)
            end
        end
        local isDict = v[1] == nil
        for i2, v2 in pairs(v) do
            if typeof(i2) ~= "number" then
                isDict = true
            end
        end
        for i2, v2 in pairs(v) do
            if typeof(i2) == "number" then
                if i2%20 == 0 then wait() end
            end
            append(
                nl,
                prefix.."   ",
                (function()
                    if typeof(i2) == "number" and not isDict then
                        return ""
                    else
                        return "["..module.DatatypeToConstructor(i2, prefix.."   ").."] = "
                    end
                end)(), 
                module.DatatypeToConstructor(v2, prefix.."   "),
                ","
            )
        end
        if out:sub(#out) == "," then
            out = out:sub(1, #out-1) 
        end
        append(nl, prefix, "}")
        return out
    elseif typeof(v) == "ColorSequence" then
        local out = "ColorSequence.new{"
        local function append(...)
            for _, v in pairs({...}) do
                out = out..tostring(v)
            end
        end
        for _, Keypoint in pairs(v.Keypoints) do
            append(
                nl,
                prefix,
                "   ",
                "ColorSequenceKeypoint.new(",
                module.round(Keypoint.Time,5),
                ", ", 
                module.DatatypeToConstructor(Keypoint.Value),
                "),"
            )
        end
        if out:sub(#out) == "," then
            out = out:sub(1, #out-1) 
        end
        append(nl, "}")
        return out
    elseif typeof(v) == "NumberSequence" then
        local out = "NumberSequence.new{"
        local function append(...)
            for _, v in pairs({...}) do
                out = out..tostring(v)
            end
        end
        for _, Keypoint in pairs(v.Keypoints) do
            append(
                nl,
                prefix,
                "   ",
                "NumberSequenceKeypoint.new(",
                module.round(Keypoint.Time,5),
                ", ", 
                module.round(Keypoint.Time,5),
                "),"
            )
        end
        if out:sub(#out) == "," then
            out = out:sub(1, #out-1) 
        end
        append(nl, prefix, "}")
        return out
    else
        return tostring(v)
    end
end
function module.writelua(path, tbl)
    writefile(path, "return "..module.DatatypeToConstructor(tbl))
end
function module.AppendStrings(...)
    return table.concat({...}, " ")
end
function module.removeTags(str)
	if type(str) == "string" then
    	return (str:gsub("(\\?)<[^<>]->", { [''] = '' }))
	else
		return str
	end
end
function module.isHoveringOverObj(obj)
    if typeof(obj) == "Instance" then
        local tx = obj.AbsolutePosition.X
        local ty = obj.AbsolutePosition.Y
        local bx = tx + obj.AbsoluteSize.X
        local by = ty + obj.AbsoluteSize.Y
        if Mouse.X >= tx and Mouse.Y >= ty and Mouse.X <= bx and Mouse.Y <= by then
            return true
        end
    end
end
function module.round(x, n)
    n = math.pow(10, n or 0)
    x = x * n
    if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
    return x / n
end
function module.VerifyRGB(r, g, b)
    return pcall(function() return Color3.fromRGB(r, g, b) end)
end
function module.VerifyColor3(r, g, b)
    return pcall(function() return Color3.new(r, g, b) end)
end
function module.localTeleportWithRetry(_PlaceId, _JobId, retryTime)
    local connection
    connection = game:GetService("TeleportService").TeleportInitFailed:Connect(function(player, teleportResult, errorMessage)
        if player == LP then
            -- check the teleportResult to ensure it is appropriate to retry
            if teleportResult == Enum.TeleportResult.Failure or teleportResult == Enum.TeleportResult.Flooded or teleportResult == Enum.TeleportResult.GameFull then
                -- disconnect the connection
                -- retry in retryTime seconds
                wait(retryTime)
                    game:GetService("TeleportService"):TeleportToPlaceInstance(_PlaceId, _JobId)
                
            else
                connection:Disconnect()
                module.localTeleportWithRetry(_PlaceId, _JobId, retryTime)
            end
        end
    end)
    game:GetService("TeleportService"):TeleportToPlaceInstance(_PlaceId, _JobId)
end
function module.Compare(A, B)
    if typeof(A) == "string" then 
        A = A:lower()
    elseif typeof(A) == "table" then 
        A = module.JSONEncode(A)
    elseif typeof(A) == "Instance" then 
        A = module.JSONEncode(module.DatatypeToTable(A:GetDescendants()))
    elseif typeof(A) == "number" then 
        A = tostring(A)
    end
    if typeof(B) == "string" then 
        B = B:lower()
    elseif typeof(B) == "table" then 
        B = module.JSONEncode(B)
    elseif typeof(B) == "Instance" then 
        B = module.JSONEncode(module.DatatypeToTable(B:GetDescendants()))
    elseif typeof(B) == "number" then 
        B = tostring(B)
    end
    local _, ret = pcall(function() 
        return A==B 
    end)
    return ret
end
local formulas = {
    types = {
        ['months'] = 60*60*24*30;
        ['weeks'] = 60*60*24*7;
        ['days'] = 60*60*24;
        ['hours'] = 60*60;
        ['minutes'] = 60;
        ['seconds'] = 1;
    };
    shortcuts = {
        ['mo'] = 'months';
        ['mths'] = 'months';
        ['month'] = 'months';
        ['w'] = 'weeks';
        ['week'] = 'weeks';
        ['ws'] = 'weeks';
        ['d'] = 'days';
        ['day'] = 'days';
        ['ds'] = 'days';
        ['h'] = 'hours';
        ['hs'] = 'hours';
        ['hour'] = 'hours';
        ['min'] = 'minutes';
        ['mins'] = 'minutes';
        ['minute'] = 'minutes';
        ['minutes'] = 'minutes';
        ['sec'] = 'seconds';
        ['secs'] = 'seconds';
        ['s'] = 'seconds';
        ['second'] = 'seconds';
    };
}

local NAME_COLORS =
{
	Color3.new(253/255, 41/255, 67/255), -- BrickColor.new("Bright red").Color,
	Color3.new(1/255, 162/255, 255/255), -- BrickColor.new("Bright blue").Color,
	Color3.new(2/255, 184/255, 87/255), -- BrickColor.new("Earth green").Color,
	BrickColor.new("Bright violet").Color,
	BrickColor.new("Bright orange").Color,
	BrickColor.new("Bright yellow").Color,
	BrickColor.new("Light reddish violet").Color,
	BrickColor.new("Brick yellow").Color,
}
local function GetNameValue(pName)
	local value = 0
	for index = 1, #pName do
		local cValue = string.byte(string.sub(pName, index, index))
		local reverseIndex = #pName - index + 1
		if #pName%2 == 1 then
			reverseIndex = reverseIndex - 1
		end
		if reverseIndex%4 >= 2 then
			cValue = -cValue
	end
		value = value + cValue
	end
	return value
end
function module.GetDataTypeIcon(Type, Size)
    if not Size then Size = 16 end
    local Sizes = {
        ["16"] = "rbxassetid://12367120122",
        ["64"] = "rbxassetid://12367117828"
    }
    Size = tonumber(Size)
    local data = DataTypeIconData[Type]
    if data and Sizes[tostring(Size)] then
        return {
            Image = Sizes[tostring(Size)],
            ImageRectOffset = Vector2.new(data[1]*Size,data[2]*Size),
            ImageRectSize = Vector2.new(Size,Size),
        }
    else
        warn("DatatypeIcon size not found!")
        return {
            Image = Sizes["16"],
            ImageRectOffset = Vector2.new(48,48),
            ImageRectSize = Vector2.new(16,16),
        }
    end
end
function module.GetClassIcon(ClassName)
    local data = ClassImages[ClassName]
    if data then
        return {
            Image = "rbxasset://textures/ClassImages.png",
            ImageRectOffset = module.TableToDatatype(data.ImageRectOffset),
            ImageRectSize = module.TableToDatatype(data.ImageRectSize),
        }
    else
        return {
            Image = "rbxasset://textures/ClassImages.png",
            ImageRectOffset = Vector2.new(0,0),
            ImageRectSize = Vector2.new(16,16),
        }
    end
end
function module.DatatypeToTable(v)
    if typeof(v) == "Vector3" then
        return {typeof(v), v.X, v.Y, v.Z}
    elseif typeof(v) == "Color3" then
        return {typeof(v), v:ToHex()}
    elseif typeof(v) == "Vector2" then
        return {typeof(v), v.X, v.Y}
    elseif typeof(v) == "UDim" then
        return {typeof(v), v.Scale, v.Offset}
    elseif typeof(v) == "UDim2" then
        return {typeof(v), v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset}
    elseif typeof(v) == "NumberRange" then
        return {typeof(v), v.Min, v.Max}
    elseif typeof(v) == "Instance" then
        return {typeof(v), v.ClassName, v.Name}
    elseif typeof(v) == "NumberSequence" then
        local _Temp = {typeof(v)}
        for _, val in pairs(v.Keypoints) do
            table.insert(_Temp, {val.Time, val.Value, val.Envelope})
        end
        return _Temp
    elseif typeof(v) == "ColorSequence" then
        local _Temp = {typeof(v)}
        for _, val in pairs(v.Keypoints) do
            table.insert(_Temp, {val.Time, val.Value:ToHex()})
        end
        return _Temp
    elseif typeof(v) == "CFrame" then
        return {typeof(v), v:GetComponents()}
    elseif typeof(v) == "EnumItem" then
        return {"EnumItem", tostring(v.EnumType), v.Name}
    elseif typeof(v) == "table" then
		local _out = {}
		for i2, v2 in pairs(v) do
			_out[i2] = module.DatatypeToTable(v2)
		end
		return _out
	else
        return v
    end
end
function module.TableToDatatype(value)
    if typeof(value) == "table" then
        if value[1] == "Vector2" then
            return Vector2.new(table.unpack(value, 2))
        elseif value[1] == "Vector3" then
            return Vector3.new(table.unpack(value, 2))
        elseif value[1] == "UDim2" then
            return UDim2.new(table.unpack(value, 2))
        elseif value[1] == "UDim" then
            return UDim.new(table.unpack(value, 2))
        elseif value[1] == "EnumItem" then
            return Enum[value[2]][value[3]]
        elseif value[1] == "CFrame" then
            return CFrame.new(table.unpack(value, 2))
        elseif value[1] == "Color3" then
            return Color3.fromHex(value[2])
        elseif value[1] == "NumberSequence" then
            local _Keypoints = {}
            for i = 2, #value do
                table.insert(_Keypoints, NumberSequenceKeypoint.new(table.unpack(value[i])))
            end
            return NumberSequence.new(table.unpack(_Keypoints))
        elseif value[1] == "ColorSequence" then
            local _Keypoints = {}
            for i = 2, #value do
                table.insert(_Keypoints, ColorSequenceKeypoint.new(value[i][1], Color3.fromHex(value[i][2])))
            end
            return NumberSequence.new(table.unpack(_Keypoints))
        elseif value[1] == "NumberRange" then
            return NumberRange.new(table.unpack(value, 2))
        end
        return nil
    else
        return false
    end
end
function module.FindPlayerById(Id)
    for _, v in pairs(Players:GetChildren()) do
        if v.UserId == tonumber(Id) then return v end
    end
end
function module.IfExists(obj, ret)
    if pcall(function() if obj.Name == "" then end end) then
        return obj
    else
        return ret
    end
end
module.MouseClickWithoutDrag = Instance.new("BindableEvent")
Mouse.Button2Down:Connect(function()
    pcall(function()
        local Campos = (workspace.CurrentCamera.CFrame.Position-(module.IfExists(workspace.CurrentCamera.CameraSubject.Parent.HumanoidRootPart, workspace.CurrentCamera.CameraSubject).Position-Vector3.new(1,1,1))).Magnitude
        Mouse.Button2Up:Wait()
        if math.abs((workspace.CurrentCamera.CFrame.Position-(module.IfExists(workspace.CurrentCamera.CameraSubject.Parent.HumanoidRootPart, workspace.CurrentCamera.CameraSubject).Position-Vector3.new(1,1,1))).Magnitude-Campos)<0.3 then
            module.MouseClickWithoutDrag:Fire()
        end
    end)
end)
function module.GiveTpTool()
    local TpTool = Instance.new("Tool")
    local Functions = LoadModule("UtilFunctions")
    TpTool.Name = "Teleport Tool"
    TpTool.RequiresHandle = false
    TpTool.Parent = LP.Backpack
    TpTool.Activated:Connect(function()
        local Chart = LP.Character
        local HRPs = Chart.HumanoidRootPart
        local MPos = Mouse.Hit.p
        Mouse.Button1Up:Wait()
        if (Mouse.Hit.p-MPos).Magnitude > 1 then
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                Functions.TeleportTo(CFrame.new(MPos+Vector3.new(0,Chart.Humanoid.HipHeight+3,0), Mouse.Hit.p),{TeleportOffset = CFrame.new(0,0,0)})
            else
                Functions.TeleportTo(CFrame.new(MPos+Vector3.new(0,Chart.Humanoid.HipHeight+3,0), Vector3.new(Mouse.Hit.X, MPos.Y+Chart.Humanoid.HipHeight+3,Mouse.Hit.Z)),{TeleportOffset = CFrame.new(0,0,0)})
            end
        else
            Functions.TeleportTo(CFrame.new(Mouse.Hit.X, Mouse.Hit.Y + Chart.Humanoid.HipHeight+3, Mouse.Hit.Z, select(4, HRPs.CFrame:components())),{TeleportOffset = CFrame.new(0,0,0)})
        end
    end)
end
function module.VerifyHex(hex)
    return pcall(function() return Color3.fromHex(hex) end)
end
function module.FindWSChild(obj)
    local iteration = 0
    local part = obj
    while part and part.Parent and part.Parent ~= workspace do
        part = part.Parent
        iteration = iteration+1
        if iteration > 255 then
            return nil
        end
    end
    return part
end
function module.FindLastAncestor(obj)
    local iteration = 0
    local part = obj
    while not pcall(function() return game:GetService(part.Parent.Name) end) do
        part = part.Parent
        iteration = iteration+1
        if iteration > 255 then
            return nil
        end
    end
    return part
end
function module.CMAnchorPoint()
    local MouseLocation = UserInputService:GetMouseLocation()
    local ScreenMiddle = workspace.CurrentCamera.ViewportSize*Vector2.new(0.5,0.5)
    local X, Y = 0, 0
    if MouseLocation.X > ScreenMiddle.X then
        X = 1
    end
    if MouseLocation.Y > ScreenMiddle.Y then
        Y = 1
    end
    return Vector2.new(X,Y)
end
function module.getMouseHitIncludingChar()
    local vector = Mouse.Hit.p - workspace.CurrentCamera.CFrame.p
    local ray = workspace:Raycast(workspace.CurrentCamera.CFrame.p, vector.Unit * (vector.Magnitude + 5), RaycastParams.new())
    return ray
end
function module.formatfile(str)
    local a = string.split(string.gsub(string.gsub(str, "\\","^"), "/","^"),"^")
    if a[#a] == "" then
        return a[#a-1]
    else
        return a[#a]
    end
end
local color_offset = 0
function module.ComputeNameColor(pName)
	return NAME_COLORS[((GetNameValue(pName) + color_offset) % #NAME_COLORS) + 1]
end
function module.ConvertShortcutToUnit(input)
    if not input then return end
    for shortcut, stringfix in pairs (formulas.shortcuts) do
        if string.lower(input) == shortcut then
            return stringfix
        end
    end
    for stringfix in pairs (formulas.types) do
        if string.lower(input) == stringfix then
            return stringfix
        end
    end
end

function module.ConvertTimeIntoSeconds(amount,unit)
    if amount == nil then 
        return 0 
    end
    local unit = unit
    unit = module.ConvertShortcutToUnit(unit)
    for unittype , formula in pairs (formulas.types) do
        if string.lower(unittype) == unit then
            return (amount * formula)
        end
    end
    return 999999999999
end

function module.ValidateTime(Time, Unit)
    if tonumber(Time) then
        for shortcut, stringfix in pairs (formulas.shortcuts) do
            if string.lower(Unit) == shortcut then
                return true
            end
        end
        for stringfix in pairs (formulas.types) do
            if string.lower(Unit) == stringfix then
                return true
            end
        end
    end
    return false
end

function module.IsCyclic(v)
    local succ, err = pcall(module.JSONEncode,v)
    if err then
        if string.find(err:lower(), "cyclic") then
            return true
        end
    end
    return false
end
function module.GetServerList(_PlaceId)
    local ret
    xpcall(function() 
        module.Notify("Downloading new list, this might take some time...", "ServerList Download")
        ServerList = {}
        local _ServersAPI = module.JSONDecode(game:HttpGet(
                                                    "https://games.roblox.com/v1/games/" ..
                                                        _PlaceId ..
                                                        "/servers/Public?sortOrder=Desc&limit=100"))
        ServerList.data = _ServersAPI.data
        if _ServersAPI.nextPageCursor then
            while _ServersAPI.nextPageCursor do
                local _Cursor = _ServersAPI.nextPageCursor
                _ServersAPI = module.JSONDecode(game:HttpGet(
                                                        "https://games.roblox.com/v1/games/" ..
                                                            _PlaceId ..
                                                            "/servers/Public?sortOrder=Desc&limit=100&cursor=" ..
                                                            _Cursor))
                for i, v in pairs(_ServersAPI.data) do
                    table.insert(ServerList.data, v)
                end
                wait(.5)
            end
        end
        --[[local PlaceName = module.JSONDecode(game:HttpGet("https://api.roblox.com/universes/get-universe-containing-place?placeid=" .._PlaceId))
        PlaceName = module.JSONDecode(game:HttpGet(
                                            "https://games.roblox.com/v1/games?universeIds=" ..
                                                PlaceName.UniverseId))
        PlaceName = PlaceName.data[1].name
        ServerList.PlaceName = PlaceName]]
        module.Notify("Finished downloading "..#ServerList.data.." servers.", "ServerList Download")
        ret = ServerList
        return ServerList
    end,warn)
    return ret
end
function module.tablelength(t)
    local _count = 0
    for _, _ in pairs(t) do
        _count = _count+1
    end
    return _count
end
function module.Notify(Message, Title, timer)
    if not timer then timer = 10 end
    if Title == nil then Title = "Notification" end
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = Title;
        Text = Message;
        Duration = timer;
        Button1 = "Dismiss";
    })
end
function module.getUserIdFromUsername(name)
    UserCache = module.readJSON("UserCache.json")
	local player = Players:FindFirstChild(name)
	if player then
		return tostring(player.UserId)
	end
    if UserCache then
        if UserCache[name] then
            return UserCache[name]
        end
    end
	-- If all else fails, send a request
	local id
	pcall(function()
		id = Players:GetUserIdFromNameAsync(name)
	end)
    if id then
        return tostring(id)
    else
        return
    end
end
function module.InvertColor(Color)
    if typeof(Color) == "string" then Color = Color3.fromHex(Color) end
    return Color3.new(1-Color.R,1-Color.G,1-Color.B)
end
function module.getUsernameFromUserId(id)
    UserCache = module.readJSON("UserCache.json")
    if typeof(id) == "number" then id = tostring(id) end
    for _, v in pairs(Players:GetChildren()) do
        if v.UserId == id then
            return v.Name
        end
    end
    if UserCache then
        if UserCache[id] then
            return UserCache[id]
        end
    end
	-- If all else fails, send a request
	local name
	pcall(function()
		name = Players:GetNameFromUserIdAsync(id)
	end)
    if name then
        return name
    else
        return
    end
end
local function appendstr(tbl)
    local out = ""
    for _, v in pairs(tbl) do
        out = out..tostring(v)
    end
    return out
end
function module.FindFunction(source, Name, FunctionName, ScriptPath)
    local ret = "function() print(\"Failed to decompile!\") end"
    pcall(function()
        local srctable = source:split("\n")
        local _depth = 0
        local _startline = 0
        local _endline = 0
        local Locals = {}
        if ScriptPath then
            local ModuleTableName, ModuleTableValue = "module", "require("..module.GetPath(ScriptPath)..")"
        if string.find(srctable[#srctable-1], "return ", 0, true) then
            ModuleTableName = srctable[#srctable-1]:sub(8,#srctable[#srctable-1]-2)
        end
            Locals[ModuleTableName] = ModuleTableValue
            Locals["script"] = module.GetPath(ScriptPath)
        end
        local function GetWhitespaces(str)
            if str then
                for i, v in pairs(str:split("")) do
                    if v ~= "	" then
                        return i-1
                    end
                end
            end
            return 0
        end
        local function FindLocals(Line)
            if string.find(Line, "local") and Line:sub(#Line)==";" and GetWhitespaces(Line)<1 then
                local _, namestart = string.find(Line, "local", 0, true)
                local nameend, varstart = string.find(Line, " = ", namestart+1, true)
                local name = string.sub(Line, namestart+2, nameend-1)
                local var = string.sub(Line, varstart+1, #Line-1)
                Locals[name] = var
            end
        end
        local function Replace(stringt, pattern, replace)
            local i = 0
            while string.find(stringt, pattern, 0, true) and i<100 do
                local foundpattern = string.find(stringt, pattern, 0, true)
                if foundpattern then
                    return stringt:sub(0,foundpattern-1)..replace..stringt:sub(foundpattern+#pattern,#stringt)
                end
                i=i+1
            end
            return stringt
        end
        for i, v in pairs(srctable) do
            FindLocals(v)
            if string.find(v, Name.."(", 0, true) and string.find(v, "function", 0, true) then
                _startline = i
            end
        end
        _depth = GetWhitespaces(srctable[_startline])
        for i = _startline+1, #srctable do
            local succ, err = pcall(function()
                srctable[i] = string.gsub(srctable[i], "[%w_]+", Locals)
            end)
            if err then rconsolewarn(err) end
            local Line = srctable[i]
            if GetWhitespaces(Line) == _depth then
                _endline = i
                if FunctionName then
                    local _ptr1 = string.find(srctable[_startline], "function", 0, true)
                    local _ptr2 = string.find(srctable[_startline], "(",0, true)
                    srctable[_startline] = srctable[_startline]:sub(_ptr1, _ptr1+7).." "..FunctionName..srctable[_startline]:sub(_ptr2)
                else
                    local _ptr1 = string.find(srctable[_startline], "function", 0, true)
                    local _ptr2 = string.find(srctable[_startline], "(",0, true)
                    srctable[_startline] = srctable[_startline]:sub(_ptr1, _ptr1+7)..srctable[_startline]:sub(_ptr2)
                end
                pcall(function()
                    ret = table.concat(srctable, "\n", _startline, _endline)
                end)
            end
        end
    end)
    return ret
    --[[local function FindAll(str, Pattern)
        local ptr = 0
        local count = 0
        while string.find(str, Pattern, ptr+1, true) do
            ptr = string.find(str, Pattern, ptr+1, true)
            count = count+1
        end
        return count
    end
    for i = _startline, #srctable do
        Line = srctable[i]
        local positive = {"do", "then", "function"}
        local negative = {"end;"}
        for _, v in pairs(positive) do
            _depth = _depth+FindAll(Line, v)
        end
        for _, v in pairs(negative) do
            _depth = _depth-FindAll(Line, v)
        end
        if _depth < 1 then
            _endline = i
            break
        end
        srctable[i] = srctable[i].." @Depth of ".._depth
    end]]
end
function module.DataTypeToString(v, prefix)
    if not prefix then prefix = "" end
    local nl = "\n"
    if v == nil then
        return "nil"
    elseif typeof(v) == "Vector3" then
        return {typeof(v), " ", v.X, ", ", v.Y, ", ", v.Z}
    elseif typeof(v) == "Color3" then
        return {typeof(v), " ", math.round(v.R*255), ", ", math.round(v.G*255), ", ", math.round(v.B*255)}
    elseif typeof(v) == "Vector2" then
        return {typeof(v), " ", v.X, ", ", v.Y}
    elseif typeof(v) == "UDim" then
        return {typeof(v), " {", v.Scale, ", ", v.Offset,"}"}
    elseif typeof(v) == "UDim2" then
        return {typeof(v)," {", v.X.Scale,", ", v.X.Offset, "},{",v.Y.Scale,", ", v.Y.Offset,"}"}
    elseif typeof(v) == "NumberRange" then
        return {typeof(v), " ", v.Min, ", ", v.Max}
    elseif typeof(v) == "string" then
        return {"\"", v:gsub("\"", "\\\""),"\""}
    elseif typeof(v) == "Instance" then
        return {v.ClassName," ", v:GetFullName()}
    elseif typeof(v) == "CFrame" then
        return {typeof(v), " ", v.X, ", ", v.Y, ", ", v.Z, "; ", v.XVector, ", ", v.YVector, ", ", v.ZVector }
    elseif typeof(v) == "EnumItem" then
        return {v}
    elseif typeof(v) == "function" then
        local info = {}
        if getinfo then
            info = getinfo(v)
            info.func = nil
        end
        --return {"function: ", DataTypeToString(info, prefix.."   ")}
        local out = "function: {"
        local function append(...)
            for _, v in pairs({...}) do
                out = out..tostring(v)
            end
        end
        for i2, v2 in pairs(info) do
            if typeof(i2) == "number" then
                if i2%20 == 0 then wait() end
            end
            append( 
                nl,
                prefix,
                "   [\"",
                i2,
                "\"] = ", 
                appendstr(module.DataTypeToString(v2, prefix.."   ")),
                ","
            )
        end
        out = out:sub(1, #out-1) 
        append(nl, prefix, "}")
        return {out}
    elseif typeof(v) == "table" then
        local out = "{"
        local function append(...)
            for _, v in pairs({...}) do
                out = out..tostring(v)
            end
        end
        for i2, v2 in pairs(v) do
            if typeof(i2) == "number" then
                if i2%20 == 0 then wait() end
            end
            if module.IsCyclic(v2) then
                append( 
                    nl,
                    prefix,
                    "   [\"",
                    i2,
                    "\"] = ", 
                    "{Cyclic Table}",
                    ","
                )
            else
                append( 
                    nl,
                    prefix,
                    "   [\"",
                    i2,
                    "\"] = ", 
                    appendstr(module.DataTypeToString(v2, prefix.."   ")),
                    ","
                )
            end
        end
        if out:sub(#out) == "," then
            out = out:sub(1, #out-1) 
        end
        append(nl, prefix, "}")
        return {out}
    else
        return {tostring(v)}
    end
end
function module.print(...)
    local nl = "\n"
    local out = ""
    local function append(...)
        for _, v in pairs({...}) do
            out = out..tostring(v)
        end
    end
    for _, v in pairs({...}) do
        --print(DataTypeToString(v, ""))
        append(module.DatatypeToConstructor(v, ""))
        append(",",nl)
    end
    if #out < 16384 then
        print(out)
    else
        for i, v in pairs(out:split(nl)) do
            if i%20 == 0 then wait() end
            print(v)
        end
    end
end
function module.VerifyProperty(ClassName, Property)
    local inst
    if typeof(ClassName) == "Instance" then inst = ClassName end
    local success = pcall(function() 
        if not inst then
            inst = Instance.new(ClassName)
        end
        local a = inst[Property]
    end)
    if inst and typeof(ClassName) ~= "Instance" then inst:Destroy() end
    return success
end
function module.VerifyInstance(ClassName)
    local inst
    local success = pcall(function() 
        inst = Instance.new(ClassName)
    end)
    if inst then inst:Destroy() end
    return success
end
function module.GetPropertiesFromDocs(ClassName)
    local Response = request({
        Url = "https://create.roblox.com/docs/reference/engine/classes/"..ClassName,
        Method = "GET"
    }).Body
    local ptr1 = string.find(Response, "properties\">Properties</h3>")
    local ptr2 = string.find(Response, "id=\"summary", ptr1+1)
    Response = string.sub(Response, ptr1, ptr2)
    local ret = {}
    local ret2 = {}
    for _, v in pairs(Response:split("/docs/reference/engine/classes/")) do
        local ptr1 = string.find(v, "\">")
        local ptr2 = string.find(v, "</a>", ptr1+1)
        if ptr1 and ptr2 then
            table.insert(ret, string.sub(v, ptr1+2, ptr2-1))
        end
    end
    local chars = "abcdefghijklmnopqrstuvwxyz123467890"
    for i, v in pairs(ret) do
        local valid = true
        for _, tokenchar in pairs(v:lower():split("")) do
            if not table.find(chars:split(""), tokenchar) then
                valid = false
            end
        end
        if table.find(ret2, v) then
            valid = false
        end
        if valid then table.insert(ret2, v) end
    end
    table.sort(ret2)
    return ret2
end
function module.findprev(str, pattern, index)
    str = str:sub(1,index)
    local str = str:reverse()
    if string.find(str, pattern, 0, true) and index then
        return index-string.find(str, pattern, 0, true)
    end
    return 0
end
function module.InverseTable(tbl)
    local out = {}
    for i, v in pairs(tbl) do
        out[v] = i
    end
    return out
end
function module.GetHTMLAsText(url)
    return request({
        Url = "https://toolsyep.com/en/webpage-to-plain-text/?u="..url,
        Method = "GET"
    }).Body
end

function module.GetPropertyLockedFromDocs(ClassName)
    local Response = readfile("DevForum/"..ClassName..".txt")
    local out = {}
    local succ, err = pcall(function()
        local PROPERTIES = string.find(Response, "PROPERTIES", 0, true)
        local METHODS = string.find(Response, "METHODS", 0, true)
        local substr = Response:sub(PROPERTIES, METHODS-1)
        local tbl = substr:split("\n")
        local props = Properties[ClassName]
        for _, v in pairs(props) do
            local property = string.find(substr, "\\n"..v, 0)
            if not property then property = #substr end
            local End = string.find(substr, ":", property+#v+3)
            if not End then End = #substr end
            local propSubstr = substr:sub(property, End-1)
            if string.find(propSubstr:lower(), "read only") or string.find(propSubstr:lower(), "read-only") then
                out[v] = true
            end
        end
    end)
    if succ then
        return out
    else
        return {"failed!", err}
    end
end
function module.GetMethodsFromDocs(ClassName)
    local Response = readfile("DevForum/"..ClassName..".txt")
    local out = {}
    local MethodDict = {}
    local MethodTable = {}
    local succ = pcall(function()
        local Methods = string.find(Response, "METHODS", 0, true)
        local Events = string.find(Response, "EVENTS", 0, true)
        local substr = Response:sub(Methods, Events-1)
        local tbl = substr:split("\n")
        for i, v in pairs(tbl) do
            if string.find(v, "-",0,true) then
                if string.find(tbl[i-1], "%(") == nil then
                    if string.find(tbl[i-2], "%(") == nil then
                        table.insert( MethodTable, tbl[i-3].." "..tbl[i-2].." "..tbl[i-1] )
                    else
                        table.insert( MethodTable, tbl[i-2].." "..tbl[i-1] )
                    end
                else
                    table.insert( MethodTable, tbl[i-1] )
                end
            end
        end
        for _, v in pairs(MethodTable) do
            local Args = {}
            for _, v in pairs(v:split("(")[2]:split(")")[1]:split(", ")) do
                table.insert(Args, {Name = v:split(": ")[1], Type = v:split(": ")[2]})
            end
            MethodDict[v:split("(")[1]] = {
                Args = Args,
                Return = v:split(": ")[#v:split(": ")]:split(" ")[1]
            }
        end
    end)
    if succ then
        return MethodDict
    else
        return {"failed!"}
    end
end

function module.GetMethodsFromFile(file)
    local Response = readfile(file)
    local out = {}
    local MethodDict = {}
    local MethodTable = {}
    local succ, err = pcall(function()
        local MethodTable = Response:split("\n")
        for _, v in pairs(MethodTable) do
            local Args = {}
            for _, v in pairs(v:split("(")[2]:split(")")[1]:split(", ")) do
                local typev = v:split(": ")[2]
                if typev then typev=typev:gsub("%s+", "") end
                local namev = v:split(": ")[1]
                if namev then namev=namev:gsub("%s+", "") end
                table.insert(Args, {Name = namev, Type = typev})
            end
            MethodDict[v:split("(")[1]] = {
                Args = Args,
                Return = v:split(": ")[#v:split(": ")]:split(" ")[1]:sub(1,#(v:split(": ")[#v:split(": ")]:gsub("%s+", ""):split(" ")[1]))
            }
        end
    end)
    if succ then
        return MethodDict
    else
        return {"failed!", err}
    end
end
function module.GetEventsFromDocs(ClassName)
    local Response = request({
        Url = "https://create.roblox.com/docs/reference/engine/"..ClassName,
        Method = "GET"
    }).Body
    local chars = "abcdefghijklmnopqrstuvwxyz123467890"
    local ptr1 = string.find(Response, "events\">Events</h3>",0, true)
    local ptr2 = string.find(Response, "id=\"properties\">Properties</h2>", ptr1+1, true)
    Response = string.sub(Response, ptr1, ptr2)
    local ret = {}
    local ret2 = {}
    for _, v in pairs(Response:split("/docs/reference/engine/classes/")) do
        local ptr1 = string.find(v, "\">", 0, true) or 0
        local ptr2 = string.find(v, "</a>", ptr1+1, true)
        if not ptr1 then continue end
        if not ptr2 then continue end
        local jss138 = string.find(v, "jss138", ptr1+1, true)
        local open = string.find(v, "(", ptr1+1, true)
        local close = string.find(v, ")", ptr1+1, true)
        --if not returnpointer then continue end
        if ptr1 and ptr2 and tonumber(close) then
            local Name = string.sub(v, ptr1+2, ptr2-1)
            local Args = module.removeTags(string.sub(v,ptr2,close))
            ret[Name] = {
                Args = Args
            }
        end
    end
    for i, v in pairs(ret) do
        local valid = true
        for _, tokenchar in pairs(i:lower():split("")) do
            if not table.find(chars:split(""), tokenchar) then
                valid = false
            end
        end
        if ret2[i] then
            valid = false
        end
        if valid then ret2[i] = v end
    end
    table.sort(ret2)
    return ret2
end
function module.rconsoleprint(...)
    local nl = "\n"
    local out = ""
    local function append(...)
        for _, v in pairs({...}) do
            out = out..tostring(v)
        end
    end
    for _, v in pairs({...}) do
        --print(DataTypeToString(v, ""))
        append(module.DatatypeToConstructor(v, ""))
        append(",",nl)
    end
    rconsoleprint(out)
    rconsoleprint(nl)
end
function module.stringify(...)
    local nl = "\n"
    local out = ""
    local function append(...)
        for _, v in pairs({...}) do
            out = out..tostring(v)
        end
    end
    for _, v in pairs({...}) do
        append(module.DatatypeToConstructor(v, ""))
        append(nl)
    end
    return out
end
return module