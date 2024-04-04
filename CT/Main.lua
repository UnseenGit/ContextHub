if not game:IsLoaded() then game.Loaded:Wait() end

-----INFERIOR EXECUTOR FIXES

getcustomasset = getcustomasset or function() return "rbxassetid://15550979444" end
queue_on_teleport = queue_on_teleport or function() end




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
local Util = LoadModule("Util")
local ContextMenus = LoadModule("ContextMenus")
local Functions = LoadModule("UtilFunctions")
local InstanceSerializer = LoadModule("ObjectSerializer")
local ConfigModule = LoadModule("ConfigModule")
local SerializedInstances = {}
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local LPChar = LP.Character
local LPHRP = LPChar and (LPChar:FindFirstChild("HumanoidRootPart") or LPChar:FindFirstChildWhichIsA("BasePart"))
LP.CharacterAdded:Connect(function(Char)
    LPChar = Char
    LPHRP = LPChar and (LPChar:FindFirstChild("HumanoidRootPart") or LPChar:FindFirstChildWhichIsA("BasePart"))
end)        
local _ALLOWEDEXECS = {}
local _INVIS = "­"
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local ChatService = game:GetService("Chat")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local MaterialService = game:GetService("MaterialService")
local Mouse = game:GetService("Players").LocalPlayer:GetMouse()
local ESP = false
local Aimbot = false
local AimbotTarget, AimPart
if not isfile("StaffGroups.json") then writefile("StaffGroups.json", "[]") end
local StaffGroups = Util.readJSON("StaffGroups.json")[tostring(game.PlaceId)]
local ZoomMax, ZoomMin = LP.CameraMaxZoomDistance, LP.CameraMinZoomDistance
local request = request or syn.request
local MouseLocation = UserInputService:GetMouseLocation()
local Autocomplete
local Commands
local AddLogEntry
local infiniteJump = false
local CurrentFov = workspace.CurrentCamera.FieldOfView
local StartFov = workspace.CurrentCamera.FieldOfView
local Mouse1Held = false
local Mouse2Held = false
UserInputService.InputBegan:Connect(function(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseButton1 then
        Mouse1Held = true
    elseif inputType == Enum.UserInputType.MouseButton2 then
        Mouse2Held = true
    end
end)    
UserInputService.InputEnded:Connect(function(input)
    local inputType = input.UserInputType
    if inputType == Enum.UserInputType.MouseButton1 then
        Mouse1Held = false
    elseif inputType == Enum.UserInputType.MouseButton2 then
        Mouse2Held = false
    end
end)
local ListsModule = LoadModule("Lists")
local Lists = {} do if ListsModule then Lists = ListsModule.CheckArray(Players:GetChildren()) end end
local Config = ConfigModule:Create("CTCONFIG.lua",{
    RandomIncludeLP = true,
    RandomizeName = true,
    ChatSpy = true,
    OldAccountAgeMin = 356*4,
    NewAccountAgeMax = 14,
    NearDistance = 1000,
    FarDistance = 10000,
    ChatLogLimit = 20000,
    Prefix = ":",
    Keybind = Enum.KeyCode.Semicolon,
    [tostring(game.PlaceId)] = {
        EnvironmentCMs = false,
        QuickChatLogs = true,
        GuiPosition = UDim2.new(0,615,0,45),
        ESP = {
            Style = "Highlight",
            TeamColors = true,
            ShowLP = true,
            ShowName = true,
            ShowDisplayName = true,
            ShowHealth = true,
            TeamType = "all", -- "enemy" "friendly" "select"
            ShowDistance = true,
            UseDetailsDistance = true,
            ShowHealthType = "Scale",
            DefaultColor = Color3.new(1,1,0),
            ListColors = true,
            Keybind = Enum.KeyCode.F3,
            Distance = 20000,
            DetailDistance = 500,
            DistanceDecimalPoints = 1,
            DistanceMode = "Character",
            Details = {
                Health = true,
                Distance = false,
                Name = false,
            }
        },
        Aimbot = {
            Method = "Lock",
            SilentMode = "Raycast",
            FOV = 100,
            IgnoreLists = {},
            IgnoreDead = true,
            IgnoreStaff = false,
            Distance = 1250,
            WallCheck = true,
            AimPart = "Head",
            Keybind = Enum.KeyCode.F4,
            AimKey = Enum.KeyCode.LeftAlt,
            Mouse2Aim = true,
            Mouse1Aim = false,
            TeamType = "all", -- "enemy" "friendly" "select"
            Drop = false,
            DropAmount = 2,
            DropIncrease = 2,
            DropType = "Quad",
            Pred = false,
            PredAmount = 1
        },
        Radar = {
            AutoOpen = true,
            LPColor = Color3.fromRGB(100, 100, 240),
            DefaultColor = Color3.fromRGB(255,255,0),
            FriendlyColor = Color3.fromRGB(100, 220, 100),
            EnemyColor = Color3.fromRGB(220, 50, 50),
            ListColors = true,
            ColorType = "Team", --Ally, Team, None
            PlayerSize = 6,
            BackgroundColor = Color3.fromHex("#1e2024"),
            BorderColor = Color3.fromHex("#323336"),
            Transparency = 0.5,
            Shape = "Round",
            BorderThickness = 3,
            BorderTransparency = 0,
            Size = UDim2.fromOffset(150,150),
            Position = UDim2.new(0,1500,0,0),
            PositionLocked = false,
            Axis = "Dot", --Dot, Line, None
            AxisDir = 0, 
            ShowElevation = true,
            ElevationTreshold = 10,
            ElevationFade = 100,
            Rotation = "Camera", --Fixed, CameraSubject, Camera
            PositionPart = "CameraSubject", --CameraSubject, Camera, Character 
            FixedDegree = 0,
            LookVector = "None", --None, Line, Cone,
            ConeDegree = 0, --0 for LP camera fov, number for degrees
        },
        LocalChatLogDist = 20,
        TeleportOffset = CFrame.new(0,0,-5)*CFrame.Angles(math.rad(0),math.rad(180),math.rad(0)),
        BringTeleportOffset = CFrame.new(0,0,-5)*CFrame.Angles(math.rad(0),math.rad(180),math.rad(0))
    },
    [tostring(LP.UserId)] = {
        NameHidden = false
    },
})
local ESPHealthDisplayTypes = {
    "Scale",
    "Number",
    "Color",
    "Bar",
}
local WPs = ConfigModule:Create("SAVEDPOSITIONS.lua",{
    [tostring(game.PlaceId)] = {}
})


local StaffRanks
local function GetStaffLists(groupId, rank)
    Util.Notify("Updating StaffList, might lag a little", "StaffList Download", 3)
    local function GetGroupRoles(groupid)
        return Util.JSONRequest("https://groups.roblox.com/v1/groups/" ..groupid .."/roles/")
    end
    local function GetGroupRoleMembers(groupid, roleid)
        local members = {}
        local _API = Util.JSONRequest("https://groups.roblox.com/v1/groups/" ..groupid .."/roles/" ..roleid .."/users?limit=100")
        for i, v in pairs(_API.data) do table.insert(members, v) end
        if _API.nextPageCursor then
            while _API.nextPageCursor do
                wait(1)
                local _Cursor = _API.nextPageCursor
                _API = Util.JSONRequest("https://groups.roblox.com/v1/groups/" ..groupid .."/roles/" ..roleid .."/users?limit=100&cursor=" .._Cursor)
                for i, v in pairs(_API.data) do
                    table.insert(members, v)
                end
            end
        end
        return members
    end
    local Roles = {}
    local _api = GetGroupRoles(groupId)
            wait(.2)
    for _, v in pairs(_api.roles) do
        if tonumber(v.rank) >= tonumber(rank) then
            Roles[v.name] = GetGroupRoleMembers(_api.groupId, v.id)
            wait(.2)
        end
    end
    Util.Notify("Finished updating StaffList", "StaffList Download", 3)
    return Roles
end
local function UpdateStaff()
    coroutine.wrap(function() StaffRanks = GetStaffLists(StaffGroups.GroupId, StaffGroups.Rank) end)()
end
if StaffGroups then
    UpdateStaff()
end

local function ChangeStaffGroupPrompt()
    local GroupId, Rank = "", ""
    if StaffGroups then
        GroupId, Rank = StaffGroups.GroupId, StaffGroups.Rank
    end
    xpcall(function()
        ContextMenus.Prompt(
            {
                Content = {
                    {
                        ClassName = "TextBox",
                        Size = UDim2.new(1,0,0,28),
                        Text = GroupId,
                        TextSize = 24,
                        PlaceholderText = "Group ID",
                        TextYAlignment = Enum.TextYAlignment.Center,
                        TextColor3 = Color3.fromHex("9cdcfe"),
                        InitFunction = function(self, prompt, settings)
                            self.FocusLost:Connect(function()
                                GroupId = self.ContentText
                            end)
                        end
                    },
                    {
                        ClassName = "TextBox",
                        Size = UDim2.new(1,0,0,28),
                        Position = UDim2.new(0,0,0,32),
                        TextColor3 = Color3.fromHex("9cdcfe"),
                        Text = Rank,
                        TextSize = 24,
                        TextYAlignment = Enum.TextYAlignment.Center,
                        PlaceholderText = "Minimum Rank",
                        InitFunction = function(self, prompt, settings)
                            self.FocusLost:Connect(function()
                                Rank = self.ContentText
                            end)
                        end
                    }
                },
                Settings = {
                    Focus = false, 
                    ButtonAlignment = "Right", 
                    ReturnType = "Object",
                    Title = {
                        Text = "Set Staff Group"
                    },
                    Content = {ClipsDescendants = false}
                },
                Buttons = {
                    {
                        Text = "Set", 
                        M1Func = function(prompt)
                            local File = Util.readJSON("StaffGroups.json")
                            File[tostring(game.PlaceId)] = {
                                GroupId = GroupId,
                                Rank = Rank
                            }
                            Util.writeJSON("StaffGroups.json", File)
                            StaffGroups = File[tostring(game.PlaceId)]
                            UpdateStaff()
                        end
                    },
                    {
                        Text = "Cancel"
                    }
                }
            }
        ) 
    end,warn)
end

local function CheckStaff(Player)
    if not StaffRanks then return false end
    if not tostring(tonumber(Player)) then
        if typeof(Player) == "Instance" and Player:IsA("Player") then
            Player = tostring(Player.UserId)
        end
    end
    for Rank, Members in pairs(StaffRanks) do
        for _, Member in pairs(Members) do
            if tostring(Member.userId) == tostring(Player) then
                return Rank
            end
        end
    end
end

local ESPTeams = {}
local AimbotTeams = {}
local function GetAimbotTargets()
    local Set = Config[tostring(game.PlaceId)].Aimbot
    local out = {}
    for _, Player in pairs(Players:GetPlayers()) do
        if Player == LP then continue end
        if Set.TeamType == "all" or (Set.TeamType == "enemy" and Player.Team ~= LP.Team) or (Set.TeamType == "friendly" and Player.Team == LP.Team) or (Set.TeamType == "select" and AimbotTeams[v.Team.Name] ) then
            table.insert( out, Player )
        end
    end
    return out
end

local function GetAimbotPart(Player)
    if not Player then return end
    local Set = Config[tostring(game.PlaceId)].Aimbot
    local Char = Player.Character
    if Char then
        return Char:FindFirstChild(Set.AimPart)
    end
end

local function CheckIfPlayerBehindWall(Target)
    local Set = Config[tostring(game.PlaceId)].Aimbot
    if not Target then return false end
    local Part = workspace:FindPartOnRayWithIgnoreList(Ray.new(LP.Character.Head.Position, (Target.Position - LP.Character.Head.Position).Unit*Set.Distance), {LP.Character}, false, true)
    local Child = Part
    if Child and LP.Character then
        repeat
            Child = Child.Parent
        until Child.Parent == LP.Character.Parent or (not Child.Parent)
    end
    --warn(Child)
    local Humanoid = Child and Child:FindFirstChild("Humanoid")
    if Humanoid then
        for _, v in pairs(Humanoid.Parent:GetDescendants()) do
            if v == Target then
                local _, Visible = workspace.CurrentCamera:WorldToScreenPoint(Target.Position)
                return Visible
            end
        end
    end
end

local function GetPlayerClosestToMouse()
    local Set = Config[tostring(game.PlaceId)].Aimbot
    local Target, Part
    local ClosestTarget = Set.FOV+1
    local TargetList = GetAimbotTargets()
    --Util.print(TargetList)
    local function CheckSkip(Player)
        local Notify = false
        local Char = Player.Character
        if (not Char) or (not LPChar) then return true, Notify and warn("Skipping", Player, "No Character") 
        elseif Player == LP then return true, Notify and warn("Skipping", Player, "is Local")
        elseif (not Char:FindFirstChild("HumanoidRootPart")) or (not Char:FindFirstChild("Humanoid")) then return true, Notify and warn("Skipping", Player, "Humanoid/HumanoidRootPart not found")
        elseif Set.IgnoreStaff and CheckStaff(Player) then return true, Notify and warn("Skipping", Player, "is Staff")
        elseif ((LP.Character.HumanoidRootPart.CFrame.Position - Player.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude) > Set.Distance then return true, Notify and warn("Skipping", Player, "Too far")
        elseif ListsModule and Lists and Lists[tostring(Player.UserId)] and Set.IgnoreLists[Lists[tostring(Player.UserId)]] then return true, Notify and warn("Skipping", Player, "is Listed")
        elseif Set.WallCheck and not CheckIfPlayerBehindWall(GetAimbotPart(Player)) then return true, Notify and warn("Skipping", Player, "is Behind Wall")
        elseif Set.IgnoreDead and Char.Humanoid.Health <= 0 then return true
        else return false
        end
    end
    for _, Player in pairs(TargetList) do 
        --print(Player)
        if CheckSkip(Player) then
            continue
        end
        local Pos, Vis = workspace.CurrentCamera:WorldToViewportPoint(GetAimbotPart(Player).Position)
        local Dist = (Vector2.new(Pos.X,Pos.Y)-MouseLocation).Magnitude
        if Vis and Dist < Set.FOV and Dist < ClosestTarget then 
            --print(Player)
            ClosestTarget = Dist
            Target, Part = Player, GetAimbotPart(Player)
        end
    end
    return Target, Part
end

local function GetESPDistance(Player)
    if Player.Character == nil or Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") == nil then return math.huge, false end
    local DistancePart do 
        if Config[tostring(game.PlaceId)].ESP.DistanceMode == "Character" then
            DistancePart = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        elseif Config[tostring(game.PlaceId)].ESP.DistanceMode == "Camera" then
            DistancePart = workspace.CurrentCamera
        end
    end
    return DistancePart and (DistancePart.CFrame.Position - Player.Character:FindFirstChild("HumanoidRootPart").Position).Magnitude or math.huge, false
end
local function GetESPText(Player)
    local set = Config[tostring(game.PlaceId)].ESP
    local str = ""
    local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
    local Distance = GetESPDistance(Player)
    local DetailsVisible = (not set.UseDetailsDistance) or Distance < set.DetailDistance
    if (Config[tostring(game.PlaceId)].ESP.Details.Name and DetailsVisible) or not Config[tostring(game.PlaceId)].ESP.Details.Name then
        if set.ShowName or set.ShowDisplayName then
            if set.ShowName and set.ShowDisplayName and Player.Name ~= Player.DisplayName then
                str = `{Player.DisplayName} (@{Player.Name})`
            elseif set.ShowName or set.ShowDisplayName then
                str = set.ShowDisplayName and Player.DisplayName or Player.Name
            end
        end
        if set.ShowHealth or set.ShowDistance then
            str = str.."\n"
        end
    end
    if (Config[tostring(game.PlaceId)].ESP.Details.Health and DetailsVisible) or not Config[tostring(game.PlaceId)].ESP.Details.Health then
        if Humanoid and set.ShowHealth and table.find({"Scale", "Number"}, set.ShowHealthType) then
            str = `{str}{Humanoid.Health}`
        end
        if Humanoid and set.ShowHealth and set.ShowHealthType == "Scale" then
            str = str.."/"..Humanoid.MaxHealth
        end
    end
    if (Config[tostring(game.PlaceId)].ESP.Details.Distance and DetailsVisible) or not Config[tostring(game.PlaceId)].ESP.Details.Distance then
        if set.ShowDistance and Player ~= LP then
            str = `{str} ↔{Util.round(Distance, set.DistanceDecimalPoints)}`
        end
    end
    if __EspTextModify then
        str = __EspTextModify(str)
    end
    return str
end
if not _G.ChatLogs then _G.ChatLogs = {} end
local credits = {
    "--- <b>ContextTerminal</b> ---",
    "Developed by The Unseen",
    "Design: GREENERY_101",
    "Functionality: GREENERY_101, i_mNoAstronaut",
    "Commands: GREENERY_101, i_mNoAstronaut",
    "Plugins: i_mNoAstronaut, GREENERY_101"
}

local function setclipboardint(str)
    setclipboard(tostring(str))
end

local function CheckIfInvokerAllowed(Invoker)
    if table.find(_ALLOWEDEXECS, Invoker) then return true end
end

local function CheckIfVisible(part)
    local _, vis = workspace.CurrentCamera:WorldToViewportPoint(part.Position)
    return vis
end

local function FakeChat(Player, Message)
    local HRP = Player.Character:FindFirstChild("Head")
    if HRP then ChatService:Chat(HRP, _INVIS .. Message, 2) end
end

local function UnlockCamera()
    LP.CameraMode = 'Classic'
    LP.CameraMaxZoomDistance = 1000000
    LP.CameraMinZoomDistance = 0
    UserInputService.inputBegan:Connect(function(input) 
        xpcall(function()
            if input.KeyCode == Enum.KeyCode.LeftAlt then
                LP.CameraMaxZoomDistance = (workspace.CurrentCamera.CoordinateFrame.p - workspace.CurrentCamera.Focus.p).magnitude
                LP.CameraMinZoomDistance = (workspace.CurrentCamera.CoordinateFrame.p - workspace.CurrentCamera.Focus.p).magnitude
                repeat wait() until not UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt)
                LP.CameraMaxZoomDistance = 1000000
                LP.CameraMinZoomDistance = 0
            end
            if input.UserInputType == Enum.UserInputType.MouseButton3 then
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
                    TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {FieldOfView = StartFov}):Play()
                end
            end
        end,warn)
    end)
    Mouse.WheelForward:Connect(function() 
        xpcall(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
                CurrentFov = math.max(math.round(CurrentFov)-5,5)
                TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {FieldOfView = CurrentFov}):Play()
            end
        end,warn)
    end)
    Mouse.WheelBackward:Connect(function() 
        xpcall(function()
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) then
                CurrentFov = math.min(math.max(math.round(CurrentFov)+5,5),120)
                TweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.40, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {FieldOfView = CurrentFov}):Play()
            end
        end,warn)
    end)
end

local ListColors = {
    Blacklist = Color3.new(0.8, 0.8, 0),
    Whitelist = Color3.new(0, 0.9, 0.9),
    Staff = Color3.fromHex("ed1c24"),
    SoftWhitelist = Color3.new(0.7, 1, 1)
}
local ListImages = {
    Blacklist = {
        Image = "rbxassetid://13916216483",
        ImageRectSize = Vector2.new(0,0),
        ImageRectOffset = Vector2.new(0,0)
    },
    Whitelist = {
        Image = "rbxassetid://13916215200",
        ImageRectSize = Vector2.new(0,0),
        ImageRectOffset = Vector2.new(0,0)
    },
    SoftWhitelist = {
        Image = "rbxassetid://13916215200",
        ImageRectSize = Vector2.new(0,0),
        ImageRectOffset = Vector2.new(0,0)
    },
    Staff = {
        Image = "rbxassetid://13916217584",
        ImageRectSize = Vector2.new(0,0),
        ImageRectOffset = Vector2.new(0,0)
    }
}
local function GenListSubMenu(UserId)
    if not Lists then return end
    UserId = tostring(UserId)
    local out = {}
    for _, List in pairs({"Whitelist", "SoftWhitelist", "Blacklist"}) do
        table.insert(out,{
            Text = List,
            Type = "CheckBox",
            Name = List,
            IsAChoice = true,
            Value = Lists[UserId] == List,
            OnUnchecked = function()
                Lists[UserId] = nil
                Util.Notify(ListsModule.RemoveFromList({
                    UserId = UserId,
                    List = List
                }))
            end,
            OnChecked = function()
                Lists[UserId] = List
                Util.Notify(ListsModule.AddToList({
                    UserId = UserId,
                    List = List
                }))
            end
        })
    end
    return out
end
if ListsModule then
    coroutine.wrap(function()
        while wait(10) do
            xpcall(function() 
                while wait(120) do
                    Lists = ListsModule.CheckArray(Players:GetChildren())
                end
            end,warn)
        end
    end)()
end
local ChatInit do
    pcall(function()
        ChatInit = ReplicatedStorage.DefaultChatSystemChatEvents.GetInitDataRequest
    end)
end
local ChatDoneFiltering do
    pcall(function()
        ChatDoneFiltering = ReplicatedStorage.DefaultChatSystemChatEvents.OnMessageDoneFiltering
    end)
