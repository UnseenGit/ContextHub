local module = {}
module.__index = module

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
local ContextGui = game:GetService("CoreGui")
local LP = game:GetService("Players").LocalPlayer
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Mouse = LP:GetMouse()
local mouseLocation = UserInputService:GetMouseLocation()

local ScreenSize = workspace.CurrentCamera.ViewportSize
if ScreenSize.Y > ScreenSize.X then
	ScreenSize = Vector2.new(ScreenSize.Y, ScreenSize.X)
end

local ColorLibraryFile = ConfigModule:Create( "ColorLibrary.lua", {
	Colors = {
		["Lost Pink"] = Color3.new(1, 0, 1),
		["Deep Green"] = Color3.fromHex("009600"),
		["Beefy Red"] = Color3.fromHex("8f0a0a"),
		["Astro Teal"] = Color3.fromHex("23c8be"),
		["Moon Blue"] = Color3.fromHex("00c8c8"),
	},
	Recent = {},
})

local function Create(ClassName, ...)
	local Obj = Instance.new(ClassName)
	for _, Properties in pairs({ ... }) do
		for Prop, Val in pairs(Properties) do
			pcall(function()
				Obj[Prop] = Val
			end)
		end
	end
	return Obj
end

RunService.RenderStepped:connect(function()
	mouseLocation = UserInputService:GetMouseLocation()
end)
local function MoveToTop(obj)
	local Parent = obj.Parent
	obj.Parent = nil
	obj.Parent = Parent
end
module.DefaultSettings = ConfigModule:Create( "ContextMenuConfig.lua", {
	TooltipSize = 300,
	BorderColor = Color3.fromHex("#323336"),
	BorderSizePixel = 1,
	ContextMenuEntries = {
		BackgroundColor3 = Color3.fromHex("#1e2024"),
		BorderColor3 = Color3.fromHex("#323336"),
		BorderSizePixel = 0,
		TextColor3 = Color3.fromHex("#e8e8e8"),
		TextStrokeTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 14,
		RichText = true,
		BorderMode = "Inset",
		TextXAlignment = "Left",
	},
	ContextMenuEntriesCheckbox = {
		CheckboxCheckedSymbol = "✓",
		CheckboxChoiceSymbol = "●",
		CheckboxUncheckedSymbol = "",
	},
	ContextMenuEntriesKeybind = {
		ButtonTextColor3 = Color3.fromHex("#6688ef"),
		TextXAlignment = "Center",
		TextYAlignment = "Center",
	},
	ContextMenuEntriesColor3 = {},
	ContextMenuEntriesTextBox = {
		TextColor3 = Color3.fromHex("#efefef"),
		PlaceholderText = "Input...",
	},
	ContextMenuEntriesSlider = {
		BackgroundColor3 = Color3.fromHex("#191a1c"),
		TextColor3 = Color3.fromHex("#efefef"),
	},
	Prompts = {
		Body = {
			BackgroundColor3 = Color3.fromHex("#1e2024"),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 1,
			Size = UDim2.fromOffset(400, 150),
			Position = UDim2.new(0.5, -200, 0.5, -75),
			BorderMode = "Inset",
			ClipsDescendants = true,
		},
		Title = {
			BackgroundColor3 = Color3.fromHex("#323336"),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 3,
			TextColor3 = Color3.fromHex("#e8e8e8"),
			TextStrokeTransparency = 1,
			Font = Enum.Font.Code,
			Text = "Prompt",
			TextSize = 18,
			TextXAlignment = "Left",
			AnchorPoint = Vector2.new(0, 1),
			BorderMode = "Inset",
			TextTruncate = "AtEnd",
		},
		Content = {
			ClipsDescendants = true,
			TextLabel = {
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				TextColor3 = Color3.fromHex("#e8e8e8"),
				TextStrokeTransparency = 1,
				Font = Enum.Font.Gotham,
				RichText = true,
				Text = "If you see this the dev done fucked up.",
				TextSize = 14,
				TextXAlignment = "Left",
				TextYAlignment = "Top",
			},
			TextBox = {
				BackgroundColor3 = Color3.fromHex("#191a1c"),
				BorderColor3 = Color3.fromHex("#323336"),
				BorderSizePixel = 1,
				TextColor3 = Color3.fromHex("#e8e8e8"),
				TextStrokeTransparency = 1,
				Font = Enum.Font.Code,
				TextSize = 14,
				Size = UDim2.new(1, 0, 0, 17),
				TextXAlignment = "Left",
				TextYAlignment = "Top",
				ClearTextOnFocus = false,
				Text = "",
				PlaceholderText = "Input...",
				TextWrapped = true,
			},
			Frame = {
				BorderColor3 = Color3.fromHex("#323336"),
				BorderSizePixel = 1,
				BackgroundTransparency = 1,
			},
			TextButton = {
				BackgroundColor3 = Color3.fromHex("#1e2024"),
				BorderColor3 = Color3.fromHex("#323336"),
				BorderSizePixel = 1,
				TextColor3 = Color3.fromHex("#e8e8e8"),
				TextStrokeTransparency = 1,
				Font = Enum.Font.Code,
				TextSize = 14,
				TextXAlignment = "Center",
				TextYAlignment = "Center",
				AutoButtonColor = true,
			},
			ImageButton = {
				BackgroundColor3 = Color3.fromHex("#1e2024"),
				BorderColor3 = Color3.fromHex("#323336"),
				BorderSizePixel = 1,
				AutoButtonColor = true,
			},
		},
		Buttons = {
			BackgroundColor3 = Color3.fromHex("#1e2024"),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 1,
			TextColor3 = Color3.fromHex("#e8e8e8"),
			TextStrokeTransparency = 1,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextXAlignment = "Center",
			TextYAlignment = "Center",
			AutoButtonColor = true,
			GrayedOutBackgroundColor3 = Color3.fromRGB(18, 18, 18),
			GrayedOutTextColor3 = Color3.fromRGB(31, 31, 31),
		},
		Focus = false,
		Scalable = false,
		HasCloseButton = true,
		MinimumButtonSize = 75,
		ReturnType = "Object",
	},
	TextBox = {
		Entries = {
			BackgroundColor3 = Color3.fromHex("#1e2024"),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 1,
			TextColor3 = Color3.fromHex("#e8e8e8"),
			TextStrokeTransparency = 1,
			Font = Enum.Font.Code,
			TextSize = 14,
			RichText = true,
			TextXAlignment = "Left",
			TextWrapped = true,
		},
		Buttons = {
			BackgroundColor3 = Color3.fromHex("#1e2024"),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 3,
			TextColor3 = Color3.fromHex("#e8e8e8"),
			TextStrokeTransparency = 1,
			Font = Enum.Font.Code,
			TextSize = 15,
			RichText = true,
			TextXAlignment = "Center",
			GrayedOutBackgroundColor3 = Color3.fromHex("#a1a5ad"),
			AutoButtonColor = true,
		},
		TextBox = {
			BackgroundColor3 = Color3.fromHex("#1e2024"),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 0,
			Size = UDim2.fromOffset(math.round(ScreenSize.X * 0.5), math.round(ScreenSize.Y / 1.4)),
			Position = UDim2.fromOffset(math.round(ScreenSize.X * 0.35), math.round(ScreenSize.Y * 0.1)),
			BorderMode = "Inset",
		},
		Filter = {
			BackgroundColor3 = Color3.fromHex("#191a1c"),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 1,
			TextColor3 = Color3.fromHex("#e8e8e8"),
			TextStrokeTransparency = 1,
			Font = Enum.Font.Code,
			TextSize = 14,
			TextXAlignment = "Left",
			ClearTextOnFocus = false,
			Text = "",
			PlaceholderText = "Filter",
			TextWrapped = true,
		},
		Title = {
			BackgroundColor3 = Color3.fromHex("#323336"),
			TextColor3 = Color3.fromHex("#e8e8e8"),
			TextStrokeTransparency = 1,
			Font = Enum.Font.Code,
			Text = "Text Box",
			TextSize = 18,
			TextXAlignment = "Left",
			AnchorPoint = Vector2.new(0, 1),
			TextTruncate = "AtEnd",
			BorderSizePixel = 0,
		},
		ButtonTooltips = {
			BackgroundColor3 = Color3.fromHex("#2a2d33"),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 1,
			TextColor3 = Color3.fromHex("#e8e8e8"),
			TextStrokeTransparency = 1,
			Font = Enum.Font.Code,
			TextSize = 13,
			RichText = true,
		},
		BackdropColor3 = Color3.fromHex("#1a1c1f"),
		Resizeable = true,
		Draggable = true,
		EntryListPadding = {
			Top = 15,
			Bottom = 15,
			Left = 15,
			Right = 15,
			Text = 8,
		},
		TopBar = {
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		},
		ButtonHeight = 30,
		TopBarWidthOffset = 0.77,
	},
	ColorPicker = {
		Buttons = {
			BackgroundColor3 = Color3.fromHex("#1e2024"),
			BorderColor3 = Color3.fromHex("#323336"),
			TextColor3 = Color3.fromRGB(202, 202, 202),
			BorderSizePixel = 3,
			TextStrokeTransparency = 1,
			Font = Enum.Font.Roboto,
			TextSize = 18,
			RichText = true,
			TextXAlignment = "Center",
			AutoButtonColor = true,
		},
		Input = {
			BackgroundColor3 = Color3.fromRGB(25, 27, 30),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 1,
			TextColor3 = Color3.fromRGB(202, 202, 202),
			TextStrokeTransparency = 1,
			Font = Enum.Font.SourceSans,
			ClearTextOnFocus = false,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Center,
		},
		Title = {
			BackgroundColor3 = Color3.fromHex("#323336"),
			TextColor3 = Color3.fromHex("#e8e8e8"),
			TextStrokeTransparency = 1,
			Font = Enum.Font.Code,
			Text = "Text Box",
			TextSize = 18,
			TextXAlignment = "Left",
			AnchorPoint = Vector2.new(0, 1),
			TextTruncate = "AtEnd",
			BorderSizePixel = 0,
		},
		Indicators = {
			Name = "UnitIndicator",
			BackgroundTransparency = 1,
			Font = Enum.Font.Roboto,
			TextSize = 18,
			RichText = true,
			TextColor3 = Color3.fromRGB(153, 153, 153),
			Size = UDim2.new(1, 0, 0, 22),
			TextXAlignment = Enum.TextXAlignment.Left,
		},
		Labels = {
			BackgroundTransparency = 1,
			Font = Enum.Font.Roboto,
			TextSize = 18,
			RichText = true,
			TextColor3 = Color3.fromRGB(202, 202, 202),
			Size = UDim2.new(1, 0, 0, 22),
			TextXAlignment = Enum.TextXAlignment.Left,
		},
		Backdrop = {
			BackgroundColor3 = Color3.fromHex("#1e2024"),
			BorderColor3 = Color3.fromHex("#323336"),
			BorderSizePixel = 0,
			AutoButtonColor = false,
			BorderMode = "Inset",
		},
	},
	Tooltips = {
		BackgroundColor3 = Color3.fromHex("#2a2d33"),
		BorderColor3 = Color3.fromHex("#323336"),
		BorderSizePixel = 1,
		TextColor3 = Color3.fromHex("#e8e8e8"),
		TextStrokeTransparency = 1,
		Font = Enum.Font.Code,
		TextSize = 13,
		RichText = true,
	},
	Padding = 3, --halved!!!
	TooltipDelay = 0.5,
	Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y),
	FrameAnchorPoint = Vector2.new(0, 0),
	MinSize = 100,
})

function module.SetSettings(SettingsTable, SettingsToChange)
	for set, value in pairs(SettingsToChange) do
		if typeof(value) == "table" then
			if value[1] == "Vector2" then
				pcall(function()
					SettingsTable[set] = Vector2.new(table.unpack(value, 2))
				end)
			elseif value[1] == "Vector3" then
				pcall(function()
					SettingsTable[set] = Vector3.new(table.unpack(value, 2))
				end)
			elseif value[1] == "UDim2" then
				pcall(function()
					SettingsTable[set] = UDim2.new(table.unpack(value, 2))
				end)
			elseif value[1] == "UDim" then
				pcall(function()
					SettingsTable[set] = UDim.new(table.unpack(value, 2))
				end)
			elseif value[1] == "CFrame" then
				pcall(function()
					SettingsTable[set] = CFrame.new(table.unpack(value, 2))
				end)
			elseif value[1] == "CFrameAngles" then
				pcall(function()
					SettingsTable[set] = CFrame.Angles(math.rad(value[2]), math.rad(value[3]), math.rad(value[4]))
				end)
			elseif value[1] == "Color3" then
				pcall(function()
					SettingsTable[set] = Color3.fromHex(value[2])
				end)
			elseif value[1] == "NumberSequence" then
				pcall(function()
					local _Keypoints = {}
					for i = 2, #value do
						table.insert(_Keypoints, NumberSequenceKeypoint.new(table.unpack(value[i])))
					end
					SettingsTable[set] = NumberSequence.new(table.unpack(_Keypoints))
				end)
			elseif value[1] == "ColorSequence" then
				pcall(function()
					local _Keypoints = {}
					for i = 2, #value do
						table.insert(_Keypoints, ColorSequenceKeypoint.new(value[i][1], Color3.fromHex(value[i][2])))
					end
					SettingsTable[set] = NumberSequence.new(table.unpack(_Keypoints))
				end)
			elseif value[1] == "NumberRange" then
				pcall(function()
					SettingsTable[set] = NumberRange.new(table.unpack(value, 2))
				end)
			else
				if not SettingsTable[set] then
					pcall(function()
						SettingsTable[set] = {}
					end)
				end
				module.SetSettings(SettingsTable[set], value)
			end
		else
			pcall(function()
				SettingsTable[set] = value
			end)
		end
	end
end
function module.GetSettings()
	return module.DefaultSettings
end
function module.CreateSyntaxHighlightTextbox(Locked, ...)
	local DisplayBox = Instance.new("TextLabel")
	local PropTable = { ... }
	local SelectionStart = '<stroke color="#00A2FF" joins="miter" thickness="3">'
	local SelectionEnd = "</stroke>"
	local succ, err = pcall(function()
		local Text = ""
		local TextBox = Instance.new("TextBox", DisplayBox)
		local CursorLabel = Instance.new("TextLabel", TextBox)
		CursorLabel.RichText = true
		local cursor = "_"
		if Locked then
			cursor = ""
		end
		TextBox:GetPropertyChangedSignal("CursorPosition"):Connect(function()
			CursorLabel.Text = '<font transparency="1">'
				.. TextBox.Text:sub(0, TextBox.CursorPosition)
				.. "</font>"
				.. cursor
		end)
		local function UpdateText()
			if TextBox.Text == "" then
				Text = TextBox.PlaceholderText
				DisplayBox.TextTransparency = 0.5
				DisplayBox.Text = Text
			else
				Text = Util.SyntaxHighlight(
					TextBox.Text,
					math.min(TextBox.CursorPosition, TextBox.SelectionStart),
					math.max(TextBox.CursorPosition, TextBox.SelectionStart)
				)
				DisplayBox.TextTransparency = 0
				DisplayBox.Text = Text
				if Locked then
					TextBox.TextEditable = false
					DisplayBox.TextTransparency = 0.4
				end
			end
		end
		TextBox:GetPropertyChangedSignal("Text"):Connect(UpdateText)
		TextBox:GetPropertyChangedSignal("SelectionStart"):Connect(UpdateText)
		TextBox:GetPropertyChangedSignal("CursorPosition"):Connect(UpdateText)
		TextBox.Focused:Connect(function()
			repeat
				if TextBox.CursorPosition > 0 and not Locked then
					for i = 0, 1, 0.2 do
						CursorLabel.Text = '<font transparency="1">'
							.. TextBox.Text:sub(1, TextBox.CursorPosition - 1)
							.. '</font><font transparency="'
							.. i
							.. '">'
							.. cursor
							.. "</font>"
						wait()
					end
					for i = 1, 0, -0.2 do
						CursorLabel.Text = '<font transparency="1">'
							.. TextBox.Text:sub(1, TextBox.CursorPosition - 1)
							.. '</font><font transparency="'
							.. i
							.. '">'
							.. cursor
							.. "</font>"
						wait()
					end
				end
				wait()
			until TextBox.CursorPosition < 0
			CursorLabel.Text = ""
		end)
		for _, Properties in pairs(PropTable) do
			module.SetSettings(DisplayBox, Properties)
			module.SetSettings(TextBox, Properties)
			module.SetSettings(CursorLabel, Properties)
		end
		CursorLabel.Text = ""
		DisplayBox.RichText = true
		CursorLabel.RichText = true
		if Locked then
			TextBox.TextEditable = false
			DisplayBox.TextTransparency = 0.4
		end
		TextBox.Parent = DisplayBox
		CursorLabel.Parent = TextBox
		DisplayBox.Name = "DisplayBox"
		CursorLabel.Name = "CursorLabel"
		TextBox.TextStrokeTransparency = 1
		TextBox.TextTransparency = 1
		TextBox.BackgroundTransparency = 1
		TextBox.BorderSizePixel = 0
		TextBox.Size = UDim2.fromScale(1, 1)
		DisplayBox.ClipsDescendants = true
		CursorLabel.Size = UDim2.fromScale(1, 1)
		CursorLabel.BackgroundTransparency = 1
	end)
	if err then
		rconsoleprint(err)
	end
	return DisplayBox
