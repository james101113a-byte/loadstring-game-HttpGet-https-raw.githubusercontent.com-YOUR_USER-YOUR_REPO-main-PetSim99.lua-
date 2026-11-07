-- PetSim99.lua
-- Pixie menu for Pet Simulator 99, built on the KittenHub UI library (inlined).

local KittenHub = (function()
--!strict
-- KittenHub UI Library
-- Monochrome Roblox UI inspired by Project Real's visual language.

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ContentProvider = game:GetService("ContentProvider")

local LocalPlayer = Players.LocalPlayer

local KittenHub = {}
KittenHub.Version = "0.6.2"
KittenHub.AssetId = "rbxassetid://102065448126548"
KittenHub.DefaultAssets = {
	Logo = "rbxassetid://102065448126548",
	Paw = "rbxassetid://131136157222328",
	Heart = "rbxassetid://107252414250704",
	Sleeping = "rbxassetid://112356892711029",
	Peek = "rbxassetid://133697879389288",
	Curled = "rbxassetid://101414414893719",
	DarkCat = "rbxassetid://118910476036241",
	DropdownCat = "rbxassetid://98425969504037",
	Sparkles = "rbxassetid://114850152769331",
	Home = "rbxassetid://118174015024924",
	Plus = "rbxassetid://98329354716868",
	Players = "rbxassetid://125376145853165",
	Settings = "rbxassetid://87200505076227",
	Bell = "rbxassetid://80479928306450",
	Unload = "rbxassetid://93174476369835",
	ToggleUI = "rbxassetid://94264300792153",
	CrossedRifles = "rbxassetid://130005119002593",
	Shield = "rbxassetid://72509035967594",
	Horse = "rbxassetid://99101952385157",
	Gun = "rbxassetid://72587317513615",
	Money = "rbxassetid://117009994405006",
	MoneyBag = "rbxassetid://117403966034571",
	Bear = "rbxassetid://100189939993137",
	Bison = "rbxassetid://139284799775207",
	Gator = "rbxassetid://119651820074451",
}

KittenHub.AssetScales = {
	[KittenHub.DefaultAssets.CrossedRifles] = 1.45,
	[KittenHub.DefaultAssets.Horse] = 1.45,
	[KittenHub.DefaultAssets.Gun] = 1.45,
	[KittenHub.DefaultAssets.Money] = 1.45,
	[KittenHub.DefaultAssets.MoneyBag] = 1.45,
	[KittenHub.DefaultAssets.Bear] = 1.2,
	[KittenHub.DefaultAssets.Bison] = 1.2,
	[KittenHub.DefaultAssets.Gator] = 1.2,
}

local function font(family: string, weight: Enum.FontWeight, fallback: string): Font
	local ok, value = pcall(Font.new, "rbxasset://fonts/families/" .. family .. ".json", weight)
	if ok and value then
		return value
	end
	warn("[Pixie] Font family unavailable:", family, "- falling back to", fallback)
	return Font.new("rbxasset://fonts/families/" .. fallback .. ".json", weight)
end

local Fonts = {
	Display = font("FredokaOne", Enum.FontWeight.Regular, "SourceSansPro"),
	Body = font("Nunito", Enum.FontWeight.Medium, "BuilderSans"),
	Medium = font("Nunito", Enum.FontWeight.SemiBold, "BuilderSans"),
	Semibold = font("Nunito", Enum.FontWeight.Bold, "BuilderSans"),
	Bold = font("Nunito", Enum.FontWeight.ExtraBold, "BuilderSans"),
	Value = font("Nunito", Enum.FontWeight.Bold, "BuilderSans"),
	Mono = font("BuilderMono", Enum.FontWeight.Medium, "RobotoMono"),
}

local Line = {
	Window = 0.46,
	Panel = 0.52,
	Card = 0.56,
	Control = 0.5,
	Tile = 0.54,
	Popup = 0.44,
	Inner = 0.78,
	TabSelected = 0.54,
}

local MAX_NOTIFICATIONS = 5
local DROPDOWN_OPTION_HEIGHT = 40
local DROPDOWN_OPTION_PADDING = 4
local DROPDOWN_SEARCH_HEIGHT = 34
local DROPDOWN_MAX_LIST_HEIGHT = 246
local FALLBACK_GLYPH_DELAY = 12

local Theme = {
	Background = Color3.fromRGB(10, 11, 12),
	Surface = Color3.fromRGB(28, 29, 32),
	SurfaceHover = Color3.fromRGB(45, 46, 50),
	Selected = Color3.fromRGB(60, 61, 66),
	Border = Color3.fromRGB(186, 188, 196),
	Divider = Color3.fromRGB(76, 78, 84),
	Text = Color3.fromRGB(244, 244, 245),
	MutedText = Color3.fromRGB(188, 188, 194),
	FaintText = Color3.fromRGB(113, 113, 122),
	Accent = Color3.fromRGB(255, 255, 255),
	AccentSoft = Color3.fromRGB(222, 222, 226),
	Track = Color3.fromRGB(74, 75, 80),
	Danger = Color3.fromRGB(196, 72, 78),
	Shadow = Color3.fromRGB(0, 0, 0),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	Fonts = Fonts,
}

local function create(className: string, properties: {[string]: any}?, children: {Instance}?): Instance
	local object = Instance.new(className)
	if object:IsA("GuiBase2d") then
		(object :: any).AutoLocalize = false
	end
	local parent: Instance? = nil
	for property, value in pairs(properties or {}) do
		if property == "Parent" then
			parent = value
		else
			(object :: any)[property] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = object
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local Supports = {
	InnerStroke = (function(): boolean
		local ok = pcall(function()
			local probe = Instance.new("UIStroke")
			probe.BorderStrokePosition = Enum.BorderStrokePosition.Inner
			probe:Destroy()
		end)
		return ok
	end)(),
	Shadow = (function(): boolean
		local ok = pcall(function()
			Instance.new("UIShadow"):Destroy()
		end)
		return ok
	end)(),
}

local function corner(radius: number): UICorner
	return create("UICorner", { CornerRadius = UDim.new(0, radius) }) :: UICorner
end

local function dropShadow(parent: GuiObject, blur: number, spread: number, transparency: number, offsetY: number): Instance?
	if not Supports.Shadow then
		return nil
	end
	return create("UIShadow", {
		BlurRadius = UDim.new(0, blur),
		Spread = UDim2.fromOffset(spread, spread),
		Offset = UDim2.fromOffset(0, offsetY),
		Color = Theme.Shadow,
		Transparency = transparency,
		Parent = parent,
	})
end

local function stroke(color: Color3?, transparency: number?, lit: boolean?): UIStroke
	local base = color or Theme.Border
	local alpha = transparency or 0
	local instance = create("UIStroke", {
		Color = lit and Theme.White or base,
		Thickness = 1,
		Transparency = lit and 0 or alpha,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}) :: UIStroke

	if Supports.InnerStroke then
		instance.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	end

	if lit then
		create("UIGradient", {
			Rotation = 90,
			Color = ColorSequence.new(base, base),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, alpha),
				NumberSequenceKeypoint.new(0.55, math.clamp(alpha + 0.18, 0, 1)),
				NumberSequenceKeypoint.new(1, math.clamp(alpha + 0.3, 0, 1)),
			}),
			Parent = instance,
		})
	end

	return instance
end

local function padding(top: number, right: number, bottom: number, left: number): UIPadding
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingRight = UDim.new(0, right),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
	}) :: UIPadding
end

local function listLayout(paddingAmount: number): UIListLayout
	return create("UIListLayout", {
		Padding = UDim.new(0, paddingAmount),
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
	}) :: UIListLayout
end

local function gradient(topColor: Color3, bottomColor: Color3, rotation: number?): UIGradient
	return create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, topColor),
			ColorSequenceKeypoint.new(1, bottomColor),
		}),
		Rotation = rotation or 90,
	}) :: UIGradient
end

local function separatorLine(parent: Instance, y: number | UDim, left: number, right: number)
	local offsetY: UDim = if typeof(y) == "UDim" then y else UDim.new(0, y :: number)
	return create("Frame", {
		Name = "Divider",
		AnchorPoint = Vector2.new(0, offsetY.Scale),
		Position = UDim2.new(0, left, offsetY.Scale, offsetY.Offset),
		Size = UDim2.new(1, -(left + right), 0, 1),
		BackgroundColor3 = Theme.Divider,
		BackgroundTransparency = 0,
		BorderSizePixel = 0,
		LayoutOrder = 1,
		Parent = parent,
	}) :: Frame
end

local preloadQueue: {Instance} = {}
local preloadRunning = false
local warnedAssets: {[string]: boolean} = {}
local preloadCallbacks: {() -> ()} = {}
local assetFetchStatus: {[string]: EnumItem} = {}

local function fetchStatusSaysLoaded(imageId: string): boolean
	local status = assetFetchStatus[imageId]
	return status ~= nil and status == Enum.AssetFetchStatus.Success
end

local function queuePreload(instance: Instance, onSettled: () -> ())
	table.insert(preloadQueue, instance)
	table.insert(preloadCallbacks, onSettled)
	if preloadRunning then
		return
	end
	preloadRunning = true
	task.defer(function()
		while #preloadQueue > 0 do
			local batch = preloadQueue
			local callbacks = preloadCallbacks
			preloadQueue = {}
			preloadCallbacks = {}
			local reported = pcall(function()
				ContentProvider:PreloadAsync(batch, function(contentId, status)
					if type(contentId) == "string" then
						assetFetchStatus[contentId] = status
					end
				end)
			end)
			if not reported then
				pcall(function()
					ContentProvider:PreloadAsync(batch)
				end)
			end
			for _, callback in ipairs(callbacks) do
				pcall(callback)
			end
		end
		preloadRunning = false
	end)
end

type FallbackEntry = {
	Image: ImageLabel,
	Fallback: TextLabel,
	Id: string,
	Start: number,
}

local pendingFallbacks: {FallbackEntry} = {}
local fallbackWatcherRunning = false

local function isRendered(element: GuiObject): boolean
	local current: Instance? = element
	while current and not current:IsA("ScreenGui") do
		if current:IsA("GuiObject") and not current.Visible then
			return false
		end
		current = current.Parent
	end
	if current and current:IsA("ScreenGui") and not current.Enabled then
		return false
	end
	return current ~= nil
end

local function imageHasContent(image: ImageLabel): boolean
	if image.IsLoaded then
		return true
	end
	if fetchStatusSaysLoaded(image.Image) then
		return true
	end
	local ok, size = pcall(function()
		return image.ContentImageSize
	end)
	return ok and typeof(size) == "Vector2" and size.Magnitude > 0
end

local FALLBACK_GLYPH_GIVE_UP = 30

local function runFallbackWatcher()
	if fallbackWatcherRunning then
		return
	end
	fallbackWatcherRunning = true
	task.spawn(function()
		while #pendingFallbacks > 0 do
			local now = os.clock()
			for index = #pendingFallbacks, 1, -1 do
				local entry = pendingFallbacks[index]
				local image = entry.Image
				local done = false

				if not image.Parent then
					done = true
				elseif imageHasContent(image) then
					if entry.Fallback.Parent then
						entry.Fallback.Visible = false
					end
					done = true
				elseif not isRendered(image) then
					if entry.Fallback.Parent and entry.Fallback.Visible then
						entry.Fallback.Visible = false
					end
					entry.Start = now
				else
					local elapsed = now - entry.Start
					if elapsed > FALLBACK_GLYPH_DELAY then
						if entry.Fallback.Parent and not entry.Fallback.Visible then
							entry.Fallback.Visible = true
						end
						if not warnedAssets[entry.Id] then
							warnedAssets[entry.Id] = true
							warn("[Pixie] Image asset still not loaded after", FALLBACK_GLYPH_DELAY .. "s:", entry.Id)
						end
					end
					if elapsed > FALLBACK_GLYPH_GIVE_UP then
						if entry.Fallback.Parent then
							entry.Fallback.Visible = false
						end
						done = true
					end
				end

				if done then
					table.remove(pendingFallbacks, index)
				end
			end
			task.wait(1)
		end
		fallbackWatcherRunning = false
	end)
end

local function watchFallback(image: ImageLabel, fallback: TextLabel, imageId: string)
	table.insert(pendingFallbacks, {
		Image = image,
		Fallback = fallback,
		Id = imageId,
		Start = os.clock(),
	})
	runFallbackWatcher()
end