end
local function BuildPacket(Message, Player, ExtraData)
    return {
        ["IsFilterResult"] = true,
        ["MessageLength"] = #Message,
        ["SpeakerUserId"] = Player.UserId,
        ["SpeakerDisplayName"] = Player.DisplayName,
        ["OriginalChannel"] = "All",
        ["Message"] = Message,
        ["FromSpeaker"] = Player.Name,
        ["Time"] = os.time(),
        ["MessageLengthUtf8"] = #Message,
        ["ID"] = _G.ChatLogs and _G.ChatLogs[#_G.ChatLogs] and _G.ChatLogs[#_G.ChatLogs].ID+1 or 0,
        ["IsFiltered"] = true,
        ["ExtraData"] = ExtraData or {},
        ["MessageType"] = "Message"
     }
end
coroutine.wrap(function()
    game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents")
    if ChatInit then
        local Channels = ChatInit:InvokeServer().Channels
        for _, Channel in pairs(Channels) do
            if Channel[1] == "All" then
                for _, Message in pairs(Channel[3]) do
                    table.insert(_G.ChatLogs, Message)
                end
            end
        end
    end
    local function AddLog(packet)
        if #_G.ChatLogs > Config.ChatLogLimit then
            while #_G.ChatLogs > Config.ChatLogLimit do
                table.remove(_G.ChatLogs, 1)
            end
        end
        table.insert(_G.ChatLogs, packet)
    end
    local LogTracker = {
        Chatted = {},
        Event = {}
    }
    local function ConnectWhisperLog(Player)
        Player.Chatted:Connect(function(msg)
            AddLog(BuildPacket(msg,Player))
            if Config.ChatSpy and table.find({"/w","/whisper"},msg:split(" ")[1]) then
                game.StarterGui:SetCore( "ChatMakeSystemMessage",  { Text = "["..Player.Name.." >> "..msg:split(" ")[2].."]:"..table.concat( msg:split(" "), " ", msg:split(" ")[3] == "" and 4 or 3 ), Color = Color3.fromRGB( 200,255,255 ), Font = Enum.Font.Arial, FontSize = 16 } )
                FakeChat(Player, "To "..msg:split(" ")[2].." >> "..table.concat( msg:split(" "), " ", msg:split(" ")[3] == "" and 4 or 3 ))
            end
            if Config.ChatSpy and table.find({"/e"},msg:split(" ")[1]) then
                game.StarterGui:SetCore( "ChatMakeSystemMessage",  { Text = "["..Player.Name.."]:"..table.concat( msg:split(" "), " ", 2 ), Color = Color3.fromRGB( 200,255,255 ), Font = Enum.Font.Arial, FontSize = 16 } )
            end
        end)
    end
    for _, v in pairs(Players:GetPlayers()) do
        ConnectWhisperLog(v)
    end
    Players.PlayerAdded:Connect(ConnectWhisperLog)
end)()
local function GetChatLogs(num)
    if num and _G.ChatLogs then
        local out = {}
        for i = #_G.ChatLogs-num, #_G.ChatLogs do
            table.insert(out, _G.ChatLogs[i])
        end
        return out
    else
        return _G.ChatLogs or {}
    end
end
local function ApplyProperties(obj, props)
    for i, v in pairs(props) do
        xpcall(function()
            obj[i] = v
        end,warn)
    end
    return obj
end
local function CreateObject(class, props)
    return ApplyProperties(Instance.new(class),props)
end

pcall(function()
    CoreGui:FindFirstChild("CT"):Destroy()
end)

local ScreenGui = CreateObject("ScreenGui", {
    Name = "CT",
    DisplayOrder = 2,
    ResetOnSpawn = false,
    Parent = CoreGui
})
local function WrapError(Name, func)
    return xpcall(func,function(err)
        local Traceback = debug.traceback()
        ContextMenus.Prompt({
            Content = err,
            Settings = {
                Title = {Text = Name},
                Focus = false, 
                ButtonAlignment = "Right", 
                ReturnType = "object"
            },
            Buttons = {
                {
                    Text = "Print Traceback", 
                    M1Func = function(prompt)
                        warn("Traceback for "..Name..":\n"..Traceback)
                    end
                },
                {
                    Text = "Dismiss"
                }
            }
        })
    end)
end
RunService.RenderStepped:connect(function()
	MouseLocation = UserInputService:GetMouseLocation()
end)
local BubbleChat = game:GetService("CoreGui"):FindFirstChild("BubbleChat")
if BubbleChat then
    local function CheckBubble(v)
        if v:IsA("Frame") then
            if string.find(v.Frame.Text.Text, _INVIS) then
                v.Frame.BackgroundColor3 = Color3.new(0.5, 0.5, 0.9)
                if v:FindFirstChild("Carat") then
                    v.Carat.BackgroundColor3 = Color3.new(0.5, 0.5, 0.9)
                    v.Carat.ImageColor3 = Color3.new(0.5, 0.5, 0.9)
                end
            end
        end
    end
    BubbleChat.DescendantAdded:Connect(function(Child)
        if Child:IsA("Frame") and Child.Name:sub(1,6):lower() == "bubble" and Child:FindFirstChild("Frame") then
            CheckBubble(Child)
        end
    end)
end

local callSigns = {}
local Chars = "abcdefghijklmnopqrstuvwxyz"
local function GetCallSign(name)
    if callSigns[name] then return callSigns[name] end
    filtered = name:split("")
    for i, v in pairs(filtered) do
        if not Chars:find(v:lower()) then
            table.remove(filtered, i)
        end
    end
    filtered = table.concat(filtered, "")
    local FirstChar = filtered:sub(1,1)
    local SecondChar = filtered:sub(2,2)
    local function CheckName(name)
        for _, v in pairs(callSigns) do
            if name:lower() == v:lower() then
                return false
            end
        end
        return true
    end
    local CallSign = FirstChar..SecondChar
    local i = 1
    while not CheckName(CallSign) and i<#filtered do
        i = i+1
        SecondChar = filtered:sub(i,i)
        CallSign = FirstChar..SecondChar
    end
    if not CheckName(CallSign) then
        local i = 1
        SecondChar = i
        CallSign = FirstChar..SecondChar
        while not CheckName(CallSign) do
            i = i+1
            SecondChar = i
            CallSign = FirstChar..SecondChar
        end
    end
    callSigns[name] = CallSign:upper()
    return CallSign:upper()
end
local RadarConns = {}
local function CreateRadar()
    local RadarFrame = CreateObject("ImageLabel",{
        Position = Config[tostring(game.PlaceId)].Radar.Position,
        Size = Config[tostring(game.PlaceId)].Radar.Size,
        BackgroundTransparency = Config[tostring(game.PlaceId)].Radar.Transparency,
        BackgroundColor3 = Config[tostring(game.PlaceId)].Radar.BackgroundColor,
        Parent = ScreenGui,
        Name = "CTR",
        ClipsDescendants = true
    })
    local RadarButton = CreateObject("TextButton",{
        Text = "",
        Parent = RadarFrame,
        Transparency = 1,
        Size = UDim2.fromScale(1,1)
    })
    local UICorner = CreateObject("UICorner",{
        CornerRadius = UDim.new(Config[tostring(game.PlaceId)].Radar.Shape == "Round" and 0.5 or 0.03,0),
        Parent = RadarFrame
    })
    local UIStroke = CreateObject("UIStroke",{
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Color = Config[tostring(game.PlaceId)].Radar.BorderColor,
        LineJoinMode = Enum.LineJoinMode.Round,
        Thickness = Config[tostring(game.PlaceId)].Radar.BorderThickness,
        Transparency = Config[tostring(game.PlaceId)].Radar.BorderTransparency,
        Parent = RadarFrame
    })
    local PlayerDisplayFrame = CreateObject("Frame",{
        Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.fromOffset(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = RadarFrame,
        Name = "PlayerDisplayFrame",
        AnchorPoint = Vector2.new(0.5,0.5)
    })
    local PlayerDisplay = CreateObject("Frame",{
        Position = UDim2.fromScale(0.5,0.5),
        Size = UDim2.fromScale(1,1),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = PlayerDisplayFrame,
        Name = "PlayerDisplay",
        AnchorPoint = Vector2.new(0.5,0.5)
    })
    local Icons = CreateObject("Folder",{
        Name = "Players",
        Parent = PlayerDisplay
    })
    local CurrentZoom = 1
    local UIPageLayout = CreateObject("UIPageLayout",{
        Circular = true,
        Animated = false,
        Parent = RadarButton
    })
    for i = 1, 3 do
        CreateObject("Frame",{
            Size = UDim2.new(0,0,0,0),
            Transparency = 1,
            Parent = RadarButton,
            Name = i
        })
    end
    local LastPage = UIPageLayout.CurrentPage.Name
    local order = {
        ["1"] = "2",
        ["2"] = "3",
        ["3"] = "1"
    }
    local function Zoom()
        PlayerDisplay:TweenSize(UDim2.fromScale(CurrentZoom,CurrentZoom),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.2,true)
    end
    local Scale = CreateObject("Frame",{
        Size = UDim2.new(0,10,0,2),
        Parent = RadarFrame,
        Name = "Scale",
        AnchorPoint = Vector2.new(1,0),
        Position = Config[tostring(game.PlaceId)].Radar.Shape == "Round" and UDim2.new(0.85,0,0.83,0) or UDim2.new(0.9,0,0.9,0),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0
    })
    local ScaleLabel = CreateObject("TextLabel",{
        Size = UDim2.new(0,0,0,14),
        Parent = Scale,
        BackgroundTransparency = 1,
        Name = "Scale",
        AnchorPoint = Vector2.new(1,1),
        Position = UDim2.new(1,-2,0,-6),
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Arial,
        TextSize = 12,
        TextColor3 = Color3.new(1,1,1),      
        Text = ""
    })
    CreateObject("Frame",{
        Size = UDim2.new(0,2,0,6),
        Parent = Scale,
        Name = "ScaleEnd",
        AnchorPoint = Vector2.new(1,1),
        Position = UDim2.new(1,0,0,0),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0
    })
    CreateObject("Frame",{
        Size = UDim2.new(0,2,0,6),
        Parent = Scale,
        Name = "ScaleEnd",
        AnchorPoint = Vector2.new(0,1),
        Position = UDim2.new(0,0,0,0),
        BackgroundColor3 = Color3.new(1,1,1),
        BorderSizePixel = 0
    })
    local Dividers = {}
    for i = 1, 9 do     
        table.insert(Dividers,CreateObject("Frame",{
            Size = UDim2.new(0,1,0,3),
            Parent = Scale,
            Name = "ScaleEnd",
            AnchorPoint = Vector2.new(0,1),
            Position = UDim2.new(i/10,0,0,0),
            BackgroundColor3 = Color3.new(1,1,1),
            BorderSizePixel = 0,
            Visible = false
        }))
    end
    do
        local Unit = PlayerDisplay.Size.X.Scale
        local Mul = 1
        if Mul*Unit < RadarFrame.AbsoluteSize.X/15 then
            repeat Mul = Mul*10 until Mul*Unit > RadarFrame.AbsoluteSize.X/15
        end
        Scale.Size = UDim2.new(0,Mul*Unit,0,2)
        ScaleLabel.Text = Mul
    end
    PlayerDisplay:GetPropertyChangedSignal("Size"):Connect(function()
        local Unit = PlayerDisplay.Size.X.Scale
        local Mul = 1
        if Mul*Unit < RadarFrame.AbsoluteSize.X/15 then
            repeat Mul = Mul*10 until Mul*Unit > RadarFrame.AbsoluteSize.X/15
        end
        Scale.Size = UDim2.new(0,Mul*Unit,0,2)
        ScaleLabel.Text = Mul
        for _, v in pairs(Dividers) do
            v.Visible = Mul*Unit > RadarFrame.AbsoluteSize.X/4
        end
    end)
    UIPageLayout:GetPropertyChangedSignal("CurrentPage"):Connect(function()
        if order[LastPage] == UIPageLayout.CurrentPage.Name then
            --ZoomOut
            if CurrentZoom>0.02 then
                CurrentZoom = CurrentZoom/1.25
            end
        else
            --ZoomIn
            if CurrentZoom<20 then
                CurrentZoom = CurrentZoom*1.25
            end
        end
        LastPage = UIPageLayout.CurrentPage.Name
        Zoom()
    end)
    local function Drag()
        if Config[tostring(game.PlaceId)].Radar.PositionLocked then return end
        local DragOffset = Vector2.new(RadarFrame.Position.X.Offset-MouseLocation.X, RadarFrame.Position.Y.Offset-MouseLocation.Y)
        local Connect = Mouse.Move:Connect(function()
            RadarFrame.Position = UDim2.fromOffset(MouseLocation.X+(DragOffset.X),MouseLocation.Y+(DragOffset.Y))
        end)
        repeat wait() until not Mouse1Held
        Connect:Disconnect()
        Config[tostring(game.PlaceId)].Radar.Position = RadarFrame.Position
        Config:Write()
    end
    RadarConns.Mouseclick1 = RadarButton.MouseButton1Down:Connect(function()
        local Connect
        Connect = Mouse.Move:Connect(function()
            Connect:Disconnect()
            Connect = nil
            Drag()
        end)
        repeat wait() until not Mouse1Held
        if not Connect then return end
        Connect:Disconnect()
        --Clicked
    end)
    RadarConns.Mouseclick2 = RadarButton.MouseButton2Down:Connect(function()
        ContextMenus.Create(
            {
                FrameAnchorPoint = Util.CMAnchorPoint(),
                Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                TitleIcon = Util.GetDataTypeIcon("function"),
                TitleText = "  Radar Settings   "
            },
            {
                Text = "Close Radar",
                M1Func = function()
                    RadarFrame:Destroy()
                end
            },
            {
                Type = "CheckBox",
                Text = "Lock Position",
                Name = "LockPos",
                Value = Config[tostring(game.PlaceId)].Radar.PositionLocked,
                M1Func = function(Value)
                    Config[tostring(game.PlaceId)].Radar.PositionLocked = Value
                    Config:Write()
                end
            },
            {
                Type = "CheckBox",
                Text = "Open Automatically",
                Name = "AutoOpen",
                Value = Config[tostring(game.PlaceId)].Radar.AutoOpen,
                M1Func = function(Value)
                    Config[tostring(game.PlaceId)].Radar.AutoOpen = Value
                    Config:Write()
                end
            },
            {
                Text = "Shape...",
                Submenu = function()
                    return {
                        {
                            Type = "CheckBox",
                            Text = "Round",
                            Name = "Round",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.Shape == "Round",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.Shape = "Round"
                                TweenService:Create(UICorner, TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {CornerRadius = UDim.new(0.5,0)}):Play()
                                Scale:TweenPosition(UDim2.new(0.75,0,0.83,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.2,true)
                                Config:Write()
                            end
                        },
                        {
                            Type = "CheckBox",
                            Text = "Square",
                            Name = "Square",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.Shape == "Square",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.Shape = "Square"
                                TweenService:Create(UICorner, TweenInfo.new(.2,Enum.EasingStyle.Quad,Enum.EasingDirection.Out), {CornerRadius = UDim.new(0.03,0)}):Play()
                                Scale:TweenPosition(UDim2.new(0.9,0,0.9,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,.2,true)
                                Config:Write()
                            end
                        }
                    }
                end
            },
            {
                Type = "CheckBox",
                Text = "Show Elevation",
                Name = "ShowElevation",
                Value = Config[tostring(game.PlaceId)].Radar.ShowElevation,
                M1Func = function(Value)
                    Config[tostring(game.PlaceId)].Radar.ShowElevation = Value
                    Config:Write()
                end
            },
            {
                Type = "Slider",
                Text = "Elevation Treshold",
                Name = "ElevationTreshold",
                ValueDisplay = true,
                MaxValue = 100,
                MinValue = 0,
                MinSliderSize = 200,
                StartingValue = Config[tostring(game.PlaceId)].Radar.ElevationTreshold,
                Rounding = 0,
                OnRelease = function(Value) 
                    Config[tostring(game.PlaceId)].Radar.ElevationTreshold = Value
                    Config:Write()
                end
            },
            {
                Type = "Slider",
                Text = "Elevation Fade",
                Name = "ElevationFade",
                Tooltip = "0 = Off",
                ValueDisplay = true,
                MaxValue = 500,
                MinValue = 0,
                MinSliderSize = 200,
                StartingValue = Config[tostring(game.PlaceId)].Radar.ElevationFade,
                Rounding = -1,
                OnRelease = function(Value) 
                    Config[tostring(game.PlaceId)].Radar.ElevationFade = Value
                    Config:Write()
                end
            },
            {
                Text = "Team Display Type...",
                Submenu = function()
                    return {
                        {
                            Type = "CheckBox",
                            Text = "None",
                            Name = "None",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.ColorType == "None",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.ColorType = "None"
                                Config:Write()
                            end
                        },
                        {
                            Type = "CheckBox",
                            Text = "Ally",
                            Name = "Ally",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.ColorType == "Ally",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.ColorType = "Ally"
                                Config:Write()
                            end
                        },{
                            Type = "CheckBox",
                            Text = "Team Color",
                            Name = "TeamColor",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.ColorType == "Team",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.ColorType = "Team"
                                Config:Write()
                            end
                        }
                    }
                end
            },
            {
                Text = "Rotation...",
                Submenu = function()
                    return {
                        {
                            Type = "CheckBox",
                            Text = "Fixed",
                            Name = "Fixed",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.Rotation == "Fixed",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.Rotation = "Fixed"
                                Config:Write()
                            end,
                            Submenu = function()
                                return {
                                    {
                                        Type = "CheckBox",
                                        Text = "X+",
                                        Name = "X+",
                                        IsAChoice = true,
                                        Value = Config[tostring(game.PlaceId)].Radar.FixedDegree == 270,
                                        OnChecked = function(Value)
                                            Config[tostring(game.PlaceId)].Radar.FixedDegree = 270
                                            Config:Write()
                                        end
                                    },
                                    {
                                        Type = "CheckBox",
                                        Text = "X-",
                                        Name = "X-",
                                        IsAChoice = true,
                                        Value = Config[tostring(game.PlaceId)].Radar.FixedDegree == 90,
                                        OnChecked = function(Value)
                                            Config[tostring(game.PlaceId)].Radar.FixedDegree = 90
                                            Config:Write()
                                        end
                                    },{
                                        Type = "CheckBox",
                                        Text = "Z+",
                                        Name = "Z+",
                                        IsAChoice = true,
                                        Value = Config[tostring(game.PlaceId)].Radar.FixedDegree == 0,
                                        OnChecked = function(Value)
                                            Config[tostring(game.PlaceId)].Radar.FixedDegree = 0
                                            Config:Write()
                                        end
                                    },{
                                        Type = "CheckBox",
                                        Text = "Z-",
                                        Name = "Z-",
                                        IsAChoice = true,
                                        Value = Config[tostring(game.PlaceId)].Radar.FixedDegree == 180,
                                        OnChecked = function(Value)
                                            Config[tostring(game.PlaceId)].Radar.FixedDegree = 180
                                            Config:Write()
                                        end
                                    }
                                }
                            end
                        },
                        {
                            Type = "CheckBox",
                            Text = "Camera",
                            Name = "Camera",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.Rotation == "Camera",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.Rotation = "Camera"
                                Config:Write()
                            end
                        },{
                            Type = "CheckBox",
                            Text = "Camera Subject",
                            Name = "CameraSubject",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.Rotation == "CameraSubject",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.Rotation = "CameraSubject"
                                Config:Write()
                            end
                        },{
                            Type = "CheckBox",
                            Text = "Character",
                            Name = "Character",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.Rotation == "Character",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.Rotation = "Character"
                                Config:Write()
                            end
                        }
                    }
                end
            },
            {
                Text = "Axis...",
                Submenu = function()
                    return {
                        {
                            Type = "CheckBox",
                            Text = "None",
                            Name = "None",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.Axis == "None",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.Axis = "None"
                                Config:Write()
                            end
                        },
                        {
                            Type = "CheckBox",
                            Text = "Dot",
                            Name = "Dot",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.Axis == "Dot",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.Axis = "Dot"
                                Config:Write()
                            end
                        },{
                            Type = "CheckBox",
                            Text = "Line",
                            Name = "Line",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.Axis == "Line",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.Axis = "Line"
                                Config:Write()
                            end
                        },
                        {
                            Type = "Slider",
                            Text = "Direction",
                            Name = "Direction",
                            Tooltip = "0 = Z+",
                            ValueDisplay = true,
                            MaxValue = 359,
                            MinValue = 0,
                            MinSliderSize = 100,
                            StartingValue = Config[tostring(game.PlaceId)].Radar.AxisDir,
                            Rounding = 0,
                            OnRelease = function(Value) 
                                Config[tostring(game.PlaceId)].Radar.AxisDir = Value
                                Config:Write()
                            end
                        }
                    }
                end
            },
            {
                Text = "Look Vector...",
                Submenu = function()
                    return {
                        {
                            Type = "CheckBox",
                            Text = "None",
                            Name = "None",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.LookVector == "None",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.LookVector = "None"
                                Config:Write()
                            end
                        },
                        {
                            Type = "CheckBox",
                            Text = "Line",
                            Name = "Line",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.LookVector == "Line",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.LookVector = "Line"
                                Config:Write()
                            end
                        },{
                            Type = "CheckBox",
                            Text = "Cone",
                            Name = "Cone",
                            IsAChoice = true,
                            Value = Config[tostring(game.PlaceId)].Radar.LookVector == "Cone",
                            OnChecked = function(Value)
                                Config[tostring(game.PlaceId)].Radar.LookVector = "Cone"
                                Config:Write()
                            end
                        },
                        {
                            Type = "Slider",
                            Text = "Cone FOV",
                            Name = "ConeDegree",
                            Tooltip = "0 = Camera FOV",
                            ValueDisplay = true,
                            MaxValue = 180,
                            MinValue = 0,
                            MinSliderSize = 100,
                            StartingValue = Config[tostring(game.PlaceId)].Radar.ConeDegree,
                            Rounding = 0,
                            OnRelease = function(Value) 
                                Config[tostring(game.PlaceId)].Radar.ConeDegree = Value
                                Config:Write()
                            end
                        }
                    }
                end
            },
            {
                Type = "Slider",
                Text = "Dot Size",
                Name = "PlayerSize",
                ValueDisplay = true,
                MaxValue = 10,
                MinValue = 0,
                MinSliderSize = 200,
                StartingValue = Config[tostring(game.PlaceId)].Radar.PlayerSize,
                Rounding = 1,
                OnRelease = function(Value) 
                    Config[tostring(game.PlaceId)].Radar.PlayerSize = Value
                    Config:Write()
                    for _, v in pairs(Icons:GetChildren()) do
                        v.Size = UDim2.fromOffset(Value,Value)
                    end
                end
            },
            {
                Text = "Colors...",
                Submenu = function()
                    return {
                        {
                            Type = "Color3",
                            Mode = "RGB",
                            Text = "LocalPlayer",
                            Color = Config[tostring(game.PlaceId)].Radar.LPColor,
                            OnColorChange = function(Color)
                                Config[tostring(game.PlaceId)].Radar.LPColor = Color
                                Config:Write()
                            end
                        },
                        {
                            Type = "Color3",
                            Mode = "RGB",
                            Text = "Default",
                            Color = Config[tostring(game.PlaceId)].Radar.DefaultColor,
                            OnColorChange = function(Color)
                                Config[tostring(game.PlaceId)].Radar.DefaultColor = Color
                                Config:Write()
                            end
                        },
                        {
                            Type = "Color3",
                            Mode = "RGB",
                            Text = "Friendly",
                            Color = Config[tostring(game.PlaceId)].Radar.FriendlyColor,
                            OnColorChange = function(Color)
                                Config[tostring(game.PlaceId)].Radar.FriendlyColor = Color
                                Config:Write()
                            end
                        },
                        {
                            Type = "Color3",
                            Mode = "RGB",
                            Text = "Enemy",
                            Color = Config[tostring(game.PlaceId)].Radar.EnemyColor,
                            OnColorChange = function(Color)
                                Config[tostring(game.PlaceId)].Radar.EnemyColor = Color
                                Config:Write()
                            end
                        },
                        {
                            Type = "Divider"
                        },
                        {
                            Type = "Color3",
                            Mode = "RGB",
                            Text = "Background Color",
                            Color = Config[tostring(game.PlaceId)].Radar.BackgroundColor,
                            OnColorChange = function(Color)
                                Config[tostring(game.PlaceId)].Radar.BackgroundColor = Color
                                Config:Write()
                            end
                        },
                        {
                            Type = "Slider",
                            Text = "Transparency",
                            Name = "Transparency",
                            ValueDisplay = true,
                            MaxValue = 1,
                            MinValue = 0,
                            MinSliderSize = 100,
                            StartingValue = Config[tostring(game.PlaceId)].Radar.Transparency,
                            Rounding = 1,
                            OnRelease = function(Value) 
                                Config[tostring(game.PlaceId)].Radar.Transparency = Value
                                Config:Write()
                            end
                        },
                        {
                            Type = "Color3",
                            Mode = "RGB",
                            Text = "Border Color",
                            Color = Config[tostring(game.PlaceId)].Radar.BorderColor,
                            OnColorChange = function(Color)
                                Config[tostring(game.PlaceId)].Radar.BorderColor = Color
                                Config:Write()
                            end
                        },
                        {
                            Type = "Slider",
                            Text = "Border Thickness",
                            Name = "BorderThickness",
                            ValueDisplay = true,
                            MaxValue = 10,
                            MinValue = 0,
                            MinSliderSize = 100,
                            StartingValue = Config[tostring(game.PlaceId)].Radar.BorderThickness,
                            Rounding = 1,
                            OnRelease = function(Value) 
                                Config[tostring(game.PlaceId)].Radar.BorderThickness = Value
                                Config:Write()
                            end
                        },
                        {
                            Type = "Slider",
                            Text = "Border Transparency",
                            Name = "BorderTransparency",
                            ValueDisplay = true,
                            MaxValue = 1,
                            MinValue = 0,
                            MinSliderSize = 100,
                            StartingValue = Config[tostring(game.PlaceId)].Radar.BorderTransparency,
                            Rounding = 1,
                            OnRelease = function(Value) 
                                Config[tostring(game.PlaceId)].Radar.BorderTransparency = Value
                                Config:Write()
                            end
                        }
                    }
                end
            }
        )
    end)
    local TriangleId = "rbxassetid://16977390688"
    local function GetColor(Player)
        local set = Config[tostring(game.PlaceId)].Radar
        local Color do 
            if Player == LP then Color = set.LPColor
            elseif set.ListColors and CheckStaff(tostring(Player.UserId)) then Color = ListColors.Staff
            elseif set.ListColors and ListsModule and Lists and Lists[tostring(Player.UserId)] then Color = ListColors[Lists[tostring(Player.UserId)]]
            elseif set.ColorType == "Team" then Color = Player.TeamColor.Color
            elseif set.ColorType == "Ally" then Color = Player.Team == LP.Team and set.FriendlyColor or set.EnemyColor
            else Color = set.DefaultColor end
        end
        return Color
    end
    local function CFrameToYaw(cframe)
        -- Extract rotation matrix
        local _, _, _, _, _, m02, _, _, _, _, _, m22 = cframe:GetComponents()
        return math.deg(math.atan2(m02, m22))-180
    end
    local function CreatePlayerDisplay(Player)
        local function SetPos(Icon, Char)
            local set = Config[tostring(game.PlaceId)].Radar
            local HRP = Char and (Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChildWhichIsA("BasePart"))
            local PosPart
            if set.PositionPart == "Character" then
                PosPart = LPHRP
            elseif set.PositionPart == "Camera" then
                PosPart = workspace.CurrentCamera
            elseif set.PositionPart == "CameraSubject" then
                PosPart = workspace.CurrentCamera.CameraSubject
                if PosPart and not PosPart:IsA("BasePart") then
                    PosPart = PosPart:FindFirstChild("HumanoidRootPart") or PosPart:FindFirstChildWhichIsA("BasePart") or PosPart.Parent:FindFirstChild("HumanoidRootPart")
                end
            end
            if (not PosPart) or (not HRP) then return end
            Icon.Position = UDim2.fromScale(
                PosPart.Position.X-HRP.Position.X+0.5,
                PosPart.Position.Z-HRP.Position.Z+0.5
            )
            if not Icon:FindFirstChild("UICorner") then return end
            if set.ShowElevation then
                local ElevDisc = PosPart.Position.Y-HRP.Position.Y
                if math.abs(ElevDisc) > set.ElevationTreshold then
                    if ElevDisc<0 then
                        Icon.Image = TriangleId
                        Icon.BackgroundTransparency = 1
                        Icon.UICorner.CornerRadius = UDim.new(0,0)
                        Icon.Rotation = 0 - PlayerDisplay.AbsoluteRotation
                    else
                        Icon.Image = TriangleId
                        Icon.BackgroundTransparency = 1
                        Icon.UICorner.CornerRadius = UDim.new(0,0)
                        Icon.Rotation = 180 - PlayerDisplay.AbsoluteRotation
                    end
                    if math.abs(ElevDisc) > set.ElevationFade then
                        Icon.ImageTransparency = ((math.abs(ElevDisc)-set.ElevationFade)/set.ElevationFade)
                    else
                        Icon.ImageTransparency = 0
                    end
                else
                    Icon.ImageTransparency = 0
                    Icon.Image = "rbxassetid://0"
                    Icon.BackgroundTransparency = 0
                    Icon.UICorner.CornerRadius = UDim.new(.5,0)
                    Icon.Rotation = 0 - PlayerDisplay.AbsoluteRotation
                end
            else
                Icon.Image = "rbxassetid://0"
                Icon.BackgroundTransparency = 0
                Icon.UICorner.CornerRadius = UDim.new(.5,0)
                Icon.Rotation = 0 - PlayerDisplay.AbsoluteRotation
            end
        end
        local function ConnChar(Player, Char)
            local set = Config[tostring(game.PlaceId)].Radar
            local HRP = Char and (Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChildWhichIsA("BasePart") or Char:WaitForChild("HumanoidRootPart",2))
            if (not Char) or (not HRP) then return end
            local Color = GetColor(Player)
            local Icon = CreateObject("ImageLabel",{
                Parent = Icons,
                Size = UDim2.fromOffset(set.PlayerSize,set.PlayerSize),
                BorderSizePixel = 0,
                BackgroundColor3 = Color,
                ImageColor3 = Color,
                AnchorPoint = Vector2.new(0.5,0.5),
                Name = Player.Name
            })
            local UICorner = CreateObject("UICorner",{
                CornerRadius = UDim.new(.5,0),
                Parent = Icon
            })
            local function UpdatePos()
                local set = Config[tostring(game.PlaceId)].Radar
                SetPos(Icon, Char)
                if set.Shape == "Round" then
                    Icon.Visible = (PlayerDisplay.AbsolutePosition - Icon.AbsolutePosition-Vector2.new(set.PlayerSize/2,set.PlayerSize/2)).Magnitude < RadarFrame.AbsoluteSize.X/2
                elseif set.Shape == "Square" then
                    local tx = RadarFrame.AbsolutePosition.X-set.PlayerSize/2
                    local ty = RadarFrame.AbsolutePosition.Y-set.PlayerSize/2
                    local bx = tx + RadarFrame.AbsoluteSize.X
                    local by = ty + RadarFrame.AbsoluteSize.Y
                    Icon.Visible = Icon.AbsolutePosition.X >= tx and Icon.AbsolutePosition.Y >= ty and Icon.AbsolutePosition.X <= bx and Icon.AbsolutePosition.Y <= by
                end
                Color = GetColor(Player)
                Icon.BackgroundColor3 = Color
                Icon.ImageColor3 = Color
            end
            local conn = RunService.RenderStepped:Connect(UpdatePos)
            Player.CharacterRemoving:Connect(function()
                conn:Disconnect()
                Icon:Destroy()
            end)
        end
        Player.CharacterAdded:Connect(function(Char)
            ConnChar(Player, Char)
        end)
        if Player.Character then
            ConnChar(Player, Player.Character)
        end
    end
    RadarConns.PlayerAdded = Players.PlayerAdded:Connect(CreatePlayerDisplay)
    for _, Player in pairs(Players:GetChildren()) do
        CreatePlayerDisplay(Player)
    end
    RadarConns.RenderStepped = RunService.RenderStepped:Connect(function()
        local set = Config[tostring(game.PlaceId)].Radar
        local RotPart
        if set.Rotation == "Character" then
            RotPart = LPHRP
        elseif set.Rotation == "Camera" then
            RotPart = workspace.CurrentCamera
        elseif set.Rotation == "CameraSubject" then
            RotPart = workspace.CurrentCamera.CameraSubject
            if RotPart and not RotPart:IsA("BasePart") then
                RotPart = RotPart:FindFirstChild("HumanoidRootPart") or RotPart:FindFirstChildWhichIsA("BasePart") or RotPart.Parent:FindFirstChild("HumanoidRootPart")
            end
        end
        PlayerDisplayFrame.Rotation = RotPart and CFrameToYaw(RotPart.CFrame) or set.FixedDegree
    end)
    RadarFrame.Destroying:Once(function()
        for _, v in pairs(RadarConns) do v:Disconnect() end
    end)
end


local function CheckESPTeam(v)
    if Config[tostring(game.PlaceId)].ESP.TeamType == "all" then
        return true
    elseif Config[tostring(game.PlaceId)].ESP.TeamType == "enemy" and v.Team ~= LP.Team then
        return true
    elseif Config[tostring(game.PlaceId)].ESP.TeamType == "friendly" and v.Team == LP.Team then
        return true
    elseif Config[tostring(game.PlaceId)].ESP.TeamType == "select" and ESPTeams[v.Team.Name] then
        return true
    end
    return false
end

local function GetAimKey()
    local Set = Config[tostring(game.PlaceId)].Aimbot
    return (UserInputService:IsKeyDown(Set.AimKey) or Set.Mouse1Aim and Mouse1Held or Set.Mouse2Aim and Mouse2Held)
end

local function CalculateDropAndPred(AimPart)
    local Set = Config[tostring(game.PlaceId)].Aimbot
    local Pos = AimPart.Position
    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
        local Distance = (LP.Character.HumanoidRootPart.Position - AimPart.Position).Magnitude
        if Set.Drop then
            if Set.DropType == "Linear" then
                Pos = AimPart.Position+Vector3.new(0,(Distance/1000)*Set.DropAmount,0)
            elseif Set.DropType == "LinearInc" then
                local Distance = (LP.Character.HumanoidRootPart.Position - AimPart.Position).Magnitude
                Pos = AimPart.Position+Vector3.new(0,((Distance/1000)*Set.DropAmount)+((Distance/1000)^Set.DropIncrease),0)
            elseif Set.DropType == "Quad" then
                local Distance = (LP.Character.HumanoidRootPart.Position - AimPart.Position).Magnitude
                Pos = AimPart.Position+Vector3.new(0,(Distance^2)/(100000/Set.DropAmount),0)
            end
        end
        if Set.Pred then
            Pos = Pos+(((AimPart.Velocity*Distance)/1000)*Set.PredAmount)
        end
    end
    return Pos
end
local ExpectedArguments = {
    FindPartOnRayWithIgnoreList = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Ray", "table", "boolean", "boolean"
        }
    },
    FindPartOnRayWithWhitelist = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Ray", "table", "boolean"
        }
    },
    FindPartOnRay = {
        ArgCountRequired = 2,
        Args = {
            "Instance", "Ray", "Instance", "boolean", "boolean"
        }
    },
    Raycast = {
        ArgCountRequired = 3,
        Args = {
            "Instance", "Vector3", "Vector3", "RaycastParams"
        }
    }
}
local function ValidateArguments(Args, RayMethod)
    local Matches = 0
    if #Args < RayMethod.ArgCountRequired then
        return false
    end
    for Pos, Argument in next, Args do
        if typeof(Argument) == RayMethod.Args[Pos] then
            Matches = Matches + 1
        end
    end
    return Matches >= RayMethod.ArgCountRequired
