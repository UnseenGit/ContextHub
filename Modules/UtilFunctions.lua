local Players = game:GetService("Players")
local CoreGui = game:GetService("StarterGui")
local LP = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local mouseLocation = UserInputService:GetMouseLocation()
local Mouse = LP:GetMouse()

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
local ConfigModule = LoadModule("ConfigModule")
RunService.RenderStepped:connect(function()
	mouseLocation = UserInputService:GetMouseLocation()
end)
local module = {}
module.__index = module
local Config = ConfigModule:Create("CTCONFIG.lua",{
    [tostring(game.PlaceId)] = {
        TeleportOffset = CFrame.new(0,0,-5)*CFrame.Angles(math.rad(0),math.rad(180),math.rad(0)),
        BringTeleportOffset = CFrame.new(0,0,-5)*CFrame.Angles(math.rad(0),math.rad(180),math.rad(0))
    },
    [tostring(LP.UserId)] = {
        NameHidden = false
    },
})
function module.SetSettings(SettingsTable, SettingsToChange)
    for set, value in pairs(SettingsToChange) do
        if typeof(value) == "table" then
            if not SettingsTable[set] then
                pcall(function()
                    SettingsTable[set] = {}
                end)
            end
            module.SetSettings(SettingsTable[set], value)
        else
            pcall(function()
                SettingsTable[set] = value
            end)
        end
    end
end
function removeInvalidCharacters(fileName)
    local invalidChars = '[<>:"/\\|?*]'
    local cleanFileName = fileName:gsub(invalidChars, '')
    return cleanFileName
end
local PlaceName = removeInvalidCharacters(game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

function module.SetSettingsToFile()
end
function module.GiveTpTool()
    local TpTool = Instance.new("Tool")
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
                module.TeleportTo(CFrame.new(MPos+Vector3.new(0,Chart.Humanoid.HipHeight+3,0), Mouse.Hit.p),{TeleportOffset = CFrame.new(0,0,0)})
            else
                module.TeleportTo(CFrame.new(MPos+Vector3.new(0,Chart.Humanoid.HipHeight+3,0), Vector3.new(Mouse.Hit.X, MPos.Y+Chart.Humanoid.HipHeight+3,Mouse.Hit.Z)),{TeleportOffset = CFrame.new(0,0,0)})
            end
        else
            module.TeleportTo(CFrame.new(Mouse.Hit.X, Mouse.Hit.Y + Chart.Humanoid.HipHeight+3, Mouse.Hit.Z, select(4, HRPs.CFrame:components())),{TeleportOffset = CFrame.new(0,0,0)})
        end
    end)
end
function module.ReadSettingsFromFile()
end
function module.TeleportTo(Destination, SettingsOverride)
    module.Teleport(LP, Destination, SettingsOverride)
