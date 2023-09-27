local module = {}

module.Properties = {
    Global = {
        "ClassName",
        "Name",
        "Parent"
    },
    Model = {
        "PrimaryPart"
    },
    BasePart = {
        "BackSurface",
        "BottomSurface",
        "CFrame",
        "CanCollide",
        "Color",
        "FrontSurface",
        "LeftSurface",
        "Material",
        "Orientation",
        "Position",
        "Reflectance",
        "RightSurface",
        "Rotation",
        "Size",
        "TopSurface",
        "Transparency"
    },
    MeshPart = {
        "DoubleSided",
        "MeshId",
        "MeshSize",
        "RenderFidelity",
        "TextureID",
        "MeshSize"
    },
    Accoutrement = {
        "AttachmentForward",
        "AttachmentPoint",
        "AttachmentPos",
        "AttachmentRight",
        "AttachmentUp"
    },
    Attachment = {
        "Axis",
        "CFrame",
        "Orientation",
        "Position",
        "SecondaryAxis",
        "Visible",
        "WorldAxis",
        "WorldCFrame",
        "WorldOrientation",
        "WorldPosition",
        "WorldSecondaryAxis"
    },
    JointInstance = {
        "Active",
        "C0",
        "C1",
        "Enabled",
        "Part0",
        "Part1",
    },
    Decal = {
        "Color3",
        "Texture",
        "Transparency",
        "ZIndex"
    },
    GuiObject = {
        "Active",
        "AnchorPoint",
        "AutomaticSize",
        "BackgroundColor3",
        "BackgroundTransparency",
        "BorderColor3",
        "BorderMode",
        "BorderSizePixel",
        "ClipsDescendants",
        "LayoutOrder",
        "NextSelectionDown",
        "NextSelectionLeft",
        "NextSelectionRight",
        "NextSelectionUp",
        "Position",
        "Position",
        "Selectable",
        "SelectionImageObject",
        "SelectionOrder",
        "Size",
        "SizeConstraint",
        "Visible",
        "ZIndex"
    },
    ScreenGui = {
        "DisplayOrder",
        "IgnoreGuiInset"
    },
    LayerCollector = {
        "Enabled",
        "ResetOnSpawn",
        "ZIndexBehavior"
    },
    BillboardGui = {
        "Active",
        "Adornee",
        "AlwaysOnTop",
        "Brightness",
        "ClipsDescendants",
        "CurrentDistance",
        "DistanceLowerLimit",
        "DistanceStep",
        "DistanceUpperLimit",
        "ExtentsOffset",
        "ExtentsOffsetWorldSpace",
        "LightInfluence",
        "MaxDistance",
        "PlayerToHideFrom",
        "Size",
        "SizeOffset",
        "StudsOffset",
        "StudsOffsetWorldSpace"
    },
    Humanoid = {
        "AutoJumpEnabled",
        "AutoRotate",
        "AutomaticScalingEnabled",
        "BreakJointsOnDeath",
        "CameraOffset",
        "DisplayDistanceType",
        "DisplayName",
        "FloorMaterial",
        "Health",
        "HealthDisplayDistance",
        "HealthDisplayType",
        "HipHeight",
        "Jump",
        "JumpHeight",
        "JumpPower",
        "MaxHealth",
        "MaxSlopeAngle",
        "MoveDirection",
        "NameDisplayDistance",
        "NameOcclusion",
        "PlatformStand",
        "RequiresNeck",
        "RigType",
        "RootPart",
        "SeatPart",
        "Sit",
        "TargetPoint",
        "UseJumpPower",
        "WalkSpeed",
        "WalkToPart",
        "WalkToPoint"
    },
    SpecialMesh = {
        "MeshType"
    },
    FileMesh = {
        "MeshId",
        "TextureId"
    },
    DataModelMesh = {
        "Offset",
        "Scale",
        "VertexColor"
    },
    Frame = {
        "Style"
    },
    TextLabel = {
        "Font",
        "FontFace",
        "LineHeight",
        "MaxVisibleGraphemes",
        "RichText",
        "Text",
        "TextColor3",
        "TextScaled",
        "TextSize",
        "TextStrokeColor3",
        "TextStrokeTransparency",
        "TextTransparency",
        "TextTruncate",
        "TextWrapped",
        "TextXAlignment",
        "TextYAlignment"
    },
    Clothing = {
        "Color3"
    },
    Shirt = {
        "ShirtTemplate"
    },
    Pants = {
        "PantsTemplate"
    },
    Tool = {
        "CanBeDropped",
        "Enabled",
        "Grip",
        "GripForward",
        "GripPos",
        "GripRight",
        "GripUp",
        "ManualActivationOnly",
        "RequiresHandle",
        "ToolTip"
    },
    BackpackItem = {
        "TextureId"
    },
    ObjectValue = {
        "Value"
    },
    BinaryStringValue = {
        "Value"
    },
    BoolValue = {
        "Value"
    },
    BrickColorValue = {
        "Value"
    },
    CFrameValue = {
        "Value"
    },
    Color3Value = {
        "Value"
    },
    DoubleConstrainedValue = {
        "Value",
        "MaxValue",
        "MinValue"
    },
    IntConstrainedValue = {
        "Value",
        "MaxValue",
        "MinValue"
    },
    IntValue = {
        "Value"
    },
    NumberValue = {
        "Value"
    },
    RayValue = {
        "Value"
    },
    StringValue = {
        "Value"
    },
    Vector3Value = {
        "Value"
    },
    Light = {
        "Brightness",
        "Color",
        "Enabled",
        "Shadows"
    },
    PointLight = {
        "Range"
    },
    SpotLight = {
        "Angle",
        "Face",
        "Range"
    },
    SurfaceLight = {
        "Angle",
        "Face",
        "Range"
    },
    ParticleEmitter = {
        "Acceleration",
        "Brightness",
        "Color",
        "Drag",
        "EmissionDirection",
        "Enabled",
        "FlipbookFramerate",
        "FlipbookIncompatible",
        "FlipbookLayout",
        "FlipbookMode",
        "FlipbookStartRandom",
        "Lifetime",
        "LightEmission",
        "LightInfluence",
        "LockedToPart",
        "Orientation",
        "Rate",
        "RotSpeed",
        "Rotation",
        "Shape",
        "ShapeInOut",
        "ShapePartial",
        "ShapeStyle",
        "Size",
        "Speed",
        "SpreadAngle",
        "Squash",
        "Texture",
        "TimeScale",
        "Transparency",
        "VelocityInheritance",
        "ZOffset"
    },
    Constraint = {
        "Active",
        "Attachment0",
        "Attachment1",
        "Color",
        "Enabled",
        "Visible"
    },
    UITextSizeConstraint = {
        "MaxTextSize",
        "MinTextSize"
    }
}
local InstancesTable = {}
local InstanceQueue = {}
local function SetSettings(obj, SettingsToChange)
	for setting, value in pairs(SettingsToChange) do
		if typeof(value) == "table" then
            if value[1] == "Instance" then
                if InstancesTable[value[2]] then
                    pcall(function()
                    obj[setting] = InstancesTable[value[2]]
                end)
                elseif InstanceQueue[value[2]] then
                    table.insert(InstanceQueue[value[2]],{obj, setting})
                else
                    InstanceQueue[value[2]] = {{obj, setting}}
                end
            elseif value[1] == "Vector2" then
                pcall(function()
                    obj[setting] = Vector2.new(table.unpack(value, 2))
                end)
            elseif value[1] == "Vector3" then
                pcall(function()
                    obj[setting] = Vector3.new(table.unpack(value, 2))
                end)
            elseif value[1] == "UDim2" then
                pcall(function()
                    obj[setting] = UDim2.new(table.unpack(value, 2))
                end)
            elseif value[1] == "UDim" then
                pcall(function()
                    obj[setting] = UDim.new(table.unpack(value, 2))
                end)
            elseif value[1] == "CFrame" then
                pcall(function()
                    obj[setting] = CFrame.new(table.unpack(value, 2))
                end)
            elseif value[1] == "Color3" then
                pcall(function()
                    obj[setting] = Color3.new(table.unpack(value, 2))
                end)
            elseif value[1] == "NumberSequence" then
                pcall(function()
                    local _Keypoints = {}
                    for i = 2, #value do
                        table.insert(_Keypoints, NumberSequenceKeypoint.new(table.unpack(value[i])))
                    end
                    obj[setting] = NumberSequence.new(table.unpack(_Keypoints))
                end)
            elseif value[1] == "ColorSequence" then
                pcall(function()
                    local _Keypoints = {}
                    for i = 2, #value do
                        table.insert(_Keypoints, ColorSequenceKeypoint.new(value[i][1], Color3.fromHex(value[i][2])))
                    end
                    obj[setting] = NumberSequence.new(table.unpack(_Keypoints))
                end)
            elseif value[1] == "NumberRange" then
                pcall(function()
                    obj[setting] = NumberRange.new(table.unpack(value, 2))
                end)
            end
		else
			pcall(function()
				obj[setting] = value
			end)
		end
	end