local function imageOrGlyph(parent: Instance, sourceProperties: {[string]: any}, imageId: string?, glyph: string): GuiObject
	local properties: {[string]: any} = {}
	for key, value in pairs(sourceProperties) do
		properties[key] = value
	end

	if imageId and imageId ~= "" then
		local fallbackProperties = {
			Name = (properties.Name or "Image") .. "Fallback",
			AnchorPoint = properties.AnchorPoint or Vector2.zero,
			Position = properties.Position or UDim2.fromOffset(0, 0),
			Size = properties.Size or UDim2.fromScale(1, 1),
			Rotation = properties.Rotation or 0,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			FontFace = Fonts.Display,
			Text = glyph,
			TextColor3 = Theme.FaintText,
			TextTransparency = properties.TextTransparency or 0,
			TextSize = properties.TextSize or 18,
			TextXAlignment = properties.TextXAlignment or Enum.TextXAlignment.Center,
			TextYAlignment = properties.TextYAlignment or Enum.TextYAlignment.Center,
			Visible = false,
			ZIndex = properties.ZIndex or 1,
			Parent = parent,
		}
		properties.TextTransparency = nil
		properties.TextSize = nil
		properties.TextXAlignment = nil
		properties.TextYAlignment = nil
		properties.TextColor3 = nil
		properties.FontFace = nil
		properties.TextWrapped = nil
		properties.Image = imageId
		properties.ScaleType = properties.ScaleType or Enum.ScaleType.Fit
		properties.BackgroundTransparency = 1
		properties.Parent = parent
		local assetScale = KittenHub.AssetScales[imageId]
		if assetScale then
			local size = properties.Size or UDim2.fromScale(1, 1)
			local position = properties.Position or UDim2.fromOffset(0, 0)
			local anchor = properties.AnchorPoint or Vector2.zero
			properties.AnchorPoint = Vector2.new(0.5, 0.5)
			properties.Position = UDim2.new(
				position.X.Scale + size.X.Scale * (0.5 - anchor.X),
				position.X.Offset + size.X.Offset * (0.5 - anchor.X),
				position.Y.Scale + size.Y.Scale * (0.5 - anchor.Y),
				position.Y.Offset + size.Y.Offset * (0.5 - anchor.Y)
			)
		end

		local image = create("ImageLabel", properties) :: ImageLabel
		if assetScale then
			create("UIScale", { Scale = assetScale, Parent = image })
		end
		if glyph and glyph ~= "" then
			local fallback = create("TextLabel", fallbackProperties) :: TextLabel

			local function hideFallbackIfLoaded()
				if fallback.Parent and imageHasContent(image) then
					fallback.Visible = false
				end
			end
			image:GetPropertyChangedSignal("IsLoaded"):Connect(hideFallbackIfLoaded)
			queuePreload(image, hideFallbackIfLoaded)
			watchFallback(image, fallback, imageId)
		end
		return image
	end
	properties.ImageTransparency = nil
	properties.ImageColor3 = nil
	properties.ScaleType = nil
	properties.BackgroundTransparency = 1
	properties.BorderSizePixel = 0
	properties.FontFace = Fonts.Display
	properties.Text = glyph
	properties.TextColor3 = Theme.FaintText
	properties.TextTransparency = properties.TextTransparency or 0
	properties.Parent = parent
	return create("TextLabel", properties) :: TextLabel
end

local function spriteOrGlyph(parent: Instance, properties: {[string]: any}, assets: {[string]: any}, role: string, glyph: string): GuiObject
	local direct = assets[role]
	if not direct and role == "Logo" then
		direct = assets.Logo or assets.RowIcon
	elseif not direct and role == "Curled" then
		direct = assets.RowIcon
	elseif not direct and role == "Sleeping" then
		direct = assets.CornerCat
	end
	return imageOrGlyph(parent, properties, direct, glyph)
end

local function addSoftPattern(parent: Instance, assets: {[string]: any})
	local marks = {
		{0.10, 0.63, 20, 0.93}, {0.31, 0.87, 16, 0.94}, {0.55, 0.74, 22, 0.93},
		{0.86, 0.66, 18, 0.94}, {0.93, 0.91, 14, 0.95},
	}
	for index, mark in ipairs(marks) do
		local item = spriteOrGlyph(parent, {
			Name = "Pattern" .. index,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(mark[1], mark[2]),
			Size = UDim2.fromOffset(mark[3], mark[3]),
			ImageTransparency = mark[4],
			TextTransparency = mark[4],
			TextSize = mark[3],
			ZIndex = 1,
		}, assets, "Paw", "*")
		item.Rotation = (index % 2 == 0) and 12 or -10
	end
end

local function label(properties: {[string]: any}): TextLabel
	local defaults = {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Fonts.Body,
		TextColor3 = Theme.Text,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	for key, value in pairs(properties) do
		defaults[key] = value
	end
	return create("TextLabel", defaults) :: TextLabel
end

local function button(properties: {[string]: any}, children: {Instance}?): TextButton
	local defaults = {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = Fonts.Body,
		Text = "",
		TextColor3 = Theme.Text,
		TextSize = 15,
	}
	for key, value in pairs(properties) do
		defaults[key] = value
	end
	return create("TextButton", defaults, children) :: TextButton
end

local function decimalPlaces(value: number): number
	local text = tostring(value)
	if string.find(text, "e", 1, true) or string.find(text, "inf", 1, true) then
		return 0
	end
	local point = string.find(text, ".", 1, true)
	if not point then
		return 0
	end
	return #text - point
end

local function snapToIncrement(value: number, minimum: number, increment: number): number
	if increment <= 0 then
		return value
	end
	local steps = math.floor(((value - minimum) / increment) + 0.5)
	local snapped = minimum + (steps * increment)
	local places = math.max(decimalPlaces(increment), decimalPlaces(minimum))
	if places > 0 then
		return tonumber(string.format("%." .. places .. "f", snapped)) or snapped
	end
	return snapped
end

local function tween(instance: Instance, duration: number, properties: {[string]: any})
	TweenService:Create(instance, TweenInfo.new(duration, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), properties):Play()
end

local function safeCallback(callback: ((...any) -> ())?, ...: any)
	if not callback then
		return
	end
	task.spawn(function(...)
		local ok, message = pcall(callback :: any, ...)
		if not ok then
			warn("[Pixie] Callback error:", message)
		end
	end, ...)
end

local function getParent(): Instance
	local ok, hiddenUi = pcall(function()
		if typeof(gethui) == "function" then
			return gethui()
		end
		return nil
	end)
	if ok and hiddenUi then
		return hiddenUi
	end
	return game:GetService("CoreGui")
end

local function isPressInput(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMoveInput(input: InputObject): boolean
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local function fireInputHandlers(handlers: {(InputObject, boolean) -> ()}, input: InputObject, processed: boolean)
	for _, handler in ipairs(handlers) do
		local ok, message = pcall(handler, input, processed)
		if not ok then
			warn("[Pixie] Input handler error:", message)
		end
	end
end

local function disconnectAll(connections: {RBXScriptConnection})
	for _, connection in ipairs(connections) do
		if connection.Connected then
			connection:Disconnect()
		end
	end
	table.clear(connections)
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods

local TabMethods = {}
TabMethods.__index = TabMethods

local SectionMethods = {}
SectionMethods.__index = SectionMethods

local function makeDraggable(window: any, handle: GuiObject, target: GuiObject)
	local dragging = false
	local dragStart = Vector2.zero
	local startPosition = target.Position
	local shadowStart = window._shadow and window._shadow.Position or nil

	table.insert(window._connections, handle.InputBegan:Connect(function(input)
		if isPressInput(input) then
			dragging = true
			dragStart = input.Position
			startPosition = target.Position
			shadowStart = window._shadow and window._shadow.Position or nil
		end
	end))

	table.insert(window._inputEnded, function(input)
		if isPressInput(input) then
			dragging = false
		end
	end)

	table.insert(window._inputChanged, function(input)
		if not dragging or not isMoveInput(input) then
			return
		end
		local delta = input.Position - dragStart
		target.Position = UDim2.new(
			startPosition.X.Scale,
			startPosition.X.Offset + delta.X,
			startPosition.Y.Scale,
			startPosition.Y.Offset + delta.Y
		)
		if window._shadow and shadowStart then
			window._shadow.Position = UDim2.new(
				shadowStart.X.Scale,
				shadowStart.X.Offset + delta.X,
				shadowStart.Y.Scale,
				shadowStart.Y.Offset + delta.Y
			)
		end
	end)
end

local function updateResponsiveScale(window: any)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local usableWidth = math.max(viewport.X - 40, 320)
	local usableHeight = math.max(viewport.Y - 40, 240)
	local scale = math.min(window._designScale, usableWidth / window._baseSize.X, usableHeight / window._baseSize.Y)
	window._uiScale.Scale = math.clamp(scale, 0.48, 1)
	if window._shadow then
		window._shadow.Size = UDim2.fromOffset((window._baseSize.X + 18) * scale, (window._baseSize.Y + 18) * scale)
	end
	window:ClosePopups()
end

function KittenHub:CreateWindow(options: {[string]: any}?)
	options = options or {}
	local baseSize = options.Size or Vector2.new(1280, 760)
	local designScale = options.Scale or 0.78
	local title = options.Title or "Pixie"
	local toggleKey = options.ToggleKey or Enum.KeyCode.RightShift
	local assets = options.Assets or {}
	assets.Logo = assets.Logo or options.Icon or KittenHub.DefaultAssets.Logo
	for role, id in pairs(KittenHub.DefaultAssets) do
		if assets[role] == nil then
			assets[role] = id
		end
	end
	assets.RowIcon = assets.RowIcon or assets.Logo

	local existing = getParent():FindFirstChild("PixieUI")
	if existing then
		existing:Destroy()
	end

	local screenGui = create("ScreenGui", {
		Name = "PixieUI",
		DisplayOrder = 999,
		IgnoreGuiInset = true,
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = getParent(),
	}) :: ScreenGui

	local shadow: Frame? = nil
	if not Supports.Shadow then
		shadow = create("Frame", {
			Name = "WindowShadow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 8),
			Size = UDim2.fromOffset(baseSize.X + 18, baseSize.Y + 18),
			BackgroundColor3 = Theme.Shadow,
			BackgroundTransparency = 0.6,
			BorderSizePixel = 0,
			Parent = screenGui,
		}, { corner(24) }) :: Frame
	end

	local root = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(baseSize.X, baseSize.Y),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = screenGui,
	}, {
		corner(18),
		stroke(Theme.Border, Line.Window, true),
		gradient(Color3.fromRGB(16, 17, 19), Color3.fromRGB(8, 9, 10), 115),
	}) :: Frame
	dropShadow(root, 54, 6, 0.34, 14)
	addSoftPattern(root, assets)

	local uiScale = create("UIScale", { Scale = 1, Parent = root }) :: UIScale

	local topbar = create("Frame", {
		Name = "Topbar",
		Size = UDim2.new(1, 0, 0, 94),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = root,
	}) :: Frame

	create("Frame", {
		Name = "TopDivider",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 306, 1, 0),
		Size = UDim2.new(1, -320, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		Parent = topbar,
	})

	local brand = create("Frame", {
		Name = "Brand",
		Size = UDim2.fromOffset(306, 94),
		BackgroundTransparency = 1,
		Parent = topbar,
	}) :: Frame

	spriteOrGlyph(brand, {
		Name = "KittenIcon",
		Position = UDim2.fromOffset(24, 22),
		Size = UDim2.fromOffset(52, 52),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 28,
	}, assets, "Logo", "*")

	label({
		Name = "Title",
		Position = UDim2.fromOffset(86, 0),
		Size = UDim2.new(1, -98, 1, 0),
		FontFace = Fonts.Display,
		Text = title,
		TextSize = 34,
		Parent = brand,
	})
	spriteOrGlyph(brand, {
		Name = "BrandPaw",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 2),
		Size = UDim2.fromOffset(30, 30),
		TextSize = 21,
		ImageTransparency = 0.08,
		TextTransparency = 0.08,
	}, assets, "Paw", "*")
	spriteOrGlyph(brand, {
		Name = "BrandSparkles",
		Position = UDim2.fromOffset(12, 6),
		Size = UDim2.fromOffset(26, 22),
		ImageTransparency = 0.12,
		TextTransparency = 0.12,
		TextSize = 17,
		ZIndex = 5,
	}, assets, "Sparkles", "*")

	local windowControls = create("Frame", {
		Name = "WindowControls",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.fromOffset(132, 94),
		BackgroundTransparency = 1,
		Parent = topbar,
	}) :: Frame

	create("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 4),
		Parent = windowControls,
	})

	local minimize, maximize, close
	local controlParts: {{ Plate: Frame, Icon: Frame, Danger: boolean }} = {}
	do
		local function controlButton(name: string, order: number, danger: boolean?)
			local hit = button({
				Name = name,
				Size = UDim2.fromOffset(34, 34),
				BackgroundTransparency = 1,
				Text = "",
				LayoutOrder = order,
				Parent = windowControls,
			}, { corner(10) })

			local plate = create("Frame", {
				Name = "Plate",
				Size = UDim2.fromScale(1, 1),
				BackgroundColor3 = danger and Theme.Danger or Theme.SurfaceHover,
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = hit,
			}, { corner(10) }) :: Frame

			local icon = create("Frame", {
				Name = "Icon",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromOffset(12, 12),
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Parent = hit,
			}) :: Frame

			table.insert(controlParts, { Plate = plate, Icon = icon, Danger = danger == true })
			return hit, plate, icon
		end

		local function bar(parent: Instance, position: UDim2, size: UDim2, rotation: number?)
			return create("Frame", {
				Position = position,
				Size = size,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Rotation = rotation or 0,
				BackgroundColor3 = Theme.MutedText,
				BorderSizePixel = 0,
				Parent = parent,
			}, { corner(1) }) :: Frame
		end

		local minimizeIcon, maximizeIcon, closeIcon
		minimize, _, minimizeIcon = controlButton("Minimize", 1)
		bar(minimizeIcon, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(12, 2))

		maximize, _, maximizeIcon = controlButton("Center", 2)
		create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(11, 11),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = maximizeIcon,
		}, { corner(3), stroke(Theme.MutedText, 0) })

		close, _, closeIcon = controlButton("Close", 3, true)
		bar(closeIcon, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(13, 2), 45)
		bar(closeIcon, UDim2.fromScale(0.5, 0.5), UDim2.fromOffset(13, 2), -45)
	end

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(14, 164),
		Size = UDim2.new(0, 276, 1, -178),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = root,
	}, {
		corner(20),
		stroke(Theme.Border, Line.Panel, true),
		gradient(Color3.fromRGB(36, 37, 41), Color3.fromRGB(20, 21, 23), 110),
	}) :: Frame
	dropShadow(sidebar, 26, 0, 0.55, 8)
	addSoftPattern(sidebar, assets)
	spriteOrGlyph(root, {
		Name = "SidebarPeek",
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromOffset(152, 170),
		Size = UDim2.fromOffset(150, 88),
		TextSize = 30,
		ImageTransparency = 0,
		TextTransparency = 0,
		ZIndex = 5,
	}, assets, "Peek", "")

	create("Frame", {
		Name = "SidebarDivider",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 1, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	local tabList = create("ScrollingFrame", {
		Name = "TabList",
		Position = UDim2.fromOffset(12, 30),
		Size = UDim2.new(1, -24, 1, -150),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Border,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = sidebar,
	}, { listLayout(7), padding(0, 3, 0, 3) }) :: ScrollingFrame

	local footer = create("Frame", {
		Name = "Footer",
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 12, 1, -12),
		Size = UDim2.new(1, -24, 0, 86),
		BackgroundColor3 = Theme.SurfaceHover,
		BorderSizePixel = 0,
		Parent = sidebar,
	}, { corner(17), stroke(Theme.Border, Line.Panel, true) }) :: Frame
	dropShadow(footer, 16, 0, 0.6, 5)

	spriteOrGlyph(footer, {
		Name = "Avatar",
		Position = UDim2.fromOffset(12, 14),
		Size = UDim2.fromOffset(58, 58),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 26,
	}, assets, "Logo", "*")

	label({
		Position = UDim2.fromOffset(82, 14),
		Size = UDim2.new(1, -112, 0, 28),
		FontFace = Fonts.Bold,
		Text = options.UserName or (LocalPlayer and LocalPlayer.DisplayName) or "Player",
		TextSize = 17,
		Parent = footer,
	})
	label({
		Name = "FooterStatus",
		Position = UDim2.fromOffset(82, 43),
		Size = UDim2.new(1, -112, 0, 24),
		FontFace = Fonts.Medium,
		Text = options.UserStatus or ("Pixie v" .. KittenHub.Version),
		TextColor3 = Theme.MutedText,
		TextSize = 14,
		Parent = footer,
	})

	local content = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(306, 76),
		Size = UDim2.new(1, -320, 1, -90),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = root,
	}, {
		corner(20),
		stroke(Theme.Border, Line.Panel, true),
		gradient(Color3.fromRGB(36, 37, 41), Color3.fromRGB(19, 20, 22), 105),
	}) :: Frame
	dropShadow(content, 26, 0, 0.55, 8)
	local contentFooterLine = separatorLine(content, UDim.new(1, -30), 0, 0)
	spriteOrGlyph(contentFooterLine, {
		Name = "FooterHeart",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(26, 24),
		ImageTransparency = 0.25,
		TextTransparency = 0.25,
		TextSize = 16,
		ZIndex = 3,
	}, assets, "Heart", "*")
	spriteOrGlyph(root, {
		Name = "BottomPaw",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, 8, 1, 8),
		Size = UDim2.fromOffset(72, 72),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 28,
		Rotation = -18,
		ZIndex = 4,
	}, assets, "Paw", "*")
	spriteOrGlyph(content, {
		Name = "CornerMascot",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -20, 0, 22),
		Size = UDim2.fromOffset(142, 82),
		TextSize = 26,
		ImageTransparency = 0,
		TextTransparency = 0.18,
		ZIndex = 4,
	}, assets, "Sleeping", "*")

	local pages = create("Frame", {
		Name = "Pages",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ZIndex = 2,
		Parent = content,
	}) :: Frame

	local overlay = create("Frame", {
		Name = "Overlay",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 40,
		Parent = screenGui,
	}) :: Frame

	local window = setmetatable({
		Gui = screenGui,
		Root = root,
		Overlay = overlay,
		_shadow = shadow,
		Sidebar = sidebar,
		TabList = tabList,
		Pages = pages,
		Theme = Theme,
		Assets = assets,
		Tabs = {},
		Flags = {},
		_connections = {},
		_inputBegan = {},
		_inputChanged = {},
		_inputEnded = {},
		_popups = {},
		PageTitle = options.PageTitle,
		_baseSize = baseSize,
		_designScale = math.clamp(designScale, 0.48, 1),
		_uiScale = uiScale,
		_selectedTab = nil,
		_visible = true,
		_minimized = false,
		_destroyed = false,
	}, WindowMethods)

	table.insert(window._connections, UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == toggleKey then
			window:Toggle()
		end
		fireInputHandlers(window._inputBegan, input, processed)
	end))
	table.insert(window._connections, UserInputService.InputChanged:Connect(function(input, processed)
		fireInputHandlers(window._inputChanged, input, processed)
	end))
	table.insert(window._connections, UserInputService.InputEnded:Connect(function(input, processed)
		fireInputHandlers(window._inputEnded, input, processed)
	end))

	makeDraggable(window, topbar, root)
	updateResponsiveScale(window)

	if workspace.CurrentCamera then
		table.insert(window._connections, workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
			updateResponsiveScale(window)
		end))
	end

	local collapsibles: {GuiObject} = { sidebar, content }
	for _, child in ipairs(root:GetChildren()) do
		if child:IsA("GuiObject") and child ~= topbar and child ~= sidebar and child ~= content then
			table.insert(collapsibles, child)
		end
	end

	local collapseToken = 0
	table.insert(window._connections, minimize.MouseButton1Click:Connect(function()
		window:ClosePopups()
		window._minimized = not window._minimized
		local minimized = window._minimized
		collapseToken += 1
		local token = collapseToken

		if minimized then
			for _, element in ipairs(collapsibles) do
				element.Visible = false
			end
		end
		tween(root, 0.25, {
			Size = UDim2.fromOffset(baseSize.X, minimized and 76 or baseSize.Y),
		})
		if not minimized then
			task.delay(0.18, function()
				if token ~= collapseToken or window._destroyed then
					return
				end
				for _, element in ipairs(collapsibles) do
					element.Visible = true
				end
			end)
		end
		if shadow then
			shadow.Visible = not minimized
		end
	end))

	table.insert(window._connections, maximize.MouseButton1Click:Connect(function()
		root.Position = UDim2.fromScale(0.5, 0.5)
		if shadow then
			shadow.Position = UDim2.new(0.5, 0, 0.5, 8)
		end
		updateResponsiveScale(window)
	end))

	table.insert(window._connections, close.MouseButton1Click:Connect(function()
		window:Destroy()
	end))

	for index, control in ipairs({ minimize, maximize, close }) do
		local parts = controlParts[index]
		local function paint(hovered: boolean)
			tween(parts.Plate, 0.14, { BackgroundTransparency = hovered and 0.12 or 1 })
			local tint = hovered and (parts.Danger and Theme.White or Theme.Text) or Theme.MutedText
			for _, piece in ipairs(parts.Icon:GetChildren()) do
				if piece:IsA("Frame") then
					tween(piece, 0.14, { BackgroundColor3 = tint })
					local pieceStroke = piece:FindFirstChildOfClass("UIStroke")
					if pieceStroke then
						tween(pieceStroke, 0.14, { Color = tint })
					end
				end
			end
		end
		table.insert(window._connections, control.MouseEnter:Connect(function()
			paint(true)
		end))
		table.insert(window._connections, control.MouseLeave:Connect(function()
			paint(false)
		end))
	end

	return window