end
local oldNameCall
--[[oldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local Method = getnamecallmethod()
    local Args = {...}
    local self = Args[1]
    if Aimbot and Config[tostring(game.PlaceId)].Aimbot.Method == "Silent" and Args[1] == workspace and AimbotTarget and AimPart and not checkcaller() then
        local Set = Config[tostring(game.PlaceId)].Aimbot
        if Method == "FindPartOnRayWithWhitelist" and Set.SilentMode == "FindPartOnRayWithWhitelist" then
            if ValidateArguments(Args, ExpectedArguments.FindPartOnRayWithWhitelist) then
                local oldRay = Args[2]
                local Origin = oldRay.Origin
                Args[2] = Ray.new(Origin, (CalculateDropAndPred(AimPart)-Origin).Unit * Set.Distance)
                return oldNameCall(table.unpack(Args))
            end
        elseif Method == "Raycast" and Set.SilentMode == "Raycast" then
            if not ValidateArguments(Args, ExpectedArguments.Raycast) then
                return oldNameCall(...)
            end
            Util.print(Args, "old")
            local Origin = Args[2]
            Args[3] = (CalculateDropAndPred(AimPart)-Origin).Unit * Set.Distance
            Util.print(Args)
            return oldNameCall(Args[1],Args[2],Args[3],Args[4],Args[5])
        end
    end
    return oldNameCall(...)
end))]]


RunService.Stepped:connect(function(deltaTime)
    xpcall(function()
        if UserInputService:IsKeyDown(Enum.KeyCode.V) then
            LP.DevCameraOcclusionMode = 1
        else
            LP.DevCameraOcclusionMode = 0
        end
        xpcall(function()
            if Aimbot then
                local Set = Config[tostring(game.PlaceId)].Aimbot
                AimbotTarget, AimPart = GetPlayerClosestToMouse()
                if Set.Method == "Lock" then
                    if AimPart and GetAimKey() then
                        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, CalculateDropAndPred(AimPart))
                    end
                end
            else
                AimbotTarget = nil
            end
        end,warn)
        if ESP then
            for i, v in pairs(Players:GetPlayers()) do
                xpcall(function()
                    local Char = v.Character
                    if Char and Char:FindFirstChild("HumanoidRootPart") and not (Char:FindFirstChild("ESPHighlight") or Char.HumanoidRootPart:FindFirstChild("ESPHighlight")) and CheckIfVisible(Char:FindFirstChild("HumanoidRootPart")) and GetESPDistance(v) < Config[tostring(game.PlaceId)].ESP.Distance and CheckESPTeam(v) then
                        local Color do 
                            if Config[tostring(game.PlaceId)].ESP.ShowHealth and Config[tostring(game.PlaceId)].ESP.ShowHealthType == "Color" then Color = Color3.new(1-Char.Humanoid.Health/Char.Humanoid.MaxHealth,Char.Humanoid.Health/Char.Humanoid.MaxHealth)
                            elseif Config[tostring(game.PlaceId)].ESP.ListColors and CheckStaff(tostring(v.UserId)) then Color = ListColors.Staff
                            elseif Config[tostring(game.PlaceId)].ESP.ListColors and ListsModule and Lists and Lists[tostring(v.UserId)] then Color = ListColors[Lists[tostring(v.UserId)]]
                            elseif Config[tostring(game.PlaceId)].ESP.TeamColors then Color = v.TeamColor.Color
                            else Color = Config[tostring(game.PlaceId)].ESP.DefaultColor end
                        end
                        local Extents = Char:GetExtentsSize()
                        local HL = Config[tostring(game.PlaceId)].ESP.Style == "Highlight" and CreateObject("Highlight",{
                            OutlineColor = Color,
                            FillTransparency = 1,
                            DepthMode = "AlwaysOnTop",
                            Name = "ESPHighlight",
                            Parent = Char
                        }) or Config[tostring(game.PlaceId)].ESP.Style == "Box" and CreateObject("BillboardGui",{
                            Name = "ESPHighlight",
                            Size = UDim2.fromScale(Extents.X,Extents.Y),
                            StudsOffset = Vector3.new(0,-0.5,0),
                            LightInfluence = 0,
                            MaxDistance = Config[tostring(game.PlaceId)].ESP.Distance,
                            AlwaysOnTop = true,
                            ClipsDescendants = false,
                            Parent = Char.HumanoidRootPart,
                            Enabled = (not Config[tostring(game.PlaceId)].ESP.ShowLP and v ~= LP or Config[tostring(game.PlaceId)].ESP.ShowLP)
                        })
                        if Config[tostring(game.PlaceId)].ESP.Style == "Box" then
                            CreateObject("UIStroke",{
                                Name = "Stroke",
                                Thickness = 2,
                                ApplyStrokeMode = 1,
                                Color = Color,
                                Parent = CreateObject("Frame",{
                                    BackgroundTransparency = 1,
                                    Size = UDim2.fromScale(1,1),
                                    Name = "Frame",
                                    Parent = HL
                                })
                            })
                        end
                        local function ChangeColor(Color)
                            if HL:IsA("Highlight") then
                                HL.OutlineColor = Color
                            elseif HL:IsA("BillboardGui") then
                                HL.Frame.Stroke.Color = Color
                            end
                        end
                        local NameGui = CreateObject("BillboardGui",{
                            Name = "ESPName",
                            Size = UDim2.fromOffset(240,24),
                            SizeOffset = Vector2.new(0.5,1),
                            LightInfluence = 0,
                            MaxDistance = Config[tostring(game.PlaceId)].ESP.Distance,
                            AlwaysOnTop = true,
                            ClipsDescendants = false,
                            Parent = Char.Head,
                            Enabled = (not Config[tostring(game.PlaceId)].ESP.ShowLP and v ~= LP or Config[tostring(game.PlaceId)].ESP.ShowLP)
                        })
                        local NameText = CreateObject("TextLabel", {
                            Text = GetESPText(v),
                            BackgroundTransparency = 1,
                            Size = UDim2.new(1,0,1,0),
                            BorderSizePixel = 0,
                            Parent = NameGui,
                            Font = Enum.Font.Arial,
                            TextSize = 12,
                            TextColor3 = Color3.new(0.9,0.9,0.9),
                            TextStrokeColor3 = Color3.new(0,0,0),
                            TextStrokeTransparency = 0.2,
                            TextXAlignment = Enum.TextXAlignment.Left
                        })
                        if Config[tostring(game.PlaceId)].ESP.ShowHealth and Config[tostring(game.PlaceId)].ESP.ShowHealthType == "Color" then
                            local RS do 
                                RS = Char.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                                    ChangeColor(Color3.new(2-(Char.Humanoid.Health/Char.Humanoid.MaxHealth)*2,(Char.Humanoid.Health/Char.Humanoid.MaxHealth)*2))
                                end)
                                HL.Destroying:Once(function()
                                    RS:Disconnect()
                                end)
                            end
                        elseif Config[tostring(game.PlaceId)].ESP.ShowHealth and Config[tostring(game.PlaceId)].ESP.ShowHealthType == "Bar" then
                            NameText.Position = UDim2.fromOffset(0,4)
                            local HealthBarFrame = CreateObject("Frame", {
                                BackgroundTransparency = 0.1,
                                Size = UDim2.fromOffset(100,2),
                                BorderSizePixel = 0,
                                Parent = NameText,
                                BackgroundColor3 = Color3.fromHex("#262626"),
                                Position = UDim2.fromOffset(0,-4)
                            })
                            local HealthBarDelay = CreateObject("Frame", {
                                BackgroundTransparency = 0.1,
                                Size = UDim2.fromScale(Char.Humanoid.Health/Char.Humanoid.MaxHealth,1),
                                BorderSizePixel = 0,
                                Parent = HealthBarFrame,
                                BackgroundColor3 = Color3.fromHex("#ff0000")
                            })
                            local HealthBarDisplay = CreateObject("Frame", {
                                Size = UDim2.fromScale(Char.Humanoid.Health/Char.Humanoid.MaxHealth,1),
                                BorderSizePixel = 0,
                                Parent = HealthBarFrame,
                                BackgroundColor3 = Color3.new(2-(Char.Humanoid.Health/Char.Humanoid.MaxHealth)*2,(Char.Humanoid.Health/Char.Humanoid.MaxHealth)*2)
                            })
                            local timeout = 0
                            local RS do
                                RS = Char.Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                                    HealthBarDisplay.BackgroundColor3 = Color3.new(2-(Char.Humanoid.Health/Char.Humanoid.MaxHealth)*2,(Char.Humanoid.Health/Char.Humanoid.MaxHealth)*2)
                                    if HealthBarDisplay.Parent == HealthBarFrame then
                                        HealthBarDisplay:TweenSize(UDim2.fromScale(Char.Humanoid.Health/Char.Humanoid.MaxHealth,1),
                                            Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.5, true)
                                    end
                                    if timeout == 0 then
                                        timeout = 2
                                        while timeout > 0 do
                                            wait(.1)
                                            timeout = timeout-0.1
                                        end
                                        timeout = 0
                                        if HealthBarDelay.Parent == HealthBarFrame then
                                            HealthBarDelay:TweenSize(UDim2.fromScale(Char.Humanoid.Health/Char.Humanoid.MaxHealth,1),
                                            Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.3, true)
                                        end
                                    else
                                        timeout = .7
                                    end
                                end)
                                HL.Destroying:Once(function()
                                    RS:Disconnect()
                                end)
                            end
                        end
                        if Config[tostring(game.PlaceId)].ESP.ShowDistance or table.find({"Scale", "Number"}, Config[tostring(game.PlaceId)].ESP.ShowHealthType) then
                            local RS do 
                                RS = RunService.RenderStepped:Connect(function()
                                    NameText.Text = GetESPText(v)
                                end)
                                HL.Destroying:Once(function()
                                    RS:Disconnect()
                                end)
                            end
                        end
                        HL.Destroying:Connect(function()
                            NameGui:Destroy()
                        end)
                    end
                end,warn)
            end
        else
            for i, v in pairs(Players:GetPlayers()) do
                local Char = v.Character
                if Char and Char:FindFirstChild("ESPHighlight") then Char:FindFirstChild("ESPHighlight"):Destroy() end
                if Char and Char:FindFirstChild("HumanoidRootPart") and Char.HumanoidRootPart:FindFirstChild("ESPHighlight") then Char.HumanoidRootPart:FindFirstChild("ESPHighlight"):Destroy() end
            end
        end
    end,function(err)
        warn(debug.traceback( err ))
    end)
end)
local function refresh()
	local oldpos = LP.Character.HumanoidRootPart.CFrame
	LP.Character.Humanoid.Health = 0
	if LP.Character:FindFirstChild("Head") then LP.Character.Head:Destroy() end
	LP.CharacterAdded:Wait()
	LP.Character:WaitForChild("HumanoidRootPart")
    Functions.TeleportTo(oldpos,{TeleportOffset = CFrame.new(0,0,0)})
