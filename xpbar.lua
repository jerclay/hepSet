-- Remove the measurement lines (dividers) from the experience bar and status bar 2.
-- Each line is a child frame of the bar container holding a BarDividerTexture. Blizzard
-- rebuilds and re-shows them as the bars update, so each texture is locked hidden once found,
-- and the containers are rescanned whenever they show, resize, or update their dividers.
local statusBarContainers = { "MainStatusTrackingBarContainer", "SecondaryStatusTrackingBarContainer" }

local function LockDividerHidden(texture)
	if texture.hepLocked then return end
	texture.hepLocked = true
	hooksecurefunc(texture, "Show", texture.Hide)
	hooksecurefunc(texture, "SetShown", function(self, shown)
		if shown then self:Hide() end
	end)
end

local function HideStatusBarDividers()
	for _, containerName in ipairs(statusBarContainers) do
		local container = (StatusTrackingBarManager and StatusTrackingBarManager[containerName]) or _G[containerName]
		if container then
			for _, child in ipairs({ container:GetChildren() }) do
				local texture = child.BarDividerTexture
				if texture then
					LockDividerHidden(texture)
					texture:Hide()
				end
			end
		end
	end
end

local dividerFrame = CreateFrame("Frame")
dividerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
dividerFrame:RegisterEvent("PLAYER_XP_UPDATE")
dividerFrame:RegisterEvent("UPDATE_FACTION")
dividerFrame:SetScript("OnEvent", function()
	HideStatusBarDividers()
	C_Timer.After(0, HideStatusBarDividers)
end)

for _, containerName in ipairs(statusBarContainers) do
	local container = (StatusTrackingBarManager and StatusTrackingBarManager[containerName]) or _G[containerName]
	if container then
		local function Rescan()
			C_Timer.After(0, HideStatusBarDividers)
		end
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