end

function WindowMethods:Toggle(force: boolean?)
	if self._destroyed then
		return
	end
	if force == nil then
		self._visible = not self._visible
	else
		self._visible = force
	end
	if not self._visible then
		self:ClosePopups()
	end
	self.Gui.Enabled = self._visible
end

function WindowMethods:ClosePopups(except: any?)
	for _, popup in ipairs(self._popups) do
		if popup ~= except then
			popup.Close()
		end
	end
end

function WindowMethods:Notify(options: {[string]: any}?)
	if self._destroyed then
		return
	end
	options = options or {}

	local holder = self.Gui:FindFirstChild("Notifications") :: Frame?
	if not holder then
		holder = create("Frame", {
			Name = "Notifications",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -22, 1, -22),
			Size = UDim2.fromOffset(330, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = 50,
			Parent = self.Gui,
		}, {
			create("UIListLayout", {
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = UDim.new(0, 9),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}) :: UIListLayout,
		}) :: Frame
	end

	local liveSlots = {}
	for _, child in ipairs((holder :: Frame):GetChildren()) do
		if child:IsA("Frame") then
			table.insert(liveSlots, child)
		end
	end
	for index = 1, #liveSlots - (MAX_NOTIFICATIONS - 1) do
		liveSlots[index]:Destroy()
	end

	local slot = create("Frame", {
		Name = "NotificationSlot",
		Size = UDim2.fromOffset(330, 86),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 51,
		Parent = holder,
	}) :: Frame
	local notification = create("Frame", {
		Name = "Notification",
		Position = UDim2.fromOffset(38, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		ZIndex = 52,
		Parent = slot,
	}, {
		corner(14),
		stroke(Theme.Border, Line.Popup, true),
		gradient(Color3.fromRGB(52, 53, 58), Color3.fromRGB(28, 29, 32), 105),
	}) :: Frame
	create("Frame", {
		Name = "InnerBorder",
		Position = UDim2.fromOffset(4, 4),
		Size = UDim2.new(1, -8, 1, -8),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ZIndex = 53,
		Parent = notification,
	}, { corner(11), stroke(Theme.Border, Line.Inner) })
	local iconTile = create("Frame", {
		Name = "IconTile",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		ZIndex = 54,
		Parent = notification,
	}, { corner(12), stroke(Theme.Border, Line.Tile, true) }) :: Frame
	spriteOrGlyph(iconTile, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(38, 34),
		ImageTransparency = 0,
		TextTransparency = 0,
		TextSize = 20,
		ZIndex = 55,
	}, self.Assets, "Logo", "*")
	label({
		Name = "Title",
		Position = UDim2.fromOffset(72, 9),
		Size = UDim2.new(1, -158, 0, 27),
		FontFace = Fonts.Bold,
		Text = options.Title or "Pixie",
		TextSize = 16,
		ZIndex = 55,
		Parent = notification,
	})
	label({
		Name = "Content",
		Position = UDim2.fromOffset(72, 36),
		Size = UDim2.new(1, -158, 0, 39),
		Text = options.Content or "Notification",
		TextColor3 = Theme.MutedText,
		TextSize = 12,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
		ZIndex = 55,
		Parent = notification,
	})
	local dismissButton = button({
		Name = "Dismiss",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		ZIndex = 57,
		Parent = notification,
	})

	local closing = false
	local dismissConnection: RBXScriptConnection? = nil
	local function dismiss()
		if closing or not slot.Parent then
			return
		end
		closing = true
		if dismissConnection then
			dismissConnection:Disconnect()
			dismissConnection = nil
		end
		tween(notification, 0.25, { Position = UDim2.fromOffset(350, 0) })
		task.delay(0.27, function()
			if slot.Parent then
				slot:Destroy()
			end
		end)
	end
	dismissConnection = dismissButton.MouseButton1Click:Connect(dismiss)
	slot.Destroying:Connect(function()
		if dismissConnection then
			dismissConnection:Disconnect()
			dismissConnection = nil
		end
	end)
	tween(notification, 0.3, { Position = UDim2.fromOffset(0, 0) })
	task.delay(options.Duration or 4, dismiss)
end

