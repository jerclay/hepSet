-- Remove the measurement lines (dividers) from the experience bar and status bar 2.
-- Each line is a child frame of the bar container holding a BarDividerTexture. Blizzard
-- rebuilds and re-shows them as the bars update, so each texture is locked hidden once found,
-- and the containers are rescanned whenever they show, resize, or update their dividers.
local _, ns = ...

local statusBarContainers = { "MainStatusTrackingBarContainer", "SecondaryStatusTrackingBarContainer" }

local function HideIfShown(self, shown)
	if shown then self:Hide() end
end

local function LockDividerHidden(texture)
	if texture.hepLocked then return end
	texture.hepLocked = true
	hooksecurefunc(texture, "Show", texture.Hide)
	hooksecurefunc(texture, "SetShown", HideIfShown)
end

-- Takes the children as varargs so a scan doesn't build a table.
local function HideChildDividers(...)
	for i = 1, select("#", ...) do
		local texture = (select(i, ...)).BarDividerTexture
		if texture then
			LockDividerHidden(texture)
			texture:Hide()
		end
	end
end

local function GetContainer(containerName)
	return (StatusTrackingBarManager and StatusTrackingBarManager[containerName]) or _G[containerName]
end

local function HideStatusBarDividers()
	for _, containerName in ipairs(statusBarContainers) do
		local container = GetContainer(containerName)
		if container then
			HideChildDividers(container:GetChildren())
		end
	end
end

-- Several hooks can fire in the same frame, so they share one deferred rescan.
local rescanPending = false

local function RunRescan()
	rescanPending = false
	HideStatusBarDividers()
end

local function Rescan()
	if rescanPending then return end
	rescanPending = true
	C_Timer.After(0, RunRescan)
end

-- XP and reputation updates don't need a scan of their own: locked textures stay hidden,
-- and rebuilt dividers are caught by the container hooks below.
ns.RegisterEvent("PLAYER_ENTERING_WORLD", function()
	HideStatusBarDividers()
	Rescan()
end)

for _, containerName in ipairs(statusBarContainers) do
	local container = GetContainer(containerName)
	if container then
		container:HookScript("OnShow", Rescan)
		container:HookScript("OnSizeChanged", Rescan)

		-- Hook whatever method Blizzard uses to (re)build the dividers
		for key, value in pairs(container) do
			if type(value) == "function" and type(key) == "string" and key:find("Divider") then
				hooksecurefunc(container, key, Rescan)
			end
		end
	end
end