end
local function RejoinDiff(arg) --Skidded off of CMD-X, cheers
	local Decision = arg or "any"
	if arg == "" then Decision = "any" end
	local GUIDs = {}
	local maxPlayers = 0
	local pagesToSearch = 100
	if Decision == "fast" then pagesToSearch = 5 end
	local Http = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="))
	for i = 1,pagesToSearch do
		for i,v in pairs(Http.data) do
			if v.playing ~= v.maxPlayers and v.id ~= game.JobId then
				maxPlayers = v.maxPlayers
				table.insert(GUIDs, {id = v.id, users = v.playing})
			end
		end
		if Http.nextPageCursor ~= null then Http = game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100&cursor="..Http.nextPageCursor)) else break end
	end
	if Decision == "any" or Decision == "fast" then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, GUIDs[math.random(1,#GUIDs)].id, LP)
	elseif Decision == "smallest" then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, GUIDs[#GUIDs].id, LP)
	elseif Decision == "largest" then
		game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, GUIDs[1].id, LP)
	end
end

local function CheckDex(Player)
    if _G.DexObj then
        return {
            Text = "Dex..",
            Submenu = {
                {
                    Text = "Select in tab...",
                    Submenu = (function()
                        local obj = Player
                        local out = {}
                        pcall(function()
                            local function AddTab(TabObject)
                                table.insert(out, {
                                    Text = TabObject.Name,
                                    M1Func = function()
                                        _G.DexObj:JumpToInstance(obj,TabObject)
                                    end
                                })
                            end
                            for _, TabObject in pairs(_G.DexObj.Tabs) do
                                if TabObject == ActiveTab then continue end
                                for _, Inst in pairs(TabObject.RefreshFunction()) do
                                    if Inst == obj then
                                        AddTab(TabObject)
                                        continue
                                    end
                                    for _, Inst in pairs(Inst:GetDescendants()) do
                                        if Inst == obj then
                                            AddTab(TabObject)
                                            break
                                        end
                                    end
                                end
                            end
                        end)
                        if out == {} then
                            return {Text = "Not found!"}
                        end
                        return out
                    end)()
                },
                {
                    Text = "Select character in tab...",
                    Submenu = (function()
                        local obj = Player.Character
                        local out = {}
                        pcall(function()
                            local function AddTab(TabObject)
                                table.insert(out, {
                                    Text = TabObject.Name,
                                    M1Func = function()
                                        _G.DexObj:JumpToInstance(obj,TabObject)
                                    end
                                })
                            end
                            for _, TabObject in pairs(_G.DexObj.Tabs) do
                                if TabObject == ActiveTab then continue end
                                for _, Inst in pairs(TabObject.RefreshFunction()) do
                                    if Inst == obj then
                                        AddTab(TabObject)
                                        continue
                                    end
                                    for _, Inst in pairs(Inst:GetDescendants()) do
                                        if Inst == obj then
                                            AddTab(TabObject)
                                            break
                                        end
                                    end
                                end
                            end
                        end)
                        if out == {} then
                            return {Text = "Not found!"}
                        end
                        return out
                    end)()
                },
                {
                    Text = "Jump to Player",
                    M1Func = function()
                        _G.DexObj:JumpToInstance(Player)
                    end
                },
                {
                    Text = "Jump to Character",
                    M1Func = function()
                        _G.DexObj:JumpToInstance(Player.Character)
                    end
                }
            },
            Tooltip = "Dex options."
        }
    else
        return nil
    end
end
Mouse.Button1Down:connect(function()
    if Config[tostring(game.PlaceId)].QuickChatLogs and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and (workspace.CurrentCamera.CoordinateFrame.p - LP.Character.Head.Position).magnitude > 2 then
        local Player
        pcall(function()
            Player = Players[Util.FindWSChild(Util.getMouseHitIncludingChar().Instance).Name]
        end)
        if Player then
            local logsToDisplay = {}
            local args = {}
            if Player then
                local ChatLogs = GetChatLogs(1000)
                for i = 1, math.floor(#ChatLogs/2) do
                    local j = #ChatLogs - i + 1
                    ChatLogs[i], ChatLogs[j] = ChatLogs[j], ChatLogs[i]
                end
                for _, v in pairs(ChatLogs) do
                    if v.FromSpeaker == Player.Name then
                        table.insert(logsToDisplay, {
                            Tooltip = os.date("%X", v.Time), Text = v.Message,
                            M2Func = function() 
                                setclipboardint(os.date("%X", v.Time).." | "..v.FromSpeaker.." : ".. v.Message)
                            end
                        })
                    end
                    if #logsToDisplay >= 10 then break end
                end
                ContextMenus.Create(
                    {
                        FrameAnchorPoint = Util.CMAnchorPoint(),
                        Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                        TitleText = "  ChatLogs for <font color=\"#"..Util.ComputeNameColor(Player.Name):ToHex().."\">"..Player.DisplayName.." (@"..Player.Name..")".."</font>   ",
                        ContextMenuEntries = {
                            AutoButtonColor = false
                        }
                    },
                    table.unpack(logsToDisplay)
                )
            end
        end
    elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftAlt) and (workspace.CurrentCamera.CoordinateFrame.p - LP.Character.Head.Position).magnitude > 2 then
        local Player = Util.FindWSChild(Util.getMouseHitIncludingChar().Instance)
        local logsToDisplay = {}
        if Player:FindFirstChild("Humanoid") then
            for _, v in pairs(Player:GetChildren()) do --will run once for every part in Player.Character and v will be the part.
                if v:IsA("Accoutrement") or v:GetAttribute("AssetType") then
                    table.insert(logsToDisplay, {
                        Text = v.Name,
                        Tooltip = v:GetAttribute("AssetType") or v.ClassName,
                        M1Func = function()
                            setclipboardint(tostring(v:GetAttribute("ID") or v:GetAttribute("UUID")))
                        end,
                        Submenu = {
                            {
                                Text = "Copy Name",
                                M1Func = function()
                                    setclipboardint(v.Name)
                                end
                            }
                        }
                    })
                end
            end
            table.insert(logsToDisplay, {
                    Type = "Divider"
                }
            )
            ContextMenus.Create({
                FrameAnchorPoint = Util.CMAnchorPoint(),
                Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                TitleText = "  Morph info for <font color=\"#"..Util.ComputeNameColor(Player.Name):ToHex().."\">@"..Player.Name.."</font>   ",
                ContextMenuEntries = {
                    AutoButtonColor = false
                }
            },
            {
                Type = "Divider"
            },
            table.unpack(logsToDisplay)
        )
        end
    end
end)
local ThemeProvider = (function()
    for _, v in pairs(CoreGui:GetDescendants()) do
        local ret
        pcall(function()
            if v.Name == "Background" and v.Image == "rbxasset://textures/ui/TopBar/iconBase.png" then ret = v end
        end)
        if ret then return ret end
    end
end)()

local function GetPosList()
    WPs = ConfigModule:Create("SAVEDPOSITIONS.lua",{
        [tostring(game.PlaceId)] = {}
    })
    if WPs[tostring(game.PlaceId)] and WPs[tostring(game.PlaceId)] ~= {} then
        local out = {}
        for name,pos in pairs(WPs[tostring(game.PlaceId)]) do
            if typeof(pos) ~= "function" then
                table.insert(
                    out,
                    {
                        Text = name,
                        M1Func = function()
                            Functions.TeleportTo(pos, {TeleportOffset = CFrame.new(0,0,0)})
                        end
                    }
                )
            end
        end
        return out
    end
end


local function GetGotoList()
    local out = {}
    for _, v in pairs(Players:GetChildren()) do
        table.insert(
            out,
            {
                Text = v.Name,
                M1Func = function()
                    Functions.TeleportTo(v.Character.HumanoidRootPart)
                end
            }
        )
    end
    return out
end
local CustomLPEntries = {}
local CustomPlayerEntries = {}
local CustomThemeproviderEntries = {}
local function ThemeProviderEntries()
    local Entries = {
        {
            FrameAnchorPoint = Util.CMAnchorPoint(),
            Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
            TitleText = "  Settings   ",
            ContextMenuEntries = {
                TextSize = ContextMenuSize
            }
        },
        function()
            if LP.Character and not (workspace.CurrentCamera.CameraSubject == LP.Character or workspace.CurrentCamera.CameraSubject == LP.Character.Humanoid) then
                return {
                    Text = "Unview",
                    M1Func = function()
                        workspace.CurrentCamera.CameraSubject = LP.Character
                    end
                },
                {
                    Type = "Divider"
                }
            end
        end,
        function()
            if _G.ChatNotifs then 
                return {
                    Text = "Notification History",
                    Tooltip = "Chat Notifications.",
                    M1Func = function()
                        local ChatNotifs = ContextMenus.CreateTextBox({
                            TextBox = {
                                Title = {Text = "Chat Notifications"},
                                HasFilter = true,   
                                FilterLocation = "Top"
                            }
                        }, "ChatNotifs")
                        local function RefreshEntries()
                            for _, v in pairs(_G.ChatNotifs) do
                                local msg
                                local IsAWhisper = false
                                if v.Message:split(" ")[1] == "/w" and v.Message:split(" ")[3] == "" then
                                    IsAWhisper = true
                                    msg = os.date("%X", v.Time) .. " | <font color=\"#50ffff\">[" ..v.FromSpeaker .. " >> "..v.Message:split(" ")[2].."]</font> : " ..table.concat(v.Message:gsub("\n",""):split(" "), " ", 4):gsub(">","&gt;"):gsub("<","&lt;")
                                else
                                    msg = os.date("%X", v.Time) .. " | <font color=\"#"..Util.ComputeNameColor(v.FromSpeaker):ToHex().."\">" ..v.FromSpeaker .. "</font> : " .. v.Message:gsub("\n",""):gsub(">","&gt;"):gsub("<","&lt;")
                                end
                                local function AddEntry(msg)
                                    ChatNotifs.AddEntry(
                                        {
                                            NoRenderStep = true
                                        }, 
                                        msg,
                                        {
                                            M2Func = function()
                                                ContextMenus.Create(
                                                    {
                                                        FrameAnchorPoint = Util.CMAnchorPoint(),
                                                        Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
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
                                                                    setclipboardint(v.FromSpeaker)
                                                                end
                                                            },
                                                            {
                                                                Text = "UserId",
                                                                Icon = Util.GetClassIcon("Player"),
                                                                M1Func = function()
                                                                    setclipboardint(Util.getUserIdFromUsername(v.FromSpeaker))
                                                                end
                                                            },
                                                            {
                                                                Text = "Message",
                                                                Icon = Util.GetClassIcon("Chat"),
                                                                M1Func = function()
                                                                    setclipboardint(Util.removeTags(msg))
                                                                end
                                                            },
                                                            (function()
                                                                if IsAWhisper then 
                                                                    return {
                                                                        Text = "Recipient",
                                                                        Icon = Util.GetClassIcon("Player"),
                                                                        M1Func = function()
                                                                            setclipboardint(v.Message:split(" ")[2])
                                                                        end
                                                                    },
                                                                    {
                                                                        Text = "Recipient Id",
                                                                        Icon = Util.GetClassIcon("Player"),
                                                                        M1Func = function()
                                                                            setclipboardint(Util.getUserIdFromUsername(v.Message:split(" ")[2]))
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
                                                        M1Func = function()
                                                            module.TeleportTo(Players[v.FromSpeaker].Character.HumanoidRootPart)
                                                        end
                                                    },
                                                    {
                                                        Text = "Filtered ChatLogs",
                                                        Icon = Util.GetClassIcon("Chat"),
                                                        M1Func = function()
                                                            Functions.OpenChatLogs(ContextMenus, {v.FromSpeaker})
                                                        end
                                                    },
                                                    (function()
                                                        if IsAWhisper then 
                                                            return {
                                                                Text = "Open Conversation",
                                                                Icon = Util.GetClassIcon("TextSource"),
                                                                M1Func = function()
                                                                    Functions.OpenChatLogs(ContextMenus, {v.FromSpeaker, v.Message:split(" ")[2]})
                                                                end
                                                            }
                                                        end
                                                    end)()
                                                )
                                            end
                                        }
                                    )
                                end
                                if ChatNotifs.FilterTable then
                                    for _, phrase in pairs(ChatNotifs.FilterTable) do
                                        if string.match(msg:lower(), phrase:lower()) then
                                            AddEntry(msg)
                                            break
                                        end
                                    end
                                else
                                    AddEntry(msg)
                                end
                            end
                        end
                        RefreshEntries()
                        ChatNotifs.AddButton(
                            {

                            }, 
                            "Refresh", 
                            {
                                M1Func = function()
                                    ChatNotifs.ClearList()
                                    RefreshEntries()
                                end
                            }
                        )
                        ChatNotifs.AddButton({}, "Export to file", {
                            M1Func = function()
                                if not isfolder("Chatlogs") then makefolder("Chatlogs") end
                                local path
                                if ChatNotifs.FilterTable then
                                    path = "Chatlogs/ChatNotifsFiltered "..table.concat(ChatNotifs.FilterTable, " ").." "..game.JobId..".txt"
                                    writefile(path, "Filtered chat notifications ("..table.concat(ChatNotifs.FilterTable, ", ")..") for "..game.JobId.." exported by "..(Config[tostring(LP.UserId)].NameHidden and "namehidden" or LP.Name).." at "..os.date("%d.%m.%Y %X"))
                                    Util.Notify("Saving filtered chat notifs! ("..#_G.ChatNotifs.." entries)")
                                    for i, v in pairs(_G.ChatNotifs) do
                                        local msg
                                        if v.Message:split(" ")[1] == "/w" and v.Message:split(" ")[3] == "" then
                                            msg = os.date("%X", v.Time) .. " | [" ..v.FromSpeaker .. " >> "..v.Message:split(" ")[2].."] : " ..table.concat(v.Message:gsub("\n",""):split(" "), " ", 4)
                                        else
                                            msg = os.date("%X", v.Time) .. " | " ..v.FromSpeaker .. " : " .. v.Message:gsub("\n","")
                                        end
                                        for _, name in pairs(ChatNotifs.FilterTable) do
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
                                    Util.Notify("Finished saving chatnotifs!")
                                else
                                    path = "Chatlogs/ChatNotifs "..game.JobId..".txt"
                                    writefile(path, "Chat notifications for "..game.JobId.." exported by "..(Config[tostring(LP.UserId)].NameHidden and "namehidden" or LP.Name).." at "..os.date("%d.%m.%Y %X"))
                                    Util.Notify("Saving chat notifs! This might take a while ("..#_G.ChatNotifs.." entries)")
                                    for i, v in pairs(_G.ChatNotifs) do
                                        local msg
                                        if v.Message:split(" ")[1] == "/w" and v.Message:split(" ")[3] == "" then
                                            msg = os.date("%X", v.Time) .. " | [" ..v.FromSpeaker .. " >> "..v.Message:split(" ")[2].."] : " ..table.concat(v.Message:gsub("\n",""):split(" "), " ", 4)
                                        else
                                            msg = os.date("%X", v.Time) .. " | " ..v.FromSpeaker .. " : " .. v.Message:gsub("\n","")
                                        end
                                        appendfile(path, "\n"..msg)
                                        if i%100 == 0 then wait() end
                                    end
                                    Util.Notify("Finished saving chatnotifs!")
                                end
                            end
                        })
                    end
                }
            end
        end,
        {
            Text = "Chat Logs",
            Icon = Util.GetClassIcon("Chat"),
            M1Func = function()
                Functions.OpenChatLogs(ContextMenus)
            end,
            Tooltip = "ChatLogs for the whole server."
        },
        {
            Text = "View Commands",
            Tooltip = "View the ContextTerminal commands.",
            M1Func = OpenCommandList
        },
        {
            Text = "Give TpTool",
            M1Func = Functions.GiveTpTool
        },
        {
            Text = "BTools",
            Tooltip = "F3X build tools.",
            M1Func = function()
                loadstring(game:GetObjects("rbxassetid://4698064966")[1].Source)()
            end
        },
        {
            Text = "Teleport to...",
            Tooltip = "Teleport yourself.",
            Submenu = {
                {
                    Text = "Players...",
                    Icon = Util.GetClassIcon("Players"),
                    Submenu = GetGotoList(),
                    SubmenuSettings = {Scrollable = true, ScrollableSizeY = 300, SortOrder = "Name"}
                },
                {
                    Text = "Saved Positions...",    
                    Icon = Util.GetClassIcon("SpawnLocation"),
                    Submenu = GetPosList(),
                    SubmenuSettings = {Scrollable = true, ScrollableSizeY = 300, SortOrder = "Name"}
                },
                {
                    Text = "Save position...",
                    Icon = Util.GetClassIcon("SpawnLocation"),
                    M1Func = function()
                        xpcall(function()
                            local PosName = ""
                            ContextMenus.Prompt(
                                {
                                    Content = {
                                        {
                                            ClassName = "TextBox",
                                            Size = UDim2.new(1,0,0,28),
                                            Text = GroupId,
                                            TextSize = 24,
                                            PlaceholderText = "Position Name",
                                            TextYAlignment = Enum.TextYAlignment.Center,
                                            TextColor3 = Color3.fromHex("9cdcfe"),
                                            InitFunction = function(self, prompt, settings)
                                                self.FocusLost:Connect(function()
                                                    PosName = self.ContentText
                                                end)
                                            end
                                        }
                                    },
                                    Settings = {
                                        Focus = false, 
                                        ButtonAlignment = "Right", 
                                        ReturnType = "Object",
                                        Title = {
                                            Text = "Save Position"
                                        },
                                        Content = {ClipsDescendants = false}
                                    },
                                    Buttons = {
                                        {
                                            Text = "Save", 
                                            M1Func = function(prompt)
                                                WPs[tostring(game.PlaceId)][PosName] = LP.Character.HumanoidRootPart.CFrame
                                                WPs:Write()
                                            end
                                        },
                                        {
                                            Text = "Cancel"
                                        }
                                    }
                                }
                            ) 
                        end,warn)
                    end
                }
            }
        },
        {
            Text = "Refresh",
            Tooltip = "Refreshes your character.",
            M1Func = refresh
        },
        {
            Text = "Change Staff Group",
            M1Func = ChangeStaffGroupPrompt,
            Tooltip = "Change the group used to find staff members online."
        },
        {
            Text = "Serialized Characters...",
            M1Func = function()
                local SerializedCharacters = {}
                local TextBox = ContextMenus.CreateTextBox({
                    TextBox = {
                        Title = {Text = "Serialized Characters"},
                        HasFilter = true,
                        FilterLocation = "Top"
                    }
                }, "SerializedCharacters")
                local function RefreshList()
                    SerializedCharacters = {}
                    local _temp = {}
                    local _times = {}
                    for i, v in pairs(listfiles("SerializedCharacters/")) do
                        _temp[i] = string.gsub(Util.formatfile(v), ".json", "")
                        table.insert(_times, string.gsub(Util.formatfile(v), ".json", ""):split(" ")[2])
                    end
                    table.sort(_times)
                    for i, v in pairs(_times) do
                        for i2, v2 in pairs(_temp) do
                            if v == v2:split(" ")[2] then
                                if TextBox.FilterTable then
                                    for _, phrase in pairs(TextBox.FilterTable) do
                                        if string.match(v2:lower(), phrase:lower()) then
                                            table.insert(SerializedCharacters, v2)
                                        end
                                    end
                                else
                                    table.insert(SerializedCharacters, v2)
                                end
                            end
                        end
                    end
                end
                local function RefreshEntries()
                    for i, v in pairs(SerializedCharacters) do
                        TextBox.AddEntry(
                            {
                                NoRenderStep = true
                            },
                            "<font color=\"#"..Util.ComputeNameColor(v:split(" ")[1]):ToHex().."\">"..v:split(" ")[1].."</font> serialized at "..os.date("%d.%m.%Y %X", v:split(" ")[2]),
                            {
                                M1Func = function()
                                    local ObjectFile = Util.JSONDecode(readfile("/SerializedCharacters/"..v..".json"))
                                    local SerializedInstance = InstanceSerializer.Deserialize(ObjectFile)
                                    table.insert(SerializedInstances, SerializedInstance)
                                    SerializedInstance.Parent = workspace
                                    workspace.CurrentCamera.CameraSubject = SerializedInstance.Head
                                    local conn
                                    conn = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
                                        conn:Disconnect()
                                        SerializedInstance:Destroy()
                                    end)
                                end,
                                M2Func = function()
                                    local username, sertime = table.unpack(v:split(" "))
                                    ContextMenus.Create(
                                        {
                                            FrameAnchorPoint = Util.CMAnchorPoint(),
                                            Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                                            TitleText = "  <font color=\"#"..Util.ComputeNameColor(username):ToHex().."\">"..username.."</font>   ",
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
                                                        setclipboardint(username)
                                                    end
                                                },
                                                {
                                                    Text = "UserId",
                                                    Icon = Util.GetClassIcon("Player"),
                                                    M1Func = function()
                                                        setclipboardint(tostring(getUserIdFromUsername(username)))
                                                    end
                                                },
                                                {
                                                    Text = "Timestamp",
                                                    Icon = "http://www.roblox.com/asset/?id=10193284031",
                                                    M1Func = function()
                                                        setclipboardint(os.date("%d.%m.%Y %X", sertime))
                                                    end
                                                },
                                                {
                                                    Text = "Raw data",
                                                    Icon = Util.GetClassIcon("Chat"),
                                                    M1Func = function()
                                                        setclipboardint(readfile("/SerializedCharacters/"..v..".json"))
                                                    end
                                                }
                                            }
                                        }
                                    )
                                end
                            }
                        )
                    end
                end
                local Refresh = TextBox.AddButton(
                    {

                    }, 
                    "Refresh", 
                    {
                        M1Func = function()
                            RefreshList()
                            TextBox.ClearList()
                            RefreshEntries()
                        end
                    }
                )
                
                if TextBox.FilterTable then TextBox.FilterBox.Text = table.concat(TextBox.FilterTable, ", ") end
                TextBox.FilterBox.FocusLost:connect(function()
                    TextBox.FilterTable = string.split(string.gsub(string.gsub(TextBox.FilterBox.Text, ";", ","), ", ", ","),",")
                    if #table.concat(TextBox.FilterTable, ", ")>0 then
                        TextBox.Instance.TitleBar.Text = " Serialized Characters ("..table.concat(TextBox.FilterTable, ", ")..")"
                    else
                        TextBox.Instance.TitleBar.Text = " Serialized Characters"
                    end
                    for _, phrase in pairs(TextBox.FilterTable) do
                        for _, v in pairs(TextBox.Entries) do
                            if v then
                                pcall(function()
                                    if not string.match(v.Text:lower(), phrase:lower()) then
                                        v:Destroy()
                                    end
                                end)
                            end
                        end
                    end
                end)
                if TextBox.FilterTable then
                    if #table.concat(TextBox.FilterTable, ", ")>0 then
                        TextBox.Instance.TitleBar.Text = " Serialized Characters ("..table.concat(TextBox.FilterTable, ", ")..")"
                    else
                        TextBox.Instance.TitleBar.Text = " Serialized Characters"
                    end
                end
                local Clear = TextBox.AddButton(
                    {

                    }, 
                    "Clear Models", 
                    {
                        M1Func = function()
                            for _, v in pairs(SerializedInstances) do
                                v:Destroy()
                            end
                            SerializedInstances = {}
                        end
                    }
                )
                RefreshList()
                RefreshEntries()
            end,
            Tooltip = "Preview Serialized Characters."

        },
        {
            Text = "Recent Players...",
            M1Func = function()
                local TextBox = ContextMenus.CreateTextBox({
                    TextBox = {
                        Title = {Text = "Recent Players"},
                        HasFilter = true,
                        FilterLocation = "Top"
                    }
                }, "RecentPlayers")
                local function RefreshEntries()
                        for i, v in pairs(RecentPlayers) do
                            TextBox.AddEntry(
                                {
                                    NoRenderStep = true
                                },
                                "<font color=\"#"..Util.ComputeNameColor(v.Name):ToHex().."\">"..v.Name.."</font> disconnected at "..os.date("%d.%m.%Y %X", v.Timestamp),
                                {
                                    M1Func = function()
                                        local SerializedInstance = InstanceSerializer.Deserialize(v.Serialized)
                                        table.insert(SerializedInstances, SerializedInstance)
                                        SerializedInstance.Parent = workspace
                                        workspace.CurrentCamera.CameraSubject = SerializedInstance.Head
                                        local conn
                                        conn = workspace.CurrentCamera:GetPropertyChangedSignal("CameraSubject"):Connect(function()
                                            conn:Disconnect()
                                            SerializedInstance:Destroy()
                                        end)
                                    end,
                                    M2Func = function()
                                        local username, sertime = v.Name, v.Timestamp
                                        ContextMenus.Create(
                                            {
                                                FrameAnchorPoint = Util.CMAnchorPoint(),
                                                Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                                                TitleText = "  <font color=\"#"..Util.ComputeNameColor(username):ToHex().."\">"..username.."</font>   ",
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
                                                            setclipboardint(username)
                                                        end
                                                    },
                                                    {
                                                        Text = "UserId",
                                                        Icon = Util.GetClassIcon("Player"),
                                                        M1Func = function()
                                                            setclipboardint(tostring(v.UserId))
                                                        end
                                                    },
                                                    {
                                                        Text = "Timestamp",
                                                        Icon = "http://www.roblox.com/asset/?id=10193284031",
                                                        M1Func = function()
                                                            setclipboardint(os.date("%d.%m.%Y %X", sertime))
                                                        end
                                                    },
                                                    {
                                                        Text = "Raw data",
                                                        Icon = Util.GetClassIcon("Chat"),
                                                        M1Func = function()
                                                            setclipboardint(JSONEncode(v.Serialized))
                                                        end
                                                    }
                                                }
                                            },
                                            {
                                                Text = "ChatLogs...",
                                                Icon = Util.GetClassIcon("Chat"),
                                                Submenu = {
                                                    {
                                                        Text = "Filtered",
                                                        Icon = Util.GetClassIcon("TextChatService"),
                                                        M1Func = function()
                                                            Functions.OpenChatLogs(ContextMenus, {username})
                                                        end,
                                                        Tooltip = "ChatLogs ONLY of player."
                                                    }
                                                }
                                            }
                                        )
                                    end
                                }
                            )
                        end
                end
                local Refresh = TextBox.AddButton(
                    {

                    }, 
                    "Refresh", 
                    {
                        M1Func = function()
                            TextBox.ClearList()
                            RefreshEntries()
                        end
                    }
                )
                
                if TextBox.FilterTable then TextBox.FilterBox.Text = table.concat(TextBox.FilterTable, ", ") end
                TextBox.FilterBox.FocusLost:connect(function()
                    TextBox.FilterTable = string.split(string.gsub(string.gsub(TextBox.FilterBox.Text, ";", ","), ", ", ","),",")
                    if #table.concat(TextBox.FilterTable, ", ")>0 then
                        TextBox.Instance.TitleBar.Text = " Serialized Characters ("..table.concat(TextBox.FilterTable, ", ")..")"
                    else
                        TextBox.Instance.TitleBar.Text = " Serialized Characters"
                    end
                    for _, phrase in pairs(TextBox.FilterTable) do
                        for _, v in pairs(TextBox.Entries) do
                            if v then
                                pcall(function()
                                    if not string.match(v.Text:lower(), phrase:lower()) then
                                        v:Destroy()
                                    end
                                end)
                            end
                        end
                    end
                end)
                if TextBox.FilterTable then
                    if #table.concat(TextBox.FilterTable, ", ")>0 then
                        TextBox.Instance.TitleBar.Text = " Serialized Characters ("..table.concat(TextBox.FilterTable, ", ")..")"
                    else
                        TextBox.Instance.TitleBar.Text = " Serialized Characters"
                    end
                end
                local Clear = TextBox.AddButton(
                    {

                    }, 
                    "Clear Models", 
                    {
                        M1Func = function()
                            for _, v in pairs(SerializedInstances) do
                                v:Destroy()
                            end
                            SerializedInstances = {}
                        end
                    }
                )
                RefreshEntries()
            end,
            Tooltip = "View recently disconnected players."

        },
        {
            Text = "Rejoin...",
            Submenu = {
                {
                    Text = "Different server",
                    M1Func = function()
                        local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport
                        local queue = 'game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()'
                        if queue_on_teleport then
                            pcall(function()
                                queue_on_teleport(queue)
                            end)
                        end
                        RejoinDiff()
                    end,
                    Submenu = {
                        {
                            Text = "Smallest",
                            M1Func = function()
                                local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport
                                local queue = 'game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()'
                            if queue_on_teleport then
                                    pcall(function()
                                        queue_on_teleport(queue)
                                    end)
                                end
                                RejoinDiff("smallest")
                            end
                        },
                        {
                            Text = "Largest",
                            M1Func = function()
                                local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport
                                local queue = 'game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()'
                                if queue_on_teleport then
                                    pcall(function()
                                        queue_on_teleport(queue)
                                    end)
                                end
                                RejoinDiff("largest")
                            end
                        }
                    }
                }
            },
            M1Func = function()
                local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport
                local queue = 'game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()'
                if queue_on_teleport then
                    pcall(function()
                        queue_on_teleport(queue)
                    end)
                end
                game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, Players)
            end
        },
        {
            Text = "Open ServerList...",
            M1Func = function()
                LoadModule("ServerList").OpenServerList(game.PlaceId)
            end
        },
        {
            Text = "Settings...",
            Icon = Util.GetDataTypeIcon("function"),
            Submenu = function()
                return {
                    {
                        Type = "Keybind",
                        Keybind = Config.Keybind,
                        Text = "Focus Key",
                        OnKeybindChange = function(input)
                            Config.Keybind = input.KeyCode
                            Config:Write()
                        end
                    },
                    {
                        Type = "CheckBox",
                        Text = "Environment ContextMenus",
                        Name = "EnvironmentCMs",
                                Value = Config[tostring(game.PlaceId)].EnvironmentCMs,
                                M1Func = function(Value)
                                    Config[tostring(game.PlaceId)].EnvironmentCMs = Value
                                    Config:Write()
                                end
                    },
                    {
                        Text = "Player Lookup Options",
                        Submenu = {
                            {
                                Type = "CheckBox",
                                Text = 'Include LP in "random"',
                                Name = "LPRandom",
                                Value = Config.RandomIncludeLP,
                                M1Func = function(Value)
                                    Config.RandomIncludeLP = Value
                                    Config:Write()
                                end
                            },
                            {
                                Type = "CheckBox",
                                Text = 'Randomize Partial Names',
                                Name = "RandomizeName",
                                Value = Config.RandomizeName,
                                M1Func = function(Value)
                                    Config.RandomizeName = Value
                                    Config:Write()
                                end
                            },
                            {
                                Type = "Slider",
                                Text = "Old Account Age Minimum (Years)",
                                Name = "OldAccountAgeMin",
                                ValueDisplay = true,
                                MaxValue = 20,
                                MinValue = 1,
                                MinSliderSize = 200,
                                Rounding = 1,
                                StartingValue = Util.round(Config.OldAccountAgeMin/365,1),
                                OnRelease = function(Value) 
                                    Config.OldAccountAgeMin = Value*365
                                    Config:Write()
                                end
                            },
                            {
                                Type = "Slider",
                                Text = "New Account Age Maximum (Days)",
                                Name = "NewAccountAgeMax",
                                ValueDisplay = true,
                                MaxValue = 365,
                                MinValue = 1,
                                Rounding = 0,
                                MinSliderSize = 200,
                                StartingValue = Config.NewAccountAgeMax,
                                OnRelease = function(Value) 
                                    Config.NewAccountAgeMax = Value
                                    Config:Write()
                                end
                            },
                            {
                                Type = "Slider",
                                Text = "Far Distance",
                                Name = "FarDistance",
                                ValueDisplay = true,
                                MaxValue = 20000,
                                MinValue = 1000,
                                MinSliderSize = 200,
                                StartingValue = Config.FarDistance,
                                OnRelease = function(Value) 
                                    Config.FarDistance = Value
                                    Config:Write()
                                end
                            },
                            {
                                Type = "Slider",
                                Text = "Near Distance",
                                Name = "NearDistance",
                                ValueDisplay = true,
                                MaxValue = 5000,
                                MinValue = 0,
                                MinSliderSize = 200,
                                StartingValue = Config.NearDistance,
                                OnRelease = function(Value) 
                                    Config.NearDistance = Value
                                    Config:Write()
                                end
                            }
                        }
                    },
                    {
                        Type = "CheckBox",
                        Text = "Shift-Click ChatLogs",
                        Name = "QuickChatLogs",
                                Value = Config[tostring(game.PlaceId)].QuickChatLogs,
                                M1Func = function(Value)
                                    Config[tostring(game.PlaceId)].QuickChatLogs = Value
                                    Config:Write()
                                end
                    },
                    {
                        Type = "CheckBox",
                        Text = "Chat Spy",
                        Name = "ChatSpy",
                                Value = Config.ChatSpy,
                                M1Func = function(Value)
                                    Config.ChatSpy = Value
                                    Config:Write()
                                end
                    },
                    {
                        Type = "Slider",
                        Text = "Chat Log Limit",
                        Name = "ChatLogLimit",
                        ValueDisplay = true,
                        MaxValue = 50000,
                        MinValue = 1000,
                        MinSliderSize = 200,
                        StartingValue = Config.ChatLogLimit,
                        Rounding = 0,
                        OnRelease = function(Value) 
                            Config.ChatLogLimit = Value
                            Config:Write()
                        end
                    },
                    {
                        Text = "ESP Settings...",
                        Submenu = function()
                            return {
                                {
                                    Text = "Style...",
                                    Submenu = (function()
                                        local out = {}
                                        for _, Type in pairs({"Highlight", "Box"}) do
                                            table.insert(out,{
                                                Text = Type,
                                                Type = "CheckBox",
                                                Name = Type,
                                                Value = Config[tostring(game.PlaceId)].ESP.Style == Type,
                                                IsAChoice = true,
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.Style = Type
                                                    Config:Write()
                                                end,
                                                OnUnchecked = function(Value)
                                                    Config:Write()
                                                end
                                            })
                                        end
                                        return out
                                    end)
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Show LocalPlayer Text",
                                    Name = "ShowLP",
                                    Value = Config[tostring(game.PlaceId)].ESP.ShowLP,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].ESP.ShowLP = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Show Name",
                                    Name = "ShowName",
                                    Value = Config[tostring(game.PlaceId)].ESP.ShowName,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].ESP.ShowName = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Show DisplayName",
                                    Name = "ShowDisplayName",
                                    Value = Config[tostring(game.PlaceId)].ESP.ShowDisplayName,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].ESP.ShowDisplayName = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Show Health",
                                    Name = "ShowHealth",
                                    Value = Config[tostring(game.PlaceId)].ESP.ShowHealth,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].ESP.ShowHealth = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Text = "Health Display Type...",
                                    Submenu = (function()
                                        local out = {}
                                        for _, Type in pairs(ESPHealthDisplayTypes) do
                                            table.insert(out,{
                                                Text = Type,
                                                Type = "CheckBox",
                                                Name = Type,
                                                Value = Config[tostring(game.PlaceId)].ESP.ShowHealthType == Type,
                                                IsAChoice = true,
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.ShowHealthType = Type
                                                    Config[tostring(game.PlaceId)].ESP.ShowHealth = true
                                                    Config:Write()
                                                end,
                                                OnUnchecked = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.ShowHealth = false
                                                    Config:Write()
                                                end
                                            })
                                        end
                                        return out
                                    end)
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Show Distance",
                                    Name = "ShowDistance",
                                    Value = Config[tostring(game.PlaceId)].ESP.ShowDistance,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].ESP.ShowDistance = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "Slider",
                                    Text = "Distance decimal points",
                                    Name = "DistanceDecimalPoints",
                                    ValueDisplay = true,
                                    MaxValue = 3,
                                    MinValue = 0,
                                    MinSliderSize = 200,
                                    StartingValue = Config[tostring(game.PlaceId)].ESP.DistanceDecimalPoints,
                                    Rounding = 0,
                                    OnRelease = function(Value) 
                                        Config[tostring(game.PlaceId)].ESP.DistanceDecimalPoints = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Limit Detail Distance",
                                    Name = "UseDetailsDistance",
                                    Value = Config[tostring(game.PlaceId)].ESP.UseDetailsDistance,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].ESP.UseDetailsDistance = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Text = "Details to hide...",
                                    Submenu = function()
                                        local out = {}
                                        for Type, Val in pairs(Config[tostring(game.PlaceId)].ESP.Details) do
                                            table.insert(out,{
                                                Text = Type,
                                                Type = "CheckBox",
                                                Name = Type,
                                                Value = Val,
                                                M1Func = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.Details[Type] = Value
                                                    Config:Write()
                                                end
                                            })
                                        end
                                        return out
                                    end
                                },
                                {
                                    Type = "Slider",
                                    Text = "Detail Distance",
                                    Name = "DetailDistance",
                                    ValueDisplay = true,
                                    MaxValue = 1000,
                                    MinValue = 20,
                                    MinSliderSize = 200,
                                    StartingValue = Config[tostring(game.PlaceId)].ESP.DetailDistance,
                                    Rounding = 0,
                                    OnRelease = function(Value) 
                                        Config[tostring(game.PlaceId)].ESP.DetailDistance = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Text = "Show Team...",
                                    Submenu = function()
                                        return {
                                            {
                                                Type = "CheckBox",
                                                Text = "All",
                                                Name = "All",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].ESP.TeamType == "all",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.TeamType = "all"
                                                    Config:Write()
                                                end
                                            },
                                            {
                                                Type = "CheckBox",
                                                Text = "Enemies",
                                                Name = "Enemies",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].ESP.TeamType == "enemy",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.TeamType = "enemy"
                                                    Config:Write()
                                                end
                                            },{
                                                Type = "CheckBox",
                                                Text = "Allies",
                                                Name = "Allies",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].ESP.TeamType == "friendly",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.TeamType = "friendly"
                                                    Config:Write()
                                                end
                                            },{
                                                Type = "CheckBox",
                                                Text = "Selected...",
                                                Name = "Selected",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].ESP.TeamType == "select",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.TeamType = "select"
                                                    Config:Write()
                                                end,
                                                Submenu = function()
                                                    local out = {}
                                                    for _, Team in pairs(game:GetService("Teams"):GetChildren()) do
                                                        table.insert(out, {
                                                            Text = `<font color="#{Team.TeamColor.Color:ToHex()}">{Team.Name}</font>`,
                                                            Name = Team.Name,
                                                            Type = "CheckBox",
                                                            Value = ESPTeams[Team.Name],
                                                            M1Func = function(Value)
                                                                ESPTeams[Team.Name] = Value
                                                            end
                                                        })
                                                    end
                                                    return out
                                                end
                                            }
                                        }
                                    end
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Team Colors",
                                    Name = "TeamColors",
                                    Value = Config[tostring(game.PlaceId)].ESP.TeamColors,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].ESP.TeamColors = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "List Colors",
                                    Name = "ListColors",
                                    Value = Config[tostring(game.PlaceId)].ESP.ListColors,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].ESP.ListColors = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "Slider",
                                    Text = "Distance",
                                    Name = "Distance",
                                    ValueDisplay = true,
                                    MaxValue = 20000,
                                    MinValue = 100,
                                    MinSliderSize = 200,
                                    StartingValue = Config[tostring(game.PlaceId)].ESP.Distance,
                                    Rounding = 0,
                                    OnRelease = function(Value) 
                                        Config[tostring(game.PlaceId)].ESP.Distance = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Text = "Distance Mode...",
                                    Submenu = function()
                                        return {
                                            {
                                                Type = "CheckBox",
                                                Text = "Character",
                                                Name = "Character",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].ESP.DistanceMode == "Character",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.DistanceMode = "Character"
                                                    Config:Write()
                                                end
                                            },
                                            {
                                                Type = "CheckBox",
                                                Text = "Camera",
                                                Name = "Camera",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].ESP.DistanceMode == "Camera",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].ESP.DistanceMode = "Camera"
                                                    Config:Write()
                                                end
                                            }
                                        }
                                    end
                                },
                                {
                                    Type = "Keybind",
                                    Keybind = Config[tostring(game.PlaceId)].ESP.Keybind,
                                    Text = "Keybind",
                                    OnKeybindChange = function(input)
                                        Config[tostring(game.PlaceId)].ESP.Keybind = input.KeyCode
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "Color3",
                                    Mode = "RGB",
                                    Text = "Default Color",
                                    Color = Config[tostring(game.PlaceId)].ESP.DefaultColor,
                                    OnColorChange = function(Color)
                                        Config[tostring(game.PlaceId)].ESP.DefaultColor = Color
                                        Config:Write()
                                    end
                                } 
                            }
                        end,
                        SubmenuSettings = {
                            OnlyCloseSelf = true
                        }
                    },
                    {
                        Text = "Aimbot Settings...",
                        Submenu = function()
                            return {
                                {
                                    Text = "Method...",
                                    Submenu = (function()
                                        local out = {}
                                        for _, Type in pairs({"Lock", "Smooth", "Silent"}) do
                                            table.insert(out,{
                                                Text = Type,
                                                Type = "CheckBox",
                                                Name = Type,
                                                Value = Config[tostring(game.PlaceId)].Aimbot.Method == Type,
                                                IsAChoice = true,
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].Aimbot.Method = Type
                                                    Config:Write()
                                                end,
                                                OnUnchecked = function(Value)
                                                    Config:Write()
                                                end,
                                                Submenu = Type == "Silent" and function()
                                                    local out = {}
                                                    for _, Type in pairs({"FindPartOnRayWithWhitelist", "FindPartOnRayWithIgnoreList", "FindPartOnRay", "FindPartOnRay", "Raycast", "Mouse Hit"}) do
                                                        table.insert(out,{
                                                            Text = Type,
                                                            Type = "CheckBox",
                                                            Name = Type,
                                                            Value = Config[tostring(game.PlaceId)].Aimbot.SilentMode == Type,
                                                            IsAChoice = true,
                                                            OnChecked = function(Value)
                                                                Config[tostring(game.PlaceId)].Aimbot.SilentMode = Type
                                                                Config:Write()
                                                            end,
                                                            OnUnchecked = function(Value)
                                                                Config:Write()
                                                            end
                                                        })
                                                    end
                                                    return out
                                                end
                                            })
                                        end
                                        return out
                                    end)
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Ignore Dead",
                                    Name = "IgnoreDead",
                                    Value = Config[tostring(game.PlaceId)].Aimbot.IgnoreDead,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].Aimbot.IgnoreDead = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Ignore Staff",
                                    Name = "IgnoreStaff",
                                    Value = Config[tostring(game.PlaceId)].Aimbot.IgnoreStaff,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].Aimbot.IgnoreStaff = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Wall Check",
                                    Name = "WallCheck",
                                    Value = Config[tostring(game.PlaceId)].Aimbot.WallCheck,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].Aimbot.WallCheck = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "Slider",
                                    Text = "Distance",
                                    Name = "AimbotDistance",
                                    ValueDisplay = true,
                                    MaxValue = 10000,
                                    MinValue = 5,
                                    MinSliderSize = 200,
                                    StartingValue = Config[tostring(game.PlaceId)].Aimbot.Distance,
                                    Rounding = 0,
                                    OnRelease = function(Value) 
                                        Config[tostring(game.PlaceId)].Aimbot.Distance = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "Slider",
                                    Text = "FOV",
                                    Name = "AimbotFOV",
                                    ValueDisplay = true,
                                    MaxValue = 500,
                                    MinValue = 0,
                                    MinSliderSize = 200,
                                    StartingValue = Config[tostring(game.PlaceId)].Aimbot.FOV,
                                    Rounding = 0,
                                    OnRelease = function(Value) 
                                        Config[tostring(game.PlaceId)].Aimbot.FOV = Value
                                        local CT = CoreGui:FindFirstChild("CT")
                                        if CT then
                                            local Circle = CT:FindFirstChild("FOVSphere")
                                            if Circle then
                                                Circle.Visible = false
                                            end
                                        end
                                        Config:Write()
                                    end,
                                    OnValueChange = function(Value)
                                        local CT = CoreGui:FindFirstChild("CT")
                                        if CT then
                                            local Circle = CT:FindFirstChild("FOVSphere")
                                            if Circle then
                                                Circle.Visible = true
                                                Circle.Size = UDim2.fromOffset(Value, Value)
                                            else
                                                Circle = CreateObject("Frame",{
                                                    Name = "FOVSphere",
                                                    BackgroundTransparency = 1,
                                                    AnchorPoint = Vector2.new(0.5,0.5),
                                                    Position = UDim2.fromScale(0.5,0.5),
                                                    Size = UDim2.fromOffset(Value, Value),
                                                    Parent = CT
                                                })
                                                CreateObject("UICorner",{
                                                    CornerRadius = UDim.new(1,0),
                                                    Parent = Circle
                                                })
                                                CreateObject("UIStroke",{
                                                    LineJoinMode = Enum.LineJoinMode.Round,
                                                    Thickness = 1,
                                                    Color = Color3.new(1,1,1),
                                                    Parent = Circle
                                                })
                                            end
                                        end
                                    end
                                },
                                {
                                    Text = "Show Team...",
                                    Submenu = function()
                                        return {
                                            {
                                                Type = "CheckBox",
                                                Text = "All",
                                                Name = "All",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].Aimbot.TeamType == "all",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].Aimbot.TeamType = "all"
                                                    Config:Write()
                                                end
                                            },
                                            {
                                                Type = "CheckBox",
                                                Text = "Enemies",
                                                Name = "Enemies",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].Aimbot.TeamType == "enemy",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].Aimbot.TeamType = "enemy"
                                                    Config:Write()
                                                end
                                            },
                                            {
                                                Type = "CheckBox",
                                                Text = "Allies",
                                                Name = "Allies",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].Aimbot.TeamType == "friendly",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].Aimbot.TeamType = "friendly"
                                                    Config:Write()
                                                end
                                            },
                                            {
                                                Type = "CheckBox",
                                                Text = "Selected...",
                                                Name = "Selected",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].Aimbot.TeamType == "select",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].Aimbot.TeamType = "select"
                                                    Config:Write()
                                                end,
                                                Submenu = function()
                                                    local out = {}
                                                    for _, Team in pairs(game:GetService("Teams"):GetChildren()) do
                                                        table.insert(out, {
                                                            Text = `<font color="#{Team.TeamColor.Color:ToHex()}">{Team.Name}</font>`,
                                                            Name = Team.Name,
                                                            Type = "CheckBox",
                                                            Value = AimbotTeams[Team.Name],
                                                            M1Func = function(Value)
                                                                AimbotTeams[Team.Name] = Value
                                                            end
                                                        })
                                                    end
                                                    return out
                                                end
                                            }
                                        }
                                    end
                                },
                                (function()
                                    if ListsModule then
                                        return {
                                            Text = "Ignore Lists...",
                                            Submenu = function()
                                                local out = {}
                                                for _, List in pairs({"Whitelist", "SoftWhitelist", "Blacklist"}) do
                                                    table.insert(out, {
                                                        Text = List,
                                                        Name = List,
                                                        Type = "CheckBox",
                                                        Value = Config[tostring(game.PlaceId)].Aimbot.IgnoreLists[List],
                                                        M1Func = function(Value)
                                                            Config[tostring(game.PlaceId)].Aimbot.IgnoreLists[List] = Value
                                                            Config:Write()
                                                        end
                                                    })
                                                end
                                                return out
                                            end
                                        }
                                    else
                                        return nil
                                    end
                                end)(),
                                {
                                    Type = "Keybind",
                                    Keybind = Config[tostring(game.PlaceId)].Aimbot.Keybind,
                                    Text = "Toggle Keybind",
                                    OnKeybindChange = function(input)
                                        Config[tostring(game.PlaceId)].Aimbot.Keybind = input.KeyCode
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "Keybind",
                                    Keybind = Config[tostring(game.PlaceId)].Aimbot.AimKey,
                                    Text = "Aim Keybind",
                                    OnKeybindChange = function(input)
                                        Config[tostring(game.PlaceId)].Aimbot.AimKey = input.KeyCode
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "CheckBox",
                                    Text = "Drop Compensation...",
                                    Name = "Drop",
                                    Value = Config[tostring(game.PlaceId)].Aimbot.Drop,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].Aimbot.Drop = Value
                                        Config:Write()
                                    end,
                                    Submenu = function()
                                        return {
                                            {
                                                Type = "CheckBox",
                                                Text = "Linear",
                                                Name = "Linear",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].Aimbot.DropType == "Linear",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].Aimbot.DropType = "Linear"
                                                    Config:Write()
                                                end
                                            },
                                            {
                                                Type = "CheckBox",
                                                Text = "Linear with Increase",
                                                Name = "LinearInc",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].Aimbot.DropType == "LinearInc",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].Aimbot.DropType = "LinearInc"
                                                    Config:Write()
                                                end
                                            },
                                            {
                                                Type = "CheckBox",
                                                Text = "Quad",
                                                Name = "Quad",
                                                IsAChoice = true,
                                                Value = Config[tostring(game.PlaceId)].Aimbot.DropType == "Quad",
                                                OnChecked = function(Value)
                                                    Config[tostring(game.PlaceId)].Aimbot.DropType = "Quad"
                                                    Config:Write()
                                                end
                                            }
                                        }
                                    end
                                },
                                {
                                    Type = "Slider",
                                    Text = "Drop Amount",
                                    Name = "DropAmount",
                                    ValueDisplay = true,
                                    MaxValue = 25,
                                    MinValue = 0,
                                    MinSliderSize = 250,
                                    Tooltip = (
                                        Config[tostring(game.PlaceId)].Aimbot.DropType == "Linear" and "(Distance/1000)*Amount" or
                                        Config[tostring(game.PlaceId)].Aimbot.DropType == "LinearInc" and "((Distance/1000)*Amount)+(Distance/1000)^Increase" or
                                        Config[tostring(game.PlaceId)].Aimbot.DropType == "Quad" and "(Distance^2)/(100000/Amount)"
                                    ),
                                    StartingValue = Config[tostring(game.PlaceId)].Aimbot.DropAmount,
                                    Rounding = 1,
                                    OnRelease = function(Value) 
                                        Config[tostring(game.PlaceId)].Aimbot.DropAmount = Value
                                        Config:Write()
                                    end
                                },
                                (function()
                                    if Config[tostring(game.PlaceId)].Aimbot.DropType == "LinearInc" or true then
                                        return {
                                            Type = "Slider",
                                            Text = "Drop Increase",
                                            Name = "DropIncrease",
                                            ValueDisplay = true,
                                            MaxValue = 10,
                                            MinValue = -10,
                                            MinSliderSize = 200,
                                            Tooltip = (
                                                Config[tostring(game.PlaceId)].Aimbot.DropType == "Linear" and "(Distance/1000)*Amount" or
                                                Config[tostring(game.PlaceId)].Aimbot.DropType == "LinearInc" and "((Distance/1000)*Amount)+(Distance/1000)^Increase" or
                                                Config[tostring(game.PlaceId)].Aimbot.DropType == "Quad" and "(Distance^2)/(100000/Amount)"
                                            ),
                                            StartingValue = Config[tostring(game.PlaceId)].Aimbot.DropIncrease,
                                            Rounding = 1,
                                            OnRelease = function(Value) 
                                                Config[tostring(game.PlaceId)].Aimbot.DropIncrease = Value
                                                Config:Write()
                                            end
                                        }
                                    end
                                end)(),
                                {
                                    Type = "CheckBox",
                                    Text = "Prediction...",
                                    Name = "Pred",
                                    Value = Config[tostring(game.PlaceId)].Aimbot.Pred,
                                    M1Func = function(Value)
                                        Config[tostring(game.PlaceId)].Aimbot.Pred = Value
                                        Config:Write()
                                    end
                                },
                                {
                                    Type = "Slider",
                                    Text = "Prediction Amount",
                                    Name = "PredAmount",
                                    ValueDisplay = true,
                                    MaxValue = 5,
                                    MinValue = -5,
                                    MinSliderSize = 200,
                                    Tooltip = "((Velocity*Distance)/1000)*Amount",
                                    StartingValue = Config[tostring(game.PlaceId)].Aimbot.PredAmount,
                                    Rounding = 2,
                                    OnRelease = function(Value) 
                                        Config[tostring(game.PlaceId)].Aimbot.PredAmount = Value
                                        Config:Write()
                                    end
                                }
                            }
                        end,
                        SubmenuSettings = {
                            OnlyCloseSelf = true
                        }
                    }
                } 
            end
        }
    }
    for _, v in pairs(CustomThemeproviderEntries) do
        if typeof(v) == "function" then
            v = v()
        end
        for _, e in pairs(v) do
            table.insert(Entries, e)
        end
    end
    
    return table.unpack(Entries)