function WindowMethods:AddTab(options: any)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local tabName = options.Name or "New Tab"
	local tabIcon = options.Icon or "*"
	local tabIconRole = options.IconRole
	local order = #self.Tabs + 1
	local pageTitle = options.PageTitle or (order == 1 and self.PageTitle) or tabName
	local tabStroke = stroke(Theme.Border, 1)

	local tabButton = button({
		Name = tabName,
		Size = UDim2.new(1, 0, 0, 66),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 1,
		Text = "",
		LayoutOrder = order,
		Parent = self.TabList,
	}, {
		corner(14),
		tabStroke,
		gradient(Color3.fromRGB(64, 65, 71), Color3.fromRGB(36, 37, 41), 100),
	})

	local tabIconImage = if type(tabIcon) == "string" and string.find(tabIcon, "rbxasset", 1, true) == 1
		then tabIcon
		else (tabIconRole and self.Assets[tabIconRole] or nil)
	local hasTabIconImage = type(tabIconImage) == "string" and tabIconImage ~= ""
	imageOrGlyph(tabButton, {
		Name = "Icon",
		Position = UDim2.fromOffset(16, 0),
		Size = UDim2.fromOffset(32, 66),
		TextSize = 24,
		ImageTransparency = 0.25,
		TextTransparency = 0,
		TextXAlignment = Enum.TextXAlignment.Center,
	}, hasTabIconImage and tabIconImage or nil, tostring(tabIcon))
	label({
		Name = "TabName",
		Position = UDim2.fromOffset(58, 0),
		Size = UDim2.new(1, -98, 1, 0),
		FontFace = Fonts.Semibold,
		Text = tabName,
		TextColor3 = Theme.Text,
		TextSize = 19,
		Parent = tabButton,
	})
	spriteOrGlyph(tabButton, {
		Name = "TabDecoration",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -14, 0.5, 0),
		Size = UDim2.fromOffset(28, 28),
		ImageTransparency = order == 1 and 0.08 or 0,
		TextTransparency = 0.2,
		TextSize = 17,
	}, self.Assets, order == 1 and "Paw" or "DarkCat", "*")

	local page = create("ScrollingFrame", {
		Name = tabName .. "Page",
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Border,
		CanvasSize = UDim2.fromOffset(0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Visible = false,
		Parent = self.Pages,
	}, { padding(34, 34, 34, 34), listLayout(22) }) :: ScrollingFrame

	local pageHeader = create("Frame", {
		Name = "PageHeader",
		Size = UDim2.new(1, 0, 0, 82),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = 0,
		Parent = page,
	}) :: Frame
	label({
		Name = "PageTitle",
		Position = UDim2.fromOffset(8, 0),
		Size = UDim2.new(1, -220, 0, 58),
		FontFace = Fonts.Display,
		Text = pageTitle,
		TextSize = 40,
		Parent = pageHeader,
	})
	spriteOrGlyph(pageHeader, {
		Name = "PageTitlePaw",
		Position = UDim2.fromOffset(math.clamp((#pageTitle * 22) + 18, 160, 300), 11),
		Size = UDim2.fromOffset(36, 36),
		ImageTransparency = 0.08,
		TextTransparency = 0.08,
		TextSize = 24,
		ZIndex = 3,
	}, self.Assets, "Paw", "*")
	local pageDivider = separatorLine(pageHeader, 72, 0, 0)
	pageDivider.LayoutOrder = 0
	spriteOrGlyph(pageDivider, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -170, 0.5, 0),
		Size = UDim2.fromOffset(48, 44),
		TextSize = 20,
		ImageTransparency = 0,
		TextTransparency = 0,
		ZIndex = 3,
	}, self.Assets, "Heart", "*")

	local tab = setmetatable({
		Window = self,
		Name = tabName,
		Button = tabButton,
		PageTitle = pageTitle,
		Page = page,
		Sections = {},
		Order = order,
		Stroke = tabStroke,
	}, TabMethods)
	table.insert(self.Tabs, tab)

	table.insert(self._connections, tabButton.MouseEnter:Connect(function()
		if self._selectedTab ~= tab then
			tween(tabButton, 0.18, { BackgroundTransparency = 0.55 })
		end
	end))
	table.insert(self._connections, tabButton.MouseLeave:Connect(function()
		if self._selectedTab ~= tab then
			tween(tabButton, 0.18, { BackgroundTransparency = 1 })
		end
	end))
	table.insert(self._connections, tabButton.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end))

	if not self._selectedTab then
		self:SelectTab(tab)
	end
	return tab
end

function WindowMethods:SelectTab(tab: any)
	if self._selectedTab == tab then
		return
	end
	self:ClosePopups()
	for _, item in ipairs(self.Tabs) do
		local selected = item == tab
		item.Page.Visible = selected
		tween(item.Button, 0.18, { BackgroundTransparency = selected and 0 or 1 })
		if item.Stroke then
			tween(item.Stroke, 0.18, { Transparency = selected and Line.TabSelected or 1 })
		end
		local icon = item.Button:FindFirstChild("Icon")
		if icon and icon:IsA("TextLabel") then
			icon.TextColor3 = selected and Theme.Text or Theme.MutedText
		elseif icon and icon:IsA("ImageLabel") then
			icon.ImageColor3 = selected and Theme.Text or Theme.MutedText
			icon.ImageTransparency = selected and 0 or 0.25
		end
	end
	self._selectedTab = tab
end

function WindowMethods:GetFlag(flag: string)
	local control = self.Flags[flag]
	return control and control.Value or nil
end

function WindowMethods:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	for _, popup in ipairs(self._popups) do
		if popup.Destroy then
			popup.Destroy()
		else
			popup.Close()
		end
	end
	disconnectAll(self._connections)
	table.clear(self._inputBegan)
	table.clear(self._inputChanged)
	table.clear(self._inputEnded)
	table.clear(self._popups)
	table.clear(self.Flags)
	if self.Gui then
		self.Gui:Destroy()
	end
end

function TabMethods:AddSection(options: any)
	if type(options) == "string" then
		options = { Name = options }
	end
	options = options or {}
	local name = options.Name or "Section"
	local order = #self.Sections + 2

	local wrapper = create("Frame", {
		Name = name,
		Size = UDim2.new(1, -2, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = self.Page,
	}) :: Frame

	label({
		Name = "SectionTitle",
		Position = UDim2.fromOffset(34, 0),
		Size = UDim2.new(1, -34, 0, 38),
		FontFace = Fonts.Semibold,
		Text = name,
		TextColor3 = Theme.Text,
		TextSize = 20,
		Parent = wrapper,
	})
	spriteOrGlyph(wrapper, {
		Position = UDim2.fromOffset(0, 4),
		Size = UDim2.fromOffset(28, 28),
		TextSize = 18,
		ImageTransparency = 0.12,
		TextTransparency = 0.12,
	}, self.Window.Assets, "Paw", "*")

	local card = create("Frame", {
		Name = "Card",
		Position = UDim2.fromOffset(0, 46),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = Theme.Surface,
		BorderSizePixel = 0,
		Parent = wrapper,
	}, {
		corner(22),
		stroke(Theme.Border, Line.Card, true),
		padding(8, 18, 8, 18),
		listLayout(0),
		gradient(Color3.fromRGB(44, 45, 50), Color3.fromRGB(24, 25, 28), 105),
	}) :: Frame

	local section = setmetatable({
		Tab = self,
		Window = self.Window,
		Name = name,
		Wrapper = wrapper,
		Card = card,
		Controls = {},
	}, SectionMethods)
	table.insert(self.Sections, section)
	return section
end

local function addDivider(parent: Instance, order: number)
	create("Frame", {
		Name = "Divider",
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Divider,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = parent,
	})
end

local function controlRow(section: any, height: number, title: string, description: string?, iconRole: string?): Frame
	local order = (#section.Controls * 2) + 1
	if #section.Controls > 0 then
		addDivider(section.Card, order - 1)
	end
	local row = create("Frame", {
		Name = title,
		Size = UDim2.new(1, 0, 0, height),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		LayoutOrder = order,
		Parent = section.Card,
	}) :: Frame
	local iconTile = create("Frame", {
		Name = "IconTile",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 0),
		Size = UDim2.fromOffset(58, 58),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		Parent = row,
	}, { corner(14), stroke(Theme.Border, Line.Tile, true) }) :: Frame
	spriteOrGlyph(iconTile, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(46, 46),
		TextSize = 25,
		ImageTransparency = 0,
		TextTransparency = 0,
	}, section.Window.Assets, iconRole or "Logo", "*")
	label({
		Name = "Title",
		Position = UDim2.fromOffset(78, description and 9 or 0),
		Size = UDim2.new(0.62, -78, 0, description and 32 or height),
		FontFace = Fonts.Semibold,
		Text = title,
		TextSize = 18,
		Parent = row,
	})
	if description then
		label({
			Name = "Description",
			Position = UDim2.fromOffset(78, 39),
			Size = UDim2.new(0.75, -78, 0, 25),
			Text = description,
			TextColor3 = Theme.MutedText,
			TextSize = 14,
			Parent = row,
		})
	end
	table.insert(section.Controls, row)
	return row
end

local function registerFlag(section: any, flag: string?, control: any)
	if flag and flag ~= "" then
		section.Window.Flags[flag] = control
	end
	return control
end

function SectionMethods:AddButton(options: any)
	if type(options) == "string" then
		options = { Text = options }
	end
	options = options or {}
	local text = options.Text or "Button"
	local row = controlRow(self, options.Description and 82 or 68, text, options.Description, options.IconRole or "Bell")
	local action = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(166, 54),
		BackgroundTransparency = 1,
		Text = "",
		Parent = row,
	}, {
		corner(12),
		stroke(Theme.Border, Line.Control, true),
	})
	local actionSurface = create("Frame", {
		Name = "Surface",
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = Theme.Selected,
		BorderSizePixel = 0,
		ZIndex = action.ZIndex,
		Parent = action,
	}, {
		corner(12),
		gradient(Color3.fromRGB(80, 81, 88), Color3.fromRGB(45, 46, 51), 105),
	}) :: Frame
	label({
		Name = "ButtonText",
		Position = UDim2.fromOffset(18, 0),
		Size = UDim2.new(1, -30, 1, 0),
		FontFace = Fonts.Semibold,
		Text = options.ButtonText or "Run",
		TextColor3 = Theme.Text,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Center,
		ZIndex = action.ZIndex + 2,
		Parent = action,
	})
	table.insert(self.Window._connections, action.MouseEnter:Connect(function()
		tween(actionSurface, 0.15, { BackgroundTransparency = 0.12 })
	end))
	table.insert(self.Window._connections, action.MouseLeave:Connect(function()
		tween(actionSurface, 0.15, { BackgroundTransparency = 0 })
	end))
	table.insert(self.Window._connections, action.MouseButton1Click:Connect(function()
		safeCallback(options.Callback)
	end))
	local control = { Type = "Button", Instance = row }
	function control:Fire()
		safeCallback(options.Callback)
	end
	return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddLabel(options: any)
    if type(options) == "string" then
        options = { Text = options }
    end
    options = options or {}
    local text = options.Text or "Label"
    local row = controlRow(self, options.Description and 68 or 56, text, options.Description, options.IconRole or "Logo")
    local control = { Type = "Label", Value = text, Instance = row }
    function control:Set(value)
        self.Value = tostring(value)
        local title = row:FindFirstChild("Title") :: TextLabel
        if title then title.Text = self.Value end
    end
    return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddToggle(options: any)
	options = options or {}
	local text = options.Text or "Toggle"
	local row = controlRow(self, options.Description and 82 or 68, text, options.Description, options.IconRole or "Sleeping")
	local track = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(82, 42),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Parent = row,
	}, { corner(21), stroke(Theme.Border, Line.Control, true) })
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 0),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = Theme.MutedText,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(17) }) :: Frame
	local control = { Type = "Toggle", Value = options.Default == true, Instance = row }
	function control:Set(value: boolean, silent: boolean?)
		self.Value = value == true
		tween(track, 0.18, { BackgroundColor3 = self.Value and Theme.White or Theme.Selected })
		tween(knob, 0.18, {
			Position = self.Value and UDim2.new(1, -38, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
			BackgroundColor3 = self.Value and Theme.Black or Theme.MutedText,
		})
		if not silent then
			safeCallback(options.Callback, self.Value)
		end
	end
	control:Set(control.Value, true)
	table.insert(self.Window._connections, track.MouseButton1Click:Connect(function()
		control:Set(not control.Value)
	end))
	return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddSlider(options: any)
	options = options or {}
	local text = options.Text or "Slider"
	local minimum = options.Min or 0
	local maximum = options.Max or 100
	local increment = options.Increment or 1
	local row = controlRow(self, 104, text, options.Description, options.IconRole or "Peek")
	local valueLabel = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -5, 0, 3),
		Size = UDim2.fromOffset(100, 28),
		Text = "",
		FontFace = Fonts.Value,
		TextColor3 = Theme.Text,
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Right,
		Parent = row,
	})
	local bar = button({
		Position = UDim2.new(0, 78, 1, -29),
		Size = UDim2.new(1, -88, 0, 10),
		BackgroundColor3 = Theme.Track,
		BackgroundTransparency = 0,
		Parent = row,
	}, { corner(5) })
	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = bar,
	}, { corner(5) }) :: Frame
	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = Theme.White,
		BorderSizePixel = 0,
		Parent = bar,
	}, { corner(9) }) :: Frame
	local control = { Type = "Slider", Value = options.Default or minimum, Instance = row }
	local dragging = false

	function control:Set(value: number, silent: boolean?)
		value = math.clamp(snapToIncrement(math.clamp(value, minimum, maximum), minimum, increment), minimum, maximum)
		self.Value = value
		local alpha = maximum == minimum and 0 or (value - minimum) / (maximum - minimum)
		fill.Size = UDim2.fromScale(alpha, 1)
		knob.Position = UDim2.fromScale(alpha, 0.5)
		valueLabel.Text = tostring(value) .. (options.Suffix or "")
		if not silent then
			safeCallback(options.Callback, value)
		end
	end
	local function updateFromInput(input)
		local width = bar.AbsoluteSize.X
		if width <= 0 then
			return
		end
		local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / width, 0, 1)
		control:Set(minimum + ((maximum - minimum) * alpha))
	end
	table.insert(self.Window._connections, bar.InputBegan:Connect(function(input)
		if isPressInput(input) then
			dragging = true
			updateFromInput(input)
		end
	end))
	table.insert(self.Window._inputChanged, function(input)
		if dragging and isMoveInput(input) then
			updateFromInput(input)
		end
	end)
	table.insert(self.Window._inputEnded, function(input)
		if isPressInput(input) then
			dragging = false
		end
	end)
	control:Set(control.Value, true)
	return registerFlag(self, options.Flag, control)