end
local function Assemble()
    for value, table in pairs(InstanceQueue) do
        for obj, table2 in pairs(table) do
            pcall(function()
                table2[1][table2[2]] = InstancesTable[value]
            end)
        end
    end
end
function module.Serialize(Object)
    local out = {}
    local names = {}
    local succ, err = pcall(function()
        local function rename(obj, i)
            table.insert(names, {obj = obj, name = obj.Name})
            obj.Name = i.."_"..obj.Name
        end
        local function restoreNames()
            for _, v in pairs(names) do
                v.obj.Name = v.name
            end
        end
        for i, obj in pairs({Object, table.unpack(Object:GetDescendants())}) do rename(obj, i) end
        for _, obj in pairs({Object, table.unpack(Object:GetDescendants())}) do
            out[obj.Name] = {}
            for ClassName, ClassProperties in pairs(module.Properties) do
                if obj:IsA(ClassName) or ClassName == "Global" then
                    for _, v in pairs(ClassProperties) do
                        if type(obj[v]) == "userdata" or type(obj[v]) == "vector" then
                            local succ, err = pcall(function()
                            if typeof(obj[v]) == "Instance" then
                                out[obj.Name][v] = {typeof(obj[v]), obj[v].Name}
                            elseif typeof(obj[v]) == "Vector3" then
                                out[obj.Name][v] = {typeof(obj[v]), obj[v].X, obj[v].Y, obj[v].Z}
                            elseif typeof(obj[v]) == "Color3" then
                                out[obj.Name][v] = {typeof(obj[v]), obj[v].R, obj[v].G, obj[v].B}
                            elseif typeof(obj[v]) == "Vector2" then
                                out[obj.Name][v] = {typeof(obj[v]), obj[v].X, obj[v].Y}
                            elseif typeof(obj[v]) == "UDim" then
                                out[obj.Name][v] = {typeof(obj[v]), obj[v].Scale, obj[v].Offset}
                            elseif typeof(obj[v]) == "UDim2" then
                                out[obj.Name][v] = {typeof(obj[v]), obj[v].X.Scale, obj[v].X.Offset, obj[v].Y.Scale, obj[v].Y.Offset}
                            elseif typeof(obj[v]) == "NumberRange" then
                                out[obj.Name][v] = {typeof(obj[v]), obj[v].Min, obj[v].Max}
                            elseif typeof(obj[v]) == "NumberSequence" then
                                out[obj.Name][v] = {typeof(obj[v])}
                                for _, val in pairs(obj[v].Keypoints) do
                                    table.insert(out[obj.Name][v], {val.Time, val.Value, val.Envelope})
                                end
                            elseif typeof(obj[v]) == "ColorSequence" then
                                out[obj.Name][v] = {typeof(obj[v])}
                                for _, val in pairs(obj[v].Keypoints) do
                                    table.insert(out[obj.Name][v], {val.Time, val.Value:ToHex()})
                                end
                            elseif typeof(obj[v]) == "CFrame" then
                                out[obj.Name][v] = {typeof(obj[v]), obj[v]:GetComponents()}
                            elseif typeof(obj[v]) == "EnumItem" then
                                out[obj.Name][v] = obj[v].Value
                            else
                                out[obj.Name][v] = typeof(obj[v])
                            end
                        end)
                        if err then rconsoleprint("\n[*ERROR*]"..err) end
                        else
                            out[obj.Name][v] = obj[v]
                        end
                    end
                end
            end
        end
        restoreNames()
    end)
    return out
