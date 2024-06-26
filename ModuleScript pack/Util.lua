local module = {}
local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Mouse = LP and LP:GetMouse()
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local UserCache = {}
function module.JSONDecode(arg)
	return game:GetService("HttpService"):JSONDecode(arg)
end
function module.JSONEncode(arg)
	return game:GetService("HttpService"):JSONEncode(arg)
end
function module.JSONRequest(URL)
	return game:GetService("HttpService"):JSONDecode(game:HttpGet(URL))
end
local ClassImageOffsets = {
	Vector3Value = 64,
	PluginGuiService = 736,
	StarterGui = 736,
	Accoutrement = 512,
	GuiMain = 752,
	VectorForce = 1632,
	Handles = 848,
	ValueBase = 64,
	UIScale = 416,
	CFrameValue = 64,
	ImageLabel = 784,
	StarterPlayer = 1264,
	UIListLayout = 416,
	BindableEvent = 1072,
	TextSource = 2224,
	RenderingTest = 80,
	HumanoidDescription = 1664,
	ServerScriptService = 1136,
	BillboardGui = 1024,
	MarketplaceService = 736,
	Team = 384,
	FlangeSoundEffect = 1344,
	GuiButton = 832,
	Teams = 368,
	BodyGyro = 224,
	WrapLayer = 2016,
	WeldConstraint = 1504,
	Folder = 1232,
	Animator = 960,
	Explosion = 576,
	Beam = 1536,
	Constraint = 1376,
	ProximityPrompt = 1984,
	ImageHandleAdornment = 1728,
	Lighting = 208,
	ObjectValue = 64,
	Plane = 2144,
	ColorCorrectionEffect = 1328,
	Atmosphere = 448,
	RopeConstraint = 1424,
	SelectionBox = 864,
	FaceControls = 2064,
	StarterGear = 320,
	TremoloSoundEffect = 1344,
	PoseBase = 960,
	Status = 32,
	AnimationTrack = 960,
	WrapTarget = 2032,
	PathfindingLink = 2192,
	Humanoid = 144,
	CylinderHandleAdornment = 1744,
	BloomEffect = 1328,
	Attachment = 1296,
	PitchShiftSoundEffect = 1344,
	ImageButton = 832,
	NumberValue = 64,
	CylindricalConstraint = 1520,
	WireframeHandleAdornment = 1808,
	Configuration = 928,
	Accessory = 512,
	LineForce = 1616,
	KeyframeMarker = 960,
	HopperBin = 352,
	ReplicatedStorage = 1120,
	StarterPack = 320,
	ArcHandles = 896,
	Players = 336,
	BasePart = 16,
	TextButton = 816,
	ViewportFrame = 832,
	StarterCharacterScripts = 1248,
	MaterialService = 2096,
	Dialog = 992,
	Clouds = 448,
	Seat = 560,
	Debris = 480,
	ParticleEmitter = 1280,
	Flag = 608,
	Backpack = 320,
	Actor = 1808,
	Sky = 448,
	Chat = 528,
	Workspace = 304,
	SelectionSphere = 864,
	TrussPart = 16,
	PrismaticConstraint = 1408,
	TouchTransmitter = 592,
	Fire = 976,
	CylinderMesh = 128,
	Weld = 544,
	BoolValue = 64,
	ClickDetector = 656,
	SurfaceLight = 208,
	Keyframe = 960,
	ShirtGraphic = 640,
	LocalizationTable = 1552,
	BrickColorValue = 64,
	WorldModel = 304,
	PluginDebugService = 736,
	RemoteEvent = 1200,
	Smoke = 944,
	Torque = 1648,
	UniversalConstraint = 1968,
	PointLight = 208,
	DoubleConstrainedValue = 64,
	RocketPropulsion = 224,
	CanvasGroup = 768,
	ReplicatedFirst = 1120,
	NegateOperation = 1152,
	Bone = 1824,
	TerrainRegion = 1040,
	Texture = 160,
	Script = 96,
	TextBox = 816,
	UITextSizeConstraint = 416,
	NoCollisionConstraint = 1680,
	UIAspectRatioConstraint = 416,
	RodConstraint = 1440,
	Shirt = 688,
	SlidingBallConstraint = 1408,
	SkateboardPlatform = 560,
	Decal = 112,
	CharacterMesh = 960,
	AdPortal = 2336,
	PlayerScripts = 1248,
	Speaker = 176,
	UISizeConstraint = 416,
	SurfaceAppearance = 160,
	ServerStorage = 1104,
	IntValue = 64,
	FloorWire = 64,
	CornerWedgePart = 16,
	ChatWindowConfiguration = 2256,
	UIGridLayout = 416,
	TestService = 1088,
	SoundGroup = 1360,
	SunRaysEffect = 1328,
	CorePackages = 320,
	AlignPosition = 1584,
	Message = 528,
	IKControl = 848,
	Highlight = 2128,
	WedgePart = 16,
	MeshPart = 1168,
	AngularVelocity = 1648,
	NetworkClient = 256,
	VoiceChatService = 2176,
	Model = 32,
	Terrain = 1040,
	JointInstance = 544,
	Tool = 272,
	VehicleSeat = 560,
	DialogChoice = 1008,
	TerrainDetail = 2304,
	Hat = 720,
	BallSocketConstraint = 1376,
	ModuleScript = 1216,
	Pants = 704,
	Animation = 960,
	IntConstrainedValue = 64,
	Motor6D = 1696,
	EqualizerSoundEffect = 1344,
	ReverbSoundEffect = 1344,
	TextLabel = 800,
	Snap = 544,
	BodyAngularVelocity = 224,
	TextChatService = 2288,
	Part = 16,
	TextChannel = 2240,
	SurfaceSelection = 880,
	Hint = 528,
	BlurEffect = 1328,
	SurfaceGui = 1024,
	AdGui = 2320,
	RayValue = 64,
	BodyForce = 224,
	UIPageLayout = 416,
	NetworkReplicator = 464,
	DistortionSoundEffect = 1344,
	UIPadding = 416,
	RemoteFunction = 1184,
	Sound = 176,
	StringValue = 64,
	SoundService = 496,
	BodyPosition = 224,
	RobloxPluginGuiService = 736,
	ScreenGui = 752,
	StandalonePluginScripts = 1248,
	LineHandleAdornment = 1712,
	BoxHandleAdornment = 1776,
	ForceField = 592,
	SpecialMesh = 128,
	NumberPose = 960,
	SpawnLocation = 400,
	BodyVelocity = 224,
	Color3Value = 64,
	Platform = 560,
	ChannelSelectorSoundEffect = 1344,
	SelectionPointLasso = 912,
	Frame = 768,
	PlayerGui = 736,
	BlockMesh = 128,
	Sparkles = 672,
	MaterialVariant = 2080,
	BodyThrust = 224,
	Plugin = 1376,
	RigidConstraint = 2160,
	AlignOrientation = 1600,
	EchoSoundEffect = 1344,
	SphereHandleAdornment = 1792,
	PathfindingModifier = 2048,
	NetworkServer = 240,
	FlagStand = 624,
	StarterPlayerScripts = 1248,
	AnimationController = 960,
	CustomEventReceiver = 64,
	Trail = 1488,
	DepthOfFieldEffect = 1328,
	UnionOperation = 1168,
	TextChatCommand = 2208,
	CoreGui = 736,
	SelectionPartLasso = 912,
	VideoFrame = 1920,
	ChorusSoundEffect = 1344,
	PlaneConstraint = 2144,
	SpotLight = 208,
	CompressorSoundEffect = 1344,
	VoiceSource = 176,
	ScrollingFrame = 768,
	UIStroke = 416,
	BindableFunction = 1056,
	LocalScript = 288,
	SpringConstraint = 1456,
	CustomEvent = 64,
	ChatInputBarConfiguration = 2272,
	ConeHandleAdornment = 1760,
	Camera = 80,
	Pose = 960,
	HingeConstraint = 1392,
	LocalizationService = 1472,
	Player = 192,
	LinearVelocity = 2112,
	UICorner = 416,
	Light = 208,
	TorsionSpringConstraint = 2000,
	UITableLayout = 416,
	UIGradient = 416,
	PackageLink = 1568
}