end
function module.Prompt(Info)
	if not Info then
		Info = {}
	end
	if not Info.Settings then
		Info.Settings = {}
	end
	if not Info.Settings.ButtonAlignment then
		Info.Settings.ButtonAlignment = "Right"
	end
	local PromptObject = {}
	PromptObject.__index = PromptObject
	local Settings = {}
	module.SetSettings(Settings, module.DefaultSettings)
	module.SetSettings(Settings.Prompts, Info.Settings)
	PromptObject.ScreenGui = Instance.new("ScreenGui", ContextGui)
	PromptObject.ScreenGui.DisplayOrder = 10
	PromptObject.ScreenGui.Name = "PromptHolder"
	if Settings.Prompts.Focus then
		local FocusPanel = Instance.new("TextButton", PromptObject.ScreenGui)
		FocusPanel.Text = ""
		FocusPanel.AutoButtonColor = false
		FocusPanel.Size = UDim2.fromScale(2, 2)
		FocusPanel.Position = UDim2.fromScale(-0.5, -0.5)
		FocusPanel.BackgroundColor3 = Color3.new(0, 0, 0)
		FocusPanel.BackgroundTransparency = 1
		TweenService:Create(FocusPanel, TweenInfo.new(0.10), { BackgroundTransparency = 0.6 }):Play()
	end
	PromptObject.Instance = Instance.new("Frame", PromptObject.ScreenGui)
	module.SetSettings(PromptObject.Instance, Settings.Prompts.Body)
	PromptObject.Instance.Size = UDim2.new(0, 0, 0, 0)
	PromptObject.Instance.Position =
		UDim2.fromScale(Settings.Prompts.Body.Position.X.Scale, Settings.Prompts.Body.Position.Y.Scale)
	local ButtonFrame = Instance.new("Frame", PromptObject.Instance)
	ButtonFrame.Transparency = 1
	ButtonFrame.Size = UDim2.new(1, -60, 0, Settings.Prompts.Buttons.TextSize + 6)
	ButtonFrame.Position = UDim2.new(0, 30, 1, 0 - (Settings.Prompts.Buttons.TextSize * 2.5))
	local UIListLayout = Instance.new("UIListLayout", ButtonFrame)
	UIListLayout.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout.HorizontalAlignment = Settings.Prompts.ButtonAlignment
	UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout.Padding = UDim.new(0, 15)
	local Buttons = 0
	function PromptObject.Close()
		PromptObject.ScreenGui:Destroy()
		if Info then
			if Info.OnClose then
				Info.OnClose()
			end
		end
	end
	PromptObject.Buttons = {}
	function PromptObject:AddButton(Args)
		if not Args then
			Args = {}
		end
		Buttons = Buttons + 1
		local Button = Instance.new("TextButton", ButtonFrame)
		Button.Text = Args.Text
		Button.Name = Args.Text
		module.SetSettings(Button, Settings.Prompts.Buttons)
		Button.Size = UDim2.fromOffset(
			math.max(Button.TextBounds.X + 10, Settings.Prompts.MinimumButtonSize),
			Button.TextBounds.Y + 6
		)
		if not Args.DontClose then
			Button.MouseButton1Click:connect(PromptObject.Close)
			Button.MouseButton2Click:connect(PromptObject.Close)
		end
		if Args.M1Func then
			Button.MouseButton1Click:connect(function()
				Args.M1Func(PromptObject, Settings)
			end)
		end
		if Args.M2Func then
			Button.MouseButton2Click:connect(function()
				Args.M2Func(PromptObject, Settings)
			end)
		end
		PromptObject.Buttons[Args.Text] = Button
		return Button
	end
	if Info.Buttons then
		for _, v in pairs(Info.Buttons) do
			PromptObject:AddButton(v)
		end
	end
	local TitleBar = Instance.new("TextLabel", PromptObject.ScreenGui)
	TitleBar.RichText = true
	module.SetSettings(TitleBar, Settings.Prompts.Title)
	if not Info.Title then
		TitleBar.Text = " " .. TitleBar.Text
	else
		TitleBar.Text = " " .. Info.Title
	end
	TitleBar.Name = "TitleBar"
	local TitleBarButtons = {}
	TitleBarButtons.Close = Instance.new("TextButton", TitleBar)
	TitleBarButtons.CloseHighlight = Instance.new("TextLabel", TitleBar)
	module.SetSettings(TitleBarButtons.Close, Settings.Prompts.Title)
	module.SetSettings(TitleBarButtons.CloseHighlight, Settings.Prompts.Title)
	TitleBarButtons.Close.Text = "X"
	TitleBarButtons.Close.Position = UDim2.new(1, 3, 0, -3)
	TitleBarButtons.Close.BackgroundTransparency = 1
	TitleBarButtons.Close.BorderSizePixel = 0
	TitleBarButtons.Close.AnchorPoint = Vector2.new(1, 0)
	TitleBarButtons.Close.TextXAlignment = "Center"
	TitleBarButtons.CloseHighlight.Text = "X"
	TitleBarButtons.CloseHighlight.Position = UDim2.new(1, 3, 0, -3)
	TitleBarButtons.CloseHighlight.BackgroundColor3 = Color3.new(0.6, 0, 0)
	TitleBarButtons.CloseHighlight.BorderSizePixel = 0
	TitleBarButtons.CloseHighlight.AnchorPoint = Vector2.new(1, 0)
	TitleBarButtons.CloseHighlight.TextXAlignment = "Center"
	TitleBarButtons.CloseHighlight.Transparency = 1
	RunService.RenderStepped:Connect(function()
		TitleBarButtons.Close.Size = UDim2.fromOffset(TitleBar.Size.Y.Offset, TitleBar.Size.Y.Offset)
		TitleBarButtons.CloseHighlight.Size = UDim2.fromOffset(TitleBar.Size.Y.Offset, TitleBar.Size.Y.Offset)
		TitleBar.Size = UDim2.new(0, PromptObject.Instance.AbsoluteSize.X, 0, Settings.Prompts.Title.TextSize + 3)
		TitleBar.Position =
			UDim2.fromOffset(PromptObject.Instance.AbsolutePosition.X, PromptObject.Instance.AbsolutePosition.Y)
	end)
	PromptObject.Container = Instance.new("Frame", PromptObject.Instance)
	PromptObject.Container.Size = UDim2.new(1, -20, 1, -20 - (Settings.Prompts.Buttons.TextSize * 2.5))
	PromptObject.Container.ClipsDescendants = Settings.Prompts.Content.ClipsDescendants
	PromptObject.Container.Position = UDim2.fromOffset(10, 10)
	PromptObject.Container.Transparency = 1
	if Info.Content then
		if typeof(Info.Content) == "string" then
			local TextLabel = Instance.new("TextLabel", PromptObject.Container)
			module.SetSettings(TextLabel, Settings.Prompts.Content.TextLabel)
			TextLabel.Size = UDim2.fromScale(1, 1)
			TextLabel.Text = Info.Content
			TextLabel.TextWrapped = true
		elseif typeof(Info.Content) == "table" then
			for i, v in pairs(Info.Content) do
				local GuiObject = Instance.new(v.ClassName, PromptObject.Container)
				GuiObject.Name = i
				if v.InitFunction then
					coroutine.wrap(function()
						v.InitFunction(GuiObject, PromptObject, Settings)
					end)()
				end
				if not GuiObject:IsA("GuiObject") then
					--error(v.ClassName.." "..i.." ".."is not a GuiObject!")
				end
				if Settings.Prompts.Content[v.ClassName] then
					module.SetSettings(GuiObject, Settings.Prompts.Content[v.ClassName])
				end
				module.SetSettings(GuiObject, v)
			end
		end
	end
	local BeingDragged = false
	local DragOffset = Vector2.new(
		PromptObject.Instance.Position.X.Offset - mouseLocation.X,
		PromptObject.Instance.Position.Y.Offset - mouseLocation.Y
	)
	RunService.RenderStepped:Connect(function()
		if BeingDragged then
			PromptObject.Instance.Position =
				UDim2.fromOffset(mouseLocation.X + DragOffset.X, mouseLocation.Y + DragOffset.Y)
		end
	end)
	Mouse.Button1Down:connect(function()
		if Util.isHoveringOverObj(TitleBar) then
			DragOffset = Vector2.new(
				PromptObject.Instance.AbsolutePosition.X - mouseLocation.X,
				PromptObject.Instance.AbsolutePosition.Y - mouseLocation.Y
			)
			wait()
			BeingDragged = true
			MoveToTop(PromptObject.Instance)
		end
	end)
	Mouse.Button1Up:connect(function()
		BeingDragged = false
	end)
	local CloseFadeIn =
		TweenService:Create(TitleBarButtons.CloseHighlight, TweenInfo.new(0.4), { BackgroundTransparency = 0.8 })
	local CloseFadeOut =
		TweenService:Create(TitleBarButtons.CloseHighlight, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
	TitleBarButtons.CloseHighlight.MouseEnter:connect(function()
		CloseFadeIn:Play()
	end)
	TitleBarButtons.CloseHighlight.MouseLeave:connect(function()
		CloseFadeOut:Play()
	end)
	TitleBarButtons.Close.AutoButtonColor = false
	TitleBarButtons.Close.MouseButton1Click:connect(PromptObject.Close)
	PromptObject.Instance:TweenSize(
		Settings.Prompts.Body.Size,
		Enum.EasingDirection.Out, -- EasingDirection
		Enum.EasingStyle.Quint, -- EasingStyle
		0.2, -- Time
		true
	)
	PromptObject.Instance:TweenPosition(
		Settings.Prompts.Body.Position,
		Enum.EasingDirection.Out, -- EasingDirection
		Enum.EasingStyle.Quint, -- EasingStyle
		0.2, -- Time
		true
	)
	if Settings.Prompts.ReturnType:lower() == "object" then
		return PromptObject
	elseif Settings.Prompts.ReturnType:lower() == "instance" then
		return PromptObject.instance
	elseif Settings.Prompts.ReturnType:lower() == "confirmation" then
		local ret = nil
		PromptObject:AddButton({
			Text = "Cancel",
			M1Func = function()
				ret = false
			end,
		})
		PromptObject:AddButton({
			Text = "Ok",
			M1Func = function()
				ret = true
				PromptObject.Close()
			end,
		})
		repeat
			wait()
		until ret ~= nil
		return ret
	end
end
local PickerFrame
local function SetRecent(Name)
	local Recent = ColorLibraryFile.Recent
	ColorLibraryFile.Recent = { Name }
	for _, Name in pairs(Recent) do
		if not table.find(ColorLibraryFile.Recent, Name) then
			table.insert(ColorLibraryFile.Recent, Name)
		end
		if #ColorLibraryFile.Recent > 4 then
			break
		end
	end
	ColorLibraryFile:Write()
end
function module.OpenColorPicker(CurrentColor, Parent)
	local DefaultSettings = {}
	module.SetSettings(DefaultSettings, module.DefaultSettings)
	local ColorValue = CurrentColor or Color3.new(1, 1, 1)
	local HSVColorValue = {}
	HSVColorValue.H, HSVColorValue.S, HSVColorValue.V = ColorValue:ToHSV()
	local HexColorValue = ColorValue:ToHex()
	local HueValue = HSVColorValue.H
	local SatValue = HSVColorValue.S
	local ValValue = HSVColorValue.V
	ColorLibraryFile = ConfigModule:Create( "ColorLibrary.lua", {
		Colors = {
			["Lost Pink"] = Color3.new(1, 0, 1),
			["Deep Green"] = Color3.fromHex("009600"),
			["Beefy Red"] = Color3.fromHex("8f0a0a"),
			["Astro Teal"] = Color3.fromHex("23c8be"),
			["Moon Blue"] = Color3.fromHex("00c8c8"),
		},
		Recent = {},
	})
	local Connections = {}
	local ScreenGui = Create("ScreenGui", {
		Name = "PickerGUI",
		DisplayOrder = 3,
		Parent = LP:WaitForChild("PlayerGui"),
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	local EyeDropper = Create("ImageLabel", {
		Parent = ScreenGui,
		Name = "EyeDropper",
		Image = "http://www.roblox.com/asset/?id=11583260206",
		Size = UDim2.fromOffset(20, 20),
		BackgroundTransparency = 1.000,
		Visible = false,
	})
	PickerFrame = Create("TextButton", DefaultSettings.ColorPicker.Backdrop, {
		Name = "PickerFrame",
		Text = "",
		Parent = ScreenGui,
		Position = UDim2.fromOffset(math.round(ScreenSize.X * 0.35), math.round(ScreenSize.Y * 0.1)),
		Size = UDim2.new(0, 520, 0, 279),
	})
	local Buttons = Create("Frame", {
		Name = "Buttons",
		Parent = PickerFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 308, 0, 12),
		Size = UDim2.new(0, 200, 0, 132),
	})
	local ColorPreview = Create("Frame", {
		Name = "ColorPreview",
		Parent = Buttons,
		AnchorPoint = Vector2.new(0, 0.5),
		BackgroundColor3 = Color3.fromRGB(255, 255, 255),
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.new(0, 66, 0, 76),
	})

	local New = Create("Frame", {
		Name = "New",
		Parent = ColorPreview,
		BackgroundColor3 = ColorValue,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0.5, 0),
	})
	local Old = Create("Frame", {
		Name = "Old",
		Parent = ColorPreview,
		BackgroundColor3 = ColorValue,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0.5, 0),
	})
	local OldText = Create("TextLabel", DefaultSettings.ColorPicker.Indicators, {
		Name = "OldText",
		Parent = ColorPreview,
		Position = UDim2.new(0, 0, 1, 4),
		Text = "current",
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	local NewText = Create("TextLabel", DefaultSettings.ColorPicker.Indicators, {
		Name = "NewText",
		Parent = ColorPreview,
		Position = UDim2.new(0, 0, 0, -4),
		Text = "new",
		AnchorPoint = Vector2.new(0, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	local CancelButton = Create("TextButton", DefaultSettings.ColorPicker.Buttons, {
		Name = "CancelButton",
		Parent = Buttons,
		Position = UDim2.new(0, 106, 0, 34),
		Size = UDim2.new(0, 96, 0, 28),
		Text = "Cancel",
	})
	local LibraryButton = Create("TextButton", DefaultSettings.ColorPicker.Buttons, {
		Name = "LibraryButton",
		Parent = Buttons,
		Position = UDim2.new(0, 106, 0, 104),
		Size = UDim2.new(0, 96, 0, 28),
		Text = "Open library",
	})
	local AddToLibraryButton = Create("TextButton", DefaultSettings.ColorPicker.Buttons, {
		Name = "AddToLibraryButton",
		Parent = Buttons,
		Position = UDim2.new(0, 106, 0, 70),
		Size = UDim2.new(0, 96, 0, 28),
		Text = "Add to library",
	})
	local OkButton = Create("TextButton", DefaultSettings.ColorPicker.Buttons, {
		Name = "OkButton",
		Parent = Buttons,
		Position = UDim2.new(0, 106, 0, 0),
		Size = UDim2.new(0, 96, 0, 28),
		Text = "OK",
	})
	local Picker = Create("Frame", {
		Name = "Picker",
		Parent = PickerFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 12),
		Size = UDim2.new(0, 286, 0, 255),
	})
	local HuePicker = Create("ImageButton", {
		Image = "http://www.roblox.com/asset/?id=11582211227",
		AutoButtonColor = false,
		Name = "HuePicker",
		Parent = Picker,
		BorderColor3 = Color3.fromRGB(27, 42, 53),
		Position = UDim2.new(0, 267, 0, 0),
		Size = UDim2.new(0, 19, 0, 255),
		BackgroundTransparency = 1,
	})
	Create("ImageLabel", {
		Name = "Indicator",
		Parent = HuePicker,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Position = UDim2.new(0.5, 0, math.clamp(1 - HueValue, 0, Picker.HuePicker.AbsoluteSize.Y), 0),
		Size = UDim2.new(0, 39, 0, 9),
		Image = "http://www.roblox.com/asset/?id=11582326186",
	})
	local SVPicker = Create("TextButton", {
		Name = "SVPicker",
		Parent = Picker,
		BackgroundColor3 = Color3.fromHSV(HueValue, 1, 1),
		Size = UDim2.new(0, 255, 0, 255),
		AutoButtonColor = false,
		Text = "",
	})
	Create("ImageLabel", {
		Name = "Gradient",
		Parent = SVPicker,
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Image = "http://www.roblox.com/asset/?id=11581726668",
	})
	Create("ImageLabel", {
		Name = "Indicator",
		Parent = SVPicker,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 11, 0, 11),
		Position = UDim2.fromScale(SatValue, 1 - ValValue),
		Image = "http://www.roblox.com/asset/?id=11582600649",
	})
	local RGBValues = Create("Frame", {
		Name = "RGBValues",
		Parent = PickerFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 308, 0, 152),
		Size = UDim2.new(0, 80, 0, 72),
	})
	local RValue = Create("TextLabel", DefaultSettings.ColorPicker.Labels, {
		Name = "RValue",
		Parent = RGBValues,
		Text = " R:",
	})
	local RTextBox = Create("TextBox", DefaultSettings.ColorPicker.Input, {
		Name = "RTextBox",
		Parent = RValue,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Text = "255",
	})
	local GValue = Create("TextLabel", DefaultSettings.ColorPicker.Labels, {
		Name = "GValue",
		Parent = RGBValues,
		Position = UDim2.new(0, 0, 0, 25),
		Text = " G:",
	})
	local GTextBox = Create("TextBox", DefaultSettings.ColorPicker.Input, {
		Name = "GTextBox",
		Parent = GValue,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Text = "255",
	})
	local BValue = Create("TextLabel", DefaultSettings.ColorPicker.Labels, {
		Name = "BValue",
		Parent = RGBValues,
		Position = UDim2.new(0, 0, 0, 50),
		Text = " B:",
	})
	local BTextBox = Create("TextBox", DefaultSettings.ColorPicker.Input, {
		Name = "BTextBox",
		Parent = BValue,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(1, -30, 1, 0),
		Text = "255",
	})
	local HexValue = Create("Frame", {
		Name = "HexValue",
		Parent = PickerFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 308, 0, 240),
		Size = UDim2.new(0, 200, 0, 22),
	})
	local Hex = Create("TextLabel", DefaultSettings.ColorPicker.Labels, {
		Name = "Hex",
		Parent = HexValue,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(1, -30, 0, 22),
		Text = " Hex:",
	})
	local HexTextBox = Create("TextBox", DefaultSettings.ColorPicker.Input, {
		Name = "HexTextBox",
		Parent = Hex,
		Position = UDim2.new(0, 52, 0, 0),
		Size = UDim2.new(0, 64, 1, 0),
		Text = HexColorValue,
	})
	Create("TextLabel", DefaultSettings.ColorPicker.Indicators, {
		Name = "UnitIndicator",
		Parent = HexTextBox,
		Position = UDim2.new(0, -12, 0, 0),
		Text = "#",
	})
	local HSVValues = Create("Frame", {
		Name = "HSVValues",
		Parent = PickerFrame,
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 414, 0, 152),
		Size = UDim2.new(0, 96, 0, 72),
	})
	local HValue = Create("TextLabel", DefaultSettings.ColorPicker.Labels, {
		Name = "HValue",
		Parent = HSVValues,
		Text = " H:",
	})
	local HTextBox = Create("TextBox", DefaultSettings.ColorPicker.Input, {
		Name = "HTextBox",
		Parent = HValue,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(0, 50, 1, 0),
		Text = Util.round(HSVColorValue.H * 360, 0),
	})
	Create("TextLabel", DefaultSettings.ColorPicker.Indicators, {
		Parent = HTextBox,
		Position = UDim2.new(1, 2, 0, 0),
		Text = "°",
	})
	local SValue = Create("TextLabel", DefaultSettings.ColorPicker.Labels, {
		Name = "SValue",
		Parent = HSVValues,
		Position = UDim2.new(0, 0, 0, 25),
		Text = " S:",
	})
	local STextBox = Create("TextBox", DefaultSettings.ColorPicker.Input, {
		Name = "STextBox",
		Parent = SValue,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(0, 50, 1, 0),
		Text = Util.round(HSVColorValue.S * 100, 0),
	})
	Create("TextLabel", DefaultSettings.ColorPicker.Indicators, {
		Parent = STextBox,
		Position = UDim2.new(1, 2, 0, 0),
		Text = "%",
	})
	local VValue = Create("TextLabel", DefaultSettings.ColorPicker.Labels, {
		Name = "VValue",
		Parent = HSVValues,
		Position = UDim2.new(0, 0, 0, 50),
		Text = " V:",
	})
	local VTextBox = Create("TextBox", DefaultSettings.ColorPicker.Input, {
		Name = "VTextBox",
		Parent = VValue,
		Position = UDim2.new(0, 30, 0, 0),
		Size = UDim2.new(0, 50, 1, 0),
		Text = Util.round(HSVColorValue.V * 100, 0),
	})
	Create("TextLabel", DefaultSettings.ColorPicker.Indicators, {
		Parent = VTextBox,
		Position = UDim2.new(1, 2, 0, 0),
		Text = "%",
	})
	AddToLibraryButton.MouseButton1Click:Connect(function()
		xpcall(function()
			local ColorName = ""
			module.Prompt({
				Content = {
					{
						ClassName = "TextBox",
						Size = UDim2.new(1, 0, 0, 20),
						Text = "",
						PlaceholderText = "Color Name",
						TextYAlignment = Enum.TextYAlignment.Center,
						InitFunction = function(self, prompt, settings)
							self.FocusLost:Connect(function()
								ColorName = self.ContentText
							end)
						end,
					},
				},
				Settings = {
					Focus = false,
					ButtonAlignment = "Right",
					ReturnType = "Object",
					Title = {
						Text = "Save Color",
					},
					Content = { ClipsDescendants = false },
				},
				Buttons = {
					{
						Text = "Save",
						M1Func = function(prompt)
							ColorLibraryFile.Colors[ColorName] = ColorValue
							ColorLibraryFile:Write()
						end,
					},
					{
						Text = "Cancel",
					},
				},
			})
		end, function(err)
			rconsolewarn(debug.traceback(err))
		end)
	end)

	local function SetPickerPos()
		HSVColorValue.H, HSVColorValue.S, HSVColorValue.V = ColorValue:ToHSV()
		HexColorValue = ColorValue:ToHex()
		HueValue = HSVColorValue.H
		SatValue = HSVColorValue.S
		ValValue = HSVColorValue.V
		Picker.HuePicker.Indicator.Position =
			UDim2.new(0.5, 0, math.clamp(1 - HueValue, 0, Picker.HuePicker.AbsoluteSize.Y), 0)
		Picker.SVPicker.Indicator.Position = UDim2.fromScale(SatValue, 1 - ValValue)
	end

	local succ, err = pcall(function()
		ScreenGui.Destroying:Connect(function()
			for _, v in pairs(Connections) do
				v:Disconnect()
			end
		end)
		if Parent then
			ScreenGui.Parent = Parent
		else
			ScreenGui.Parent = LP:WaitForChild("PlayerGui")
		end

		RTextBox.FocusLost:Connect(function()
			if tonumber(RTextBox.Text) and tonumber(RTextBox.Text) < 256 then
				ColorValue = Color3.fromRGB(tonumber(RTextBox.Text), tonumber(GTextBox.Text), tonumber(BTextBox.Text))
				SetPickerPos()
			else
				RTextBox.Text = Util.round(ColorValue.R * 255, 0)
			end
		end)
		GTextBox.FocusLost:Connect(function()
			if tonumber(GTextBox.Text) and tonumber(GTextBox.Text) < 256 then
				ColorValue = Color3.fromRGB(tonumber(RTextBox.Text), tonumber(GTextBox.Text), tonumber(BTextBox.Text))
				SetPickerPos()
			else
				GTextBox.Text = Util.round(ColorValue.G * 255, 0)
			end
		end)
		BTextBox.FocusLost:Connect(function()
			if tonumber(BTextBox.Text) and tonumber(BTextBox.Text) < 256 then
				ColorValue = Color3.fromRGB(tonumber(RTextBox.Text), tonumber(GTextBox.Text), tonumber(BTextBox.Text))
				SetPickerPos()
			else
				BTextBox.Text = Util.round(ColorValue.B * 255, 0)
			end
		end)

		HexTextBox.FocusLost:Connect(function()
			if Util.VerifyHex(HexTextBox.Text) then
				ColorValue = Color3.fromHex(HexTextBox.Text)
				SetPickerPos()
			else
				STextBox.Text = HexColorValue
			end
		end)
		HTextBox.FocusLost:Connect(function()
			if tonumber(HTextBox.Text) and tonumber(HTextBox.Text) < 361 then
				ColorValue = Color3.fromHSV(
					tonumber(HTextBox.Text) / 360,
					tonumber(STextBox.Text) / 100,
					tonumber(VTextBox.Text) / 100
				)
				SetPickerPos()
			else
				HTextBox.Text = Util.round(HueValue * 360, 0)
			end
		end)
		STextBox.FocusLost:Connect(function()
			if tonumber(STextBox.Text) and tonumber(STextBox.Text) < 101 then
				ColorValue = Color3.fromHSV(
					tonumber(HTextBox.Text) / 360,
					tonumber(STextBox.Text) / 100,
					tonumber(VTextBox.Text) / 100
				)
				SetPickerPos()
			else
				STextBox.Text = Util.round(SatValue * 360, 0)
			end
		end)
		VTextBox.FocusLost:Connect(function()
			if tonumber(VTextBox.Text) and tonumber(VTextBox.Text) < 101 then
				ColorValue = Color3.fromHSV(
					tonumber(HTextBox.Text) / 360,
					tonumber(STextBox.Text) / 100,
					tonumber(VTextBox.Text) / 100
				)
				SetPickerPos()
			else
				VTextBox.Text = Util.round(ValValue * 360, 0)
			end
		end)

		LibraryButton.MouseButton1Click:Connect(function()
			module.OpenColorLibrary(nil, ScreenGui, function(color)
				ColorValue = color
				SetPickerPos()
			end)
		end)
		LibraryButton.MouseButton2Click:Connect(function()
			if #ColorLibraryFile.Recent > 0 then
				local Square = "■"
				local RecentColors = {}
				for _, Color in pairs(ColorLibraryFile.Recent) do
					if ColorLibraryFile.Colors[Color] then
						table.insert(RecentColors, {
							Text = '<font color="#'
								.. ColorLibraryFile.Colors[Color]:ToHex()
								.. '">'
								.. Square
								.. "</font> "
								.. Color,
							M1Func = function()
								ColorValue = ColorLibraryFile.Colors[Color]
								SetPickerPos()
								SetRecent(Color)
							end,
						})
					end
				end
				module.Create({
					FrameAnchorPoint = Util.CMAnchorPoint(),
					Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y),
					TitleText = "  Recent Colors",
					ContextMenuEntries = {
						AutoButtonColor = false,
						TextSize = 11,
					},
					DisplayOrder = 4,
					OnlyCloseSelf = true,
				}, table.unpack(RecentColors))
			end
		end)
		local Picker = {
			ColorPreview = {
				New = New,
				Old = Old,
			},
			ColorValues = {
				Hex = HexTextBox,
				HSV = {
					H = HTextBox,
					S = STextBox,
					V = VTextBox,
				},
				RGB = {
					R = RTextBox,
					G = GTextBox,
					B = BTextBox,
				},
			},
			Buttons = {
				Ok = OkButton,
				Cancel = CancelButton,
				AddToLibrary = AddToLibraryButton,
				Library = LibraryButton,
			},
			HuePicker = HuePicker,
			SVPicker = SVPicker,
			Frame = PickerFrame,
			GUI = ScreenGui,
			UpdateColor = Instance.new("BindableEvent"),
		}
		local TitleBar = Create("TextButton", DefaultSettings.ColorPicker.Title, {
			Parent = PickerFrame,
			Text = " Color Picker",
			AutoButtonColor = false,
			Name = "TitleBar",
			AnchorPoint = Vector2.new(0, 1),
			Size = UDim2.new(1, 4, 0, 20),
			Position = UDim2.fromOffset(-2, 0)
		})
		local BeingDragged = false
		local HueBeingDragged = false
		local SVBeingDragged = false
		local DragOffset = Vector2.new(
			Picker.Frame.Position.X.Offset - mouseLocation.X,
			Picker.Frame.Position.Y.Offset - mouseLocation.Y
		)
		Connections.InputBegan = UserInputService.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if Util.isHoveringOverObj(TitleBar) then
					DragOffset = Vector2.new(
						Picker.Frame.Position.X.Offset - mouseLocation.X,
						Picker.Frame.Position.Y.Offset - mouseLocation.Y
					)
					BeingDragged = true
					MoveToTop(Picker.Frame)
				end
				if
					not Util.isHoveringOverObj(PickerFrame)
					and not Util.isHoveringOverObj(TitleBar)
					and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift)
				then
					local succ, color = pcall(function()
						return Util.getMouseHitIncludingChar().Instance.Color
					end)
					if succ then
						ColorValue = color
						SetPickerPos()
					end
				end
			end
		end)
		Connections.InputEnded = UserInputService.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				BeingDragged = false
				HueBeingDragged = false
				SVBeingDragged = false
			end
		end)
		Connections.HueBeingDragged = Picker.HuePicker.MouseButton1Down:Connect(function()
			HueBeingDragged = true
		end)
		Connections.SVBeingDragged = Picker.SVPicker.MouseButton1Down:Connect(function()
			SVBeingDragged = true
		end)
		Connections.RenderStepped = RunService.RenderStepped:Connect(function()
			xpcall(function()
				if HueBeingDragged then
					Picker.HuePicker.Indicator.Position = UDim2.new(
						0.5,
						0,
						0,
						math.clamp(
							mouseLocation.Y - 36 - Picker.HuePicker.AbsolutePosition.Y,
							0,
							Picker.HuePicker.AbsoluteSize.Y
						)
					)
					HueValue = (255 - Picker.HuePicker.Indicator.Position.Y.Offset) / 255 + 0.00000001
					ColorValue = Color3.fromHSV(HueValue, SatValue, ValValue)
				end
				if SVBeingDragged then
					Picker.SVPicker.Indicator.Position = UDim2.new(
						0,
						math.clamp(
							mouseLocation.X - Picker.SVPicker.AbsolutePosition.X,
							0,
							Picker.SVPicker.AbsoluteSize.X
						),
						0,
						math.clamp(
							mouseLocation.Y - 36 - Picker.SVPicker.AbsolutePosition.Y,
							0,
							Picker.SVPicker.AbsoluteSize.Y
						)
					)
					SatValue = Picker.SVPicker.Indicator.Position.X.Offset / 255
					ValValue = (255 - Picker.SVPicker.Indicator.Position.Y.Offset) / 255
					ColorValue = Color3.fromHSV(HueValue, SatValue, ValValue)
				end
				if BeingDragged then
					Picker.Frame.Position = UDim2.fromOffset(
						math.min(
							ScreenGui.AbsoluteSize.X - 7,
							math.max(7 - Picker.Frame.AbsoluteSize.X - 30, mouseLocation.X + DragOffset.X)
						),
						math.min(ScreenGui.AbsoluteSize.Y, math.max(7, mouseLocation.Y + DragOffset.Y))
					)
				end
				EyeDropper.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y + 15)
				if not UserInputService:GetFocusedTextBox() then
					New.BackgroundColor3 = ColorValue
					HSVColorValue.H, HSVColorValue.S, HSVColorValue.V = ColorValue:ToHSV()
					HexColorValue = ColorValue:ToHex()
					SVPicker.BackgroundColor3 = Color3.fromHSV(HueValue, 1, 1)
					VTextBox.Text = Util.round(HSVColorValue.V * 100, 0)
					STextBox.Text = Util.round(HSVColorValue.S * 100, 0)
					HTextBox.Text = Util.round(HSVColorValue.H * 360, 0)
					HexTextBox.Text = HexColorValue
					RTextBox.Text = Util.round(ColorValue.R * 255, 0)
					GTextBox.Text = Util.round(ColorValue.G * 255, 0)
					BTextBox.Text = Util.round(ColorValue.B * 255, 0)
				end
				pcall(function()
					EyeDropper.ImageColor3 = Util.getMouseHitIncludingChar().Instance.Color
				end)
				if not Util.isHoveringOverObj(Picker.Frame) and UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
					EyeDropper.Visible = true
				else
					EyeDropper.Visible = false
				end
			end, function(err)
				rconsoleprint(debug.traceback("\n[*ERROR*]Error: " .. err))
				for _, v in pairs(Connections) do
					v:Disconnect()
				end
			end)
		end)
	end)
	if err then
		rconsoleprint("\n[*ERROR*]" .. "ColorPicker Error: " .. err)
	end
	local ret = false
	OkButton.MouseButton1Click:Connect(function()
		for _, v in pairs(Connections) do
			v:Disconnect()
		end
		ScreenGui:Destroy()
		PickerFrame = false
		ret = ColorValue
	end)
	CancelButton.MouseButton1Click:Connect(function()
		for _, v in pairs(Connections) do
			v:Disconnect()
		end
		ScreenGui:Destroy()
		PickerFrame = false
		ret = CurrentColor
	end)
	while not ret do
		wait()
	end
	return ret