end
function module.OpenChatLogs(ContextMenus, FilterTable)
    Config = ConfigModule:Create("CTCONFIG.lua",{
        [tostring(game.PlaceId)] = {
            TeleportOffset = CFrame.new(0,0,-5)*CFrame.Angles(math.rad(0),math.rad(180),math.rad(0)),
            BringTeleportOffset = CFrame.new(0,0,-5)*CFrame.Angles(math.rad(0),math.rad(180),math.rad(0))
        },
        [tostring(LP.UserId)] = {
            NameHidden = false
        },
    })
    local i = 0
    local ChatLogs = {}
    local ChatLogBox = ContextMenus.CreateTextBox({
        TextBox = {
            Title = {Text = "ChatLogs"},
            HasFilter = true,
            FilterLocation = "Top"
        }
    }, "ChatLogs")
    if FilterTable then ChatLogBox.FilterTable = FilterTable end
    local canscroll = true
    ChatLogs = _G.ChatLogs
    i = #ChatLogs
    task.spawn(function()
        while ChatLogBox.Instance.Parent and wait() do
            xpcall(function()
                if canscroll and i > 0 then
                    for loop = 1, 100 do
                        local v = ChatLogs[i]
                        if not v then break end
                        local msg
                        local IsAWhisper = false
                        if v.Message:split(" ")[1] == "/w" and v.Message:split(" ")[3] == "" then
                            IsAWhisper = true
                            msg = os.date("%X", v.Time) .. " | <font color=\"#50ffff\">[" ..v.FromSpeaker .. " >> "..v.Message:split(" ")[2].."]</font> : " ..table.concat(v.Message:gsub("\n",""):split(" "), " ", 4):gsub(">","&gt;"):gsub("<","&lt;")
                        else
                            msg = os.date("%X", v.Time) .. " | <font color=\"#"..Util.ComputeNameColor(v.FromSpeaker):ToHex().."\">" ..v.FromSpeaker .. "</font> : " .. v.Message:gsub(">","&gt;"):gsub("<","&lt;"):gsub("\n","")
                        end
                        local function AddEntry(msg)
                            ChatLogBox.AddEntry(
                                {
                                    NoRenderStep = true
                                }, 
                                msg,
                                {
                                    M2Func = function()
                                        ContextMenus.Create(
                                            {
                                                FrameAnchorPoint = Util.CMAnchorPoint(),
                                                Position = UDim2.fromOffset(mouseLocation.X,mouseLocation.Y),
                                                TitleText = "  <font color=\"#"..Util.ComputeNameColor(v.FromSpeaker):ToHex().."\">"..v.FromSpeaker.."</font>   ",
                                                ContextMenuEntries = {
                                                    TextSize = 12
                                                }
                                            },
                                            {
                                                Text = "Copy...",
                                                Submenu = {
                                                    {
                                                        Text = "UserName",
                                                        Icon = Util.GetClassIcon("Player"),
                                                        M1Func = function()
                                                            setclipboard(v.FromSpeaker)
                                                        end
                                                    },
                                                    {
                                                        Text = "UserId",
                                                        Icon = Util.GetClassIcon("Player"),
                                                        M1Func = function()
                                                            setclipboard(Util.getUserIdFromUsername(v.FromSpeaker))
                                                        end
                                                    },
                                                    {
                                                        Text = "Message",
                                                        Icon = Util.GetClassIcon("Chat"),
                                                        M1Func = function()
                                                            setclipboard(Util.removeTags(msg))
                                                        end
                                                    },
                                                    {
                                                        Text = "Text",
                                                        Icon = Util.GetClassIcon("Chat"),
                                                        M1Func = function()
                                                            setclipboard(v.Message)
                                                        end
                                                    },
                                                    (function()
                                                        if IsAWhisper then 
                                                            return {
                                                                Text = "Recipient",
                                                                Icon = Util.GetClassIcon("Player"),
                                                                M1Func = function()
                                                                    setclipboard(v.Message:split(" ")[2])
                                                                end
                                                            },
                                                            {
                                                                Text = "Recipient Id",
                                                                Icon = Util.GetClassIcon("Player"),
                                                                M1Func = function()
                                                                    setclipboard(Util.getUserIdFromUsername(v.Message:split(" ")[2]))
                                                                end
                                                            }
                                                        end
                                                    end)()
                                                }
                                            },
                                            {
                                                Text = "View",
                                                Icon = Util.GetClassIcon("Camera"),
                                                M1Func = function()
                                                    local Humanoid = Players[v.FromSpeaker].Character
                                                    if Humanoid then
                                                        Humanoid = Humanoid:FindFirstChild("Humanoid")
                                                        if Humanoid then
                                                            workspace.CurrentCamera.CameraSubject = Humanoid
                                                        end
                                                    end
                                                end
                                            },
                                            {
                                                Text = "Go to",
                                                Icon = Util.GetClassIcon("Workspace"),
                                                M1Func = function()
                                                    module.TeleportTo(Players[v.FromSpeaker].Character.HumanoidRootPart)
                                                end
                                            },
                                            (function()
                                                if IsAWhisper then 
                                                    return {
                                                        Text = "Open Conversation",
                                                        Icon = Util.GetClassIcon("TextSource"),
                                                        M1Func = function()
                                                            module.OpenChatLogs(ContextMenus, {v.FromSpeaker, v.Message:split(" ")[2]})
                                                        end
                                                    }
                                                end
                                            end)()
                                        )
                                    end
                                }
                            )
                        end
                        if ChatLogBox.FilterTable then
                            for _, phrase in pairs(ChatLogBox.FilterTable) do
                                if string.match(msg:lower(), phrase:lower()) then
                                    AddEntry(msg)
                                    break
                                end
                            end
                        else
                            AddEntry(msg)
                        end
                        i=i-1
                    end
                end
                if ChatLogBox.Instance.EntryList.CanvasPosition.Y >
                    ChatLogBox.Instance.EntryList.AbsoluteCanvasSize.Y - 1000 then
                    canscroll = true
                else
                    canscroll = false
                end
            end,warn)
        end
    end)
    local Refresh = ChatLogBox.AddButton({}, "Refresh", {
        M1Func = function()
            ChatLogs = _G.ChatLogs
            i = 0
            wait()
            ChatLogBox.ClearList()
            wait()
            i = #ChatLogs
        end
    })
    if ChatLogBox.FilterTable then ChatLogBox.FilterBox.Text = table.concat(ChatLogBox.FilterTable, ", ") end
    ChatLogBox.FilterBox.FocusLost:connect(function()
        ChatLogBox.FilterTable = string.split(string.gsub(string.gsub(ChatLogBox.FilterBox.Text, ";", ","), ", ", ","),",")
        if #table.concat(ChatLogBox.FilterTable, ", ")>0 then
            ChatLogBox.TitleBar.Text = " ChatLogs ("..table.concat(ChatLogBox.FilterTable, ", ")..")"
        else
            ChatLogBox.TitleBar.Text = " ChatLogs"
        end
        for _, phrase in pairs(ChatLogBox.FilterTable) do
            for _, v in pairs(ChatLogBox.Entries) do
                pcall(function()
                    if not string.match(v.Text:lower(), phrase:lower()) then
                        v:Destroy()
                    end
                end)
            end
        end
    end)
    if ChatLogBox.FilterTable and ChatLogBox.Instance.Parent:FindFirstChild("TitleBar") then
        if #table.concat(ChatLogBox.FilterTable, ", ")>0 then
            ChatLogBox.TitleBar.Text = " ChatLogs ("..table.concat(ChatLogBox.FilterTable, ", ")..")"
        else
            ChatLogBox.TitleBar.Text = " ChatLogs"
        end
    end
    ChatLogBox.AddButton({}, "Export to file", {
        M1Func = function()
            if not isfolder("Chatlogs") then makefolder("Chatlogs") end
            local path = ""
            if not PlaceName then PlaceName = tostring(game.PlaceId) end
            if ChatLogBox.FilterTable then
                path = "Chatlogs/ChatLogsFiltered "..table.concat(ChatLogBox.FilterTable, " ", 1, math.min(#ChatLogBox.FilterTable,3)).." "..PlaceName.." "..os.time()..".txt"
                writefile(path, "Filtered chat logs ("..table.concat(ChatLogBox.FilterTable, ", ")..") for "..PlaceName.." : "..game.PlaceId.." "..game.JobId.." exported by "..(Config[tostring(LP.UserId)].NameHidden and "namehidden" or LP.Name).." at "..os.date("%d.%m.%Y %X"))
                Util.Notify("Saving filtered chatlogs! This might take a while ("..#ChatLogs.." entries)")
                for i, v in pairs(ChatLogs) do
                    local msg
                    if v.Message:split(" ")[1] == "/w" and v.Message:split(" ")[3] == "" then
                        msg = os.date("%X", v.Time) .. " | [" ..v.FromSpeaker .. " >> "..v.Message:split(" ")[2].."] : " ..table.concat(v.Message:gsub("\n",""):split(" "), " ", 4)
                    else
                        msg = os.date("%X", v.Time) .. " | " ..v.FromSpeaker .. " : " .. v.Message:gsub("\n","")
                    end
                    for _, name in pairs(ChatLogBox.FilterTable) do
                        local chk = false
                        if string.match(msg:lower(), name:lower()) then
                            chk = true
                        end
                        if chk then    
                            appendfile(path, "\n"..msg)
                        end
                    end
                    if i%100 == 0 then wait() end
                end
                Util.Notify("Finished saving chatlogs!")
            else
                path = "Chatlogs/ChatLogs "..PlaceName..".txt"
                writefile(path, "Chat logs for "..PlaceName.." : "..game.PlaceId.." "..game.JobId.." exported by "..(Config[tostring(LP.UserId)].NameHidden and "namehidden" or LP.Name).." at "..os.date("%d.%m.%Y %X"))
                Util.Notify("Saving chatlogs! This might take a while ("..#ChatLogs.." entries)")
                for i, v in pairs(ChatLogs) do
                    local msg
                    if v.Message:split(" ")[1] == "/w" and v.Message:split(" ")[3] == "" then
                        msg = os.date("%X", v.Time) .. " | [" ..v.FromSpeaker .. " >> "..v.Message:split(" ")[2].."] : " ..table.concat(v.Message:gsub("\n",""):split(" "), " ", 4)
                    else
                        msg = os.date("%X", v.Time) .. " | " ..v.FromSpeaker .. " : " .. v.Message:gsub("\n","")
                    end
                    appendfile(path, "\n"..msg)
                    if i%100 == 0 then wait() end
                end
                Util.Notify("Finished saving chatlogs!")
            end
        end
    })
end
function module.Teleport(Object, Destination, SettingsOverride)
    local Settings = {}
    module.SetSettings(Settings, Config)
    local tpObject = Object
    if Object:IsA("Player") then tpObject = Object.Character.HumanoidRootPart end
    if SettingsOverride then
        module.SetSettings(Settings, SettingsOverride)
    end
    if typeof(Destination) == "Instance" then
        if Destination:IsA("Player") then
            tpObject.CFrame = Destination.Character.HumanoidRootPart.CFrame*Settings.TeleportOffset
            return
        else
            tpObject.CFrame = Destination.CFrame*Settings.TeleportOffset
            return
        end
    else
        if typeof(Destination) == "table" then
            tpObject.CFrame = CFrame.new(table.unpack(Destination))*Settings.TeleportOffset
            return
        elseif typeof(Destination) == "CFrame" then
            tpObject.CFrame = Destination*Settings.TeleportOffset
            return
        elseif typeof(Destination) == "Instance" then
            tpObject.CFrame = Destination.CFrame*Settings.TeleportOffset
            return
        end
    end
end
return module