local DataTypeIconData = {
	Object = { 0, 0 },
	Axes = { 0, 0 },
	boolean = { 3, 0 },
	BrickColor = { 2, 3 },
	CatalogSearchParams = { 0, 0 },
	CFrame = { 4, 2 },
	Color3 = { 2, 3 },
	ColorSequence = { 0, 0 },
	ColorSequenceKeypoint = { 0, 0 },
	DateTime = { 0, 0 },
	DockWidgetPluginGuiInfo = { 0, 0 },
	Enum = { 3, 1 },
	EnumItem = { 4, 1 },
	Enums = { 3, 1 },
	Faces = { 0, 0 },
	FloatCurveKey = { 0, 0 },
	["function"] = { 0, 1 },
	Instance = { 2, 1 },
	["nil"] = { 1, 1 },
	number = { 1, 0 },
	NumberRange = { 0, 0 },
	NumberSequence = { 0, 0 },
	NumberSequenceKeypoint = { 0, 0 },
	OverlapParams = { 0, 0 },
	PathWaypoints = { 0, 0 },
	PhysicalProperties = { 0, 0 },
	Random = { 0, 0 },
	Ray = { 0, 0 },
	RaycastParams = { 0, 0 },
	RaycastResult = { 0, 0 },
	RBXScriptConnection = { 0, 3 },
	RBXScriptSignal = { 1, 3 },
	Rect = { 0, 0 },
	Region3 = { 0, 0 },
	Region3int16 = { 0, 0 },
	string = { 2, 0 },
	table = { 4, 0 },
	TweenInfo = { 0, 0 },
	UDim = { 2, 2 },
	UDim2 = { 3, 2 },
	userdata = { 0, 0 },
	Vector2 = { 1, 2 },
	Vector2int16 = { 1, 2 },
	Vector3 = { 0, 2 },
	Vector3int16 = { 0, 2 }
}

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
	error("Failed to require!")
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
		return "function()  end"
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
if Mouse then
	module.MouseClickWithoutDrag = Instance.new("BindableEvent")
	Mouse.Button2Down:Connect(function()
		pcall(function()
			local Campos = (workspace.CurrentCamera.CFrame.Position-(workspace.CurrentCamera.CameraSubject.Parent.HumanoidRootPart.Position-Vector3.new(1,1,1))).Magnitude
			Mouse.Button2Up:Wait()
			if math.abs((workspace.CurrentCamera.CFrame.Position-(workspace.CurrentCamera.CameraSubject.Parent.HumanoidRootPart.Position-Vector3.new(1,1,1))).Magnitude-Campos)<0.3 then
				module.MouseClickWithoutDrag:Fire()
			end
		end)
	end)
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
	function module.getMouseHitIncludingChar()
		local vector = Mouse.Hit.p - workspace.CurrentCamera.CFrame.p
		local ray = workspace:Raycast(workspace.CurrentCamera.CFrame.p, vector.Unit * (vector.Magnitude + 5), RaycastParams.new())
		return ray
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
	Size = tonumber(Size) or 16
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
		if not Sizes[tostring(Size)] then warn("DatatypeIcon size not found!") end
		if not data then warn("DatatypeIcon not found!") end
		return {
			Image = Sizes["16"],
			ImageRectOffset = Vector2.new(48,48),
			ImageRectSize = Vector2.new(16,16),
		}
	end