end
function module.CreateTopBar(Settings)
	local TextBoxGUI
	if not ContextGui:FindFirstChild("TextBoxHolder") then
		TextBoxGUI = Instance.new("ScreenGui", ContextGui)
		TextBoxGUI.Name = "TextBoxHolder"
		TextBoxGUI.ResetOnSpawn = false
		TextBoxGUI.IgnoreGuiInset = true
		TopBar = Instance.new("Frame", TextBoxGUI)
		TopBar.Name = "TopBar"
		TopBar.BackgroundTransparency = 1
		module.SetSettings(TopBar, Settings.TextBox.TopBar)
		TopBar.Size = UDim2.new(
			Settings.TextBox.TopBarWidthOffset,
			0,
			0,
			Settings.TextBox.Title.TextSize + Settings.TextBox.EntryListPadding.Text
		)
		TopBar.Position = UDim2.new(0.1, 0, 0, TopBar.Size.Y.Offset)
		local UIListLayout = Instance.new("UIListLayout", TopBar)
		UIListLayout.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	else
		TextBoxGUI = ContextGui:FindFirstChild("TextBoxHolder")
		TopBar = TextBoxGUI.TopBar
	end
	return TextBoxGUI, TopBar
end

local TextBoxGUI
local TopBar
_G.CMTextBoxes = {}
function module.CreateTextBox(AdditionalSettings, Name, Functions)
	local ret
	local Collapsed = false
	local Minimized = false
	local Settings = {}
	module.SetSettings(Settings, module.DefaultSettings)
	module.SetSettings(Settings, AdditionalSettings)
	local ContextFunctions = {}
	do
		for i, v in pairs(Functions or {}) do
			ContextFunctions[i] = v
		end
	end
	local GuiWindow = module.CreateContextGui(AdditionalSettings, Settings.TextBox.Title.Text or Name, ContextFunctions)
	--[[
			{
				Name = TextBoxFrame.Name,
				Instance = ContentFrame,
				TitleBar = TitleBar,
				MinimizeToTopBar = MinimizeToTopBar,
				MaximizeFromTopBar = MaximizeFromTopBar,
				MoveToTop = function() MoveToTop(TextBoxFrame) end
			}
		]]
	local TextBoxFrame = GuiWindow.Instance.Parent
	if not ContextGui:FindFirstChild("TextBoxHolder") then
		TextBoxGUI, TopBar = module.CreateTopBar(Settings)
	else
		TextBoxGUI = ContextGui:FindFirstChild("TextBoxHolder")
		TopBar = TextBoxGUI.TopBar
	end
	local EntryList = Create("ScrollingFrame", Settings.TextBox.TextBox, {
		Parent = TextBoxFrame,
		Name = "EntryList",
		CanvasSize = UDim2.fromScale(0, 0),
		AutomaticCanvasSize = "Y",
		BackgroundColor3 = Settings.TextBox.BackdropColor3,
	})
	local FilterBox
	local FilterOffset = 0
	if Settings.TextBox.HasFilter then
		FilterBox = Create("TextBox", Settings.TextBox.Filter, {
			Parent = TextBoxFrame,
			Name = "FilterBox",
		})
	end
	local Entries = {}
	local ButtonHolder = Create("Frame", Settings.TextBox.Filter, {
		Parent = TextBoxFrame,
		Name = "ButtonHolder",
		BackgroundTransparency = 1,
		Size = UDim2.new(
			1,
			0 - Settings.TextBox.EntryListPadding.Left - Settings.TextBox.EntryListPadding.Right,
			0,
			Settings.TextBox.ButtonHeight
		),
		Position = UDim2.new(
			0,
			Settings.TextBox.EntryListPadding.Left,
			1,
			0 - Settings.TextBox.EntryListPadding.Bottom - Settings.TextBox.ButtonHeight
		),
	})
	Create("UIListLayout", {
		Parent = ButtonHolder,
		FillDirection = "Horizontal",
		Padding = UDim.new(0, Settings.TextBox.EntryListPadding.Right),
	})
	Create("UIListLayout", {
		Parent = EntryList,
		FillDirection = "Vertical",
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	local Buttons = {}
	local TopBarFrame
	function ContextFunctions.OnMinimize(Collapsed)
		if FilterBox then
			FilterBox.Visible = false
		end
		for _, v in pairs(Buttons) do
			v.Visible = false
		end
		EntryList.Visible = false
	end
	function ContextFunctions.OnMaximize(Collapsed)
		if FilterBox then
			FilterBox.Visible = not Collapsed
		end
		for _, v in pairs(Buttons) do
			v.Visible = not Collapsed
		end
		EntryList.Visible = not Collapsed
	end
	function ContextFunctions.OnCollapse(Collapsed)
		if FilterBox then
			FilterBox.Visible = Collapsed
		end
		for _, v in pairs(Buttons) do
			v.Visible = Collapsed
		end
		EntryList.Visible = Collapsed
	end
	if FilterBox then
		FilterBox.Size = UDim2.new(
			1,
			0 - Settings.TextBox.EntryListPadding.Left - Settings.TextBox.EntryListPadding.Right,
			0,
			Settings.TextBox.Filter.TextSize + Settings.TextBox.EntryListPadding.Text
		)
		if Settings.TextBox.FilterLocation == "Top" then
			EntryList.Size = UDim2.new(
				1,
				0 - Settings.TextBox.EntryListPadding.Left - Settings.TextBox.EntryListPadding.Right,
				1,
				0
					- ((Settings.TextBox.EntryListPadding.Bottom * 2) + Settings.TextBox.ButtonHeight)
					- ((Settings.TextBox.Filter.TextSize - Settings.TextBox.EntryListPadding.Text) * 3)
					- Settings.TextBox.EntryListPadding.Top
			)
			EntryList.Position = UDim2.new(
				0,
				Settings.TextBox.EntryListPadding.Left,
				0,
				((Settings.TextBox.Filter.TextSize - Settings.TextBox.EntryListPadding.Text) * 3)
					+ Settings.TextBox.EntryListPadding.Top
			)
			FilterBox.Position =
				UDim2.new(0, Settings.TextBox.EntryListPadding.Left, 0, Settings.TextBox.EntryListPadding.Top / 2)
		else
			EntryList.Size = UDim2.new(
				1,
				0 - Settings.TextBox.EntryListPadding.Left - Settings.TextBox.EntryListPadding.Right,
				1,
				0
					- ((Settings.TextBox.EntryListPadding.Bottom * 2) + Settings.TextBox.ButtonHeight)
					- Settings.TextBox.Filter.TextSize
					- (Settings.TextBox.EntryListPadding.Text * 2)
			)
			EntryList.Position =
				UDim2.new(0, Settings.TextBox.EntryListPadding.Left, 0, Settings.TextBox.EntryListPadding.Top / 2)
			FilterBox.Position = UDim2.new(
				0,
				Settings.TextBox.EntryListPadding.Left,
				1,
				0
					- Settings.TextBox.EntryListPadding.Top
					- Settings.TextBox.EntryListPadding.Bottom
					- Settings.TextBox.EntryListPadding.Bottom
					- Settings.TextBox.ButtonHeight
			)
		end
	else
		if Settings.TextBox.NoButtons then
			EntryList.Size = UDim2.new(
				1,
				0 - Settings.TextBox.EntryListPadding.Left - Settings.TextBox.EntryListPadding.Right,
				1,
				0 - Settings.TextBox.EntryListPadding.Bottom - Settings.TextBox.EntryListPadding.Top
			)
			EntryList.Position =
				UDim2.new(0, Settings.TextBox.EntryListPadding.Left, 0, Settings.TextBox.EntryListPadding.Top)
		else
			EntryList.Size = UDim2.new(
				1,
				0 - Settings.TextBox.EntryListPadding.Left - Settings.TextBox.EntryListPadding.Right,
				1,
				0
					- ((Settings.TextBox.EntryListPadding.Bottom * 2) + Settings.TextBox.ButtonHeight)
					- Settings.TextBox.EntryListPadding.Top
			)
			EntryList.Position =
				UDim2.new(0, Settings.TextBox.EntryListPadding.Left, 0, Settings.TextBox.EntryListPadding.Top)
		end
	end
	local AddEntry = function(AdditionalSettings, Text, Functions)
		local EntrySettings = {}
		if not Functions then
			Functions = {}
		end
		module.SetSettings(EntrySettings, module.DefaultSettings)
		module.SetSettings(EntrySettings, AdditionalSettings)
		EntrySettings.TextBox.Entries.Text = Text
		local Entry = Create("TextButton", EntrySettings.TextBox.Entries, {
			Parent = EntryList,
			AutoButtonColor = false,
			Text = ""
		})
		local EntryText = Create("TextLabel", EntrySettings.TextBox.Entries, {
			Parent = Entry,
			Size = UDim2.new(1, -3 - EntryList.ScrollBarThickness, 1, 0),
			Position = UDim2.fromOffset(3),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
		})
		if Functions.M1Func then
			Entry.MouseButton1Click:connect(function()
				xpcall(function()
					Functions.M1Func(Entry)
				end, error)
			end)
		end
		if Functions.M2Func then
			Entry.MouseButton2Click:connect(function()
				xpcall(function()
					Functions.M2Func(Entry)
				end, error)
			end)
		end
		if not EntrySettings.NoRenderStep then
			local step
			step = RunService.RenderStepped:Connect(function()
				local _, Y = Util.GetTextSize(EntryText, EntrySettings.TextBox.EntryListPadding.Text, EntryList.AbsoluteSize.X - 3 - EntryList.ScrollBarThickness)
				--Entry.Size = UDim2.new(1,0-EntryList.ScrollBarThickness,0,TextService:GetTextSize(Util.removeTags(Text), EntrySettings.TextBox.Entries.TextSize, EntrySettings.TextBox.Entries.Font, Vector2.new(EntryList.AbsoluteSize.X-EntryList.ScrollBarThickness, 99999)).Y+EntrySettings.TextBox.EntryListPadding.Text)
				Entry.Size = UDim2.new(1, 0, 0, Y)
			end)
			Entry.Destroying:Connect(function()
				step:Disconnect()
			end)
		else
			local _, Y = Util.GetTextSize(EntryText, EntrySettings.TextBox.EntryListPadding.Text, EntryList.AbsoluteSize.X - 3 - EntryList.ScrollBarThickness)
			--Entry.Size = UDim2.new(1,0-EntryList.ScrollBarThickness,0,TextService:GetTextSize(Util.removeTags(Text), EntrySettings.TextBox.Entries.TextSize, EntrySettings.TextBox.Entries.Font, Vector2.new(EntryList.AbsoluteSize.X-EntryList.ScrollBarThickness, 99999)).Y+EntrySettings.TextBox.EntryListPadding.Text)
			Entry.Size = UDim2.new(1, 0, 0, Y)
		end
		table.insert(Entries, Entry)
		return Entry
	end
	local AddButton = function(AdditionalSettings, Text, Args)
		local ButtonSettings = {}
		module.SetSettings(ButtonSettings, Settings)
		module.SetSettings(ButtonSettings, AdditionalSettings)
		ButtonSettings.TextBox.Buttons.Text = Text
		local Button = Create("TextButton", ButtonSettings.TextBox.Buttons, {
			Parent = ButtonHolder,
			ClipsDescendants = true,
		})
		table.insert(Buttons, Button)
		local GrayedOut = false
		local GrayedOutBehavior = 0
		RunService.RenderStepped:connect(function()
			Button.Size = UDim2.new(
				1 / #Buttons,
				0 - ButtonSettings.TextBox.EntryListPadding.Right,
				0,
				ButtonSettings.TextBox.ButtonHeight
			)
			if GrayedOut then
				if Button.BackgroundColor3 ~= ButtonSettings.TextBox.Buttons.GrayedOutBackgroundColor3 then
					Button.BackgroundColor3 = ButtonSettings.TextBox.Buttons.GrayedOutBackgroundColor3
					Button.AutoButtonColor = false
				end
			else
				if Button.BackgroundColor3 ~= ButtonSettings.TextBox.Buttons.BackgroundColor3 then
					Button.BackgroundColor3 = ButtonSettings.TextBox.Buttons.BackgroundColor3
					Button.AutoButtonColor = ButtonSettings.TextBox.Buttons.AutoButtonColor
				end
			end
		end)
		if Args.M1Func then
			Button.MouseButton1Click:connect(function()
				if not GrayedOut or (GrayedOut and GrayedOutBehavior == 1 or GrayedOut and GrayedOutBehavior == 3) then
					Args.M1Func()
				end
			end)
		end
		if Args.M2Func then
			Button.MouseButton2Click:connect(function()
				if not GrayedOut or (GrayedOut and GrayedOutBehavior > 1) then
					Args.M2Func()
				end
			end)
		end
		local function SetGrayedOut(state)
			if typeof(state) == "number" then
				GrayedOutBehavior = state
			else
				GrayedOut = state
			end
		end
		return {
			Instance = Button,
			M1Func = Args.M1Func,
			M2Func = Args.M2Func,
			SetGrayedOut = SetGrayedOut,
			SetSettings = function(arg)
				module.SetSettings(ButtonSettings, arg)
			end,
		}
	end
	local ClearList = function()
		for _, v in pairs(Entries) do
			if v:IsA("GuiObject") then
				v:Destroy()
			end
		end
	end
	for i, v in pairs({
		AddEntry = AddEntry,
		AddButton = AddButton,
		ClearList = ClearList,
		Entries = Entries,
		FilterBox = FilterBox,
		Instance = TextBoxFrame,
		MoveToTop = function()
			MoveToTop(TextBoxFrame)
		end,
	}) do
		GuiWindow[i] = v
	end
	return GuiWindow
end

function module.CreateContextGui(AdditionalSettings, Name, Functions)
	local ret
	xpcall(function()
		coroutine.wrap(function()
			if Functions and Functions.OnInitialize then
				Functions.OnInitialize()
			end
		end)()
		local Collapsed = false
		local Minimized = false
		local Settings = {}
		module.SetSettings(Settings, module.DefaultSettings)
		module.SetSettings(Settings, AdditionalSettings)
		if not ContextGui:FindFirstChild("TextBoxHolder") then
			TextBoxGUI, TopBar = module.CreateTopBar(Settings)
		else
			TextBoxGUI = ContextGui:FindFirstChild("TextBoxHolder")
			TopBar = TextBoxGUI.TopBar
		end
		if Settings.TextBox.Parent then
			TextBoxGUI = Settings.TextBox.Parent
		end
		local TitleTextSize = TextService:GetTextSize(
			Util.removeTags(Name),
			Settings.TextBox.Title.TextSize,
			Settings.TextBox.Title.Font,
			Vector2.new(99999, 99999)
		)

		local TextBoxFrame = Create("Frame", Settings.TextBox.TextBox, {
			Parent = TextBoxGUI,
			Name = "GUI_" .. Name,
		})
		local ContentFrame = Create("Frame", Settings.TextBox.TextBox, {
			Parent = TextBoxFrame,
			Name = "Content",
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.new(),
			BorderSizePixel = 1,
		})
		local TitleBar = Create("TextLabel", Settings.TextBox.Title, {
			Parent = TextBoxFrame,
			Text = " " .. Name,
			Name = "TitleBar",
			AutoButtonColor = false,
			--Position = UDim2.fromOffset(TitleBar.Position.X.Offset-1,TitleBar.Position.Y.Offset),
			Size = UDim2.new(1, 0, 0, TitleTextSize.Y * 1.25),
		})
		local TitleBarButtonHolder = Create("Frame", {
			BackgroundTransparency = 1,
			Name = "TitleBarButtonHolder",
			AnchorPoint = Vector2.new(1, 0),
			Parent = TitleBar,
			Position = UDim2.fromScale(1, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Size = UDim2.fromScale(3, 1),
		})
		local TitleBarButtons = {}
		TitleBarButtons.Close = Create("TextButton", Settings.TextBox.Title, {
			Parent = TitleBarButtonHolder,
			Text = "X",
			Name = "Close",
			AnchorPoint = Vector2.new(1, 0),
			TextXAlignment = "Center",
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AutoButtonColor = false,
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(1, 0),
		})
		TitleBarButtons.Collapse = Create("TextButton", Settings.TextBox.Title, {
			Parent = TitleBarButtonHolder,
			Text = "",
			Name = "Collapse",
			AnchorPoint = Vector2.new(0.5, 0),
			TextXAlignment = "Center",
			BackgroundColor3 = Color3.new(0.6, 0.6, 0.6),
			BackgroundTransparency = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AutoButtonColor = false,
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0),
		})
		TitleBarButtons.HideInBar = Create("TextButton", Settings.TextBox.Title, {
			Parent = TitleBarButtonHolder,
			Text = "",
			Name = "HideInBar",
			AnchorPoint = Vector2.new(0, 0),
			TextXAlignment = "Center",
			BackgroundColor3 = Color3.new(0.6, 0.6, 0.6),
			BackgroundTransparency = 1,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			AutoButtonColor = false,
			Size = UDim2.fromScale(1, 1),
		})
		TitleBarButtons.CloseHighlight = Create("TextLabel", Settings.TextBox.Title, {
			Parent = TitleBarButtons.Close,
			Text = "X",
			Name = "Highlight",
			BackgroundColor3 = Color3.new(0.6, 0, 0),
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0, 0),
			TextXAlignment = "Center",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
		})
		TitleBarButtons.CollapseHighlight = Create("TextLabel", Settings.TextBox.Title, {
			Parent = TitleBarButtons.Collapse,
			Text = "V",
			Name = "Highlight",
			Rotation = 180,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			TextXAlignment = "Center",
			BackgroundTransparency = 1,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
		})
		TitleBarButtons.HideInBarHighlight = Create("TextLabel", Settings.TextBox.Title, {
			Parent = TitleBarButtons.HideInBar,
			Text = "__",
			Name = "Highlight",
			BackgroundTransparency = 1,
			Rotation = 180,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(1, 1),
		})
		local CloseFadeIn =
			TweenService:Create(TitleBarButtons.CloseHighlight, TweenInfo.new(0.4), { BackgroundTransparency = 0.8 })
		local CloseFadeOut =
			TweenService:Create(TitleBarButtons.CloseHighlight, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
		local CollapseFadeIn =
			TweenService:Create(TitleBarButtons.Collapse, TweenInfo.new(0.4), { BackgroundTransparency = 0.8 })
		local CollapseFadeOut =
			TweenService:Create(TitleBarButtons.Collapse, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
		local HideInBarFadeIn =
			TweenService:Create(TitleBarButtons.HideInBar, TweenInfo.new(0.4), { BackgroundTransparency = 0.8 })
		local HideInBarFadeOut =
			TweenService:Create(TitleBarButtons.HideInBar, TweenInfo.new(0.4), { BackgroundTransparency = 1 })
		TitleBarButtons.CloseHighlight.MouseEnter:connect(function()
			CloseFadeIn:Play()
		end)
		TitleBarButtons.CloseHighlight.MouseLeave:connect(function()
			CloseFadeOut:Play()
		end)
		TitleBarButtons.CollapseHighlight.MouseEnter:connect(function()
			CollapseFadeIn:Play()
		end)
		TitleBarButtons.CollapseHighlight.MouseLeave:connect(function()
			CollapseFadeOut:Play()
		end)
		TitleBarButtons.HideInBarHighlight.MouseEnter:connect(function()
			HideInBarFadeIn:Play()
		end)
		TitleBarButtons.HideInBarHighlight.MouseLeave:connect(function()
			HideInBarFadeOut:Play()
		end)
		local TopBarFrame
		TitleBarButtons.Close.MouseButton1Click:connect(function()
			TextBoxFrame:Destroy()
			coroutine.wrap(function()
				if Functions and Functions.OnClose then
					Functions.OnClose()
				end
			end)()
			if TopBarFrame then
				local info = TweenInfo.new(
					0.2, -- Time
					Enum.EasingStyle.Quint, -- EasingStyle
					Enum.EasingDirection.Out -- EasingDirection
				)
				TweenService:Create(TopBarFrame, info, {
					Size = UDim2.fromOffset(0, TopBarFrame.Size.Y.Offset),
				}):Play()
				wait(0.20)
				TopBarFrame:Destroy()
			end
		end)
		local CollapseSize = 0
		TitleBarButtons.Collapse.MouseButton1Click:connect(function()
			local info = TweenInfo.new(
				0.2, -- Time
				Enum.EasingStyle.Quint, -- EasingStyle
				Enum.EasingDirection.Out -- EasingDirection
			)
			coroutine.wrap(function()
				if Functions and Functions.OnCollapse then
					Functions.OnCollapse(Collapsed)
				end
			end)()
			if Collapsed then
				Collapsed = false
				TweenService:Create(TitleBarButtons.CollapseHighlight, info, { Rotation = 180 }):Play()
				TextBoxFrame:TweenSize(
					CollapseSize,
					Enum.EasingDirection.Out, -- EasingDirection
					Enum.EasingStyle.Quint, -- EasingStyle
					0.2, -- Time
					true
				)
				wait(0.05)
				ContentFrame.Visible = true
			else
				CollapseSize = TextBoxFrame.Size
				Collapsed = true
				TweenService:Create(TitleBarButtons.CollapseHighlight, info, { Rotation = 0 }):Play()
				TextBoxFrame:TweenSize(
					UDim2.fromOffset(TextBoxFrame.Size.X.Offset, 1),
					Enum.EasingDirection.Out, -- EasingDirection
					Enum.EasingStyle.Quint, -- EasingStyle
					0.2, -- Time
					true
				)
				wait(0.05)
				ContentFrame.Visible = false
			end
		end)
		local ResizeBox = Create("Frame", {
			Parent = TextBoxFrame,
			Size = UDim2.fromOffset(10, 10),
			Transparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(1, 1),
		})
		local BeingDragged = false
		local BeingResized = false
		local DragOffset = Vector2.new(
			TextBoxFrame.Position.X.Offset - mouseLocation.X,
			TextBoxFrame.Position.Y.Offset - mouseLocation.Y
		)
		local SizeOffset =
			Vector2.new(TextBoxFrame.Size.X.Offset - mouseLocation.X, TextBoxFrame.Size.Y.Offset - mouseLocation.Y)
		RunService.RenderStepped:connect(function()
			if Settings.TextBox.Draggable and BeingDragged and not Minimized then
				TextBoxFrame.Position = UDim2.fromOffset(
					math.min(
						TextBoxGUI.AbsoluteSize.X - 7,
						math.max(7 - TextBoxFrame.AbsoluteSize.X - 30, mouseLocation.X + DragOffset.X)
					),
					math.min(TextBoxGUI.AbsoluteSize.Y, math.max(7, mouseLocation.Y + DragOffset.Y))
				)
			end
			if Settings.TextBox.Resizeable and BeingResized and not Minimized and not Collapsed then
				TextBoxFrame.Size = UDim2.fromOffset(
					math.max(mouseLocation.X + SizeOffset.X, Settings.TextBox.TextBox.MinSizeX or 200),
					math.max(mouseLocation.Y + SizeOffset.Y, Settings.TextBox.TextBox.MinSizeY or 100)
				)
			end
		end)
		if not Settings.TextBox.DontDisplace then
			for _, v in pairs(TextBoxGUI:GetChildren()) do
				if v.Name ~= "TopBar" then
					if
						math.abs(v.Position.X.Offset - TextBoxFrame.Position.X.Offset) < TitleBar.Size.X.Offset + 5
						or math.abs(v.Position.Y.Offset - TextBoxFrame.Position.Y.Offset) < TitleBar.Size.Y.Offset * 1.1
					then
						TextBoxFrame.Position = v.Position
							+ UDim2.fromOffset(TitleBar.Size.Y.Offset * 1.12, TitleBar.Size.Y.Offset * 1.1)
					end
				end
			end
		end
		UserInputService.InputBegan:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				if Util.isHoveringOverObj(TitleBar) then
					DragOffset = Vector2.new(
						TextBoxFrame.Position.X.Offset - mouseLocation.X,
						TextBoxFrame.Position.Y.Offset - mouseLocation.Y
					)
					BeingDragged = true
					MoveToTop(TextBoxFrame)
					coroutine.wrap(function()
						if Functions and Functions.OnDragged then
							Functions.OnDragged(TextBoxFrame.Position)
						end
					end)()
				end
				if Util.isHoveringOverObj(ResizeBox) then
					SizeOffset = Vector2.new(
						TextBoxFrame.Size.X.Offset - mouseLocation.X,
						TextBoxFrame.Size.Y.Offset - mouseLocation.Y
					)
					BeingResized = true
					MoveToTop(TextBoxFrame)
					coroutine.wrap(function()
						if Functions and Functions.OnResized then
							Functions.OnResized(TextBoxFrame.Size)
						end
					end)()
				end
			end
		end)
		UserInputService.InputEnded:connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				BeingDragged = false
				BeingResized = false
			end
		end)
		local info = TweenInfo.new(
			0.2, -- Time
			Enum.EasingStyle.Quint, -- EasingStyle
			Enum.EasingDirection.Out -- EasingDirection
		)
		local TopBarHiddenSize
		local TopBarHiddenPos
		local TopBarPos
		local TopBarSize
		local function MinimizeToTopBar()
			coroutine.wrap(function()
				if Functions and Functions.OnMinimize then
					Functions.OnMinimize(Collapsed)
				end
			end)()
			TopBarHiddenSize = TextBoxFrame.Size
			TopBarHiddenPos = TextBoxFrame.Position
			TitleBarButtons.Collapse.Visible = false
			TitleBarButtons.HideInBar.Visible = false
			TopBarFrame = Instance.new("Frame", TopBar)
			TopBarFrame.BorderSizePixel = 0
			TopBarFrame.AnchorPoint = Vector2.new(0, 1)
			TopBarFrame.Size = UDim2.new(0, 200, 1, 0)
			TopBarFrame.Transparency = 1
			TweenService:Create(TextBoxFrame, info, {
				Position = UDim2.fromOffset(TopBarFrame.AbsolutePosition.X, TopBar.Size.Y.Offset),
				Size = UDim2.fromOffset(TopBarFrame.Size.X.Offset, 0),
			}):Play()
			wait(0.05)
			ContentFrame.Visible = false
			wait(0.15)
			TextBoxFrame.Parent = TopBarFrame
			TextBoxFrame.Position = UDim2.fromScale(0, 0)
			TextBoxFrame.Size = UDim2.fromScale(1, 0)
			Minimized = true
		end
		local function MaximizeFromTopBar()
			coroutine.wrap(function()
				if Functions and Functions.OnMaximize then
					Functions.OnMaximize(Collapsed)
				end
			end)()
			TextBoxFrame.Size = UDim2.fromOffset(TextBoxFrame.AbsoluteSize.X, TextBoxFrame.AbsoluteSize.Y)
			TextBoxFrame.Position = UDim2.fromOffset(TextBoxFrame.AbsolutePosition.X, TextBoxFrame.AbsolutePosition.Y)
			TextBoxFrame.Parent = TextBoxGUI
			TweenService:Create(TextBoxFrame, info, {
				Position = TopBarHiddenPos,
				Size = TopBarHiddenSize,
			}):Play()
			TweenService:Create(TopBarFrame, info, {
				Size = UDim2.fromOffset(0, TopBarFrame.Size.Y.Offset),
			}):Play()
			Minimized = false
			TitleBarButtons.Collapse.Visible = true
			TitleBarButtons.HideInBar.Visible = true
			wait(0.05)
			ContentFrame.Visible = true
			wait(0.15)
			TopBarFrame:Destroy()
		end
		TitleBarButtons.HideInBar.MouseButton1Click:Connect(MinimizeToTopBar)
		Mouse.Button1Down:Connect(function()
			if Minimized then
				if Util.isHoveringOverObj(TitleBar) then
					MaximizeFromTopBar()
				end
			end
		end)
		ret = {
			Name = TextBoxFrame.Name,
			Instance = ContentFrame,
			TitleBar = TitleBar,
			MinimizeToTopBar = MinimizeToTopBar,
			MaximizeFromTopBar = MaximizeFromTopBar,
			MoveToTop = function()
				MoveToTop(TextBoxFrame)
			end,
		}
		coroutine.wrap(function()
			if Functions and Functions.OnFinishedCreating then
				Functions.OnFinishedCreating()
			end
		end)()
	end, function(err)
		warn(debug.traceback(err))
	end)
	return ret
end

function module.OpenColorLibrary(AdditionalSettings, parent, SetColorFunction)
	ColorLibraryFile = ConfigModule:Create( "ColorLibrary.lua", {
		Colors = {
			["Lost Pink"] = Color3.new(1, 0, 1),
			["Deep Green"] = Color3.fromHex("009600"),
			["Beefy Red"] = Color3.fromHex("8f0a0a"),
			["Astro Teal"] = Color3.fromHex("23c8be"),
			["Moon Blue"] = Color3.fromHex("00c8c8"),
		},
		Recent = {},
	})
	local ret
	xpcall(function()
		local ContextFunctions = {}
		local GuiWindow = module.CreateContextGui({
			TextBox = {
				TextBox = { Size = UDim2.fromOffset(462, 270) },
				Resizeable = false,
				Parent = parent,
			},
		}, "Color Library", ContextFunctions)
		local Collapsed = false
		local Minimized = false
		local Settings = {}
		module.SetSettings(Settings, module.DefaultSettings)
		if AdditionalSettings then
			module.SetSettings(Settings, AdditionalSettings)
		end
		if not ContextGui:FindFirstChild("TextBoxHolder") then
			TextBoxGUI, TopBar = module.CreateTopBar(Settings)
		else
			TextBoxGUI = ContextGui:FindFirstChild("TextBoxHolder")
			TopBar = TextBoxGUI.TopBar
		end
		local TitleTextSize = TextService:GetTextSize(
			"Color Library",
			Settings.TextBox.Title.TextSize,
			Settings.TextBox.Title.Font,
			Vector2.new(99999, 99999)
		)
		local Frame = Create("TextButton", {
			Parent = GuiWindow.Instance,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		})
		local EntryList = Create("ScrollingFrame", Settings.TextBox.TextBox, {
			Parent = GuiWindow.Instance,
			Name = "EntryList",
			CanvasSize = UDim2.fromScale(0, 0),
			AutomaticCanvasSize = "Y",
			ClipsDescendants = true,
			BackgroundColor3 = Settings.TextBox.BackdropColor3,
		})
		local Entries = {}
		local UIGridLayout = Create("UIGridLayout", {
			Parent = EntryList,
			SortOrder = Enum.SortOrder.Name,
			CellPadding = UDim2.fromOffset(7, 7),
			CellSize = UDim2.fromOffset(80, 80),
		})
		function ContextFunctions.OnMinimize(Collapsed)
			EntryList.Visible = false
		end
		function ContextFunctions.OnMaximize(Collapsed)
			EntryList.Visible = not Collapsed
		end
		function ContextFunctions.OnCollapse(Collapsed)
			EntryList.Visible = Collapsed
		end
		local function GenerateColorButton(Name, Color)
			local ImageButton = Instance.new("ImageButton")
			local TextLabel = Instance.new("TextLabel")
			ImageButton.BackgroundColor3 = Color
			ImageButton.BorderColor3 = Color3.fromHex("474747")
			ImageButton.BorderSizePixel = 2
			ImageButton.Size = UDim2.new(0, 100, 0, 100)
			ImageButton.AutoButtonColor = false
			ImageButton.Image = ""
			TextLabel.Parent = ImageButton
			TextLabel.AnchorPoint = Vector2.new(0, 1)
			TextLabel.BackgroundColor3 = Color3.new(0, 0, 0)
			TextLabel.BackgroundTransparency = 0.4
			TextLabel.BorderSizePixel = 0
			TextLabel.Position = UDim2.new(0, 0, 1, 0)
			TextLabel.Size = UDim2.new(1, 0, 0.2, 0)
			TextLabel.FontFace = Font.fromName("Ubuntu", Enum.FontWeight.Bold, Enum.FontStyle.Italic)
			TextLabel.Text = Name
			TextLabel.TextColor3 = Color3.fromHex("cacaca")
			TextLabel.TextScaled = true
			TextLabel.TextSize = 14
			TextLabel.TextWrapped = true
			ImageButton.Parent = EntryList
			ImageButton.MouseButton1Click:Connect(function()
				xpcall(function()
					SetColorFunction(Color, Name)
					SetRecent(Name)
				end, warn)
			end)
			ImageButton.MouseButton2Click:Connect(function()
				xpcall(function()
					module.Create({
						FrameAnchorPoint = Util.CMAnchorPoint(),
						Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y),
						TitleText = " " .. Name,
						ContextMenuEntries = {
							TextSize = 11,
						},
						DisplayOrder = 4,
						OnlyCloseSelf = true,
					}, {
						Text = "Copy Hex",
						M1Func = function()
							setclipboard(Color:ToHex())
						end,
					}, {
						Text = "Copy RGB Values",
						M1Func = function()
							setclipboard(
								math.round(Color.R * 255)
									.. ", "
									.. math.round(Color.G * 255)
									.. ", "
									.. math.round(Color.B * 255)
							)
						end,
					}, {
						Text = "Copy HSV Values",
						M1Func = function()
							setclipboard(table.concat({ Color:ToHSV() }, ", "))
						end,
					}, {
						Text = "Remove",
						M1Func = function()
							ColorLibraryFile.Colors[Name] = nil
							ColorLibraryFile:Write()
							ImageButton:Destroy()
						end,
					})
				end, warn)
			end)
			module.CreateTooltip(
				ImageButton,
				math.round(Color.R * 255)
					.. ", "
					.. math.round(Color.G * 255)
					.. ", "
					.. math.round(Color.B * 255)
					.. ' <font color="#494c52">#'
					.. Color:ToHex()
					.. "</font>"
			)
			return ImageButton
		end
		for Name, Color in pairs(ColorLibraryFile.Colors) do
			if typeof(Color) == "Color3" then
				GenerateColorButton(Name, Color)
			end
		end
		EntryList.Size = UDim2.new(
			1,
			0 - Settings.TextBox.EntryListPadding.Left - Settings.TextBox.EntryListPadding.Right,
			1,
			0 - Settings.TextBox.EntryListPadding.Bottom - Settings.TextBox.EntryListPadding.Top
		)
		EntryList.Position =
			UDim2.new(0, Settings.TextBox.EntryListPadding.Left, 0, Settings.TextBox.EntryListPadding.Top)
	end, function(err)
		warn(debug.traceback(err))
	end)
	return ret
