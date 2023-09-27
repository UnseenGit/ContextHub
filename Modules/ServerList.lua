local Square = "■"
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
local ContextMenus = LoadModule("ContextMenus")
local Util = LoadModule("Util")
local module = {}
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
if not isfile("UUIDCOLORS.json") then writefile("UUIDCOLORS.json",'{"CreationTime": '..os.time()..'}') end
local function UUIDToColor3(UUID)
    local UUIDCOLORS = Util.readJSON("UUIDCOLORS.json")
    if UUIDCOLORS.CreationTime < os.time() - (60*60*12) then
        writefile("UUIDCOLORS.json",'{"CreationTime": '..os.time()..'}')
        UUIDCOLORS = Util.readJSON("UUIDCOLORS.json")
    end
    if UUIDCOLORS[UUID] then
        return Color3.fromHex(UUIDCOLORS[UUID])
    end
    local RandomColor = Color3.fromHSV(math.random(0,255)/255,math.random(0,255)/255,math.random(20,255)/255)
    UUIDCOLORS[UUID] = RandomColor:ToHex()
    Util.writeJSON("UUIDCOLORS.json", UUIDCOLORS)
    return RandomColor
end
function module.OpenServerList(_PlaceId)
    local succ, err = pcall(function()
        if not _PlaceId then _PlaceId = game.PlaceId end
        local i = 0
        local ServerList = Util.GetServerList(_PlaceId).data
        for _, v in pairs(ServerList) do
            UUIDToColor3(v.id)
        end
        table.sort(ServerList, function(a,b)
            local Ca = UUIDToColor3(a.id)
            local Cb = UUIDToColor3(b.id)
            Ca = Ca.R*Ca.G*Ca.B
            Cb = Cb.R*Cb.G*Cb.B
            return Ca < Cb 
        end)
        local ServerListBox = ContextMenus.CreateTextBox({
            TextBox = {
                Title = {Text = "ServerList"}
            }
        }, "ServerList")
        local canscroll = true
        i = #ServerList
        coroutine.wrap(function()
            while wait() do
                xpcall(function()
                    if canscroll and i > 0 then
                        for loop = 1, 100 do
                            local v = ServerList[i]
                            if v and v.id then
                                local msg = '<font color="#'..UUIDToColor3(v.id):ToHex()..'">'..Square.."</font> | "..v.playing.."/"..v.maxPlayers.." | "..string.sub(v.ping.." Ping    ", 1,9).."| FPS: "..v.fps
                                if v.id == game.JobId then
                                    msg = msg..' <font color="#494c52">(Current Server)</font>'
                                end
                                local function AddEntry(msg)
                                    ServerListBox.AddEntry(
                                        {
                                            NoRenderStep = true
                                        }, 
                                        msg,
                                        {
                                            M2Func = function()
                                                ContextMenus.Create(
                                                    {
                                                        FrameAnchorPoint = Util.CMAnchorPoint(),
                                                        Position = UDim2.fromOffset(game:GetService("UserInputService"):GetMouseLocation().X,game:GetService("UserInputService"):GetMouseLocation().Y),
                                                        ContextMenuEntries = {
                                                            TextSize = 12
                                                        }
                                                    },
                                                    {
                                                        Text = "Copy...",
                                                        Submenu = {
                                                            {
                                                                Text = "JobId",
                                                                M1Func = function()
                                                                    setclipboard(v.id)
                                                                end
                                                            }
                                                        }
                                                    },
                                                    {
                                                        Text = "Join",
                                                        M1Func = function()
                                                            game:GetService("TeleportService"):TeleportToPlaceInstance(_PlaceId, v.id, LP)
                                                        end
                                                    },
                                                    (function()
                                                        if table.find({"85697719", "2401702160"}, tostring(game.PlaceId)) and table.find({"85697719", "2401702160"}, tostring(_PlaceId)) then 
                                                            return {
                                                                Text = "Join with morph",
                                                                M1Func = function()
                                                                    local OCSaver = loadfile("OCSaver.lua")()
                                                                    local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport
                                                                    local queue = 'print(pcall(function()\ngame:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()'
                                                                    local RejoinOC = OCSaver.OCToTable(LP)
                                                                    RejoinOC.Info.LastPos = LP.Character.HumanoidRootPart.CFrame
                                                                    queue = queue.."\nif not game:IsLoaded() then game.Loaded:Wait() end\nlocal LP = game:GetService(\"Players\").LocalPlayer\nrepeat wait() until LP.PlayerGui:FindFirstChild\"Loader\"\nlocal Morph = "..Util.DatatypeToConstructor(RejoinOC).."\nwait(.3)\nLP.PlayerGui.Loader.PassedCharacterCreation.Value = true\nLP.PlayerGui.Loader.PassedLoading.Value = true\nLP.PlayerGui.Loader.PassedRules.Value = true\nLP.PlayerGui.Loader.MainScreen.Visible = false\nLP.PlayerGui.GameMENU.Enabled = true\nloadfile(\"OCSaver.lua\")().MorphFromTable(Morph)\nloadfile(\"functions.lua\")().TeleportTo(Morph.Info.LastPos, {TeleportOffset = CFrame.new(0,0,0)})\nend))"
                                                                    if queue_on_teleport then
                                                                        print(pcall(function()
                                                                            queue_on_teleport(queue)
                                                                        end))
                                                                    end
                                                                    game:GetService("TeleportService"):TeleportToPlaceInstance(_PlaceId, v.id, LP)
                                                                end
                                                            }
                                                        end
                                                    end)()
                                                )
                                            end
                                        }
                                    )
                                end
                                AddEntry(msg)
                                i=i-1
                            end
                        end
                    end
                    if ServerListBox.Instance:FindFirstChild("EntryList") then
                        if ServerListBox.Instance.EntryList.CanvasPosition.Y >
                            ServerListBox.Instance.EntryList.AbsoluteCanvasSize.Y - 1000 then
                            canscroll = true
                        else
                            canscroll = false
                        end
                    end
                end,warn)
            end
        end)()
        local Refresh = ServerListBox.AddButton({}, "Refresh", {
            M1Func = function()
                ServerList = Util.GetServerList(_PlaceId).data
                table.sort(ServerList, function(a,b)
                    local Ca = UUIDToColor3(a.id)
                    local Cb = UUIDToColor3(b.id)
                    Ca = Ca.R*Ca.G*Ca.B
                    Cb = Cb.R*Cb.G*Cb.B
                    return Ca < Cb 
                end)
                i = 0
                wait()
                ServerListBox.ClearList()
                wait()
                i = #ServerList
            end
        })
    end)
    if err then rconsoleprint("\n[*ERROR*]".."ServerList.lua error: "..err) end
end
return module