end
function module.Deserialize(Table)
    InstancesTable = {}
    InstanceQueue = {}
    local SpecialMeshes = {}
    local instance
    local firstInstance
    for obj, prop in pairs(Table) do
        pcall(function()
            if prop.ClassName ~= "MeshPart" then
                instance = Instance.new(prop.ClassName)
                pcall(function()
                    instance.Anchored = true
                end)
                instance.Name = obj
                InstancesTable[obj] = instance
                SetSettings(instance, prop)
            else
                local part = Instance.new("Part")
                instance = Instance.new("SpecialMesh")
                InstancesTable[obj] = part
                SetSettings(part, prop)
                SetSettings(instance, prop)
                instance.Name = "ParentTo-"..obj
                table.insert(SpecialMeshes, instance)
            end
        end)
        if instance.Name:sub(1,2) == "1_" then firstInstance = instance end
    end
    Assemble()
    for _, v in pairs(SpecialMeshes) do
        v.Parent = InstancesTable[string.split(v.Name, "-")[2]]
    end
    for _, v in pairs(InstancesTable) do
        v.Name = table.concat({table.unpack(string.split(v.Name,"_"),2)}, "_")
        pcall(function()
            v.Anchored = true
        end)
    end
    for _, v in pairs(firstInstance:GetDescendants()) do
        if v:IsA("ParticleEmitter") then v.Enabled = false end
    end
    return firstInstance
end
return module