end

function SectionMethods:AddKeybind(options: any)
	options = options or {}
	local text = options.Text or "Keybind"
	local row = controlRow(self, 76, text, options.Description, options.IconRole or "Logo")
	local keyButton = button({
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -5, 0.5, 0),
		Size = UDim2.fromOffset(96, 38),
		BackgroundColor3 = Theme.Selected,
		BackgroundTransparency = 0,
		Text = "",
		Parent = row,
	}, { corner(11), stroke(Theme.Border, Line.Control, true) })
	local keyLabel = label({
		Size = UDim2.fromScale(1, 1),
		Text = "",
		FontFace = Fonts.Mono,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = keyButton,
	})
	local control = { Type = "Keybind", Value = options.Default or Enum.KeyCode.RightShift, Instance = row, Listening = false }
	function control:Set(value: Enum.KeyCode, silent: boolean?)
		self.Value = value
		keyLabel.Text = value == Enum.KeyCode.Unknown and "None" or value.Name
		if not silent then
			safeCallback(options.ChangedCallback, value)
		end
	end
	control:Set(control.Value, true)
	table.insert(self.Window._connections, keyButton.MouseButton1Click:Connect(function()
		control.Listening = true
		keyLabel.Text = "..."
	end))
	table.insert(self.Window._inputBegan, function(input, processed)
		if control.Listening then
			if processed or input.KeyCode == Enum.KeyCode.Unknown then
				return
			end
			control.Listening = false
			if input.KeyCode == Enum.KeyCode.Escape then
				control:Set(control.Value, true)
			elseif input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
				control:Set(Enum.KeyCode.Unknown)
			else
				control:Set(input.KeyCode)
			end
			return
		end
		if not processed and control.Value ~= Enum.KeyCode.Unknown and input.KeyCode == control.Value then
			safeCallback(options.Callback)
		end
	end)
	return registerFlag(self, options.Flag, control)
end

return KittenHub
end)()

----------------------------------------------------------------
-- Pixie builder for Pet Simulator 99
----------------------------------------------------------------
local Window = KittenHub:CreateWindow({
    Title = "Pixie | PS99",
    UserStatus = "Pixie v1.0",
    PageTitle = "Farm",
    ToggleKey = Enum.KeyCode.RightShift,
})

-- tabs only (stacked vertically in the sidebar, no overlap)
local FarmTab = Window:AddTab({ Name = "Farm", IconRole = "CrossedRifles" })
local PetsTab = Window:AddTab({ Name = "Pets", IconRole = "Curled" })
local EspTab   = Window:AddTab({ Name = "ESP", IconRole = "Peek" })
local UtilTab = Window:AddTab({ Name = "Util", IconRole = "Plus" })
local DevTab = Window:AddTab({ Name = "Dev", IconRole = "Bell" })

----------------------------------------------------------------
-- ESP engine — folder-hooked, uses real PS99 paths:
--   Workspace.__THINGS.Breakables   (Models, attr BreakableID / BreakableClass / AreaID)
--   Workspace.__THINGS.Chests       (populated at runtime)
----------------------------------------------------------------
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local espState = {
    breakables = false,
    lootbags   = false,
    events     = false,
    relics     = false,
    players    = false,
    range      = 500,
}

local BREAK_COLOR = Color3.fromRGB(120, 200, 255)

local tagged = {}        -- [Model] = { hl, bb, label, kind, anchor }
local folderConns = {}   -- [kind] = {added, removed}

local function getAnchor(model)
    if model.PrimaryPart then return model.PrimaryPart end
    return model:FindFirstChildWhichIsA("BasePart", true)
end

local function tagModel(model, kind, color, label)
    if tagged[model] then return end
    local anchor
    if model:IsA("Model") then
        anchor = getAnchor(model)
    elseif model:IsA("BasePart") then
        anchor = model
    end
    if not anchor then return end

    local hl = Instance.new("Highlight")
    hl.FillTransparency = 0.72
    hl.OutlineTransparency = 0
    hl.FillColor = color
    hl.OutlineColor = color
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = model
    hl.Parent = model

    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(190, 36)
    bb.StudsOffset = Vector3.new(0, 4, 0)
    bb.AlwaysOnTop = true
    bb.LightInfluence = 0
    bb.Adornee = anchor
    bb.Parent = anchor

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 14
    lbl.TextColor3 = color
    lbl.TextStrokeTransparency = 0
    lbl.TextStrokeColor3 = Color3.new(0, 0, 0)
    lbl.Text = label
    lbl.Parent = bb

    tagged[model] = { hl = hl, bb = bb, label = lbl, kind = kind, anchor = anchor, base = label }
end

local function dropTag(model)
    local t = tagged[model]
    if not t then return end
    if t.hl and t.hl.Parent then t.hl:Destroy() end
    if t.bb and t.bb.Parent then t.bb:Destroy() end
    tagged[model] = nil
end

local function clearKind(kind)
    for model, t in pairs(tagged) do
        if t.kind == kind then dropTag(model) end
    end
end

local function breakableLabel(model)
    local id = model:GetAttribute("BreakableID") or model.Name
    local cls = model:GetAttribute("BreakableClass")
    if cls and cls ~= "Normal" then
        return string.format("%s [%s]", id, cls)
    end
    return tostring(id)
end


local function hookFolder(kind, folder, color, labelFn)
    if folderConns[kind] then return end
    local function onAdd(child)
        if child:IsA("Model") or child:IsA("BasePart") then
            -- yield so attributes/children replicate
            task.defer(function()
                if child.Parent == folder then
                    tagModel(child, kind, color, labelFn(child))
                end
            end)
        end
    end
    local function onRemove(child)
        if tagged[child] then dropTag(child) end
    end
    for _, c in ipairs(folder:GetChildren()) do onAdd(c) end
    folderConns[kind] = {
        added = folder.ChildAdded:Connect(onAdd),
        removed = folder.ChildRemoved:Connect(onRemove),
    }
end

local function unhookFolder(kind)
    local c = folderConns[kind]
    if not c then return end
    if c.added then c.added:Disconnect() end
    if c.removed then c.removed:Disconnect() end
    folderConns[kind] = nil
    clearKind(kind)
end

local function waitForThings()
    local things = workspace:FindFirstChild("__THINGS")
    if things then return things end
    return workspace:WaitForChild("__THINGS", 10)
end

local function enableBreakables(on)
    espState.breakables = on
    local things = waitForThings()
    if not things then return end
    if on then
        local folder = things:FindFirstChild("Breakables") or things:WaitForChild("Breakables", 5)
        if folder then hookFolder("breakable", folder, BREAK_COLOR, breakableLabel) end
    else
        unhookFolder("breakable")
    end
end

----------------------------------------------------------------
-- Lootbag ESP — Workspace.__THINGS.Lootbags
----------------------------------------------------------------
local LOOT_COLOR = Color3.fromRGB(255, 180, 80)

local function lootbagLabel(inst)
    local id = inst:GetAttribute("LootbagID")
        or inst:GetAttribute("LootbagType")
        or inst:GetAttribute("OwnerName")
    if id then return "Lootbag | " .. tostring(id) end
    return "Lootbag"
end

local function enableLootbags(on)
    espState.lootbags = on
    local things = waitForThings()
    if not things then return end
    if on then
        local folder = things:FindFirstChild("Lootbags") or things:WaitForChild("Lootbags", 5)
        if folder then hookFolder("lootbag", folder, LOOT_COLOR, lootbagLabel) end
    else
        unhookFolder("lootbag")
    end
end

----------------------------------------------------------------
-- Event Spawn ESP — hooks three folders under one toggle:
--   Workspace.__THINGS.RandomEvents  (comets, lucky blocks, etc.)
--   Workspace.__THINGS.Instances.ChestRoulette
--   Workspace.__THINGS.Instances.ChestRush
----------------------------------------------------------------
local EVENT_COLOR = Color3.fromRGB(180, 120, 255)

local function eventLabel(inst)
    local id = inst:GetAttribute("EventID")
        or inst:GetAttribute("EventType")
        or inst:GetAttribute("InstanceID")
        or inst.Name
    return "EVENT | " .. tostring(id)
end

----------------------------------------------------------------
-- Shiny Relic ESP — Workspace.__THINGS.ShinyRelics (MeshParts)
-- Template lives at ReplicatedStorage.Assets.Models.Misc.ShinyRelic.
-- Pet reward comes from ReplicatedStorage.__DIRECTORY.Pets.Uncategorized.Relic *
----------------------------------------------------------------
local RELIC_COLOR = Color3.fromRGB(120, 255, 240)

local function relicLabel(inst)
    local id = inst:GetAttribute("RelicID")
        or inst:GetAttribute("RelicType")
        or inst:GetAttribute("PetID")
        or inst:GetAttribute("RewardID")
        or inst:GetAttribute("AreaID")
    if id then return "Shiny Relic | " .. tostring(id) end
    return "Shiny Relic"
end

local function enableRelics(on)
    espState.relics = on
    local things = waitForThings()
    if not things then return end
    if on then
        local folder = things:FindFirstChild("ShinyRelics") or things:WaitForChild("ShinyRelics", 5)
        if folder then hookFolder("relic", folder, RELIC_COLOR, relicLabel) end
    else
        unhookFolder("relic")
    end
end

local function enableEvents(on)
    espState.events = on
    local things = waitForThings()
    if not things then return end
    local targets = {
        { kind = "event_random",   path = { "RandomEvents" } },
        { kind = "event_roulette", path = { "Instances", "ChestRoulette" } },
        { kind = "event_rush",     path = { "Instances", "ChestRush" } },
    }
    for _, t in ipairs(targets) do
        local folder = things
        for _, seg in ipairs(t.path) do
            folder = folder and folder:FindFirstChild(seg)
        end
        if on then
            if folder then hookFolder(t.kind, folder, EVENT_COLOR, eventLabel) end
        else
            unhookFolder(t.kind)
        end
    end
end