end
local function PlayerEntries(Player)
    local Entries = {
        {
            FrameAnchorPoint = Util.CMAnchorPoint(),
            Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
            TitleText = "<font color=\"#"..Util.ComputeNameColor(Player.Name):ToHex().."\">"..Player.DisplayName.." (@"..Player.Name..")</font>   ",
            TitleIcon = Util.GetClassIcon("Player"),
            ContextMenuEntries = {
                TextSize = ContextMenuSize
            }
        },
        {
            Text = "Go to",
            Icon = Util.GetClassIcon("Workspace"),
            Tooltip = "Teleports you to the player.",
            M1Func = function()
                Functions.TeleportTo(Player.Character.HumanoidRootPart)
            end
        },
        {
            Text = "View",
            Tooltip = "Views the player.",
            Icon = Util.GetClassIcon("Camera"),
            M1Func = function()
                local Humanoid = Player.Character
                if Humanoid then
                    Humanoid = Humanoid:FindFirstChild("Humanoid")
                    if Humanoid then
                        workspace.CurrentCamera.CameraSubject = Humanoid
                    end
                end
            end
        },
        function()
            if ListsModule then
                return {
                    Text = "Lists...",
                    Icon = Util.GetClassIcon("Players"),
                    Submenu = GenListSubMenu(Player.UserId),
                    Tooltip = "Assing player to lists"
                }
            end
        end,
        {
            Type = "Divider"
        },
        {
            Text = "ChatLogs...",
            Icon = Util.GetClassIcon("Chat"),
            Submenu = {
                {
                    Text = "Filtered",
                    Icon = Util.GetClassIcon("TextChatService"),
                    M1Func = function()
                        Functions.OpenChatLogs(ContextMenus, {Player.Name})
                    end,
                    Tooltip = "ChatLogs ONLY of player."
                },
                {
                    Text = "Local",
                    Icon = Util.GetClassIcon("TextSource"),
                    Submenu = {
                        {
                            Type = "Slider",
                            Text = "Distance",
                            Name = "chatDistance",
                            ValueDisplay = true,
                            MaxValue = 100,
                            MinValue = 2,
                            Rounding = 0,
                            MinSliderSize = 100,
                            StartingValue = Config[tostring(game.PlaceId)].LocalChatLogDist,
                            OnRelease = function(Value)
                                Config[tostring(game.PlaceId)].LocalChatLogDist = Value
                            end
                        }
                    },
                    M1Func = function()
                        local _Filter = {}
                        local PlayerPos = Player.Character.HumanoidRootPart.Position
                        for _, v in pairs(Players:GetChildren()) do
                            if v.Character:FindFirstChild("HumanoidRootPart") and (v.Character.HumanoidRootPart.Position-PlayerPos).Magnitude < Config[tostring(game.PlaceId)].LocalChatLogDist then
                                table.insert(_Filter, v.Name)
                            end
                        end
                        Functions.OpenChatLogs(ContextMenus, _Filter)
                    end,
                    Tooltip = "ChatLogs of everyone within "..Config[tostring(game.PlaceId)].LocalChatLogDist.." studs from the player."
                }
            }
        },
        {
            Text = "Copy...",
            Submenu = {
                {
                    Text = "UserName",
                    Icon = Util.GetClassIcon("Player"),
                    M1Func = function()
                        setclipboardint(Player.Name)
                    end
                },
                {
                    Text = "DisplayName",
                    Icon = Util.GetClassIcon("Player"),
                    M1Func = function()
                        setclipboardint(Player.DisplayName)
                    end
                },
                {
                    Text = "UserId",
                    Icon = Util.GetClassIcon("Player"),
                    M1Func = function()
                        setclipboardint(tostring(Player.UserId))
                    end
                },
                {
                    Text = "Player as path",
                    Icon = Util.GetClassIcon("Player"),
                    M1Func = function()
                        setclipboardint("game:GetService(\"Players\")[\""..Player.Name.."\"]")
                    end
                },
                {
                    Text = "Character as path",
                    Icon = Util.GetClassIcon("Humanoid"),
                    M1Func = function()
                        setclipboardint("game:GetService(\"Players\")[\""..Player.Name.."\"].Character")
                    end
                },
                {
                    Text = "Serialize",
                    Icon = Util.GetClassIcon("Model"),
                    Tooltip = "Serializes the player.",
                    M1Func = function()
                        local Serialized = Util.JSONEncode(InstanceSerializer.Serialize(Player.Character))
                        setclipboardint(Serialized)
                        if not isfolder("SerializedCharacters") then makefolder("SerializedCharacters") end
                        writefile("SerializedCharacters/"..Player.Name.." "..os.time()..".json", Serialized)
                    end
                }
            }
        },
        CheckDex(Player)
    }
    for _, v in pairs(CustomPlayerEntries) do
        if typeof(v) == "function" then
            v = v(Player)
        end
        for _, e in pairs(v) do
            table.insert(Entries, e)
        end
    end
    return table.unpack(Entries)