end

function module.CreateTooltip(GuiObject, String, AnchorPoint)
	local succ, err = pcall(function()
		if not String then
			String = "nil"
		end
		local LayerCollector = ContextGui:FindFirstChild("ToolTipHolder")
		if not LayerCollector then
			LayerCollector = Instance.new("ScreenGui", ContextGui)
			LayerCollector.ResetOnSpawn = false
			LayerCollector.Name = "ToolTipHolder"
			LayerCollector.IgnoreGuiInset = true
			LayerCollector.DisplayOrder = 5
		end
		local Tooltip
		if LayerCollector:FindFirstChild("Tooltip") then
			Tooltip = LayerCollector:FindFirstChild("Tooltip")
		else
			Tooltip = Instance.new("TextLabel", LayerCollector)
			if AnchorPoint then
				Tooltip.AnchorPoint = AnchorPoint
			end
			Tooltip.Name = "Tooltip"
			Tooltip.TextWrapped = true --asda
			Tooltip.Visible = false
			Tooltip.ClipsDescendants = true
			module.SetSettings(Tooltip, module.DefaultSettings.Tooltips)
			RunService:BindToRenderStep("moveGuiToMouse", 1, function()
				Tooltip.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y + 25)
			end)
		end
		local TooltipT = GuiObject:FindFirstChild("Tooltip")
		if TooltipT then
			TooltipT.Value = String
		else
			TooltipT = Instance.new("StringValue", GuiObject)
			TooltipT.Value = String
			TooltipT.Name = "Tooltip"
			Mouse.Move:Connect(function()
				Tooltip.Visible = false
			end)
			GuiObject.MouseMoved:connect(function()
				local succ, err = pcall(function()
					if GuiObject:FindFirstChild("Tooltip") then
						if Util.isHoveringOverObj(GuiObject) then
							if not AnchorPoint then
								if Tooltip.AbsoluteSize.X + mouseLocation.X > LayerCollector.AbsoluteSize.X then
									Tooltip.AnchorPoint = Vector2.new(1, 0)
								else
									Tooltip.AnchorPoint = Vector2.new(0, 0)
								end
							end
						end
						Tooltip.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y + 25)
						wait(module.DefaultSettings.TooltipDelay)
						if Util.isHoveringOverObj(GuiObject) then
							MoveToTop(LayerCollector)
							Tooltip.Visible = true
							Tooltip.Text = GuiObject.Tooltip.Value
							Tooltip.Size = UDim2.fromOffset(
								Util.GetTextSize(
									Tooltip,
									module.DefaultSettings.Padding,
									module.DefaultSettings.TooltipSize
								)
							)
						end
					end
				end)
				if err then
					rconsoleprint("\n[*ERROR*]" .. "CreateTooltip Error: " .. GuiObject:GetFullName() .. ":" .. err)
				end
			end)
		end
	end)
	if err then
		rconsoleprint("\n[*ERROR*]" .. "CreateTooltip Error: " .. GuiObject:GetFullName() .. ":" .. err)
	end