local playerTags = {}
local function tagPlayer(plr)
    if playerTags[plr] or plr == LocalPlayer then return end
    local function attach(char)
        local head = char:WaitForChild("Head", 5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not head then return end
        local hl = Instance.new("Highlight")
        hl.FillTransparency = 0.7
        hl.OutlineColor = Color3.fromRGB(240, 90, 90)
        hl.FillColor = Color3.fromRGB(240, 90, 90)
        hl.Parent = char
        local bb = Instance.new("BillboardGui")
        bb.Size = UDim2.fromOffset(180, 32)
        bb.StudsOffset = Vector3.new(0, 2.5, 0)
        bb.AlwaysOnTop = true
        bb.Adornee = head
        bb.Parent = head
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 14
        lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        lbl.TextStrokeTransparency = 0
        lbl.Text = plr.DisplayName
        lbl.Parent = bb
        playerTags[plr] = { hl = hl, bb = bb, label = lbl, char = char, hum = hum }
    end
    if plr.Character then attach(plr.Character) end
    plr.CharacterAdded:Connect(attach)
end

local function untagPlayer(plr)
    local t = playerTags[plr]
    if not t then return end
    if t.hl then t.hl:Destroy() end
    if t.bb then t.bb:Destroy() end
    playerTags[plr] = nil
end

local function setPlayerESP(on)
    if on then
        for _, p in ipairs(Players:GetPlayers()) do tagPlayer(p) end
    else
        for p, _ in pairs(playerTags) do untagPlayer(p) end
    end
end

Players.PlayerAdded:Connect(function(p) if espState.players then tagPlayer(p) end end)
Players.PlayerRemoving:Connect(untagPlayer)

local updateAcc = 0
RunService.Heartbeat:Connect(function(dt)
    updateAcc += dt
    if updateAcc < 0.1 then return end
    updateAcc = 0
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local origin = root.Position
    for model, t in pairs(tagged) do
        if not model.Parent or not t.anchor or not t.anchor.Parent then
            dropTag(model)
        else
            local d = (t.anchor.Position - origin).Magnitude
            local visible = d <= espState.range
            t.hl.Enabled = visible
            t.bb.Enabled = visible
            if visible then
                t.label.Text = string.format("%s | %dm", t.base, d)
            end
        end
    end
end)

----------------------------------------------------------------
-- ESP tab menu
----------------------------------------------------------------
local EspSec = EspTab:AddSection({ Name = "World ESP" })

EspSec:AddToggle({
    Text = "Breakable ESP",
    Default = false,
    IconRole = "Paw",
    Callback = function(state) enableBreakables(state) end,
})

EspSec:AddToggle({
    Text = "Lootbag ESP",
    Default = false,
    IconRole = "MoneyBag",
    Callback = function(state) enableLootbags(state) end,
})

EspSec:AddToggle({
    Text = "Event Spawn ESP",
    Default = false,
    IconRole = "Sparkles",
    Callback = function(state) enableEvents(state) end,
})

EspSec:AddToggle({
    Text = "Shiny Relic ESP",
    Default = false,
    IconRole = "Heart",
    Callback = function(state) enableRelics(state) end,
})

EspSec:AddToggle({
    Text = "Player ESP",
    Default = false,
    IconRole = "Players",
    Callback = function(state)
        espState.players = state
        setPlayerESP(state)
    end,
})

EspSec:AddSlider({
    Text = "Render range",
    Min = 50, Max = 2000, Default = 500, Increment = 50, Suffix = "m",
    IconRole = "Peek",
    Callback = function(v) espState.range = v end,
})

----------------------------------------------------------------
-- Auto Farm engine
-- Emulates PS99's native AutoTapper by firing
--   Signal_m.Fire("AutoClicker_Nearby", BreakableUID)
-- The game's PlayerPet system picks it up, routes pets, and
-- Breakables_JoinPetBulk fires on arrival. No gamepass gate.
-- Target picker mirrors GetPriorityBreakable + GetNearestBreakable
-- (StarterPlayerScripts.Scripts.GUIs.Auto Tapper).
----------------------------------------------------------------
local farmState = {
    enabled       = false,
    rate          = 8,
    range         = 150,
    zoneLock      = false,
    teleport      = false,
    lockedArea    = nil,
    lootCollect   = false,
    antiAfk       = false,
    autoReconnect = false,
    dismissPopups = false,
    charAlive     = true,
}

local function getModule(path)
    local node = game:GetService("ReplicatedStorage")
    for _, seg in ipairs(path) do
        node = node and node:FindFirstChild(seg)
        if not node then return nil end
    end
    local ok, mod = pcall(require, node)
    if ok then return mod end
    return nil
end

local function getSignal()
    return getModule({ "Library", "Signal" })
end

local function playerRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

-- Character life-cycle — always on, pauses loops while dead.
local function hookCharacter(char)
    if not char then return end
    farmState.charAlive = true
    local hum = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid", 3)
    if hum then
        hum.Died:Connect(function() farmState.charAlive = false end)
    end
end
hookCharacter(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("HumanoidRootPart", 10)
    hookCharacter(char)
end)

local function playerAreaID()
    local root = playerRoot(); if not root then return nil end
    local things = workspace:FindFirstChild("__THINGS"); if not things then return nil end
    local folder = things:FindFirstChild("Breakables"); if not folder then return nil end
    local best, bestDist = nil, math.huge
    for _, m in ipairs(folder:GetChildren()) do
        if m:IsA("Model") and m:GetAttribute("AreaID") then
            local d = (m:GetPivot().Position - root.Position).Magnitude
            if d < bestDist then bestDist, best = d, m end
        end
    end
    return best and best:GetAttribute("AreaID") or nil
end

local function iterBreakables(folder, origin, filterClass)
    local best, bestDist = nil, math.huge
    local cap = farmState.range
    for _, m in ipairs(folder:GetChildren()) do
        if m:IsA("Model")
            and not m:GetAttribute("ManualDamage")
            and not m:GetAttribute("DisableDamage")
            and m:GetAttribute("BreakableUID") then
            local cls = m:GetAttribute("BreakableClass")
            local pass = filterClass == nil or cls == filterClass
            if pass and (not farmState.zoneLock or not farmState.lockedArea
                or m:GetAttribute("AreaID") == farmState.lockedArea) then
                local d = (m:GetPivot().Position - origin).Magnitude
                if d <= cap and d < bestDist then
                    bestDist, best = d, m
                end
            end
        end
    end
    return best
end

local function pickFarmTarget()
    local root = playerRoot(); if not root then return nil end
    local things = workspace:FindFirstChild("__THINGS"); if not things then return nil end
    local folder = things:FindFirstChild("Breakables"); if not folder then return nil end
    return iterBreakables(folder, root.Position, nil)
end

local farmThread
local function stopFarm()
    farmState.enabled = false
    farmThread = nil
end

local function startFarm()
    if farmThread then return end
    local Signal_m = getSignal()
    if not Signal_m then
        Window:Notify({ Title = "Pixie", Content = "Signal module missing — can't farm.", Duration = 4 })
        return
    end
    if farmState.zoneLock then
        farmState.lockedArea = playerAreaID()
    end
    farmState.enabled = true
    farmThread = task.spawn(function()
        while farmState.enabled do
            if farmState.charAlive then
                local target = pickFarmTarget()
                if target then
                    local uid = target:GetAttribute("BreakableUID")
                    if uid then
                        pcall(Signal_m.Fire, "AutoClicker_Nearby", uid)
                        if farmState.teleport then
                            local root = playerRoot()
                            if root then
                                local pivot = target:GetPivot()
                                root.CFrame = pivot * CFrame.new(0, 6, 8)
                            end
                        end
                    end
                end
            end
            task.wait(1 / math.max(1, farmState.rate))
        end
    end)
end

----------------------------------------------------------------
-- Lootbag auto-collect — walks to each lootbag in turn.
-- Folder: Workspace.__THINGS.Lootbags
----------------------------------------------------------------
local lootThread
local function stopLoot()
    farmState.lootCollect = false
    lootThread = nil
end

local function startLoot()
    if lootThread then return end
    farmState.lootCollect = true
    lootThread = task.spawn(function()
        while farmState.lootCollect do
            if farmState.charAlive then
                local things = workspace:FindFirstChild("__THINGS")
                local bags = things and things:FindFirstChild("Lootbags")
                local root = playerRoot()
                if bags and root then
                    for _, bag in ipairs(bags:GetChildren()) do
                        if not farmState.lootCollect or not farmState.charAlive then break end
                        local pivotPart = bag:IsA("BasePart") and bag
                            or (bag:IsA("Model") and (bag.PrimaryPart or bag:FindFirstChildWhichIsA("BasePart", true)))
                        if pivotPart and pivotPart.Parent then
                            root.CFrame = pivotPart.CFrame + Vector3.new(0, 3, 0)
                            pixieStats.lootbags += 1
                            task.wait(0.35)
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end

----------------------------------------------------------------
-- Anti-AFK — simulates a click on Idled so Roblox never kicks.
----------------------------------------------------------------
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if not farmState.antiAfk then return end
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(), workspace.CurrentCamera.CFrame)
    end)
end)

----------------------------------------------------------------
-- Auto-reconnect — on error/disconnect, teleport back to the
-- same PlaceId so the farm script survives server restarts.
----------------------------------------------------------------
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
GuiService.ErrorMessageChanged:Connect(function()
    if not farmState.autoReconnect then return end
    task.wait(1)
    pcall(function()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    end)
end)

----------------------------------------------------------------
-- Dismiss popups — walks PlayerGui periodically and clicks
-- obvious close/dismiss buttons so popups don't block tapping.
----------------------------------------------------------------
local POPUP_BUTTON_NAMES = { "Close", "CloseButton", "Dismiss", "X", "Exit", "Cancel", "NoButton" }
local function isCloseButton(btn)
    if not btn:IsA("TextButton") and not btn:IsA("ImageButton") then return false end
    local n = btn.Name:lower()
    for _, key in ipairs(POPUP_BUTTON_NAMES) do
        if n:find(key:lower(), 1, true) then return true end
    end
    if btn:IsA("TextButton") then
        local t = btn.Text:lower()
        if t == "x" or t == "close" or t == "no" or t == "cancel" then return true end
    end
    return false
end
local function clickButton(btn)
    pcall(function()
        if type(getconnections) == "function" then
            for _, c in ipairs(getconnections(btn.MouseButton1Click)) do
                if c.Function then c.Function() end
            end
        elseif type(firesignal) == "function" then
            firesignal(btn.MouseButton1Click)
        end
    end)
end
task.spawn(function()
    while true do
        task.wait(2)
        if farmState.dismissPopups then
            local pg = LocalPlayer:FindFirstChildOfClass("PlayerGui")
            if pg then
                for _, sg in ipairs(pg:GetChildren()) do
                    if sg:IsA("ScreenGui") and sg.Enabled then
                        for _, d in ipairs(sg:GetDescendants()) do
                            if isCloseButton(d) and d.Parent and d.Visible ~= false then
                                clickButton(d)
                            end
                        end
                    end
                end
            end
        end
    end
end)

----------------------------------------------------------------
-- Farm tab UI — three sections: Auto Farm · Pets · Session
----------------------------------------------------------------
local FarmSec = FarmTab:AddSection({ Name = "Auto Farm" })

FarmSec:AddToggle({
    Text = "Auto Farm Breakables",
    Default = false,
    IconRole = "CrossedRifles",
    Callback = function(state)
        if state then startFarm() else stopFarm() end
    end,
})

FarmSec:AddToggle({
    Text = "Zone lock",
    Default = false,
    IconRole = "Shield",
    Callback = function(state)
        farmState.zoneLock = state
        if state then
            farmState.lockedArea = playerAreaID()
            if farmState.lockedArea then
                Window:Notify({ Title = "Pixie", Content = "Zone locked: " .. tostring(farmState.lockedArea), Duration = 3 })
            end
        else
            farmState.lockedArea = nil
        end
    end,
})

FarmSec:AddToggle({
    Text = "Teleport to target",
    Default = false,
    IconRole = "Horse",
    Callback = function(state) farmState.teleport = state end,
})

FarmSec:AddSlider({
    Text = "Tap rate",
    Min = 1, Max = 20, Default = 8, Increment = 1, Suffix = " t/s",
    IconRole = "Bell",
    Callback = function(v) farmState.rate = v end,
})

FarmSec:AddSlider({
    Text = "Target range",
    Min = 20, Max = 400, Default = 150, Increment = 10, Suffix = "s",
    IconRole = "Peek",
    Callback = function(v) farmState.range = v end,
})

----------------------------------------------------------------
local SessionSec = FarmTab:AddSection({ Name = "Session" })

SessionSec:AddToggle({
    Text = "Auto-collect Lootbags",
    Default = false,
    IconRole = "MoneyBag",
    Callback = function(state)
        if state then startLoot() else stopLoot() end
    end,
})

SessionSec:AddToggle({
    Text = "Anti-AFK",
    Default = false,
    IconRole = "Sleeping",
    Callback = function(state) farmState.antiAfk = state end,
})

SessionSec:AddToggle({
    Text = "Auto-reconnect",
    Default = false,
    IconRole = "Bell",
    Callback = function(state) farmState.autoReconnect = state end,
})

SessionSec:AddToggle({
    Text = "Dismiss popups",
    Default = false,
    IconRole = "Sparkles",
    Callback = function(state) farmState.dismissPopups = state end,
})


----------------------------------------------------------------
-- Util tab engine — movement mods + teleports
----------------------------------------------------------------
local utilState = {
    walkspeedOn  = false,
    walkspeed    = 60,
    jumpOn       = false,
    jumpPower    = 100,
    flyOn        = false,
    flySpeed     = 80,
    flyKey       = Enum.KeyCode.F,
    noclipOn     = false,
    infJumpOn    = false,
}

local function humanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function applyMovement()
    local hum = humanoid(); if not hum then return end
    hum.WalkSpeed = utilState.walkspeedOn and utilState.walkspeed or 16
    if utilState.jumpOn then
        hum.UseJumpPower = true
        hum.JumpPower = utilState.jumpPower
    else
        hum.JumpPower = 50
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    applyMovement()
end)