end
function module.GetClassIcon(ClassName)
	local offset = ClassImageOffsets[ClassName]
	if offset then
		return {
			Image = "rbxasset://textures/ClassImages.png",
			ImageRectOffset = Vector2.new(offset,0),
			ImageRectSize = Vector2.new(16,16),
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
		local ServerList = {}
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
local function SaveToCache(a1,a2)
	UserCache[tostring(a1)] = tostring(a2)
	UserCache[tostring(a2)] = tostring(a1)
end
function module.getUserIdFromUsername(name)
	if not name then return end
	local player = Players:FindFirstChild(name)
	if player then
		SaveToCache(name, player.UserId)
		return tostring(player.UserId)
	end
	if UserCache[name] then
		return UserCache[name]
	end
	-- If all else fails, send a request
	local id
	pcall(function()
		id = Players:GetUserIdFromNameAsync(name)
	end)
	if id then
		SaveToCache(name, id)
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
	if typeof(id) == "number" then id = tostring(id) end
	for _, v in pairs(Players:GetChildren()) do
		if v.UserId == id then
			SaveToCache(v.Name, id)
			return v.Name
		end
	end
	if UserCache[id] then
		return UserCache[id]
	end
	-- If all else fails, send a request
	local name
	pcall(function()
		name = Players:GetNameFromUserIdAsync(id)
	end)
	if name then
		SaveToCache(name, id)
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
			if err then warn(err) end
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