end
function module.Create(argSettings, ...)
	local Holders = {}
	local Entries = { ... }
	local Settings = {}
	module.SetSettings(Settings, module.DefaultSettings)
	module.SetSettings(Settings, argSettings)
	local CMHolder = ContextGui:FindFirstChild("CMHolder")
	if not CMHolder or CMHolder and CMHolder.DisplayOrder ~= Settings.DisplayOrder then
		CMHolder = Instance.new("ScreenGui", ContextGui)
	end
	CMHolder.DisplayOrder = Settings.DisplayOrder or 2
	CMHolder.Name = "CMHolder"
	CMHolder.IgnoreGuiInset = true
	local function GetSubmenuSettings(GuiObject, EntryPixelSize, AdditionalSettings)
		local out = {
			FrameAnchorPoint = Vector2.new(0, 0),
			Position = UDim2.fromOffset(
				GuiObject.AbsolutePosition.X + GuiObject.AbsoluteSize.X,
				GuiObject.AbsolutePosition.Y + 36
			),
			IsASubmenu = true,
		}
		if (GuiObject.AbsoluteSize.X * 2) + GuiObject.AbsolutePosition.X > ScreenSize.X then
			out.FrameAnchorPoint = Vector2.new(1, out.FrameAnchorPoint.Y)
			out.Position = UDim2.fromOffset(GuiObject.AbsolutePosition.X - 1, out.Position.Y.Offset)
		else
			out.FrameAnchorPoint = Vector2.new(0, out.FrameAnchorPoint.Y)
			out.Position = UDim2.fromOffset(out.Position.X.Offset + 1, out.Position.Y.Offset)
		end
		if EntryPixelSize + GuiObject.AbsolutePosition.Y > ScreenSize.Y then
			out.FrameAnchorPoint = Vector2.new(out.FrameAnchorPoint.Y, 1)
			out.Position = UDim2.fromOffset(
				out.Position.X.Offset,
				out.Position.Y.Offset + Settings.ContextMenuEntries.TextSize + Settings.Padding - 1
			)
		else
			out.FrameAnchorPoint = Vector2.new(out.FrameAnchorPoint.X, 0)
			out.Position = UDim2.fromOffset(out.Position.X.Offset, out.Position.Y.Offset)
		end
		if not AdditionalSettings then
			AdditionalSettings = {}
		end
		local nullifysettings = { "FrameAnchorPoint", "Position", "TitleText" }
		for _, v in pairs(nullifysettings) do
			AdditionalSettings[v] = nil
		end
		module.SetSettings(out, AdditionalSettings)
		return out
	end
	if not Settings.IsASubmenu and not Settings.NoBackFrame then
		if (not CMHolder:FindFirstChild("CMBackFrame") or Settings.OnlyCloseSelf) then
			local CMBackFrame = Instance.new("TextButton", CMHolder)
			CMBackFrame.Transparency = 1
			CMBackFrame.ZIndex = 0
			CMBackFrame.Name = "CMBackFrame"
			CMBackFrame.Position = UDim2.new(0, 0, 0, 0)
			CMBackFrame.Size = UDim2.new(1, 0, 1, 0)
			CMBackFrame.MouseButton1Click:connect(function()
				if not PickerFrame or Settings.OnlyCloseSelf then
					if Settings.OnlyCloseSelf then
						CMHolder:Destroy()
						for _, v in pairs(Holders) do
							pcall(function()
								v:Destroy()
							end)
						end
					else
						for _, v in pairs(ContextGui:GetChildren()) do
							if v.Name == "CMHolder" then
								v:Destroy()
							end
						end
					end
				end
			end)
			CMBackFrame.MouseButton2Click:connect(function()
				if not PickerFrame or Settings.OnlyCloseSelf then
					if Settings.OnlyCloseSelf then
						CMHolder:Destroy()
						for _, v in pairs(Holders) do
							pcall(function()
								v:Destroy()
							end)
						end
					else
						for _, v in pairs(ContextGui:GetChildren()) do
							if v.Name == "CMHolder" then
								v:Destroy()
							end
						end
					end
				end
			end)
		end
	end
	local CMFrame
	if Settings.Scrollable then
		CMFrame = Instance.new("ScrollingFrame", CMHolder)
		CMFrame.CanvasSize = UDim2.fromScale(0, 0)
		CMFrame.AutomaticCanvasSize = "Y"
		CMFrame.ScrollBarThickness = 0
	else
		CMFrame = Instance.new("Frame", CMHolder)
	end
	CMFrame.ClipsDescendants = true
	local UIListLayout = Instance.new("UIListLayout", CMFrame)
	if Settings.SortOrder then
		UIListLayout.SortOrder = Settings.SortOrder
	else
		UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	end
	local TitleTextBounds = {}
	local Title
	local TitleText
	local TitleIcon
	if Settings.TitleText then
		TitleTextBounds = TextService:GetTextSize(
			Util.removeTags(Settings.TitleText),
			Settings.ContextMenuEntries.TextSize,
			Settings.ContextMenuEntries.Font,
			Vector2.new(99999, 99999)
		)
		Title = Instance.new("Frame", CMFrame)
		TitleText = Instance.new("TextLabel", Title)
		TitleText.Text = "<b><i>" .. Settings.TitleText .. "</i></b>"
		module.SetSettings(Title, Settings.ContextMenuEntries)
		module.SetSettings(TitleText, Settings.ContextMenuEntries)
		TitleText.Size = UDim2.fromScale(1, 1)
		if Settings.TitleIcon then
			TitleIcon = Instance.new("ImageLabel", Title)
			TitleIcon.BackgroundTransparency = 1
			TitleIcon.Size =
				UDim2.fromOffset(TitleTextBounds.Y + Settings.Padding, TitleTextBounds.Y + Settings.Padding)
			TitleText.Size = UDim2.new(1, 0 - TitleTextBounds.Y + Settings.Padding, 1, 0)
			TitleText.Position = UDim2.fromOffset(TitleTextBounds.Y + (Settings.Padding * 1.5), 0)
			if typeof(Settings.TitleIcon) == "table" then
				for i, v in pairs(Settings.TitleIcon) do
					TitleIcon[i] = v
				end
			else
				TitleIcon.Image = Settings.TitleIcon
			end
		end
	end
	local CMTooltip = Instance.new("TextLabel", CMHolder)
	CMTooltip.Visible = false
	CMTooltip.Name = "Tooltip"
	CMTooltip.ZIndex = 2
	CMTooltip.TextWrapped = true
	module.SetSettings(CMTooltip, Settings.Tooltips)
	RunService:BindToRenderStep("moveGuiToMouse", 1, function()
		if CMTooltip.AbsoluteSize.X + mouseLocation.X > CMHolder.AbsoluteSize.X then
			CMTooltip.AnchorPoint = Vector2.new(1, 0)
		else
			CMTooltip.AnchorPoint = Vector2.new(0, 0)
		end
		CMTooltip.Position = UDim2.fromOffset(mouseLocation.X, mouseLocation.Y + 25)
	end)
	local CMEntries = {}

	local _SizeX, _SizeY = Settings.MinSize, 0
	if Title then
		_SizeX = TitleTextBounds.X + Settings.Padding
		_SizeY = TitleTextBounds.Y + Settings.Padding
	end
	for _, v in pairs(Entries) do
		if typeof(v) == "function" then
			v = v(Settings)
		end
		if v then
			if not v.Text then
				v.Text = "X"
			end
			if not v.SubmenuSettings then
				v.SubmenuSettings = argSettings
			end
			local EntryText = v.Text .. "  "
			local TextBounds
			if v.Type == "TextLabel" and v.TextWrappedSize then
				TextBounds = TextService:GetTextSize(
					Util.removeTags(EntryText),
					Settings.ContextMenuEntries.TextSize,
					Settings.ContextMenuEntries.Font,
					Vector2.new(v.TextWrappedSize - Settings.ContextMenuEntries.TextSize + Settings.Padding, 99999)
				)
			else
				TextBounds = TextService:GetTextSize(
					Util.removeTags(EntryText),
					Settings.ContextMenuEntries.TextSize,
					Settings.ContextMenuEntries.Font,
					Vector2.new(99999, 99999)
				)
			end
			--v.Text = "  "..v.Text
			local _Entry
			local Tooltip
			local Submenu
			local function _GenEntry(Type, EntryText, Icon)
				local Frame = Instance.new(Type)
				Frame.Text = ""
				Frame.Size = UDim2.new(1, 0, 0, TextBounds.Y + Settings.Padding)
				local Text = Instance.new("TextLabel", Frame)
				Text.BackgroundTransparency = 1
				Text.BorderSizePixel = 0
				Text.Text = EntryText
				Text.Name = "EntryText"
				if Icon then
					local IconLabel = Instance.new("ImageLabel", Frame)
					IconLabel.BackgroundTransparency = 1
					IconLabel.Size = UDim2.fromOffset(
						Settings.ContextMenuEntries.TextSize + Settings.Padding,
						Settings.ContextMenuEntries.TextSize + Settings.Padding
					)
					IconLabel.Position =
						UDim2.fromOffset((Settings.ContextMenuEntries.TextSize + Settings.Padding) / 2, 0)
					if typeof(Icon) == "table" then
						for i, v in pairs(Icon) do
							IconLabel[i] = v
						end
					else
						IconLabel.Image = Icon
					end
				end
				Text.Size = UDim2.new(1, 0 - ((Settings.ContextMenuEntries.TextSize + Settings.Padding) * 2), 1, 0)
				Text.Position = UDim2.new(0, (Settings.ContextMenuEntries.TextSize + Settings.Padding) * 2, 0, 0)
				return Frame
			end
			if v.Type == "Divider" then
				_Entry = Instance.new("TextLabel")
				_Entry.Text = ""
				_Entry.Name = "Divider"
				_Entry.Size = UDim2.new(1, 0, 0, Settings.Padding * 2)
				local Line = Instance.new("Frame", _Entry)
				Line.BackgroundColor3 = Settings.BorderColor
				Line.BorderSizePixel = 0
				if v.DividerStyle == 1 then
					Line.Size = UDim2.new(1, 0 - ((TextBounds.Y + Settings.Padding) * 2), 0, 1)
					Line.Position = UDim2.new(0, (TextBounds.Y + Settings.Padding) * 2, 0.5, 0)
				else
					Line.Size = UDim2.new(1, 0 - (Settings.Padding * 2), 0, 1)
					Line.Position = UDim2.new(0, Settings.Padding, 0.5, 0)
				end
				module.SetSettings(_Entry, Settings.ContextMenuEntries)
			elseif v.Type == "Color3" then
				local Color = v.Color
				local OnColorChange = function() end
				if v.OnColorChange then
					OnColorChange = v.OnColorChange
				end
				_Entry = Instance.new("Frame")
				if EntryText == "X  " then
					_Entry.Size = UDim2.new(1, 0, 0, TextBounds.Y + Settings.Padding)
				else
					_Entry.Size = UDim2.new(1, 0, 0, (TextBounds.Y + Settings.Padding) * 2)
					local TextLabel = Instance.new("TextLabel", _Entry)
					module.SetSettings(TextLabel, Settings.ContextMenuEntries)
					module.SetSettings(TextLabel, Settings.ContextMenuEntriesColor3)
					TextLabel.BackgroundTransparency = 1
					TextLabel.BorderSizePixel = 0
					TextLabel.Text = EntryText
					TextLabel.Name = "EntryText"
					TextLabel.TextXAlignment = "Left"
					TextLabel.Size = UDim2.new(
						1,
						0 - ((TextBounds.Y + Settings.Padding) * 2),
						1,
						0 - (Settings.ContextMenuEntries.TextSize + Settings.Padding)
					)
					TextLabel.Position = UDim2.new(0, (TextBounds.Y + Settings.Padding) * 2, 0, 0)
				end
				module.SetSettings(_Entry, Settings.ContextMenuEntries)
				module.SetSettings(_Entry, Settings.ContextMenuEntriesColor3)
				local ColorMark = Instance.new("TextButton", _Entry)
				module.SetSettings(ColorMark, Settings.ContextMenuEntries)
				module.SetSettings(ColorMark, Settings.ContextMenuEntriesColor3)
				ColorMark.Size = UDim2.new(0, (TextBounds.Y * 2), 1, 0 - Settings.Padding)
				ColorMark.AnchorPoint = Vector2.new(0.5, 0.5)
				ColorMark.Position = UDim2.new(0, TextBounds.Y + Settings.Padding, 0.5, 0)
				ColorMark.BorderSizePixel = 2
				ColorMark.Text = ""
				ColorMark.BackgroundColor3 = Color
				local click = 0
				local ChangeValsFunction = function() end
				ColorMark.MouseButton1Click:Connect(function()
					click = click + 1
					if click > 1 then
						local Value = module.OpenColorPicker(Color, CMHolder)
						ColorMark.BackgroundColor3 = Value
						Color = Value
						ChangeValsFunction()
						OnColorChange(Value)
					end
					wait(0.3)
					click = click - 1
				end)
				local ValuesFrame = Instance.new("Frame", _Entry)
				ValuesFrame.BackgroundTransparency = 1
				ValuesFrame.Size = UDim2.new(1, 0 - ((TextBounds.Y + Settings.Padding) * 2), 1, 0)
				ValuesFrame.Position = UDim2.new(0, (TextBounds.Y + Settings.Padding) * 2, 0, 0)
				local function CreateVals(val1Placeholder, val2Placeholder, val3Placeholder)
					local vals = {}
					vals.Val1 = Instance.new("TextBox")
					vals.Val2 = Instance.new("TextBox")
					vals.Val3 = Instance.new("TextBox")
					for i, v in pairs(vals) do
						module.SetSettings(v, Settings.ContextMenuEntries)
						module.SetSettings(v, Settings.ContextMenuEntriesColor3)
						v.TextXAlignment = "Center"
						v.Name = i
						v.Size = UDim2.new(1 / 3, 0, 0, TextBounds.Y + Settings.Padding)
						v.BackgroundColor3 = Color3.fromRGB(25, 27, 30)
						v.BorderMode = "Inset"
					end
					vals.Val1.PlaceholderText = val1Placeholder
					vals.Val2.PlaceholderText = val2Placeholder
					vals.Val3.PlaceholderText = val3Placeholder
					return vals.Val1, vals.Val2, vals.Val3
				end
				if v.Mode == "RGB" or not v.Mode then
					local RVal, GVal, BVal = CreateVals("R", "G", "B")
					ChangeValsFunction = function()
						RVal.Text = Util.round(Color.R * 255, 0)
						GVal.Text = Util.round(Color.G * 255, 0)
						BVal.Text = Util.round(Color.B * 255, 0)
					end
					RVal.Text = Util.round(Color.R * 255, 0)
					GVal.Text = Util.round(Color.G * 255, 0)
					BVal.Text = Util.round(Color.B * 255, 0)
					RVal.Parent = ValuesFrame
					GVal.Parent = ValuesFrame
					BVal.Parent = ValuesFrame
					RVal.Position = UDim2.new(0, 0, 0, TextBounds.Y + Settings.Padding)
					GVal.Position = UDim2.new(1 / 3, 0, 0, TextBounds.Y + Settings.Padding)
					BVal.Position = UDim2.new(2 / 3, 0, 0, TextBounds.Y + Settings.Padding)
					RVal.FocusLost:Connect(function()
						if tonumber(RVal.Text) and tonumber(GVal.Text) and tonumber(BVal.Text) then
							local Value = Color3.fromRGB(
								math.clamp(tonumber(RVal.Text), 0, 255),
								math.clamp(tonumber(GVal.Text), 0, 255),
								math.clamp(tonumber(BVal.Text), 0, 255)
							)
							RVal.Text = Util.round(Color.R * 255, 0)
							ColorMark.BackgroundColor3 = Value
							Color = Value
							OnColorChange(Value)
						end
					end)
					GVal.FocusLost:Connect(function()
						if tonumber(RVal.Text) and tonumber(GVal.Text) and tonumber(BVal.Text) then
							local Value = Color3.fromRGB(
								math.clamp(tonumber(RVal.Text), 0, 255),
								math.clamp(tonumber(GVal.Text), 0, 255),
								math.clamp(tonumber(BVal.Text), 0, 255)
							)
							GVal.Text = Util.round(Color.G * 255, 0)
							ColorMark.BackgroundColor3 = Value
							Color = Value
							OnColorChange(Value)
						end
					end)
					BVal.FocusLost:Connect(function()
						if tonumber(RVal.Text) and tonumber(GVal.Text) and tonumber(BVal.Text) then
							local Value = Color3.fromRGB(
								math.clamp(tonumber(RVal.Text), 0, 255),
								math.clamp(tonumber(GVal.Text), 0, 255),
								math.clamp(tonumber(BVal.Text), 0, 255)
							)
							BVal.Text = Util.round(Color.B * 255, 0)
							ColorMark.BackgroundColor3 = Value
							Color = Value
							OnColorChange(Value)
						end
					end)
				end
			elseif v.Type == "Keybind" then
				pcall(function()
					local Keybind = v.Keybind
					local OnKeybindChange = function(Keybind) end
					if v.OnKeybindChange then
						OnKeybindChange = v.OnKeybindChange
					end
					_Entry = Instance.new("Frame")
					if EntryText == "X  " then
						_Entry.Size = UDim2.new(1, 0, 0, (TextBounds.Y * 2) + Settings.Padding)
					else
						_Entry.Size = UDim2.new(1, 0, 0, (TextBounds.Y * 3) + (Settings.Padding * 2))
						local TextLabel = Instance.new("TextLabel", _Entry)
						module.SetSettings(TextLabel, Settings.ContextMenuEntries)
						module.SetSettings(TextLabel, Settings.ContextMenuEntriesKeybind)
						TextLabel.BackgroundTransparency = 1
						TextLabel.BorderSizePixel = 0
						TextLabel.Text = EntryText
						TextLabel.Name = "EntryText"
						TextLabel.TextXAlignment = "Left"
						TextLabel.Size = UDim2.new(
							1,
							0 - ((TextBounds.Y + Settings.Padding) * 2),
							0,
							(Settings.ContextMenuEntries.TextSize + Settings.Padding)
						)
						TextLabel.Position = UDim2.new(0, (TextBounds.Y + Settings.Padding) * 2, 0, 0)
					end
					module.SetSettings(_Entry, Settings.ContextMenuEntries)
					module.SetSettings(_Entry, Settings.ContextMenuEntriesKeybind)
					local KeybindFrame = Instance.new("Frame", _Entry)
					KeybindFrame.BackgroundTransparency = 1
					KeybindFrame.Name = "KeybindFrame"
					KeybindFrame.BackgroundColor3 = Color3.new(1, 1, 1)
					KeybindFrame.Size = UDim2.new(
						1,
						0 - (((TextBounds.Y + Settings.Padding) * 2) + Settings.Padding),
						0,
						TextBounds.Y * 2
					)
					KeybindFrame.Position = UDim2.new(
						0,
						((TextBounds.Y + Settings.Padding) * 2),
						0,
						(Settings.ContextMenuEntries.TextSize + Settings.Padding)
					)
					local Frame = Instance.new("Frame", KeybindFrame)
					module.SetSettings(Frame, Settings.ContextMenuEntries)
					module.SetSettings(Frame, Settings.ContextMenuEntriesKeybind)
					Frame.AnchorPoint = Vector2.new(0.5, 0.5)
					Frame.Size = UDim2.fromScale(1, 1)
					Frame.Position = UDim2.fromScale(0.5, 0.5)
					Frame.BackgroundColor3 = Settings.ContextMenuEntriesKeybind.ButtonTextColor3
					local UICorner = Instance.new("UICorner", Frame)
					UICorner.CornerRadius = UDim.new(0.2, 0)
					local KeybindButton = Instance.new("TextButton", KeybindFrame)
					module.SetSettings(KeybindButton, Settings.ContextMenuEntries)
					module.SetSettings(KeybindButton, Settings.ContextMenuEntriesKeybind)
					KeybindButton.AnchorPoint = Vector2.new(0.5, 0.5)
					KeybindButton.Size = UDim2.new(1, -2, 1, -2)
					KeybindButton.Position = UDim2.fromScale(0.5, 0.5)
					KeybindButton.TextColor3 = Settings.ContextMenuEntriesKeybind.ButtonTextColor3
					KeybindButton.Text = (function()
						if Keybind then
							return Keybind.Name
						else
							return "Not set!"
						end
					end)()
					local UICorner = Instance.new("UICorner", KeybindButton)
					UICorner.CornerRadius = UDim.new(0.2, 0)
					local click = 0
					KeybindButton.MouseButton1Click:Connect(function()
						click = click + 1
						if click == 2 then
							KeybindButton.Text = "..."
							UserInputService.InputEnded:wait()
							UserInputService.InputBegan:wait()
							local conn
							conn = UserInputService.InputEnded:Connect(function(input)
								if input.KeyCode.Name ~= "Unknown" then
									Keybind = input.KeyCode
									KeybindButton.Text = input.KeyCode.Name
									OnKeybindChange(input)
								else
									KeybindButton.Text = Keybind.Name
								end
								conn:Disconnect()
							end)
						end
						wait(0.3)
						click = click - 1
					end)
					local lclick = 0
					KeybindButton.MouseButton2Click:Connect(function()
						lclick = lclick + 1
						if lclick == 2 then
							KeybindButton.Text = "Unbound!"
							OnKeybindChange(nil)
						end
						wait(0.3)
						lclick = lclick - 1
					end)
				end)
			elseif v.Type == "CheckBox" then
				_Entry = _GenEntry("TextButton", EntryText)
				_Entry.Name = v.Name
				module.SetSettings(_Entry, Settings.ContextMenuEntries)
				module.SetSettings(_Entry, Settings.ContextMenuEntriesCheckbox)
				if _Entry:FindFirstChild("EntryText") then
					module.SetSettings(_Entry.EntryText, Settings.ContextMenuEntries)
					module.SetSettings(_Entry.EntryText, Settings.ContextMenuEntriesCheckbox)
				end
				local Line = Instance.new("Frame", _Entry)
				Line.Name = "Line"
				Line.BackgroundColor3 = Settings.BorderColor
				Line.BorderSizePixel = 0
				Line.Size = UDim2.new(0, 1, 1, 0 - Settings.Padding)
				Line.AnchorPoint = Vector2.new(0.5, 0.5)
				Line.Position = UDim2.new(0, _Entry.EntryText.Position.X.Offset - Settings.Padding, 0.5, 0)
				local Value = false
				if v.Value then
					Value = v.Value
				end
				local CheckMark = Instance.new("TextLabel", _Entry)
				module.SetSettings(CheckMark, Settings.ContextMenuEntries)
				module.SetSettings(CheckMark, Settings.ContextMenuEntriesCheckbox)
				CheckMark.BackgroundTransparency = 1
				CheckMark.Size = UDim2.new(0, Line.Position.X.Offset, 1, 0)
				CheckMark.Position = UDim2.fromScale(0, 0)
				CheckMark.TextXAlignment = "Center"
				if Value then
					CheckMark.Text = v.IsAChoice and Settings.ContextMenuEntriesCheckbox.CheckboxChoiceSymbol or Settings.ContextMenuEntriesCheckbox.CheckboxCheckedSymbol
				else
					CheckMark.Text = Settings.ContextMenuEntriesCheckbox.CheckboxUncheckedSymbol
				end
				if v.M1Func then
					_Entry.MouseButton1Click:connect(function()
						v.M1Func(not Value)
					end)
					_Entry.MouseButton1Click:connect(function()
						wait()
						if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not Settings.NoShiftModifier then
							Value = not Value
							if Value then
								CheckMark.Text = v.IsAChoice and Settings.ContextMenuEntriesCheckbox.CheckboxChoiceSymbol or Settings.ContextMenuEntriesCheckbox.CheckboxCheckedSymbol
							else
								CheckMark.Text = Settings.ContextMenuEntriesCheckbox.CheckboxUncheckedSymbol
							end
						else
							if Settings.OnlyCloseSelf then
								CMHolder:Destroy()
								for _, v in pairs(Holders) do
									pcall(function()
										v:Destroy()
									end)
								end
							else
								for _, v in pairs(ContextGui:GetChildren()) do
									if v.Name == "CMHolder" then
										v:Destroy()
									end
								end
							end
						end
					end)
				end
				if v.M2Func then
					_Entry.MouseButton2Click:connect(function()
						v.M2Func(not Value)
					end)
					_Entry.MouseButton2Click:connect(function()
							wait()
						if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not Settings.NoShiftModifier then
							Value = not Value
							if Value then
								CheckMark.Text = v.IsAChoice and Settings.ContextMenuEntriesCheckbox.CheckboxChoiceSymbol or Settings.ContextMenuEntriesCheckbox.CheckboxCheckedSymbol
							else
								CheckMark.Text = Settings.ContextMenuEntriesCheckbox.CheckboxUncheckedSymbol
							end
						else
							if Settings.OnlyCloseSelf then
								CMHolder:Destroy()
								for _, v in pairs(Holders) do
									pcall(function()
										v:Destroy()
									end)
								end
							else
								for _, v in pairs(ContextGui:GetChildren()) do
									if v.Name == "CMHolder" then
										v:Destroy()
									end
								end
							end
						end
					end)
				end
				if v.OnChecked then
					_Entry.MouseButton1Click:connect(function()
						if not Value then
							v.OnChecked(not Value)
						end
					end)
					_Entry.MouseButton1Click:connect(function()
							wait()
						if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not Settings.NoShiftModifier then
							Value = not Value
							if Value then
								CheckMark.Text = v.IsAChoice and Settings.ContextMenuEntriesCheckbox.CheckboxChoiceSymbol or Settings.ContextMenuEntriesCheckbox.CheckboxCheckedSymbol
							else
								CheckMark.Text = Settings.ContextMenuEntriesCheckbox.CheckboxUncheckedSymbol
							end
						else
							if Settings.OnlyCloseSelf then
								CMHolder:Destroy()
								for _, v in pairs(Holders) do
									pcall(function()
										v:Destroy()
									end)
								end
							else
								for _, v in pairs(ContextGui:GetChildren()) do
									if v.Name == "CMHolder" then
										v:Destroy()
									end
								end
							end
						end
					end)
				end
				if v.OnUnchecked then
					_Entry.MouseButton1Click:connect(function()
						if Value then
							v.OnUnchecked(not Value)
						end
					end)
					_Entry.MouseButton1Click:connect(function()
							wait()
						if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and not Settings.NoShiftModifier then
							Value = not Value
							if Value then
								CheckMark.Text = v.IsAChoice and Settings.ContextMenuEntriesCheckbox.CheckboxChoiceSymbol or Settings.ContextMenuEntriesCheckbox.CheckboxCheckedSymbol
							else
								CheckMark.Text = Settings.ContextMenuEntriesCheckbox.CheckboxUncheckedSymbol
							end
						else
							if Settings.OnlyCloseSelf then
								CMHolder:Destroy()
								for _, v in pairs(Holders) do
									pcall(function()
										v:Destroy()
									end)
								end
							else
								for _, v in pairs(ContextGui:GetChildren()) do
									if v.Name == "CMHolder" then
										v:Destroy()
									end
								end
							end
						end
					end)
				end
			elseif v.Type == "Slider" then
				local MaxValue = 0
				local OnChangedEvent = Instance.new("BindableEvent", CMHolder)
				local MinValue = 1
				local SliderValue = 0
				local Rounding = 2
				if v.StartingValue then
					SliderValue = v.StartingValue
				end
				if v.MaxValue then
					MaxValue = v.MaxValue
				end
				if v.MinValue then
					MinValue = v.MinValue
				end
				if v.Rounding then
					Rounding = v.Rounding
				end
				local Funcs = {
					"OnValueChange",
					"OnDrag",
					"OnRelease",
				}
				_Entry = Instance.new("TextButton")
				_Entry.AutoButtonColor = false
				_Entry.Text = ""
				_Entry.Name = v.Name
				if EntryText == "X  " then
					_Entry.Size = UDim2.new(1, 0, 0, Settings.ContextMenuEntries.TextSize + Settings.Padding)
				else
					_Entry.Size =
						UDim2.new(1, 0, 0, TextBounds.Y + Settings.ContextMenuEntries.TextSize + (2 * Settings.Padding))
					local TextLabel = Instance.new("TextLabel", _Entry)
					module.SetSettings(TextLabel, Settings.ContextMenuEntries)
					module.SetSettings(TextLabel, Settings.ContextMenuEntriesSlider)
					TextLabel.BackgroundTransparency = 1
					TextLabel.BorderSizePixel = 0
					TextLabel.Text = EntryText
					TextLabel.Name = "EntryText"
					TextLabel.TextXAlignment = "Left"
					TextLabel.Size = UDim2.new(
						1,
						0 - ((TextBounds.Y + Settings.Padding) * 2),
						1,
						0 - (Settings.ContextMenuEntries.TextSize + Settings.Padding)
					)
					TextLabel.Position = UDim2.new(0, (TextBounds.Y + Settings.Padding) * 2, 0, 0)
				end
				module.SetSettings(_Entry, Settings.ContextMenuEntries)
				module.SetSettings(_Entry, Settings.ContextMenuEntriesSlider)
				local Line = Instance.new("Frame", _Entry)
				Line.Name = "Line"
				Line.BackgroundColor3 = Settings.BorderColor
				Line.BorderSizePixel = 0
				Line.Size = UDim2.new(1, 0 - ((TextBounds.Y + Settings.Padding) * 2.5), 0, 1)
				Line.Position = UDim2.new(
					0,
					(TextBounds.Y + Settings.Padding) * 2,
					1,
					0 - ((Settings.ContextMenuEntries.TextSize + Settings.Padding) / 2)
				)
				local DragBoundingBox = Instance.new("TextButton", Line)
				DragBoundingBox.AnchorPoint = Vector2.new(0.5, 0.5)
				DragBoundingBox.Position = UDim2.fromScale(0.5, 0.5)
				DragBoundingBox.Size = UDim2.new(1, 5, 1, 5)
				DragBoundingBox.Text = ""
				DragBoundingBox.BackgroundTransparency = 1
				local ValueDisplay
				if v.ValueDisplay then
					ValueDisplay = Instance.new("TextBox", _Entry)
					module.SetSettings(ValueDisplay, Settings.ContextMenuEntries)
					module.SetSettings(ValueDisplay, Settings.ContextMenuEntriesSlider)
					ValueDisplay.Name = "ValueDisplay"
					ValueDisplay.BackgroundTransparency = 1
					ValueDisplay.AnchorPoint = Vector2.new(0, 1)
					ValueDisplay.Position = UDim2.fromScale(0, 1)
					ValueDisplay.Size = UDim2.fromOffset((TextBounds.Y * 2), TextBounds.Y)
					ValueDisplay.Text = SliderValue
					ValueDisplay.TextXAlignment = "Left"
					ValueDisplay.TextScaled = true
				end
				local Handle = Instance.new("Frame", Line)
				Handle.Name = "Handle"
				Handle.BorderSizePixel = 0
				Handle.Size = UDim2.fromOffset(
					(Settings.ContextMenuEntries.TextSize + Settings.Padding) / 2,
					(Settings.ContextMenuEntries.TextSize + Settings.Padding) / 2
				)
				Handle.AnchorPoint = Vector2.new(0.5, 0.5)
				Handle.BackgroundColor3 = Color3.new(1, 1, 1)
				Handle.Position =
					UDim2.fromScale((math.clamp(SliderValue, MinValue, MaxValue) - MinValue) / (MaxValue - MinValue), 0)
				ValueDisplay.FocusLost:Connect(function()
					if tonumber(ValueDisplay.Text) then
						OnChangedEvent:Fire(tonumber(ValueDisplay.Text), SliderValue)
						SliderValue = tonumber(ValueDisplay.Text)
						Handle.Position =
							UDim2.fromScale(math.clamp((SliderValue - MinValue) / (MaxValue - MinValue), 0, 1), 0)
					else
						ValueDisplay.Text = SliderValue
					end
				end)
				local held = false
				DragBoundingBox.MouseButton1Down:Connect(function()
					held = true
					if v.OnDrag then
						v.OnDrag(SliderValue)
					end
				end)
				local UICorner = Instance.new("UICorner", Handle)
				UICorner.CornerRadius = UDim.new(1, 0)
				local BeingDragged = false
				DragBoundingBox.MouseButton1Down:Connect(function()
					BeingDragged = true
				end)
				UserInputService.InputEnded:connect(function(input) --add touchended
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						BeingDragged = false
						if v.OnRelease then
							if held then
								held = false
								v.OnRelease(SliderValue)
							end
						end
					end
				end)
				local _lastval = SliderValue
				local _Init = false
				if v.OnValueChange then
					OnChangedEvent.Event:Connect(v.OnValueChange)
				end
				RunService.RenderStepped:Connect(function()
					if BeingDragged then
						SliderValue = Util.round(
							MinValue + ((Handle.Position.X.Offset / Line.AbsoluteSize.X) * (MaxValue - MinValue)),
							Rounding
						)
						if ValueDisplay then
							ValueDisplay.Text = SliderValue
						end
						if _Init and (SliderValue ~= _lastval) then
							OnChangedEvent:Fire(SliderValue, _lastval)
						end
						_Init = true
						Handle.Position = UDim2.fromOffset(
							math.clamp(mouseLocation.X - Line.AbsolutePosition.X, 0, Line.AbsoluteSize.X),
							Handle.Position.Y.Offset
						)
						_lastval = SliderValue
					end
				end)
			elseif v.Type == "TextLabel" or v.Type == "TextButton" or not v.Type then
				if v.M1Func or v.M2Func then
					v.Type = "TextButton"
					_Entry = _GenEntry(v.Type, EntryText, v.Icon)
					if v.M1Func then
						_Entry.MouseButton1Click:connect(v.M1Func)
						_Entry.MouseButton1Click:connect(function()
							wait()
							if Settings.OnlyCloseSelf then
								CMHolder:Destroy()
								for _, v in pairs(Holders) do
									pcall(function()
										v:Destroy()
									end)
								end
							else
								for _, v in pairs(ContextGui:GetChildren()) do
									if v.Name == "CMHolder" then
										v:Destroy()
									end
								end
							end
						end)
					end
					if v.M2Func then
						_Entry.MouseButton2Click:connect(v.M2Func)
						_Entry.MouseButton2Click:connect(function()
							wait()
							if Settings.OnlyCloseSelf then
								CMHolder:Destroy()
								for _, v in pairs(Holders) do
									pcall(function()
										v:Destroy()
									end)
								end
							else
								for _, v in pairs(ContextGui:GetChildren()) do
									if v.Name == "CMHolder" then
										v:Destroy()
									end
								end
							end
						end)
					end
				else
					v.Type = "TextLabel"
					_Entry = _GenEntry(v.Type, EntryText, v.Icon)
				end
				module.SetSettings(_Entry, Settings.ContextMenuEntries)
				if _Entry:FindFirstChild("EntryText") then
					module.SetSettings(_Entry.EntryText, Settings.ContextMenuEntries)
					if v.TextWrappedSize then
						_Entry.EntryText.TextWrapped = true
						--_Entry.RichText = false
					end
				end
				if v.AutoButtonColor then
					_Entry.AutoButtonColor = v.AutoButtonColor
				end
			end
			if v.Tooltip then
				Tooltip = Instance.new("StringValue", _Entry)
				Tooltip.Value = v.Tooltip
				Tooltip.Name = "Tooltip"
			end
			local function GetMenuSize(Entries, Scrollable, ScrollableSizeY)
				if not ScrollableSizeY then ScrollableSizeY = 200 end
				local out = 0
				for _, Entry in pairs(Entries) do 
					if table.find({"textlabel","textbutton", "checkbox"},Entry.Type and Entry.Type:lower()) then
						out = out + (Settings.ContextMenuEntries.TextSize + Settings.Padding)
					end
					if table.find({"divider"},Entry.Type and Entry.Type:lower()) then
						out = out + (Settings.Padding*2)
					end
					if table.find({"color3", "keybind", "slider"},Entry.Type and Entry.Type:lower()) then
						if Entry.Text then
							out = out + ((Settings.ContextMenuEntries.TextSize + Settings.Padding) * 2)
						else
							out = out + (Settings.ContextMenuEntries.TextSize + Settings.Padding)
						end
					end
				end
				if Scrollable then return ScrollableSizeY end
				return out
			end
			if v.Submenu and v.Submenu ~= {} and (v.Type == "TextButton" or v.Type == "TextLabel") then
				Submenu = Instance.new("TextButton", _Entry)
				Submenu.Size = UDim2.fromOffset(TextBounds.Y + Settings.Padding, TextBounds.Y + Settings.Padding)
				Submenu.Text = ">"
				Submenu.AnchorPoint = Vector2.new(1, 0)
				Submenu.Position = UDim2.fromScale(1, 0)
				module.SetSettings(Submenu, Settings.ContextMenuEntries)
				Submenu.TextXAlignment = "Center"
				local Submenuholder
				local SubmenuConn = Submenu.MouseButton1Up:Connect(function()
					if Submenuholder and Submenuholder.Parent then
						Submenuholder:Destroy()
						Submenuholder = nil
					else
						if typeof(v.Submenu) == "function" then
							pcall(function()
								local Entries = v.Submenu()
								Submenuholder, Holders[#Holders + 1] = module.Create(
									GetSubmenuSettings(
										_Entry,
										GetMenuSize(Entries, v.SubmenuSettings.Scrollable, v.SubmenuSettings.ScrollableSizeY),
										v.SubmenuSettings
									),
									table.unpack(Entries)
								)
							end)
						else
							pcall(function()
								Submenuholder, Holders[#Holders + 1] = module.Create(
									GetSubmenuSettings(
										_Entry,
										GetMenuSize(v.Submenu, v.SubmenuSettings.Scrollable, v.SubmenuSettings.ScrollableSizeY),
										v.SubmenuSettings
									),
									table.unpack(v.Submenu)
								)
							end)
						end
					end
				end)
			end
			if v.Submenu then
				_SizeX = math.max(
					_SizeX,
					TextBounds.X
						+ Settings.Padding
						+ TextBounds.Y
						+ Settings.Padding
						+ ((TextBounds.Y + Settings.Padding) * 1.5)
				)
			else
				if v.Type == "Slider" then
					if v.MinSliderSize then
						_SizeX = math.max(_SizeX, (TextBounds.Y + Settings.Padding) * 3.5 + v.MinSliderSize)
					else
						_SizeX =
							math.max(_SizeX, TextBounds.X + Settings.Padding + (TextBounds.Y + Settings.Padding) * 1.5)
					end
				else
					_SizeX = math.max(_SizeX, TextBounds.X + Settings.Padding + (TextBounds.Y + Settings.Padding) * 1.5)
				end
			end
			_SizeY = _SizeY + _Entry.AbsoluteSize.Y
			CMEntries[#CMEntries + 1] = _Entry
		end
	end
	if Settings.IsASubmenu then
		CMFrame.Size = UDim2.fromOffset(0, 0)
	else
		CMFrame.Size = UDim2.fromOffset(_SizeX, 0)
	end
	if Settings.Scrollable == true then
		if not Settings.ScrollableSizeY then
			Settings.ScrollableSizeY = 200
		end
		CMFrame:TweenSize(
			UDim2.fromOffset(_SizeX, math.min(Settings.ScrollableSizeY, _SizeY)),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quint,
			0.1
		)
	else
		CMFrame:TweenSize(UDim2.fromOffset(_SizeX, _SizeY), Enum.EasingDirection.Out, Enum.EasingStyle.Quint, 0.1)
	end
	CMFrame.BorderColor3 = Settings.BorderColor
	CMFrame.BackgroundColor3 = Settings.BorderColor
	CMFrame.BorderSizePixel = Settings.BorderSizePixel
	if Title then
		Title.Size = UDim2.fromOffset(_SizeX, TitleTextBounds.Y + Settings.Padding)
	end
	for _, entry in pairs(CMEntries) do
		entry.Parent = CMFrame
		Mouse.Move:Connect(function()
			CMTooltip.Visible = false
		end)
		entry.MouseMoved:connect(function()
			if entry:FindFirstChild("Tooltip") then
				wait(Settings.TooltipDelay)
				if Util.isHoveringOverObj(entry) then
					CMTooltip.Visible = true
					CMTooltip.Text = entry.Tooltip.Value
					CMTooltip.Size =
						UDim2.fromOffset(Util.GetTextSize(CMTooltip, Settings.Padding, Settings.TooltipSize))
				end
			end
		end)
		--entry.MouseMoved:connect()
	end
	CMFrame.Position = Settings.Position
	if _SizeY < 450 or CMFrame.ClassName == "ScrollingFrame" then
		CMFrame.AnchorPoint = Settings.FrameAnchorPoint
	else
		CMFrame.AnchorPoint = Vector2.new(Settings.FrameAnchorPoint.X, 0.5)
	end
	return CMFrame, CMHolder
end
module.DefaultSettings:Write()
return module