-- Noclip — runs only while toggle is on.
RunService.Stepped:Connect(function()
    if not utilState.noclipOn then return end
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

-- Infinite jump
local UIS = game:GetService("UserInputService")
UIS.JumpRequest:Connect(function()
    if utilState.infJumpOn then
        local hum = humanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- Fly — simple BodyVelocity + gyro rig, follows camera look vector.
local flyBV, flyBG, flyConn
local function stopFly()
    utilState.flyOn = false
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    local hum = humanoid()
    if hum then hum.PlatformStand = false end
end

local function startFly()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = humanoid()
    if not root or not hum then return end
    utilState.flyOn = true
    hum.PlatformStand = true
    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root
    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 10000
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root
    flyConn = RunService.RenderStepped:Connect(function()
        if not utilState.flyOn then return end
        local cam = workspace.CurrentCamera
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit * utilState.flySpeed end
        flyBV.Velocity = dir
        flyBG.CFrame = cam.CFrame
    end)
end

----------------------------------------------------------------
-- Util tab UI — two sections: Movement · Teleports
----------------------------------------------------------------
local MoveSec = UtilTab:AddSection({ Name = "Movement" })

MoveSec:AddToggle({
    Text = "Walkspeed",
    Default = false,
    IconRole = "Horse",
    Callback = function(state) utilState.walkspeedOn = state; applyMovement() end,
})
MoveSec:AddSlider({
    Text = "Walkspeed value",
    Min = 16, Max = 500, Default = 60, Increment = 2,
    IconRole = "Horse",
    Callback = function(v) utilState.walkspeed = v; if utilState.walkspeedOn then applyMovement() end end,
})
MoveSec:AddToggle({
    Text = "Jump Power",
    Default = false,
    IconRole = "Sparkles",
    Callback = function(state) utilState.jumpOn = state; applyMovement() end,
})
MoveSec:AddSlider({
    Text = "Jump Power value",
    Min = 50, Max = 800, Default = 100, Increment = 10,
    IconRole = "Sparkles",
    Callback = function(v) utilState.jumpPower = v; if utilState.jumpOn then applyMovement() end end,
})
MoveSec:AddToggle({
    Text = "Fly",
    Default = false,
    IconRole = "Peek",
    Callback = function(state)
        if state then startFly() else stopFly() end
    end,
})
MoveSec:AddSlider({
    Text = "Fly speed",
    Min = 20, Max = 400, Default = 80, Increment = 10,
    IconRole = "Peek",
    Callback = function(v) utilState.flySpeed = v end,
})
MoveSec:AddToggle({
    Text = "Noclip",
    Default = false,
    IconRole = "Shield",
    Callback = function(state) utilState.noclipOn = state end,
})
MoveSec:AddToggle({
    Text = "Infinite Jump",
    Default = false,
    IconRole = "Sparkles",
    Callback = function(state) utilState.infJumpOn = state end,
})

local TpSec = UtilTab:AddSection({ Name = "Server" })

TpSec:AddButton({
    Text = "Rejoin Server",
    ButtonText = "Go",
    IconRole = "Bell",
    Callback = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
        end)
    end,
})

----------------------------------------------------------------
-- Auto Hatch — fires Network_m.Invoke("Eggs_RequestPurchase", eggID, count)
-- The game's own HatchingCmds uses the same call (Library.Client.HatchingCmds
-- line 379). Egg ID comes from the nearest RenderedEgg the player is standing
-- near, or from an explicit "last seen" cache.
----------------------------------------------------------------
local hatchState = {
    enabled      = false,
    count        = 8,
    interval     = 0.6,
    autoClick    = true,
    clickRate    = 10,  -- clicks per second
    stopOnHuge   = true,
    stopOnShiny  = false,
    stopOnMythic = false,
    stopOnRainbow = false,
}

----------------------------------------------------------------
-- Dev / Session stats
----------------------------------------------------------------
local pixieStats = {
    hatches  = 0,
    rares    = 0,
    lootbags = 0,
    clicks   = 0,
    errors   = 0,
    startTs  = os.clock(),
}

-- Fires a client-side mouse click at the screen center AND the game's
-- AutoClicker_Click signal so hatch animations dismiss and any click-gated
-- purchase path still runs.
local VIM = game:GetService("VirtualInputManager")
local function fireHatchClick()
    pixieStats.clicks += 1
    local cam = workspace.CurrentCamera
    if cam then
        local x = cam.ViewportSize.X * 0.5
        local y = cam.ViewportSize.Y * 0.5
        pcall(function()
            VIM:SendMouseButtonEvent(x, y, 0, true,  game, 0)
            VIM:SendMouseButtonEvent(x, y, 0, false, game, 0)
        end)
    end
    local Signal_m = getModule({ "Library", "Signal" })
    if Signal_m and Signal_m.Fire then
        local cam = workspace.CurrentCamera
        local pos = cam and Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y * 0.5)
            or Vector2.zero
        pcall(Signal_m.Fire, "AutoClicker_Click", pos)
    end
end

-- The game exposes every zone egg's position as an attribute on
-- ReplicatedStorage.ZoneEggIndex: "Egg<N>" -> Vector3. EggsUtil_m.GetEggPosition
-- reads it, GetIdByNumber maps N -> egg name. This is the only way the game's
-- own quest/goal code finds eggs, so we use the same.
local function eggIndex()
    return game:GetService("ReplicatedStorage"):FindFirstChild("ZoneEggIndex")
end

local Directory_m
local function eggDir()
    if Directory_m == nil then
        Directory_m = getModule({ "Library", "Directory" }) or false
    end
    return Directory_m or nil
end

-- Build eggNumber -> egg name map lazily (name is both _id and .name since
-- LazyModuleLoader strips the "N | " prefix when keying).
local eggByNumber
local function buildEggMap()
    if eggByNumber then return eggByNumber end
    local dir = eggDir()
    if not dir or type(dir.Eggs) ~= "table" then return nil end
    eggByNumber = {}
    for k, v in pairs(dir.Eggs) do
        if type(v) == "table" and type(v.eggNumber) == "number" then
            eggByNumber[v.eggNumber] = (type(v.name) == "string" and v.name) or k
        end
    end
    return eggByNumber
end

-- Primary resolver: ZoneEggIndex attributes. Falls back to walking every
-- __THINGS.* egg-shaped folder if the index isn't present.
local EGG_FOLDERS = { "Eggs", "ZoneEggs", "RenderedEggs", "FarmEggs", "CustomEggs", "InfinityEggs", "ExclusiveEggs" }

-- Try to pull an eggNumber from a Model.Name across every naming scheme PS99
-- uses: "252 - Egg Capsule", "252 | Fantasy Egg", or a Directory key.
local function extractEggNumber(modelName)
    local n = tonumber(string.match(modelName, "^%s*(%d+)%s*%-"))
        or tonumber(string.match(modelName, "^%s*(%d+)%s*|"))
    return n
end

-- Try to pull egg NAME from the same.
local function extractEggName(modelName)
    return string.match(modelName, "^%s*%d+%s*|%s*(.+)$")
        or modelName
end

-- Walk the entire __THINGS subtree, find the closest Model whose name
-- resolves to a known egg. This is the only reliable way — ZoneEggIndex
-- positions are zone centers, not the pedestal the server checks against.
-- Returns: name, dist, eggNum, kind  where kind is "zone" or "custom"
local function nearestEgg()
    local root = playerRoot(); if not root then return nil end
    local origin = root.Position
    local things = workspace:FindFirstChild("__THINGS")
    if not things then return nil end

    local map = buildEggMap()
    local nameSet = {}
    if map then
        for _, n in pairs(map) do nameSet[n] = true end
    end

    local best, bestD, bestN, bestKind = nil, math.huge, nil, nil

    -- Custom eggs: Model.Name = UID; pass UID to CustomEggs_Hatch.
    -- Also handles human-named custom eggs (e.g. "Werewolf Egg").
    local customFolder = things:FindFirstChild("CustomEggs")
    if customFolder then
        for _, m in ipairs(customFolder:GetChildren()) do
            if m:IsA("Model") then
                local part = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart", true)
                if part then
                    local d = (part.Position - origin).Magnitude
                    if d < bestD then
                        bestD, best, bestN, bestKind = d, m.Name, nil, "custom"
                    end
                end
            end
        end
    end

    -- Zone/physical eggs: Model.Name is directory key, resolve via Directory.
    local function scanZoneContainer(container)
        for _, descendant in ipairs(container:GetDescendants()) do
            if descendant:IsA("Model") then
                local mn = descendant.Name
                local eggNum = extractEggNumber(mn)
                local eggName = (map and eggNum and map[eggNum])
                    or (nameSet[mn] and mn)
                    or nil
                if eggName then
                    local part = descendant.PrimaryPart or descendant:FindFirstChildWhichIsA("BasePart", true)
                    if part then
                        local d = (part.Position - origin).Magnitude
                        if d < bestD then
                            bestD, best, bestN, bestKind = d, eggName, eggNum, "zone"
                        end
                    end
                end
            end
        end
    end
    for _, fname in ipairs({ "Eggs", "ZoneEggs", "RenderedEggs", "FarmEggs", "InfinityEggs", "ExclusiveEggs" }) do
        local folder = things:FindFirstChild(fname)
        if folder then scanZoneContainer(folder) end
    end

    if best then return best, bestD, bestN, bestKind end
    return nil
end

-- kind: "zone" -> Eggs_RequestPurchase(eggName, count)
--       "custom" -> CustomEggs_Hatch(uid, count)
local function invokeHatch(eggNameOrUid, count, eggNumber, kind)
    local remoteName = (kind == "custom") and "CustomEggs_Hatch" or "Eggs_RequestPurchase"
    local Network_m = getModule({ "Library", "Client", "Network" })
    if Network_m and Network_m.Invoke then
        local ok, success, err = pcall(Network_m.Invoke, remoteName, eggNameOrUid, count)
        if ok and success then return true end
        -- For zone eggs, retry with eggNumber (some endpoints accept both)
        if kind ~= "custom" and ok and not success and eggNumber then
            local ok2, s2, e2 = pcall(Network_m.Invoke, remoteName, eggNumber, count)
            if ok2 and s2 then return true end
            return false, tostring(e2 or err or "rejected")
        end
        return false, tostring(err or "rejected")
    end
    -- Raw remote fallback
    local net = game:GetService("ReplicatedStorage"):FindFirstChild("Network")
    local remote = net and net:FindFirstChild(remoteName)
    if remote and remote:IsA("RemoteFunction") then
        local ok, success, err = pcall(remote.InvokeServer, remote, eggNameOrUid, count)
        if ok and success then return true end
        if kind ~= "custom" and eggNumber then
            local ok2, s2, e2 = pcall(remote.InvokeServer, remote, eggNumber, count)
            if ok2 and s2 then return true end
            return false, tostring(e2 or err or "rejected")
        end
        return false, tostring(err or "rejected")
    end
    return false, remoteName .. " remote not found"
end

-- Hatch-result listener: hooks the chat hatches remote so Pixie sees what
-- dropped and can halt on Huge/Shiny/Mythic/Rainbow.
local hatchListener
local function hookHatchListener()
    if hatchListener then return end
    local rs = game:GetService("ReplicatedStorage")
    local net = rs:FindFirstChild("Network"); if not net then return end
    local remote = net:FindFirstChild("Chat Msg Hatches Tab")
    if not remote or not remote:IsA("RemoteEvent") then return end
    hatchListener = remote.OnClientEvent:Connect(function(payload)
        if not hatchState.enabled then return end
        -- payload is a dict or table of pet entries; look for rarity flags.
        local function scan(entry)
            if type(entry) ~= "table" then return end
            local isHuge     = entry.huge     or entry.Huge     or entry.titanic or entry.Titanic or entry.gargantuan
            local isShiny    = entry.shiny    or entry.Shiny
            local isMythic   = entry.mythic   or entry.Mythic
            local isRainbow  = entry.rainbow  or entry.Rainbow  or entry.golden  or entry.Golden
            if isHuge or isShiny or isMythic or isRainbow then
                pixieStats.rares += 1
            end
            if (isHuge and hatchState.stopOnHuge)
                or (isShiny and hatchState.stopOnShiny)
                or (isMythic and hatchState.stopOnMythic)
                or (isRainbow and hatchState.stopOnRainbow) then
                hatchState.enabled = false
                Window:Notify({ Title = "Pixie", Content = "Rare pet hatched — auto-hatch stopped.", Duration = 5 })
            end
        end
        if type(payload) == "table" then
            for _, v in pairs(payload) do scan(v) end
            scan(payload)
        end
    end)
end

local hatchThread
local clickThread
local function stopClickLoop()
    clickThread = nil
end
local function startClickLoop()
    if clickThread then return end
    clickThread = task.spawn(function()
        while hatchState.enabled and hatchState.autoClick do
            fireHatchClick()
            task.wait(1 / math.max(1, hatchState.clickRate))
        end
        clickThread = nil
    end)
end
local function stopHatch()
    hatchState.enabled = false
    hatchThread = nil
    stopClickLoop()
end

local function startHatch()
    if hatchThread then return end
    hookHatchListener()
    local eggName, dist, eggNum, kind = nearestEgg()
    if not eggName then
        Window:Notify({ Title = "Pixie", Content = "No egg found — walk up to an egg pedestal first.", Duration = 4 })
        return
    end
    Window:Notify({
        Title = "Pixie",
        Content = string.format("[%s] Hatching: %s @ %ds",
            kind or "?", tostring(eggName), math.floor(dist or 0)),
        Duration = 4,
    })

    hatchState.enabled = true
    if hatchState.autoClick then startClickLoop() end
    hatchThread = task.spawn(function()
        local lastName, lastNum, lastKind, strikes = eggName, eggNum, kind, 0
        while hatchState.enabled do
            if not farmState.charAlive then task.wait(1); continue end
            local name, _, num, k = nearestEgg()
            if name then lastName, lastNum, lastKind = name, num, k end
            local ok, err = invokeHatch(lastName, hatchState.count, lastNum, lastKind)
            if ok then
                strikes = 0
                pixieStats.hatches += hatchState.count
            else
                local e = tostring(err or "")
                if e:find("too fast") or e:find("doing that too quickly") then
                    -- rate-limited, back off
                else
                    strikes += 1
                    pixieStats.errors += 1
                    if strikes == 1 then
                        Window:Notify({ Title = "Pixie", Content = "Server: " .. e, Duration = 4 })
                    end
                    if strikes >= 5 then
                        Window:Notify({ Title = "Pixie", Content = "Hatch stopped — last error above.", Duration = 5 })
                        stopHatch(); break
                    end
                end
            end
            task.wait(hatchState.interval)
        end
    end)