end
local function LPEntries(Player)
    local Entries = {
        {
            FrameAnchorPoint = Util.CMAnchorPoint(),
            Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
            TitleText = "<font color=\"#"..Util.ComputeNameColor(Player.Name):ToHex().."\">"..Player.DisplayName.." (@"..Player.Name..")</font>   ",
            TitleIcon = Util.GetClassIcon("Player"),
            ContextMenuEntries = {
                TextSize = ContextMenuSize
            }
        },
        {
            Text = "Character Settings...",
            Tooltip = "Character settings.",
            Icon = Util.GetClassIcon("Humanoid"),
            Submenu = {
                {
                    Type = "CheckBox",
                    Text = "PlatformStand",
                    Name = "PlatformStand",
                    Value = LP.Character.Humanoid.PlatformStand,
                    M1Func = function(Value)
                        LP.Character.Humanoid.PlatformStand = Value
                    end
                },
                {
                    Type = "CheckBox",
                    Text = "Anchored",
                    Name = "Anchored",
                    Value = LP.Character.HumanoidRootPart.Anchored,
                    M1Func = function(Value)
                        LP.Character.HumanoidRootPart.Anchored = Value
                    end
                },
                {
                    Type = "CheckBox",
                    Tooltip = "Currently R6 only!",
                    Text = "Frozen",
                    Name = "Frozen",
                    Value = LP.Character:FindFirstChild("FreezeWelds"),
                    OnChecked = function(Value)
                        local Welds = Instance.new("Folder", Player.Character)
                        Welds.Name = "FreezeWelds"
                        local parts = {"Torso", "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg"}
                        for i, v in pairs(parts) do
                            parts[i] = LP.Character[v]
                        end
                        for _, v in pairs(parts) do
                            local weld = Instance.new("WeldConstraint", Welds)
                            weld.Part0 = v
                            weld.Part1 = LP.Character.HumanoidRootPart
                        end
                        LP.Character.Humanoid.PlatformStand = true
                    end,
                    OnUnchecked = function(Value)
                        LP.Character:FindFirstChild("FreezeWelds"):Destroy()
                        LP.Character.Humanoid.PlatformStand = false
                    end
                },
                {
                    Type = "CheckBox",
                    Text = "Infinite Jump",
                    Name = "Infinite Jump",
                    Value = infiniteJump,
                    OnChecked = function(Value)
                        infiniteJump = true
                    end,
                    OnUnchecked = function(Value)
                        infiniteJump = false
                    end
                },
                {
                    Type = "Slider",
                    Text = "WalkSpeed",
                    Name = "WalkSpeed",
                    ValueDisplay = true,
                    MaxValue = 100,
                    MinValue = 0,
                    MinSliderSize = 200,
                    StartingValue = LP.Character.Humanoid.WalkSpeed,
                    OnValueChange = function(Value) 
                        LP.Character.Humanoid.WalkSpeed = Value
                    end
                },
                {
                    Type = "Slider",
                    Text = "JumpPower",
                    Name = "JumpPower",
                    ValueDisplay = true,
                    MaxValue = 250,
                    MinValue = 0,
                    MinSliderSize = 200,
                    StartingValue = LP.Character.Humanoid.JumpPower,
                    OnValueChange = function(Value) 
                        LP.Character.Humanoid.JumpPower = Value
                    end
                },
                {
                    Type = "Slider",
                    Text = "Gravity",
                    Name = "Gravity",
                    ValueDisplay = true,
                    MaxValue = 400,
                    MinValue = 0,
                    Rounding = 2,
                    MinSliderSize = 200,
                    StartingValue = workspace.Gravity,
                    OnValueChange = function(Value) 
                        workspace.Gravity = Value
                    end
                },
                {
                    Text = "Reset Gravity",
                    M1Func = function()
                        workspace.Gravity = 196.19999694824
                    end
                },
                {
                    Type = "Slider",
                    Text = "HipHeight",
                    Name = "HipHeight",
                    ValueDisplay = true,
                    MaxValue = 10,
                    MinValue = -2,
                    Rounding = 1,
                    MinSliderSize = 100,
                    StartingValue = LP.Character.Humanoid.HipHeight,
                    OnValueChange = function(Value) 
                        LP.Character.Humanoid.HipHeight = Value
                    end
                },
                {
                    Type = "Slider",
                    Text = "Health",
                    Name = "Health",
                    ValueDisplay = true,
                    MaxValue = 100,
                    MinValue = 0,
                    MinSliderSize = 100,
                    StartingValue = LP.Character.Humanoid.Health,
                    OnValueChange = function(Value)
                        LP.Character.Humanoid.Health = Value
                    end
                },
                {
                    Type = "CheckBox",
                    Text = "Name Hidden",
                    Name = "NameHidden",
                    Value = Config[tostring(LP.UserId)].NameHidden,
                    M1Func = function(Value)
                        Config[tostring(LP.UserId)].NameHidden = Value
                        Config:Write()
                    end
                }
            }
        },
        {
            Type = "Divider"
        },
        {
            Text = "Refresh",
            Tooltip = "Refreshes your character.",
            M1Func = refresh
        },
        function()
            if ListsModule then
                return {
                    Text = "Lists...",
                    Icon = Util.GetClassIcon("Players"),
                    Submenu = GenListSubMenu(Player.UserId),
                    Tooltip = "Assing player to lists"
                }
            end
        end,
        {
            Text = "Teleport to...",
            Tooltip = "Teleport yourself.",
            Submenu = {
                {
                    Text = "Players...",
                    Icon = Util.GetClassIcon("Players"),
                    Submenu = GetGotoList(),
                    SubmenuSettings = {Scrollable = true, ScrollableSizeY = 300, SortOrder = "Name"}
                },
                {
                    Text = "Saved Positions...",    
                    Icon = Util.GetClassIcon("SpawnLocation"),
                    Submenu = GetPosList(),
                    SubmenuSettings = {Scrollable = true, ScrollableSizeY = 300, SortOrder = "Name"}
                },
                {
                    Text = "Save position...",
                    Icon = Util.GetClassIcon("SpawnLocation"),
                    M1Func = function()
                        xpcall(function()
                            local PosName = ""
                            ContextMenus.Prompt(
                                {
                                    Content = {
                                        {
                                            ClassName = "TextBox",
                                            Size = UDim2.new(1,0,0,28),
                                            Text = GroupId,
                                            TextSize = 24,
                                            PlaceholderText = "Position Name",
                                            TextYAlignment = Enum.TextYAlignment.Center,
                                            TextColor3 = Color3.fromHex("9cdcfe"),
                                            InitFunction = function(self, prompt, settings)
                                                self.FocusLost:Connect(function()
                                                    PosName = self.ContentText
                                                end)
                                            end
                                        }
                                    },
                                    Settings = {
                                        Focus = false, 
                                        ButtonAlignment = "Right", 
                                        ReturnType = "Object",
                                        Title = {
                                            Text = "Save Position"
                                        },
                                        Content = {ClipsDescendants = false}
                                    },
                                    Buttons = {
                                        {
                                            Text = "Save", 
                                            M1Func = function(prompt)
                                                WPs[tostring(game.PlaceId)][PosName] = LP.Character.HumanoidRootPart.CFrame
                                                WPs:Write()
                                            end
                                        },
                                        {
                                            Text = "Cancel"
                                        }
                                    }
                                }
                            ) 
                        end,warn)
                    end
                }
            }
        },
        {
            Type = "Divider"
        },
        {
            Text = "Copy...",
            Submenu = {
                {
                    Text = "UserName",
                    Icon = Util.GetClassIcon("Player"),
                    M1Func = function()
                        setclipboardint(Player.Name)
                    end
                },
                {
                    Text = "DisplayName",
                    Icon = Util.GetClassIcon("Player"),
                    M1Func = function()
                        setclipboardint(Player.DisplayName)
                    end
                },
                {
                    Text = "UserId",
                    Icon = Util.GetClassIcon("Player"),
                    M1Func = function()
                        setclipboardint(tostring(Player.UserId))
                    end
                },
                {
                    Text = "Player as path",
                    Icon = Util.GetClassIcon("Player"),
                    M1Func = function()
                        setclipboardint("game:GetService(\"Players\")[\""..Player.Name.."\"]")
                    end
                },
                {
                    Text = "Character as path",
                    Icon = Util.GetClassIcon("Humanoid"),
                    M1Func = function()
                        setclipboardint("game:GetService(\"Players\")[\""..Player.Name.."\"].Character")
                    end
                },
                {
                    Text = "Serialize",
                    Icon = Util.GetClassIcon("Model"),
                    Tooltip = "Serializes the player.",
                    M1Func = function()
                        local Serialized = Util.JSONEncode(InstanceSerializer.Serialize(Player.Character))
                        setclipboardint(Serialized)
                        if not isfolder("SerializedCharacters") then makefolder("SerializedCharacters") end
                        writefile("SerializedCharacters/"..Player.Name.." "..os.time()..".json", Serialized)
                    end
                }
            }
        },
        {
            Text = "ChatLogs...",
            Icon = Util.GetClassIcon("Chat"),
            Submenu = {
                {
                    Text = "Filtered",
                    Icon = Util.GetClassIcon("TextChatService"),
                    M1Func = function()
                        Functions.OpenChatLogs(ContextMenus, {Player.Name})
                    end,
                    Tooltip = "ChatLogs ONLY of player."
                },
                {
                    Text = "Local",
                    Icon = Util.GetClassIcon("TextSource"),
                    Submenu = {
                        {
                            Type = "Slider",
                            Text = "Distance",
                            Name = "chatDistance",
                            ValueDisplay = true,
                            MaxValue = 100,
                            MinValue = 2,
                            Rounding = 0,
                            MinSliderSize = 100,
                            StartingValue = Config[tostring(game.PlaceId)].LocalChatLogDist,
                            OnRelease = function(Value)
                                Config[tostring(game.PlaceId)].LocalChatLogDist = Value
                            end
                        }
                    },
                    M1Func = function()
                        local _Filter = {}
                        local PlayerPos = Player.Character.HumanoidRootPart.Position
                        for _, v in pairs(Players:GetChildren()) do
                            pcall(function()
                                if (v.Character.HumanoidRootPart.Position-PlayerPos).Magnitude < Config[tostring(game.PlaceId)].LocalChatLogDist then
                                    table.insert(_Filter, v.Name)
                                end
                            end)
                        end
                        Functions.OpenChatLogs(ContextMenus, _Filter)
                    end,
                    Tooltip = "ChatLogs of everyone within "..Config[tostring(game.PlaceId)].LocalChatLogDist.." studs from the player."
                }
            }
        },
        CheckDex(Player)
    }
    for _, v in pairs(CustomLPEntries) do
        if typeof(v) == "function" then
            v = v(Player)
        end
        for _, e in pairs(v) do
            table.insert(Entries, e)
        end
    end
    return table.unpack(Entries)
end

if not isfolder("Assets") then makefolder("Assets") end
task.spawn(function()
    local Url = "https://github.com/UnseenGit/ContextHub/blob/main/CT/ContextTerminal.png?raw=true"
    local PNG = request({
        Url = Url,
        Method = "GET"
    }).Body
    writefile("Assets/ContextTerminal.png",PNG)
end)
if ThemeProvider then
    ThemeProvider.MouseButton2Down:Connect(function()
        ContextMenus.Create(ThemeProviderEntries())
    end)
    local UnviewButton = ThemeProvider.Parent:Clone()
    UnviewButton.Parent = ThemeProvider.Parent.Parent
    UnviewButton.Name = "UnviewButton"
    UnviewButton.Background.Icon.Image = "rbxassetid://13427782310"
    UnviewButton.Background.Position = UDim2.new(0, 0, -1, 0)
    UnviewButton.Size = UDim2.new(0, -12, 1, 0)
    local function CheckView()
        if LP.Character and (workspace.CurrentCamera.CameraSubject == LP.Character or (LP.Character:FindFirstChild("Humanoid") and workspace.CurrentCamera.CameraSubject == LP.Character:FindFirstChild("Humanoid"))) then
            UnviewButton.Background:TweenPosition(UDim2.new(0, 0, -1, 0),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Back, .5, 
                false
            )
            UnviewButton:TweenSize(UDim2.new(0, -12, 1, 0),
                Enum.EasingDirection.In,
                Enum.EasingStyle.Back, .5, 
                false
            )
        else
            UnviewButton.Background:TweenPosition(UDim2.new(0, 0, 1, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Back, .5, 
                false
            )
            UnviewButton:TweenSize(UDim2.new(0, 32, 1, 0),
                Enum.EasingDirection.Out,
                Enum.EasingStyle.Back, .5, 
                false
            )
        end
    end
    UnviewButton.Background.MouseButton1Click:Connect(function()
        workspace.CurrentCamera.CameraSubject = LP.Character
        CheckView()
    end)
    game:GetService('RunService').Stepped:connect(CheckView)
else
    out("ThemeProvider not found! Server menu will not work!", 10, Color3.fromHex("#ffda44"))
end

local function UserClick(Player)
    --ContextMenus = loadfile("ContextMenus.lua")()
    if Player == LP then
        WrapError("Error!",function()
            ContextMenus.Create(LPEntries(Player))
        end)
    else
        ContextMenus.Create(PlayerEntries(Player))
    end
end
local function CheckImageIsOriginal(Obj)
    for _, v in pairs(ListImages) do
        if v.ImageRectOffset == Obj.ImageRectOffset then
            return false
        end
    end
    return true
end

local function AorAn(word: string)
    if string.find("aeiou", word:sub(1,1):lower()) then
        return "An "..word
    else
        return "A "..word
    end
end
Players.PlayerAdded:Connect(function(Player)
    local StaffStatus = CheckStaff(tostring(Player.UserId))
    if StaffStatus then
        Util.Notify(AorAn(StaffStatus).." has joined the game!", Player.Name, 30)
    end
end)
local function GetPlayerListGUI()
    wait(.5)
    local ret
    repeat wait() until #CoreGui.PlayerList:GetChildren() > 0
    for _, v in pairs(CoreGui.PlayerList:GetDescendants()) do
        if v.Name == "p_"..LP.UserId then return v.Parent end
    end
    xpcall(function()
        ret = CoreGui.PlayerList.PlayerListMaster.OffsetFrame.PlayerScrollList.SizeOffsetFrame.ScrollingFrameContainer.ScrollingFrameClippingFrame.ScollingFrame.OffsetUndoFrame
    end,warn)
    if ret then return ret end
end
local function MarklistEntry(Obj)
    local Type, Id = table.unpack(string.split(Obj.Name, "_"))
    if Type == "p" then
        local List = Lists and Lists[Id]
        local StaffStatus = CheckStaff(Id)
        local Icon = Obj.ChildrenFrame.NameFrame.BGFrame.OverlayFrame.PlayerIcon
        if StaffStatus then
            List = "Staff"
            ContextMenus.CreateTooltip(Icon, StaffStatus)
        end
        if List then
            Icon.ImageColor3 = ListColors[List]
            if Icon.Image == "" or not CheckImageIsOriginal(Icon) then
                for i, v in pairs(ListImages[List]) do
                    Icon[i] = v
                end
            end
        else
            Icon.ImageColor3 = Color3.new(1,1,1)
            if not CheckImageIsOriginal(Icon) then
                Icon.Image = ""
            end
        end
    end
end

local function ConnectPlayerlist(PlayerList)
    if PlayerList then
        local function ConnectClick(Obj)
            xpcall(function()
                local Type, Id = table.unpack(string.split(Obj.Name, "_"))
                if Type == "p" then
                    local Button
                    local Player = Util.FindPlayerById(Id)
                    pcall(function()
                        Button = Obj.ChildrenFrame.NameFrame.BGFrame
                    end)
                    if Button then
                        Button.MouseButton2Down:Connect(function()
                            UserClick(Player)
                        end)
                    end
                end
            end,warn)
        end
        for _, v in pairs(PlayerList:GetChildren()) do
            ConnectClick(v)
        end
        PlayerList.ChildAdded:Connect(ConnectClick)
    else
        out("PlayerList not found! PlayerList menu will not work!", 10, Color3.fromHex("#ffda44"))
    end
    
    coroutine.wrap(function()
        while true do
            for _, Obj in pairs(PlayerList:GetChildren()) do
                xpcall(function()
                    MarklistEntry(Obj)
                end,warn)
            end
            wait(10)
        end
    end)()
    PlayerList.ChildAdded:Connect(function(Obj)
        wait()
        xpcall(function()
            MarklistEntry(Obj)
        end,warn)
    end)
end
coroutine.wrap(function()
    if GetPlayerListGUI() then ConnectPlayerlist(GetPlayerListGUI()) end
    CoreGui.PlayerList.ChildAdded:Connect(function()
        ConnectPlayerlist(GetPlayerListGUI())
    end)
end)()

local click = 0
Util.MouseClickWithoutDrag.Event:Connect(function()
    click = click+1
    pcall(function()
        if click>1 and Config[tostring(game.PlaceId)].EnvironmentCMs then
            local Player = Players:FindFirstChild(Util.FindWSChild(Util.getMouseHitIncludingChar().Instance).Name)
            if Player and (workspace.CurrentCamera.CoordinateFrame.p - Player.Character.Head.Position).magnitude > 5 then
                UserClick(Player)
            end
        end
    end)
    wait(.3)
    click = click-1
end)

local NoclipConnect
local Anti = {}
local Loop = {}
coroutine.wrap(function()
    LP.CharacterAdded:Connect(function(Char)
        Char.ChildAdded:Connect(function(Hum)
            if Hum:IsA("Humanoid") then
                Hum.Changed:Connect(function(prop)
                    if Anti[prop] then
                        Hum[prop] = false
                    end
                    if Loop[prop] then
                        Hum[prop] = Loop[prop]
                    end
                end)
                for i, v in pairs(Loop) do
                    Hum[i] = v
                end
            end
        end)
        local Hum = Char:FindFirstChild("Humanoid")
        if Hum then
            Hum.Changed:Connect(function(prop)
                if Anti[prop] then
                    Hum[prop] = false
                end
                if Loop[prop] then
                    Hum[prop] = Loop[prop]
                end
            end)
            for i, v in pairs(Loop) do
                Hum[i] = v
            end
        end
    end)
    repeat wait() until LP.Character
    LP.Character:WaitForChild("Humanoid").Changed:Connect(function(prop)
        if Anti[prop] then
            LP.Character.Humanoid[prop] = false
        end
    end)
end)()
UserInputService.JumpRequest:Connect(function()
    if infiniteJump == true then
        LP.Character.Humanoid:ChangeState("Jumping")
    end
end)
local OutputLog = {}
local CommandLog = {}
RunService.RenderStepped:connect(function()
    MouseLocation = UserInputService:GetMouseLocation()
end)

local function FindIndex(tbl, Pattern, CaseSensitive)
    if not tbl then return end
    local function l(a)
        if CaseSensitive then
            return a
        else
            return a:lower()
        end
    end
    if tbl[Pattern] then
        return Pattern
    end
    for index in pairs(tbl) do
        if index == "__index" then continue end
        if l(index) == l(Pattern) then
            return index
        end
    end
    for index in pairs(tbl) do
        if index == "__index" then continue end
        if l(index):sub(1,#Pattern) == l(Pattern) then
            return index
        end
    end
    for index in pairs(tbl) do
        if index == "__index" then continue end
        if string.match(l(index),l(Pattern)) then
            return index
        end
    end
end
local Frame = CreateObject("Frame",{
    Name = "FRM",
    Size = UDim2.fromOffset(0,0),
    Parent = ScreenGui,
    AnchorPoint = Vector2.new(0.5,0.5),
    BackgroundTransparency = 1,
    Position = Config[tostring(game.PlaceId)].GuiPosition
})
local Button = CreateObject("ImageButton",{
    Name = "BTN",
    Size = UDim2.fromScale(1,1),
    Parent = Frame,
    AnchorPoint = Vector2.new(0,0),
    BackgroundTransparency = 1,
    Image = getcustomasset("Assets/ContextTerminal.png"),
    ZIndex = 3
})
local TextFrame = CreateObject("Frame",{
    Name = "TFRM",
    Size = UDim2.fromOffset(10,22),
    Parent = Frame,
    AnchorPoint = Vector2.new(0,0.5),
    BackgroundColor3 = Color3.fromHex("232323"),
    Position = UDim2.fromScale(0.5,0.5)
})
local InputBox = CreateObject("TextBox",{
    ClearTextOnFocus = false,
    PlaceholderText = "Input...",
    MultiLine = false,
    Text = "",
    Size = UDim2.new(1,-30,1,0),
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    Position = UDim2.new(0,30,0,0),
    TextColor3 = Color3.fromHex("8f8f8f"),
    PlaceholderColor3 = Color3.fromHex("5f5f5f"),
    ClipsDescendants = true,
    Parent = TextFrame,
    ZIndex = 2,
    Visible = false
})
local SuggestionLabel = CreateObject("TextLabel",{
    Name = "STL",
    Text = "",
    Size = UDim2.new(1,0,1,0),
    TextSize = 12,
    TextXAlignment = Enum.TextXAlignment.Left,
    BackgroundTransparency = 1,
    TextColor3 = Color3.fromHex("8f8f8f"),
    TextTransparency = 0.7,
    ClipsDescendants = true,
    Parent = InputBox
})
local UpperOutputFrame = CreateObject("Frame",{
    Name = "UOFRM",
    Size = UDim2.new(1,0,0,0),
    Position = UDim2.new(0,26,0,0),
    AutomaticSize = "Y",
    Parent = TextFrame,
    AnchorPoint = Vector2.new(0,1),
    BackgroundColor3 = Color3.fromHex("232323"),
    Transparency = 1
})
local LowerOutputFrame = CreateObject("Frame",{
    Name = "LOFRM",
    Size = UDim2.new(1,0,0,0),
    Position = UDim2.new(0,26,1,0),
    AutomaticSize = "Y",
    Parent = TextFrame,
    BackgroundColor3 = Color3.fromHex("232323"),
    Transparency = 1
})
CreateObject("UIListLayout",{
    Parent = UpperOutputFrame,
    SortOrder = Enum.SortOrder.LayoutOrder,
    FillDirection = Enum.FillDirection.Vertical,
})
CreateObject("UIListLayout",{
    Parent = LowerOutputFrame,
    SortOrder = Enum.SortOrder.LayoutOrder,
    FillDirection = Enum.FillDirection.Vertical,
})
local function SetTextFrameSize()
    wait()
    if InputBox.Text ~= "" or InputBox:IsFocused() then
        if InputBox.Text == "" then
            InputBox.Visible = true
            SuggestionLabel.Visible = true
            TextFrame:TweenSize(UDim2.fromOffset(100, 22),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.1)
        end
        InputBox.Visible = true
        SuggestionLabel.Visible = true
        local MajorTextBox = InputBox
        if InputBox.TextBounds.X < SuggestionLabel.TextBounds.X then
            MajorTextBox = SuggestionLabel
        end
        TextFrame:TweenSize(UDim2.fromOffset(math.max(Util.GetTextSize(MajorTextBox, 50),100), 22),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.1)
    else
        TextFrame:TweenSize(UDim2.fromOffset(10, 22),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.1)
        wait(.1)
        InputBox.Visible = false
        SuggestionLabel.Visible = false
    end
end
local function UpperOutput(text, color, timer)
    if not text then text = "Invalid Text!" end
    if not timer then timer = 10 end
    table.insert(OutputLog, {Text = text, Color = color, Timer = timer, Type = "Upper"})
    if AddLogEntry then
        local str = text
        if color then
            str = '<font color="#'..color:ToHex()..'">'..str.."</font>"
        end
        pcall(AddLogEntry, str)
    end
    coroutine.wrap(function() 
        local TextLabel = CreateObject("TextLabel",{
            Size = UDim2.new(1,0,0,0),
            Text = " "..text,
            TextColor3 = color,
            BackgroundTransparency = 1,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            ClipsDescendants = true,
            Parent = UpperOutputFrame,
            AnchorPoint = Vector2.new(0,1),
            TextStrokeTransparency = 0.6,
            Size = UDim2.fromOffset(0,0),
            ZIndex = 2,
        })
        if TextLabel.Parent == UpperOutputFrame then
            TextLabel:TweenSize(UDim2.new(0, 400, 0, 16),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,.1)
        end
        wait(timer)
        TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
        if TextLabel.Parent == UpperOutputFrame then
            TextLabel:TweenSize(UDim2.new(0, 400, 0, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,.1)
        end
        wait(.1)
        TextLabel:Destroy()
    end)()
end
local CommandHistoryIndex = 0
local InputBoxTextChanged = InputBox:GetPropertyChangedSignal("Text")
InputBoxTextChanged:Connect(SetTextFrameSize)
InputBox.FocusLost:Connect(SetTextFrameSize)
InputBox.Focused:Connect(SetTextFrameSize)
InputBox.Focused:Connect(function()
    CommandHistoryIndex = 0
end)
CreateObject("UICorner",{
    CornerRadius = UDim.new(0,6),
    Parent = TextFrame
})
Frame:TweenSize(UDim2.fromOffset(48,48),Enum.EasingDirection.Out,Enum.EasingStyle.Back,1)
CreateObject("UICorner",{
    CornerRadius = UDim.new(1,0),
    Parent = Button
})
Button.MouseEnter:Connect(function()
    Frame:TweenSize(UDim2.fromOffset(52,52),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.1)
end)
Button.MouseLeave:Connect(function()
    Frame:TweenSize(UDim2.fromOffset(48,48),Enum.EasingDirection.InOut,Enum.EasingStyle.Sine,.1)
end)
local function Drag()
    local DragOffset = Vector2.new(Frame.Position.X.Offset-MouseLocation.X, Frame.Position.Y.Offset-MouseLocation.Y)
    local Connect = Mouse.Move:Connect(function()
        Frame.Position = UDim2.fromOffset(MouseLocation.X+(DragOffset.X),MouseLocation.Y+(DragOffset.Y))
    end)
    repeat wait() until not Mouse1Held
    Connect:Disconnect()
    Config[tostring(game.PlaceId)].GuiPosition = Frame.Position
    Config:Write()
end
Button.MouseButton1Down:Connect(function()
    local Connect
    Connect = Mouse.Move:Connect(function()
        Connect:Disconnect()
        Connect = nil
        Drag()
    end)
    repeat wait() until not Mouse1Held
    if not Connect then return end
    Connect:Disconnect()
    InputBox:CaptureFocus()
end)
Button.MouseButton2Down:Connect(function()
    xpcall(function()
        ContextMenus.Create(
            ThemeProviderEntries()
        )
    end,function(err)
        warn(debug.traceback(err))
    end)
end)
local function RandomFromTable(tbl, startindex, endindex)
    return tbl[math.random(startindex or 1, endindex or #tbl)]
end

local FindPlrRules = {
    {
        Match = {"me", "lp", "local", "localplayer"},
        f = function(str, Invoker)
            return {Invoker}
        end
    },
	{
		Match = {"others"},
		f = function(str, Invoker)
			local ReturnList = Players:GetPlayers()
            for i, v in pairs(ReturnList) do
                if v == Invoker then table.remove(ReturnList,i) end
            end
			return ReturnList
		end
	},
	{
		Match = {"r","rand","random"},
		f = function(str, Invoker)
			local ReturnList = Players:GetPlayers()
            if not Config.RandomIncludeLP then
                for i, v in pairs(ReturnList) do
                    if v == Invoker then table.remove(ReturnList,i) end
                end
            end
			return {RandomFromTable(ReturnList)}
		end
	},
	{
		Match = {"all"},
		f = function(str)
			return Players:GetPlayers()
		end
	},
	{
		Match = {"oldest"},
		f = function(str)
            local Ret
            for _, Plr in pairs(Players:GetChildren()) do
                if not Ret then 
                    Ret = Plr
                    continue
                end
                if Plr.AccountAge > Ret.AccountAge then
                    Ret = Plr
                end
            end
            return {Ret}
		end
	},
	{
		Match = {"old"},
		f = function(str)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr.AccountAge > Config.OldAccountAgeMin then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	},
	{
		Match = {"newest"},
		f = function(str)
            local Ret
            for _, Plr in pairs(Players:GetChildren()) do
                if not Ret then 
                    Ret = Plr
                    continue
                end
                if Plr.AccountAge < Ret.AccountAge then
                    Ret = Plr
                end
            end
            return {Ret}
		end
	},
	{
		Match = {"new"},
		f = function(str)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr.AccountAge < Config.NewAccountAgeMax then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	},
	{
		Match = {"friends","friended"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr:IsFriendsWith(Invoker.UserId) and Plr ~= LP then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	},
	{
		Match = {"friend"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr:IsFriendsWith(Invoker.UserId) and Plr ~= LP then
                    table.insert(ReturnList, Plr)
                end
            end
            return {RandomFromTable(ReturnList)}
		end
	},
	{
		Match = {"team","teamed","allied","allies"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr.Team == Invoker.Team then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	},
	{
		Match = {"teammate","ally"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr.Team == Invoker.Team then
                    table.insert(ReturnList, Plr)
                end
            end
            return {RandomFromTable(ReturnList)}
		end
	},
	{
		Match = {"notteam","enemied","enemies"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr.Team ~= Invoker.Team then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	},
	{
		Match = {"enemy"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if Plr.Team ~= Invoker.Team then
                    table.insert(ReturnList, Plr)
                end
            end
            return {RandomFromTable(ReturnList)}
		end
	},
	{
		Match = {"near","close"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                local Magnitude do pcall(function() Magnitude = (Plr.Character:FindFirstChild("HumanoidRootPart").Position - Invoker.Character.HumanoidRootPart.Position).Magnitude end) end
                if Plr ~= Invoker and Magnitude and Magnitude < Config.NearDistance then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	},
	{
		Match = {"nearest","closest"},
		f = function(str, Invoker)
            local Ret
            local RetMagnitude = math.huge
            for _, Plr in pairs(Players:GetChildren()) do
                local Magnitude do pcall(function() Magnitude = (Plr.Character:FindFirstChild("HumanoidRootPart").Position - Invoker.Character.HumanoidRootPart.Position).Magnitude end) end
                if Plr ~= Invoker and Magnitude and Magnitude < RetMagnitude then
                    Ret = Plr
                    RetMagnitude = Magnitude
                end
            end
            return {Ret}
		end
	},
	{
		Match = {"far"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                local Magnitude do pcall(function() Magnitude = (Plr.Character:FindFirstChild("HumanoidRootPart").Position - Invoker.Character.HumanoidRootPart.Position).Magnitude end) end
                if Magnitude and Magnitude > Config.FarDistance then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	},
	{
		Match = {"farthest","furthest"},
		f = function(str, Invoker)
            local Ret
            local RetMagnitude = 0
            for _, Plr in pairs(Players:GetChildren()) do
                local Magnitude do pcall(function() Magnitude = (Plr.Character:FindFirstChild("HumanoidRootPart").Position - Invoker.Character.HumanoidRootPart.Position).Magnitude end) end
                if Magnitude and Magnitude > RetMagnitude then
                    Ret = Plr
                    RetMagnitude = Magnitude
                end
            end
            return {Ret}
		end
	},
	{
		Match = {"notfriends","strangers"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if not Plr:IsFriendsWith(Invoker.UserId) and Plr ~= Invoker then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	},
	{
		Match = {"notfriend","unfriended"},
		f = function(str, Invoker)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if not Plr:IsFriendsWith(Invoker.UserId) and Plr ~= Invoker then
                    table.insert(ReturnList, Plr)
                end
            end
            return {RandomFromTable(ReturnList)}
		end
	}
}

if StaffGroups then
    table.insert(FindPlrRules, {
		Match = {"admins","staff"},
		f = function(str)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if CheckStaff(Plr) then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	})
    table.insert(FindPlrRules, {
		Match = {"admin"},
		f = function(str)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if CheckStaff(Plr) then
                    table.insert(ReturnList, Plr)
                end
            end
            return {RandomFromTable(ReturnList)}
		end
	})
    table.insert(FindPlrRules, {
		Match = {"nonadmins"},
		f = function(str)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if not CheckStaff(Plr) then
                    table.insert(ReturnList, Plr)
                end
            end
            return ReturnList
		end
	})
    table.insert(FindPlrRules, {
		Match = {"nonadmin"},
		f = function(str)
			local ReturnList = {}
            for _, Plr in pairs(Players:GetChildren()) do
                if not CheckStaff(Plr) then
                    table.insert(ReturnList, Plr)
                end
            end
            return {RandomFromTable(ReturnList)}
		end
	})
end

local function FindPlayers(str, Invoker)
    Invoker = Invoker or LP
    if Players:FindFirstChild(str) then
        return {Players:FindFirstChild(str)}
    end
	local RandomList = {}
	local ReturnList = {}
    for _, Rule in pairs(FindPlrRules) do
        if table.find(Rule.Match,str:lower()) then
            return Rule.f(str, Invoker)
        end
    end
    if tonumber(str) then
        for _, Plr in pairs(Players:GetChildren()) do
            if Plr.UserId == tonumber(str) then
                return {Plr}
            end
        end
    end
    for _, Plr in pairs(Players:GetChildren()) do
        if string.match(Plr.Name:lower(), str:lower()) or string.match(Plr.DisplayName:lower(), str:lower()) then
            if Config.RandomizeName then
                table.insert(RandomList, Plr)
            else
                return {Plr}
            end
        end
    end
    if #RandomList > 0 then
		return {RandomList[math.random(1,#RandomList)]}
	end
	if #ReturnList > 0 then
		return ReturnList
	end
    return {}
end
local ChatRemote do 
    pcall(function()
        ChatRemote = ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
    end)
end
local function out(text, timer, Color)
    UpperOutput(text, Color or Color3.fromHex("#e8e8e8"), timer) 
end
local function say(str, channel)
    if ChatRemote then
        if not channel then channel = "All" end
        ChatRemote:FireServer(str, channel)
    end
end
local function GenerateArgsString(args, StartIndex)
    if not StartIndex then StartIndex = 1 end
    if #args > 0 and args[StartIndex] then
        return "<"..table.concat(args,"> <",StartIndex)..">"
    else
        return ""
    end
end
local function ExecPrompt(Name, CMD)
    local Args = {}
    ContextMenus.Prompt(
        {
            Content = (function()
                local out = {
                    {
                        ClassName = "UIListLayout",
                        SortOrder = "LayoutOrder",
                        FillDirection = Enum.FillDirection.Vertical,
                        Padding = UDim.new(0,3)
                    }
                }
                if CMD.Args then
                    for index, arg in pairs(CMD.Args) do
                        if arg == "" then continue end
                        table.insert(out, 
                            {
                                ClassName = "TextBox",
                                Size = UDim2.new(1,0,0,20),
                                PlaceholderText = "<"..arg..">",
                                InitFunction = function(self, prompt, settings)
                                    self.FocusLost:Connect(function()
                                        Args[index] = self.ContentText
                                    end)
                                end
                            }
                        )
                    end
                end
                return out
            end)(),
            Settings = {
                Focus = false, 
                ButtonAlignment = "Right", 
                ReturnType = "Object",
                Title = {
                    Text = Name
                },
                Content = {ClipsDescendants = false}
            },
            Buttons = {
                {
                    Text = "Execute", 
                    M1Func = function(prompt)
                        WrapError("Error!",function()
                            table.insert(CommandLog, {
                                String = table.concat({Name,table.unpack(Args)}," ")
                            })
                            CMD.func(LP,table.unpack(Args))
                        end)
                        prompt.Close()
                    end
                },
                {
                    Text = "Cancel"
                }
            }
        }
    ) 
end
function OpenCommandList()
    local CMDBox = ContextMenus.CreateTextBox({
        TextBox = {
            Title = {Text = "Commands"},
            NoButtons = true,
            TextBox = {
                Size = UDim2.fromOffset(350,250)
            }
        }
    }, "CMDBox")
    for Name, CMD in pairs(Commands) do
        local Entry = CMDBox.AddEntry(
            {
            }, 
            Name.." &gt;&gt; "..CMD.Desc,
            {
                M2Func = function()
                    ContextMenus.Create(
                        {
                            FrameAnchorPoint = Util.CMAnchorPoint(),
                            Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                            TitleText = "  "..Name,
                            ContextMenuEntries = {
                                TextSize = 12
                            }
                        },
                        {
                            Text = "Paste into Input Field...",
                            M1Func = function()
                                InputBox.Text = InputBox.Text..Name
                            end
                        },
                        {
                            Text = "Prompt Execute",
                            M1Func = function()
                                ExecPrompt(Name,CMD)
                            end
                        }
                    )
                end
            }
        )
        if #CMD.Args > 0 then
            ContextMenus.CreateTooltip(Entry,GenerateArgsString(CMD.Args))
        end
    end
end
local Lights = {}

local function OpenTextBox(tbl, BoxName)
    local TextBox = ContextMenus.CreateTextBox({
        TextBox = {
            Title = {Text = BoxName},
            NoButtons = true,
            TextBox = {
                Size = UDim2.fromOffset(350,250)
            }
        }
    }, "BoxName")
    if BoxName == "Output Log" then
        AddLogEntry = function(Text)
            TextBox.AddEntry(
            {
            }, 
            Text,
            {
                M2Func = function()
                    ContextMenus.Create(
                        {
                            FrameAnchorPoint = Util.CMAnchorPoint(),
                            Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                            ContextMenuEntries = {
                                TextSize = 12
                            }
                        },
                        {
                            Text = "Copy",
                            M1Func = function()
                                setclipboardint(Text)
                            end
                        }
                    )
                end
            }
        )
        end
    end
    for index, Text in pairs(tbl) do
        if typeof(Text) == "table" then
            TextBox.AddEntry(
                {
                }, 
                index,
                {
                    M2Func = function()
                        ContextMenus.Create(
                            {
                                FrameAnchorPoint = Util.CMAnchorPoint(),
                                Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                                ContextMenuEntries = {
                                    TextSize = 12
                                }
                            },
                            {
                                Text = "Copy",
                                M1Func = function()
                                    setclipboardint(index)
                                end
                            }
                        )
                    end
                }
            )
            for index, Text in pairs(Text) do
                TextBox.AddEntry(
                    {
                    }, 
                    Text,
                    {
                        M2Func = function()
                            ContextMenus.Create(
                                {
                                    FrameAnchorPoint = Util.CMAnchorPoint(),
                                    Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                                    ContextMenuEntries = {
                                        TextSize = 12
                                    }
                                },
                                {
                                    Text = "Copy",
                                    M1Func = function()
                                        setclipboardint(Text)
                                    end
                                }
                            )
                        end
                    }
                )
            end
        else
            TextBox.AddEntry(
                {
                }, 
                Text,
                {
                    M2Func = function()
                        ContextMenus.Create(
                            {
                                FrameAnchorPoint = Util.CMAnchorPoint(),
                                Position = UDim2.fromOffset(MouseLocation.X,MouseLocation.Y),
                                ContextMenuEntries = {
                                    TextSize = 12
                                }
                            },
                            {
                                Text = "Copy",
                                M1Func = function()
                                    setclipboardint(Text)
                                end
                            }
                        )
                    end
                }
            )
        end
    end
    return TextBox
end

Commands = {
    --[[      COMMAND TEMPLATE:
        testcommand = {
            Args = {"Text"},
            Desc = "Prints the first argument out!",  
            func = function(Invoker, Text)
                print(Invoker, Text)
            end,
            AllowForeignExec = true
        },
    ]]
    commands = {
        Args = {},
        Desc = "Lists all commands.",  
        func = function(Invoker)
            OpenCommandList()
        end
    },
    allowexec = {
        Args = {"Invoker"},
        Desc = "Allows the player to execute commands.",  
        func = function(Invoker, Player)
            local Targets = FindPlayers(Player)
            if #Targets > 0 then
                for _, Plr in pairs(Targets) do
                    if CheckIfInvokerAllowed(Plr) then
                        out(Plr.Name.." is already allowed to execute commands!", 10, Color3.fromHex("#ffda44"))
                    else
                        table.insert(_ALLOWEDEXECS, Plr)
                        out(Plr.Name.." can now execute commands!")
                    end
                end
            else
                return "Player not found!"
            end
        end
    },
    unallowexec = {
        Args = {"Invoker"},
        Desc = "Disallows the player to execute commands.",  
        func = function(Invoker, Player)
            local Targets = FindPlayers(Player)
            if #Targets > 0 then
                for _, Plr in pairs(Targets) do
                    if not CheckIfInvokerAllowed(Plr) then
                        out(Plr.Name.." was not allowed to execute commands!", 10, Color3.fromHex("#ffda44"))
                    else
                        for i, v in pairs(_ALLOWEDEXECS) do
                            if v == Plr then
                                table.remove(_ALLOWEDEXECS, i)
                                out(Plr.Name.." can no longer execute commands!")
                                break
                            end
                        end
                    end
                end
            else
                return "Player not found!"
            end
        end
    },
    print = {
        Args = {"Message"},
        Desc = "Echoes the arguments.",  
        func = function(Invoker, ...)
            print(...)
            out(table.concat({...}," "))
        end,
        AllowForeignExec = true
    },
    discord = {
        Args = {},
        Desc = "Joins our Discord server.",  
        func = function(Invoker)
            out("Joining Discord...")
            request(
                {
                    Url = "http://127.0.0.1:6463/rpc?v=1",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"] = "application/json",
                        ["origin"] = "https://discord.com",
                    },
                    Body = game:GetService("HttpService"):JSONEncode(
                        {
                            ["args"] = {
                                ["code"] = "Y3THnyBNTb",
                            },
                            ["cmd"] = "INVITE_BROWSER",
                            ["nonce"] = "."
                        }
                    )
                }
            )
        end
    },
    error = {
        Args = {"Message"},
        Desc = "Errors the arguments.",  
        func = function(Invoker, ...)
            error(...)
        end,
        AllowForeignExec = true
    },
    leave = {
        Args = {},
        Desc = "Leaves the game.",  
        func = function(Invoker)
            game:Shutdown()
        end
    },
    noclip = {
        Args = {},
        Desc = "Toggle Noclip.",  
        func = function(Invoker)
            if NoclipConnect then
                NoclipConnect:Disconnect()
                NoclipConnect = nil
                out("No longer noclipping.")
            else
                NoclipConnect = RunService.Stepped:Connect(function()
                    for _, v in pairs(LP.Character:GetDescendants()) do
                        if v:IsA("BasePart") and v.CanCollide then
                            v.CanCollide = false
                        end
                    end
                end)
                out("Noclipping.")
            end
        end
    },
    credits = {
        Args = {},
        Desc = "Open credits.",  
        func = function(Invoker)
            OpenTextBox(credits, "Credits")
            out("Opened credits.")
        end
    },
    chat = {
        Args = {"State"},
        Desc = "Toggles the chat.",  
        func = function(Invoker, State)
            local Core = "ChatActive"
            local Label = "Chat"
            if not State or State == "" then
                if StarterGui:GetCore(Core) then
                    StarterGui:SetCore(Core, false)
                    out(Label.." it now hidden.")
                else
                    StarterGui:SetCore(Core, true)
                    out(Label.." is no longer hidden.")
                end
            else
                if table.find({'false', 'hide', 'off'},State:lower()) then
                    if not StarterGui:GetCore(Core) then
                        return Label.." is already hidden!"
                    end
                    StarterGui:SetCore(Core, false)
                    out(Label.." it now hidden.")
                elseif table.find({'true', 'show', 'on'},State:lower()) then
                    if StarterGui:GetCore(Core) then
                        return Label.." is not hidden!"
                    end
                    StarterGui:SetCore(Core, true)
                    out(Label.." is no longer hidden.")
                else
                    return "Invalid state!"
                end
            end
        end
    },
    topbar = {
        Args = {"State"},
        Desc = "Toggles the top bar.",  
        func = function(Invoker, State)
            local Core = "TopbarEnabled"
            local Label = "Top Bar"
            if not State or State == "" then
                if StarterGui:GetCore(Core) then
                    StarterGui:SetCore(Core, false)
                    out(Label.." it now hidden.")
                else
                    StarterGui:SetCore(Core, true)
                    out(Label.." is no longer hidden.")
                end
            else
                if table.find({'false', 'hide', 'off'},State:lower()) then
                    if not StarterGui:GetCore(Core) then
                        return Label.." is already hidden!"
                    end
                    StarterGui:SetCore(Core, false)
                    out(Label.." it now hidden.")
                elseif table.find({'true', 'show', 'on'},State:lower()) then
                    if StarterGui:GetCore(Core) then
                        return Label.." is not hidden!"
                    end
                    StarterGui:SetCore(Core, true)
                    out(Label.." is no longer hidden.")
                else
                    return "Invalid state!"
                end
            end
        end
    },
    prefix = {
        Args = {"Prefix"},
        Desc = "Change the prefix.",  
        func = function(Invoker, newPrefix)
            if not newPrefix or newPrefix == "" then
                out("The prefix is "..Config.Prefix)
            else
                Config.Prefix = newPrefix
                Config:Write()
                out("The prefix is now "..Config.Prefix)
            end
        end
    },
    outputlog = {
        Args = {},
        Desc = "Open output log.",  
        func = function(Invoker)
            local Logs = {}
            for _, v in pairs(OutputLog) do
                local str = v.Text
                if v.Color then
                    str = '<font color="#'..v.Color:ToHex()..'">'..str.."</font>"
                end
                table.insert(Logs, str)
            end
            OpenTextBox(Logs, "Output Log")
            out("Opened Outputlog.")
        end
    },
    commandlog = {
        Args = {},
        Desc = "Open command log.",  
        func = function(Invoker)
            local Logs = {}
            for _, v in pairs(CommandLog) do
                local str = '<b><font color="#'..
                (v.Invoker and v.Invoker.Name ~= LP.Name and "d6cc72" or "669aed")..
                '">'
                ..(v.Invoker and v.Invoker.Name or LP.Name)..
                "</font></b> &gt;&gt; "..
                v.String
                table.insert(Logs, str)
            end
            OpenTextBox(Logs, "Command Log")
            out("Opened CommandLog.")
        end
    },
    say = {
        Args = {"Message"},
        Desc = "Forces chat. (Bypasses some mutes.)",  
        func = function(Invoker, ...)
            say(table.concat({...}," "))
            out("Chatted.")
        end
    },
    refresh = {
        Args = {},
        Desc = "Respawns you in-place.",  
        func = refresh
    },
    spectate = {
        Args = {"Player"},
        Desc = "Spectate a player.",  
        func = function(Invoker, PlrName)
            local Plr = FindPlayers(PlrName)[1]
            if Plr then
                local Char = Plr.Character
                if not Char:FindFirstChildWhichIsA("BasePart") then
                    return "BasePart not found!"
                end
                workspace.CurrentCamera.CameraSubject = Char
                out("Now spectating "..Plr.Name.."...")
            else
                return "Player not found!"
            end
        end
    },
    unspectate = {
        Args = {},
        Desc = "Reset the camera.",  
        func = function(Invoker)
            workspace.CurrentCamera.CameraSubject = LP.Character
            out("Resetting camera.")
        end
    },
    cleartools = {
        Args = {},
        Desc = "Removes all tools.",  
        func = function(Invoker)
            LP.Backpack:ClearAllChildren()
            out("Inventory Cleared.")
        end
    },
    cameraoffset = {
        Args = {"X", "Y", "Z"},
        Desc = "Change camera offset.",  
        func = function(Invoker, X, Y, Z)
            if not X and not Y and not Z then
                LP.Character.Humanoid.CameraOffset = Vector3.new(0,0,0)
                out("Reset Camera Offset.")
                return
            end
            assert(not (X and (not Y or not Z)),"Insufficient Arguments!")
            assert(tonumber(X),"X needs to be a number!")
            assert(tonumber(Y),"Y needs to be a number!")
            assert(tonumber(Z), "Z needs to be a number!")
            LP.Character.Humanoid.CameraOffset = Vector3.new(X, Y, Z)
            out("Set camera offset to "..X.." "..Y.." "..Z..".")
        end
    },
    strengthen = {
        Args = {"Strength?"},
        Desc = "Makes you strong.",  
        func = function(Invoker, str)
            if not str then str = 100 end
            assert(tonumber(str),"Strength needs to be a number!")
            table.foreach(LP.Character:GetChildren(),function(_,p)
                p.CustomPhysicalProperties = PhysicalProperties.new(tonumber(str), 0.3, 0.5)
            end)
            out("You are now strong.")
        end
    },
    light = {
        Args = {"Player?", "Brightness?", "Range?"},
        Desc = "Create a light.",  
        func = function(Invoker, Arg1, Arg2, Arg3)
            local Foreign = tonumber(Arg1)==nil
            local Brightness
            local Range
            if Foreign then
                Brightness = tonumber(Arg2) or 1
                Range = tonumber(Arg3) or 35
            else
                Brightness = tonumber(Arg1) or 1
                Range = tonumber(Arg2) or 35
            end
            local Targets = Foreign and FindPlayers(Arg1) or {LP}
            for _, Plr in pairs(Targets) do
                local HRP = Plr.Character:FindFirstChild("HumanoidRootPart")
                if HRP then
                    while HRP:FindFirstChild("CTLight") do
                        HRP:FindFirstChild("CTLight"):Destroy()
                    end
                    CreateObject("PointLight", {
                        Brightness = Brightness,
                        Range = Range,
                        Parent = HRP,
                        Name = "CTLight"
                    })
                end
            end
            if #Targets > 1 then
                out("Created Lights.")
            else
                out("Created Light.")
            end
        end
    },
    unlight = {
        Args = {"Player?"},
        Desc = "Destroys lights.",  
        func = function(Invoker, Target)
            local Targets = Target and FindPlayers(Target) or {LP}
            for _, Plr in pairs(Targets) do
                local HRP = Plr.Character:FindFirstChild("HumanoidRootPart")
                if HRP then
                    while HRP:FindFirstChild("CTLight") do
                        HRP:FindFirstChild("CTLight"):Destroy()
                    end
                end
            end
            if #Targets > 1 then
                out("Destroyed Lights.")
            else
                out("Destroyed Light.")
            end
        end
    },
    weak = {
        Args = {"Strength?"},
        Desc = "Makes you weak.",  
        func = function(Invoker, str)
            if not str then str = 0 end
            assert(tonumber(str),"Strength needs to be a number!")
            table.foreach(LP.Character:GetChildren(),function(_,p)
                p.CustomPhysicalProperties = PhysicalProperties.new(tonumber(str), 0.3, 0.5)
            end)
            out("You are now weak.")
        end
    },
    unweak = {
        Args = {},
        Desc = "Makes you strong.",  
        func = function(Invoker)
            table.foreach(LP.Character:GetChildren(),function(_,p)
                p.CustomPhysicalProperties = PhysicalProperties.new(0.7, 0.3, 0.5)
            end)
            out("You are no longer weak/strong.")
        end
    },
    reloadcontextmenus = {
        Args = {},
        Desc = "Reloads ContextMenus.",  
        func = function(Invoker)
            ContextMenus = LoadModule("ContextMenus")
            out("ContextMenus reloaded.")
        end
    },
    wipecache = {
        Args = {},
        Desc = "Removes all the cached files.",  
        func = function(Invoker)
            for _, Folder in pairs({
                "Assets",
                "Modules"
            }) do
                if isfolder(Folder) then 
                    delfolder(Folder) 
                end
            end
            out("Cache cleared.")
        end
    },
    loadpos = {
        Args = {"Position Name"},
        Desc = "Teleport to a previously saved position.",  
        func = function(Invoker, ...)
            assert(..., "Insufficient Arguments!")
            local PosName = table.concat({...}, " ")
            WPs = ConfigModule:Create("SAVEDPOSITIONS.lua",{
                [tostring(game.PlaceId)] = {}
            })
            local newPosName = FindIndex(WPs[tostring(game.PlaceId)], PosName, true)
            if not newPosName then
                newPosName = FindIndex(WPs[tostring(game.PlaceId)], PosName)
                if not newPosName then
                    return "Position "..PosName.." not found!"
                else
                    PosName = newPosName
                end
            else
                PosName = newPosName
            end
            local Pos = WPs[tostring(game.PlaceId)][PosName]
            if not Pos then
                for Name, Position in pairs(WPs[tostring(game.PlaceId)]) do
                    if Name:lower() == PosName:lower() then
                        Pos = Position
                        PosName = Name
                        break
                    end
                end
            end
            if Pos then
                out("Teleporting to "..PosName.."...")
                Functions.TeleportTo(Pos, {TeleportOffset = CFrame.new(0,0,0)})
            else
                return "Position "..PosName.." not found!"
            end
        end
    },
    savepos = {
        Args = {"Position Name"},
        Desc = "Save a position for future teleports.",  
        func = function(Invoker, ...)
            assert(..., "Insufficient Arguments!")
            local PosName = table.concat({...}, " ")
            if not table.find({""," "},PosName) then
                WPs = ConfigModule:Create("SAVEDPOSITIONS.lua",{
                    [tostring(game.PlaceId)] = {}
                })
                WPs[tostring(game.PlaceId)][PosName] = LP.Character.HumanoidRootPart.CFrame
                WPs:Write()
                out("Saved "..PosName..".")
            else
                return "Invalid name!"
            end
        end
    },
    rejoindiff = {
        Args = {"Preset?"},
        Desc = "Rejoin a different server.",  
        func = function(Invoker, dec)
            out("Rejoining...")
            local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport
            local queue = 'game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()'
            if queue_on_teleport then
                pcall(function()
                    queue_on_teleport(queue)
                end)
            end
            RejoinDiff(dec)
        end
    },
    rejoin = {
        Args = {},
        Desc = "Rejoin the same server.",  
        func = function()
            out("Rejoining...")
            local GameInfo do GameInfo = Util.JSONRequest("https://games.roblox.com/v1/games?universeIds="..game.GameId).data[1] end
            local queue_on_teleport = queue_on_teleport or syn.queue_on_teleport
            local queue = 'game:GetService("ReplicatedFirst"):RemoveDefaultLoadingScreen()'
            if queue_on_teleport then
                pcall(function()
                    queue_on_teleport(queue)    
                end)
            end
            if GameInfo and GameInfo.playing < 2 then
                out("Warning! You are the only player here;", 10, Color3.fromHex("#ffda44")) 
                out("this server will be shut down!", 10, Color3.fromHex("#ffda44"))
                wait(5)
                game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, Players)
            else
                game:GetService('TeleportService'):TeleportToPlaceInstance(game.PlaceId, game.JobId, Players)
            end
        end
    },
    tptool = {
        Args = {},
        Desc = "Get the Click TP Tool.",  
        func = function()
            out("Giving TpTool...")
            Functions.GiveTpTool()
        end
    },
    createdebuggui = {
        Args = {},
        Desc = "Creates a Debug GUI (_G.DebugGui).",  
        func = function()
            _G.DebugGui = Instance.new("Frame", Instance.new("ScreenGui", cmdlp.PlayerGui))
            _G.DebugGui.Position = UDim2.new(0.3,0,0.3,0)
            _G.DebugGui.Size = UDim2.new(0,300,0,300)
            out("_G.DebugGui Created!")
        end
    },
    delpos = {
        Args = {"Position Name"},
        Desc = "Delete a saved position.",  
        func = function(Invoker, ...)
            assert(..., "Insufficient Arguments!")
            local PosName = table.concat({...}, " ")
            if not table.find({""," "},PosName) then
                WPs = ConfigModule:Create("SAVEDPOSITIONS.lua",{
                    [tostring(game.PlaceId)] = {}
                })
                local newPosName = FindIndex(WPs[tostring(game.PlaceId)], PosName, true)
                if not newPosName then
                    newPosName = FindIndex(WPs[tostring(game.PlaceId)], PosName)
                    if not newPosName then
                        return "Position "..PosName.." not found!"
                    else
                        PosName = newPosName
                    end
                else
                    PosName = newPosName
                end
                if WPs[tostring(game.PlaceId)][PosName] then
                    WPs[tostring(game.PlaceId)][PosName] = nil
                else
                    return "Position "..PosName.." not found!"
                end
                WPs:Write()
                out("Deleted "..PosName..".")
            else
                return "Invalid name!"
            end
        end
    },
    goto = {
        Args = {"Player"},
        Desc = "Teleport to a player.",  
        func = function(Invoker, PlrName)
            assert(PlrName, "Insufficient Arguments!")
            local Plr = FindPlayers(PlrName)[1]
            if Plr then
                local Char = Plr.Character
                local Part = Char:FindFirstChild("HumanoidRootPart") or Char:FindFirstChildWhichIsA("BasePart")
                if not Part then
                    return "HumanoidRootPart/BasePart not found!"
                end
                Functions.TeleportTo(Part)
                out("Teleported to "..Plr.Name.."!")
            else
                return "Player not found!"
            end
        end
    },
    equip = {
        Args = {"Name?"},
        Desc = "Equips all tools or tools matching the name.",  
        func = function(Invoker, ToolName)
            local count = 0
            if ToolName then
                for _, v in pairs(LP.Backpack:GetChildren()) do
                    if string.find(v.Name, ToolName) then
                        v.Parent = LP.Character
                        count = count+1
                    end
                end
            else
                for _, v in pairs(LP.Backpack:GetChildren()) do
                    v.Parent = LP.Character
                    count = count+1
                end
            end
            out("Equipped "..count.." tools.")
        end
    },
    unequip = {
        Args = {"Name?"},
        Desc = "Unequips all tools or tools matching the name.",  
        func = function(Invoker, ToolName)
            local count = 0
            if ToolName then
                for _, v in pairs(LP.Character:GetChildren()) do
                    if v:IsA("Tool") and string.find(v.Name, ToolName) then
                        v.Parent = LP.Backpack
                        count = count+1
                    end
                end
            else
                for _, v in pairs(LP.Character:GetChildren()) do
                    if v:IsA("Tool") then
                        v.Parent = LP.Backpack
                        count = count+1
                    end
                end
            end
            out("Unequipped "..count.." tools.")
        end
    },
    antiplatformstand = {
        Args = {},
        Desc = "Toggle Anti-PlatformStand.",  
        func = function(Invoker)
            if Anti.PlatformStand then
                Anti.PlatformStand = false
                out("Anti-PlatformStand off.")
            else
                Anti.PlatformStand = true
                out("Anti-PlatformStand on.")
            end
        end
    },
    loopwalkspeed = {
        Args = {"Speed"},
        Desc = "Toggle WalkSpeed loop.",  
        func = function(Invoker, Speed)
            Speed = tonumber(Speed)
            LP.Character.Humanoid.WalkSpeed = Speed
            if Loop.WalkSpeed or not Speed then
                Loop.WalkSpeed = nil
                out("WalkSpeed loop off.")
            else
                Loop.WalkSpeed = Speed
                out("WalkSpeed loop on.")
            end
        end
    },
    loopjumppower = {
        Args = {"Speed"},
        Desc = "Toggle JumpPower loop.",  
        func = function(Invoker, Power)
            Power = tonumber(Power)
            LP.Character.Humanoid.JumpPower = Power
            if Loop.JumpPower or not Power then
                Loop.JumpPower = nil
                out("JumpPower loop off.")
            else
                Loop.JumpPower = Power
                out("JumpPower loop on.")
            end
        end
    },
    ["2022materials"] = {
        Args = {},
        Desc = "Toggle 2022 Materials.",  
        func = function(Invoker)
            if MaterialService.Use2022Materials then
                MaterialService.Use2022Materials = false
                out("2022 Materials off.")
            else
                MaterialService.Use2022Materials = true
                out("2022 Materials on.")
            end
        end
    },
    antisit = {
        Args = {},
        Desc = "Toggle Anti-Sit.",  
        func = function(Invoker)
            if Anti.Sit then
                Anti.Sit = false
                out("Anti-Sit off.")
            else
                Anti.Sit = true
                out("Anti-Sit on.")
            end
        end
    },
    sit = {
        Args = {},
        Desc = "Toggle Sitting.",  
        func = function(Invoker)
            if LP.Character.Humanoid.Sit then
                LP.Character.Humanoid.Sit = false
                out("No longer Sitting.")
            else
                LP.Character.Humanoid.Sit = true
                out("Sitting.")
            end
        end
    },
    platformstand = {
        Args = {},
        Desc = "Toggle PlatformStand.",  
        func = function(Invoker)
            if LP.Character.Humanoid.PlatformStand then
                LP.Character.Humanoid.PlatformStand = false
                out("No longer PlatformStanding.")
            else
                LP.Character.Humanoid.PlatformStand = true
                out("PlatformStanding.")
            end
        end
    },
    unplatformstand = {
        Args = {},
        Desc = "Disable PlatformStand.",  
        func = function(Invoker)
            if LP.Character.Humanoid.PlatformStand then
                LP.Character.Humanoid.PlatformStand = false
                out("No longer PlatformStanding.")
            else
                out("You're not PlatformStanding.")
            end
        end
    },
    infjump = {
        Args = {},
        Desc = "Toggle infinite jump.",  
        func = function(Invoker)
            if infiniteJump then
                infiniteJump = false
                out("No longer infinite jumping.")
            else
                infiniteJump = true
                out("Infinite jumping.")
            end
        end
    },
    uninfjump = {
        Args = {},
        Desc = "Disable infinite jump.",  
        func = function(Invoker)
            if infiniteJump then
                infiniteJump = false
                out("No longer infinite jumping.")
            else
                out("You're not infinite jumping.")
            end
        end
    },
    remotespy = {
        Args = {},
        Desc = "Loads RemoteSpy by exxtremestuffs.",  
        func = function(Invoker)
            loadstring(game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua"))()
        end
    },
    f3x = {
        Args = {},
        Desc = "Loads F3X BTools.",  
        func = function(Invoker)
            loadstring(game:GetObjects("rbxassetid://4698064966")[1].Source)()
        end
    },
    gameid = {
        Args = {},
        Desc = "Copies the GameId.",  
        func = function(Invoker)
            setclipboardint(tostring(game.GameId))
            out("Copied GameId")
        end
    },
    placeid = {
        Args = {},
        Desc = "Copies the PlaceId.",  
        func = function(Invoker)
            setclipboardint(tostring(game.PlaceId))
            out("Copied PlaceId")
        end
    },
    userid = {
        Args = {"Player?"},
        Desc = "Copies a player's UserId.",  
        func = function(Invoker, Player)
            local Plr = (FindPlayers(Player)[1] or LP)
            setclipboardint(tostring(Plr.UserId))
            out("Copied "..Plr.Name.."'s UserId")
        end
    },
    copyname = {
        Args = {"Player?"},
        Desc = "Copies a player's Name.",  
        func = function(Invoker, Player)
            local Plr = (FindPlayers(Player)[1] or LP)
            setclipboardint(Plr.Name)
            out("Copied "..Plr.Name.."'s Name")
        end
    },
    copydisplay = {
        Args = {"Player?"},
        Desc = "Copies a player's DisplayName.",  
        func = function(Invoker, Player)
            local Plr = (FindPlayers(Player)[1] or LP)
            setclipboardint(Plr.DisplayName)
            out("Copied "..Plr.Name.."'s DisplayName")
        end
    },
    walkspeed = {
        Args = {"Speed"},
        Desc = "WalkSpeed.",  
        func = function(Invoker, Speed)
            if Speed then
                assert(tonumber(Speed), "Speed must be a number!")
                LP.Character.Humanoid.WalkSpeed = tonumber(Speed)
                out("Set WalkSpeed to "..Speed..".")
            else
                out("Current WalkSpeed is "..LP.Character.Humanoid.WalkSpeed..".")
            end
        end
    },
    jumppower = {
        Args = {"Power"},
        Desc = "JumpPower.",  
        func = function(Invoker, Power)
            if Power then
                assert(tonumber(Power), "Power must be a number!")
                LP.Character.Humanoid.JumpPower = tonumber(Power)
                out("Set JumpPower to "..Power..".")
            else
                out("Current JumpPower is "..LP.Character.Humanoid.JumpPower..".")
            end
        end
    },
    hipheight = {
        Args = {"Height"},
        Desc = "HipHeight.",  
        func = function(Invoker, hipheight)
            if hipheight then
                assert(tonumber(hipheight), "hipheight must be a number!")
                LP.Character.Humanoid.HipHeight = tonumber(hipheight)
                out("Set HipHeight to "..hipheight..".")
            else
                out("Current HipHeight is "..LP.Character.Humanoid.HipHeight..".")
            end
        end
    },
    maxslopeangle = {
        Args = {"MaxAngle"},
        Desc = "MaxSlopeAngle.",  
        func = function(Invoker, MaxSlopeAngle)
            if MaxSlopeAngle then
                assert(tonumber(MaxSlopeAngle), "MaxAngle must be a number!")
                LP.Character.Humanoid.MaxSlopeAngle = tonumber(MaxSlopeAngle)
                out("Set MaxSlopeAngle to "..MaxSlopeAngle..".")
            else
                out("Current MaxSlopeAngle is "..LP.Character.Humanoid.MaxSlopeAngle..".")
            end
        end
    }
}
if isfile("ContextDex/ContextDex.lua") then
    Commands.dex = {
        Args = {},
        Desc = "Opens ContextDex.",  
        func = function(Invoker, Loc)
            out("Opening ContextDex...")
            loadfile("ContextDex/ContextDex.lua")()
        end
    }
end
local Aliases = {
    e = "print",
    ragdoll = "platformstand",
    wsloop = "loopwalkspeed",
    jploop = "loopjumppower",
    unragdoll = "unplatformstand",
    antiragdoll = "antiplatformstand",
    echo = "print",
    err = "error",
    view = "spectate",
    respawn = "refresh",
    re = "refresh",
    unview = "unspectate",
    v = "spectate",
    unv = "unspectate",
    spos = "savepos",   
    lpos = "loadpos",
    tppos = "loadpos",
    to = "goto",
    toplr = "goto",
    jp = "jumppower",
    ws = "walkspeed",
    cmds = "commands",
    help = "commands",
    strong = "strength",
    unstrength = "unweak",
    unstrong = "unweak",
    ps = "platformstand",
    antips = "antiplatformstand",
    btools = "f3x",
    camoffset = "cameraoffset"
}


local function FindCommand(str)
    if not str then return end
    return Commands[str] or Commands[Aliases[str]]
end
local function FindCommandSuggestion(str: string)
    for Name, Command in pairs(Commands) do
        if Name:sub(1,#str) == str then
            return Name
        end
    end
    for Name, Command in pairs(Aliases) do
        if Name:sub(1,#str) == str then
            return Name
        end
    end
end

local ChatBar do pcall(function()
    ChatBar = LP.PlayerGui.Chat.Frame.ChatBarParentFrame.Frame.BoxFrame.Frame.ChatBar
end) end

coroutine.wrap(function()
    while wait() do
        local CMD = (FindCommand(InputBox.Text:split(" ")[1]) or ChatBar and FindCommand(ChatBar.Text:sub(#Config.Prefix+1,#ChatBar.Text):split(" ")[1]))
        if CMD then
            local TextLabel = CreateObject("TextLabel",{
                Size = UDim2.new(1,0,0,0),
                Text = " "..CMD.Desc,
                TextColor3 = Color3.fromHex("#dfdfdf"),
                BackgroundTransparency = 1,
                TextTransparency = 0.4,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                ClipsDescendants = true,
                Parent = LowerOutputFrame,
                TextStrokeTransparency = 0.6,
                Size = UDim2.fromOffset(0,0),
                ZIndex = 2,
            })
            TextLabel:TweenSize(UDim2.new(0, 400, 0, 16),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,.1)
            repeat wait() until not (FindCommand(InputBox.Text:split(" ")[1]) or ChatBar and FindCommand(ChatBar.Text:sub(#Config.Prefix+1,#ChatBar.Text):split(" ")[1]))
            TextLabel.TextYAlignment = Enum.TextYAlignment.Top
            TextLabel:TweenSize(UDim2.new(0, 400, 0, 0),Enum.EasingDirection.Out,Enum.EasingStyle.Quint,.1)
            wait(.2)
            TextLabel:Destroy()
        end
    end
end)()
InputBoxTextChanged:Connect(function()
    local Text = InputBox.Text
    if #Text:split(" ") == 1 and not table.find({""," ",";"},InputBox.Text) then
        Autocomplete = FindCommandSuggestion(Text) or ""
        SuggestionLabel.Text = Autocomplete
    elseif FindCommand(Text:split(" ")[1]) then
        local CMD = FindCommand(Text:split(" ")[1])
        local StartIndex = #Text:split(" ")-1
        if Text:split(" ")[#Text:split(" ")] ~= "" then
            StartIndex = #Text:split(" ")
        end
        Autocomplete = Text.." "..GenerateArgsString(CMD.Args, StartIndex)
        SuggestionLabel.Text = Autocomplete
    else
        SuggestionLabel.Text = ""
    end
end)


local function ExecCommand(Command: string, Invoker)
    local Split = Command:split(" ")
    local CommandName = Split[1]:lower()
    if Split[#Split] == "" then Split[#Split] = nil end
    local Args = {select(2,table.unpack(Split))}
    local CMD = FindCommand(CommandName)
    if CMD then
        if not Invoker or Invoker == LP or CMD.AllowForeignExec and CheckIfInvokerAllowed(Invoker) then
            table.insert(CommandLog, {
                String = Command,
                Invoker = Invoker
            })
            return pcall(CMD.func,Invoker,table.unpack(Args))
        else
            UpperOutput(Invoker.Name.." tried executing "..CommandName.."!", Color3.fromRGB(191, 90, 90), 30)
        end
    else
        return false, "Command not found!"
    end
end

UserInputService.InputBegan:Connect(function(input)
    
    xpcall(function()
        if input.KeyCode == Config[tostring(game.PlaceId)].ESP.Keybind then
            ESP = not ESP
            out("ESP toggled "..(ESP and "On" or "Off"),1)
        end
        if input.KeyCode == Config[tostring(game.PlaceId)].Aimbot.Keybind then
            Aimbot = not Aimbot
            out("Aimbot toggled "..(Aimbot and "On" or "Off"),1)
        end
    end,warn)
    if input.KeyCode == Config.Keybind and not UserInputService:GetFocusedTextBox() then
        --repeat wait() until not UserInputService:IsKeyDown(Config.Keybind)
        task.wait()
        InputBox:CaptureFocus()
    elseif input.KeyCode == Enum.KeyCode.Up and InputBox:IsFocused() and CommandHistoryIndex < #CommandLog then
        CommandHistoryIndex = CommandHistoryIndex+1
        InputBox.Text = CommandLog[(#CommandLog-CommandHistoryIndex)+1] and CommandLog[(#CommandLog-CommandHistoryIndex)+1].String or ""
    elseif input.KeyCode == Enum.KeyCode.Down and InputBox:IsFocused() and CommandHistoryIndex > 0 then
        CommandHistoryIndex = CommandHistoryIndex-1
        InputBox.Text = CommandLog[(#CommandLog-CommandHistoryIndex)+1] and CommandLog[(#CommandLog-CommandHistoryIndex)+1].String or ""
    elseif input.KeyCode == Enum.KeyCode.Tab and InputBox:IsFocused() then
        if Autocomplete and #Autocomplete > #InputBox.Text then
            local AutocompleteText = Autocomplete
            RunService.RenderStepped:Wait()
            InputBox.Text = AutocompleteText.." "
            InputBox.CursorPosition = #InputBox.Text+1
            Autocomplete = nil
        end
    end
end)    

InputBox.FocusLost:Connect(function(EnterPressed)
    if EnterPressed and not table.find({""," ",";"},InputBox.Text) then
        local Command = InputBox.Text
        InputBox.PlaceholderText = Command
        InputBox.Text = ""
        local succ, err = ExecCommand(Command, LP)
        if err then
            if string.find(tostring(err),":") then
                local Split = string.split(err,":")
                Split[1] = Command:split(" ")[1]
                err = table.concat(Split,":")
            end
            UpperOutput(err, Color3.fromRGB(191, 90, 90), 20)
        end
        InputBox.PlaceholderText = "Input..."
    elseif table.find({" ",";"},InputBox.Text) then
        InputBox.Text = ""
    end
end)


local function formatfile(str)
    local a = string.split(string.gsub(string.gsub(str, "\\","^"), "/","^"),"^")
    if a[#a] == "" then
        return a[#a-1]
    else
        return a[#a]
    end
end
local startstr = [[local ConfigModule, credits, CustomLPEntries, CustomPlayerEntries, CustomThemeproviderEntries, _ALLOWEDEXECS, UserInputService, ContextMenus, ListsModule, Functions, Util, RunService, TweenService, InstanceSerializer, SerializedInstances, Players, CoreGui, CurrentFov, StartFov, LP, WPs, Config, ESP, ZoomMax, ZoomMin, Mouse, ReplicatedStorage, StaffGroups, CheckIfVisible, Lists, StaffRanks, GetStaffLists, UpdateStaff, ChangeStaffGroupPrompt, CheckStaff, ListColors, ListImages, GenListSubMenu, GetChatLogs, CreateObject, WrapError, refresh, CheckDex, ThemeProvider, RejoinDiff, GetPosList, GetGotoList, LPEntries, UserClick, CheckImageIsOriginal, formatfile, FindPlrRules, TextService, request, MouseLocation, infiniteJump, Anti, OutputLog, ApplyProperties, ScreenGui, Frame, Button, TextFrame, InputBox, SuggestionLabel, UpperOutputFrame, SetTextFrameSize, UpperOutput, InputBoxTextChanged, FindPlayers, RandomFromTable, ChatRemote, out, say, GenerateArgsString, ExecPrompt, OpenTextBox, Commands, Aliases, FindCommand, FindCommandSuggestion, ExecCommand, FindIndex = ...;]]   
if isfolder("ContextTerminal") and isfolder("ContextTerminal/Plugins") then
    for _, folder in pairs(listfiles("ContextTerminal/Plugins")) do
        if table.find(formatfile(folder):split(" "), tostring(game.PlaceId)) then
            local _SCRIPTS = listfiles(folder)
            for _, v in pairs(_SCRIPTS) do
                coroutine.wrap(function()
                    if isfile(v) then
                        local Script, err = loadstring(startstr..readfile(v))
                        if Script then
                            xpcall(function()
                                Script(ConfigModule, credits, CustomLPEntries, CustomPlayerEntries, CustomThemeproviderEntries, _ALLOWEDEXECS, UserInputService, ContextMenus, ListsModule, Functions, Util, RunService, TweenService, InstanceSerializer, SerializedInstances, Players, CoreGui, CurrentFov, StartFov, LP, WPs, Config, ESP, ZoomMax, ZoomMin, Mouse, ReplicatedStorage, StaffGroups, CheckIfVisible, Lists, StaffRanks, GetStaffLists, UpdateStaff, ChangeStaffGroupPrompt, CheckStaff, ListColors, ListImages, GenListSubMenu, GetChatLogs, CreateObject, WrapError, refresh, CheckDex, ThemeProvider, RejoinDiff, GetPosList, GetGotoList, LPEntries, UserClick, CheckImageIsOriginal, formatfile, FindPlrRules, TextService, request, MouseLocation, infiniteJump, Anti, OutputLog, ApplyProperties, ScreenGui, Frame, Button, TextFrame, InputBox, SuggestionLabel, UpperOutputFrame, SetTextFrameSize, UpperOutput, InputBoxTextChanged, FindPlayers, RandomFromTable, ChatRemote, out, say, GenerateArgsString, ExecPrompt, OpenTextBox, Commands, Aliases, FindCommand, FindCommandSuggestion, ExecCommand, FindIndex)
                            end,function(err)
                                warn(debug.traceback(v..":"..err))
                            end)
                            
                        else
                            warn(v..":"..err)
                        end
                    end
                end)()
            end
        end
    end
    if isfolder("ContextTerminal/Plugins/Default") then
        local _SCRIPTS = listfiles("ContextTerminal/Plugins/Default")
        for _, v in pairs(_SCRIPTS) do
            coroutine.wrap(function()
                if isfile(v) then
                    local Script, err = loadstring(startstr..readfile(v))
                    if Script then
                        xpcall(function()
                            Script(ConfigModule, credits, CustomLPEntries, CustomPlayerEntries, CustomThemeproviderEntries, _ALLOWEDEXECS, UserInputService, ContextMenus, ListsModule, Functions, Util, RunService, TweenService, InstanceSerializer, SerializedInstances, Players, CoreGui, CurrentFov, StartFov, LP, WPs, Config, ESP, ZoomMax, ZoomMin, Mouse, ReplicatedStorage, StaffGroups, CheckIfVisible, Lists, StaffRanks, GetStaffLists, UpdateStaff, ChangeStaffGroupPrompt, CheckStaff, ListColors, ListImages, GenListSubMenu, GetChatLogs, CreateObject, WrapError, refresh, CheckDex, ThemeProvider, RejoinDiff, GetPosList, GetGotoList, LPEntries, UserClick, CheckImageIsOriginal, formatfile, FindPlrRules, TextService, request, MouseLocation, infiniteJump, Anti, OutputLog, ApplyProperties, ScreenGui, Frame, Button, TextFrame, InputBox, SuggestionLabel, UpperOutputFrame, SetTextFrameSize, UpperOutput, InputBoxTextChanged, FindPlayers, RandomFromTable, ChatRemote, out, say, GenerateArgsString, ExecPrompt, OpenTextBox, Commands, Aliases, FindCommand, FindCommandSuggestion, ExecCommand, FindIndex)
                        end,function(err)
                            warn(debug.traceback(v..":"..err))
                        end)
                    else
                        warn(v..":"..err)
                    end
                end
            end)()
        end
    end
end

Commands.loadplugin = {
    Args = {"Path"},
    Desc = "Loads a plugin from path.",  
    func = function(Invoker, ...)
        local Path = table.concat({...}, " ")
        if isfile(Path) then
            local Script, err = loadstring(startstr..readfile(Path))
            if Script then
                Script(credits, CustomLPEntries, CustomPlayerEntries, CustomThemeproviderEntries, _ALLOWEDEXECS, UserInputService, ContextMenus, ListsModule, Functions, Util, RunService, TweenService, InstanceSerializer, SerializedInstances, Players, CoreGui, CurrentFov, StartFov, LP, WPs, Config, ESP, ZoomMax, ZoomMin, Mouse, ReplicatedStorage, StaffGroups, CheckIfVisible, Lists, StaffRanks, GetStaffLists, UpdateStaff, ChangeStaffGroupPrompt, CheckStaff, ListColors, ListImages, GenListSubMenu, GetChatLogs, CreateObject, WrapError, refresh, CheckDex, ThemeProvider, RejoinDiff, GetPosList, GetGotoList, LPEntries, UserClick, CheckImageIsOriginal, formatfile, FindPlrRules, TextService, request, MouseLocation, infiniteJump, Anti, OutputLog, ApplyProperties, ScreenGui, Frame, Button, TextFrame, InputBox, SuggestionLabel, UpperOutputFrame, SetTextFrameSize, UpperOutput, InputBoxTextChanged, FindPlayers, RandomFromTable, ChatRemote, out, say, GenerateArgsString, ExecPrompt, OpenTextBox, Commands, Aliases, FindCommand, FindCommandSuggestion, ExecCommand, FindIndex)
            else
                error(err)
            end
        end
    end
}

if ChatBar then
    local FocusLost
    local Command = ""
	ChatBar:GetPropertyChangedSignal("Text"):Connect(function()
        if ChatBar.Text:lower():sub(1,#Config.Prefix) == Config.Prefix then
            if FocusLost then FocusLost:Disconnect() end
            Command = ChatBar.Text:sub(#Config.Prefix+1,#ChatBar.Text)
            FocusLost = ChatBar.FocusLost:Connect(function(EnterPressed)
                if EnterPressed then
                    ExecCommand(Command, LP)
                end
            end)
        end
	end)
else
    out("ChatBar not found! Chat commands will not work!", 10, Color3.fromHex("#ffda44"))
end

if ChatDoneFiltering then
    ChatDoneFiltering.OnClientEvent:Connect(function(packet,channel)
        local Invoker = Players:FindFirstChild(packet.FromSpeaker)
        --print(packet, channel, Invoker, Invoker, CheckIfInvokerAllowed(Invoker), packet.Message:sub(1,#Config.Prefix), Config.Prefix)
        if Invoker and CheckIfInvokerAllowed(Invoker) and packet.Message:sub(1,#Config.Prefix) == Config.Prefix then
            local _command = packet.Message:sub(#Config.Prefix+1)
            local _LOG = os.date("%d.%m.%Y %X", packet.Time).." | "..packet.Message.."\n"
            local _file = "CommandLog_"..packet.FromSpeaker..".txt"
            if not isfile(_file) then writefile(_file,"") end
            appendfile(_file, _LOG)
            out("Foreign Execute >> "..packet.FromSpeaker..": ".._command, 15, Color3.fromHex("#9cdcfe"))
            ExecCommand(_command, Invoker)
        end
    end)
else
    out("OnMessageDoneFiltering not found! Chat Logs and Foreign Execute will not work!", 10, Color3.fromHex("#ffda44"))
end

CreateRadar()