end

----------------------------------------------------------------
-- Pets tab UI — two sections: Auto Hatch · Stop Conditions
----------------------------------------------------------------
local HatchSec = PetsTab:AddSection({ Name = "Auto Hatch" })

HatchSec:AddToggle({
    Text = "Auto Hatch Nearest Egg",
    Default = false,
    IconRole = "Curled",
    Callback = function(state)
        if state then startHatch() else stopHatch() end
    end,
})

HatchSec:AddSlider({
    Text = "Hatch count",
    Min = 1, Max = 20, Default = 8, Increment = 1, Suffix = "x",
    IconRole = "Sparkles",
    Callback = function(v) hatchState.count = v end,
})

HatchSec:AddSlider({
    Text = "Interval",
    Min = 1, Max = 30, Default = 6, Increment = 1, Suffix = " (/10s)",
    IconRole = "Bell",
    Callback = function(v) hatchState.interval = v / 10 end,
})

HatchSec:AddToggle({
    Text = "Auto-click while hatching",
    Default = true,
    IconRole = "Paw",
    Callback = function(state)
        hatchState.autoClick = state
        if state and hatchState.enabled then startClickLoop() end
    end,
})

HatchSec:AddSlider({
    Text = "Click rate",
    Min = 1, Max = 60, Default = 10, Increment = 1, Suffix = " c/s",
    IconRole = "Paw",
    Callback = function(v) hatchState.clickRate = v end,
})

local StopSec = PetsTab:AddSection({ Name = "Stop Conditions" })

StopSec:AddToggle({
    Text = "Stop on Huge / Titanic",
    Default = true,
    IconRole = "Bear",
    Callback = function(state) hatchState.stopOnHuge = state end,
})
StopSec:AddToggle({
    Text = "Stop on Shiny",
    Default = false,
    IconRole = "Sparkles",
    Callback = function(state) hatchState.stopOnShiny = state end,
})
StopSec:AddToggle({
    Text = "Stop on Mythic",
    Default = false,
    IconRole = "Heart",
    Callback = function(state) hatchState.stopOnMythic = state end,
})
StopSec:AddToggle({
    Text = "Stop on Rainbow / Golden",
    Default = false,
    IconRole = "MoneyBag",
    Callback = function(state) hatchState.stopOnRainbow = state end,
})

----------------------------------------------------------------
-- Dev tab — Session Stats + Remote Spy
----------------------------------------------------------------
local StatsSec = DevTab:AddSection({ Name = "Session Stats" })

local lblHatches = StatsSec:AddLabel({ Text = "Hatches: 0", IconRole = "Sparkles" })
local lblRares   = StatsSec:AddLabel({ Text = "Rares: 0",   IconRole = "Heart" })
local lblLoot    = StatsSec:AddLabel({ Text = "Lootbags: 0", IconRole = "MoneyBag" })
local lblClicks  = StatsSec:AddLabel({ Text = "Clicks: 0",  IconRole = "Paw" })
local lblErrors  = StatsSec:AddLabel({ Text = "Errors: 0",  IconRole = "Shield" })
local lblUptime  = StatsSec:AddLabel({ Text = "Uptime: 0s", IconRole = "Bell" })

local function fmtUptime(sec)
    sec = math.floor(sec)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    if h > 0 then return string.format("%dh %dm %ds", h, m, s) end
    if m > 0 then return string.format("%dm %ds", m, s) end
    return s .. "s"
end

task.spawn(function()
    while true do
        task.wait(1)
        lblHatches:Set("Hatches: " .. pixieStats.hatches)
        lblRares:Set("Rares: " .. pixieStats.rares)
        lblLoot:Set("Lootbags: " .. pixieStats.lootbags)
        lblClicks:Set("Clicks: " .. pixieStats.clicks)
        lblErrors:Set("Errors: " .. pixieStats.errors)
        lblUptime:Set("Uptime: " .. fmtUptime(os.clock() - pixieStats.startTs))
    end
end)

StatsSec:AddButton({
    Text = "Reset counters",
    ButtonText = "Reset",
    IconRole = "Bell",
    Callback = function()
        pixieStats.hatches  = 0
        pixieStats.rares    = 0
        pixieStats.lootbags = 0
        pixieStats.clicks   = 0
        pixieStats.errors   = 0
        pixieStats.startTs  = os.clock()
    end,
})

----------------------------------------------------------------
-- Remote Spy — hooks __namecall via hookmetamethod when the
-- executor supports it. Prints outbound FireServer/InvokeServer
-- calls routed through ReplicatedStorage.Network.
----------------------------------------------------------------
local SpySec = DevTab:AddSection({ Name = "Remote Spy" })

local spyState = { enabled = false, hooked = false }

local function installSpy()
    if spyState.hooked then return true end
    if type(hookmetamethod) ~= "function" then
        return false, "hookmetamethod not available"
    end
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod and getnamecallmethod() or ""
        if spyState.enabled and (method == "FireServer" or method == "InvokeServer") then
            local parent = self.Parent
            if parent and parent.Name == "Network" then
                local args = { ... }
                local parts = {}
                for i, v in ipairs(args) do
                    if i > 4 then break end
                    parts[i] = tostring(v):sub(1, 60)
                end
                print(string.format("[Pixie Spy] %s :%s(%s)",
                    self.Name, method, table.concat(parts, ", ")))
            end
        end
        return oldNamecall(self, ...)
    end)
    spyState.hooked = true
    return true
end

SpySec:AddToggle({
    Text = "Log outbound remotes",
    Default = false,
    IconRole = "Bell",
    Callback = function(state)
        if state then
            local ok, err = installSpy()
            if not ok then
                Window:Notify({ Title = "Pixie", Content = "Spy unavailable: " .. tostring(err), Duration = 4 })
                return
            end
            Window:Notify({ Title = "Pixie", Content = "Remote Spy on — check F9 console.", Duration = 3 })
        end
        spyState.enabled = state
    end,
})

-- Settings tab — menu toggle keybind + hide + close, zero overlap with other tabs
local Settings = Window:AddTab({ Name = "Settings", IconRole = "Settings" })

----------------------------------------------------------------
-- FPS Boost / Anti-Lag — strips the heavy VFX PS99 piles on
----------------------------------------------------------------
local Lighting = game:GetService("Lighting")

local perfState = { fpsBoost = false, antiLag = false }

local function stripVFX(inst)
    if inst:IsA("ParticleEmitter") or inst:IsA("Trail") or inst:IsA("Beam") or inst:IsA("Smoke") or inst:IsA("Fire") or inst:IsA("Sparkles") then
        inst.Enabled = false
    elseif inst:IsA("Explosion") then
        inst.BlastRadius = 0
        inst.BlastPressure = 0
    end
end

local fpsConn
local function applyFpsBoost(on)
    perfState.fpsBoost = on
    if on then
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 1e6
            Lighting.Brightness = 1
        end)
        for _, d in ipairs(workspace:GetDescendants()) do stripVFX(d) end
        if not fpsConn then
            fpsConn = workspace.DescendantAdded:Connect(function(d)
                if perfState.fpsBoost then stripVFX(d) end
            end)
        end
    else
        if fpsConn then fpsConn:Disconnect(); fpsConn = nil end
        pcall(function() Lighting.GlobalShadows = true end)
    end
end

local lagConn
local LAG_FOLDERS = { "VFX", "Pets", "AnimatedBreakables", "RenderedEggs", "PaintSplotches", "Ornaments" }
local function stripPS99Clutter()
    local things = workspace:FindFirstChild("__THINGS")
    if not things then return end
    for _, fname in ipairs(LAG_FOLDERS) do
        local f = things:FindFirstChild(fname)
        if f then
            for _, d in ipairs(f:GetDescendants()) do
                if d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("PointLight") or d:IsA("SpotLight") then
                    d.Enabled = false
                end
                if d:IsA("MeshPart") or d:IsA("Part") then
                    d.Material = Enum.Material.SmoothPlastic
                    d.Reflectance = 0
                end
            end
        end
    end
end
local function applyAntiLag(on)
    perfState.antiLag = on
    if on then
        stripPS99Clutter()
        if not lagConn then
            lagConn = workspace.DescendantAdded:Connect(function()
                if perfState.antiLag then task.defer(stripPS99Clutter) end
            end)
        end
    else
        if lagConn then lagConn:Disconnect(); lagConn = nil end
    end
end

local PerfSec = Settings:AddSection({ Name = "Performance" })

PerfSec:AddToggle({
    Text = "FPS Boost",
    Default = false,
    IconRole = "Sparkles",
    Callback = applyFpsBoost,
})

PerfSec:AddToggle({
    Text = "Anti-Lag (PS99 VFX strip)",
    Default = false,
    IconRole = "Shield",
    Callback = applyAntiLag,
})

local MenuSec = Settings:AddSection({ Name = "Menu" })

MenuSec:AddKeybind({
    Text = "Toggle menu",
    Default = Enum.KeyCode.RightShift,
    Callback = function()
        Window:Toggle()
    end,
})

MenuSec:AddButton({
    Text = "Hide menu",
    ButtonText = "Hide",
    Callback = function()
        Window:Toggle(false)
    end,
})

MenuSec:AddButton({
    Text = "Close menu",
    ButtonText = "Close",
    Callback = function()
        Window:Destroy()
    end,
})

----------------------------------------------------------------
-- Starry night background — overlays a dark navy field with
-- twinkling stars across the window. Sits behind the sidebar
-- and content panels (they have their own BG).
----------------------------------------------------------------
local function makeStarryNight(root)
    -- Darker navy over the base window background
    local sky = Instance.new("Frame")
    sky.Name = "StarryNight"
    sky.AnchorPoint = Vector2.new(0, 0)
    sky.Position = UDim2.fromScale(0, 0)
    sky.Size = UDim2.fromScale(1, 1)
    sky.BackgroundColor3 = Color3.fromRGB(10, 12, 28)
    sky.BackgroundTransparency = 0.05
    sky.BorderSizePixel = 0
    sky.ZIndex = 0
    sky.Parent = root

    local skyCorner = Instance.new("UICorner")
    skyCorner.CornerRadius = UDim.new(0, 18)
    skyCorner.Parent = sky

    local skyGrad = Instance.new("UIGradient")
    skyGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,    Color3.fromRGB(22, 26, 54)),
        ColorSequenceKeypoint.new(0.55, Color3.fromRGB(12, 14, 34)),
        ColorSequenceKeypoint.new(1,    Color3.fromRGB(5,  6,  14)),
    })
    skyGrad.Rotation = 105
    skyGrad.Parent = sky

    -- Stars: 80 tiny white circles, random positions + sizes, twinkle loop.
    local rng = Random.new(6767)
    for i = 1, 80 do
        local star = Instance.new("Frame")
        local size = rng:NextInteger(1, 3)
        local big = size == 3
        star.Size = UDim2.fromOffset(size, size)
        star.Position = UDim2.fromScale(rng:NextNumber(), rng:NextNumber())
        star.AnchorPoint = Vector2.new(0.5, 0.5)
        star.BackgroundColor3 = big
            and Color3.fromRGB(190, 210, 255)
            or Color3.fromRGB(255, 255, 255)
        star.BorderSizePixel = 0
        star.BackgroundTransparency = rng:NextNumber(0.1, 0.6)
        star.ZIndex = 0
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = star
        star.Parent = sky

        task.spawn(function()
            local base = star.BackgroundTransparency
            while star.Parent do
                local tw = TweenService:Create(
                    star,
                    TweenInfo.new(rng:NextNumber(1.5, 3.5), Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 0, true),
                    { BackgroundTransparency = math.clamp(base + rng:NextNumber(0.2, 0.6), 0, 0.95) }
                )
                tw:Play()
                tw.Completed:Wait()
                task.wait(rng:NextNumber(0.5, 2))
            end
        end)
    end
end

makeStarryNight(Window.Root)

----------------------------------------------------------------
-- Button bounce animations — adds a UIScale pop on click and a
-- subtle hover grow to every TextButton / ImageButton in Pixie.
----------------------------------------------------------------
local function animateButton(btn)
    if btn:FindFirstChild("__PixieScale") then return end
    local scale = Instance.new("UIScale")
    scale.Name = "__PixieScale"
    scale.Scale = 1
    scale.Parent = btn

    btn.MouseButton1Down:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.08, Enum.EasingStyle.Quad), { Scale = 0.92 }):Play()
    end)
    btn.MouseButton1Up:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Scale = 1 }):Play()
    end)
    btn.MouseEnter:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Scale = 1.04 }):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(scale, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Scale = 1 }):Play()
    end)
end

-- Walk every existing button in the UI
for _, d in ipairs(Window.Root:GetDescendants()) do
    if d:IsA("TextButton") or d:IsA("ImageButton") then
        pcall(animateButton, d)
    end
end
-- Catch any button added later (dropdown options etc.)
Window.Root.DescendantAdded:Connect(function(d)
    if d:IsA("TextButton") or d:IsA("ImageButton") then
        task.defer(function() pcall(animateButton, d) end)
    end
end)

Window:Notify({
    Title = "Pixie | PS99",
    Content = "Menu loaded with starry night + button pop.",
    Duration = 4,
})
