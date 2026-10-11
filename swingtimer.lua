-- Restyle Blizzard's swing timer bars: remove their border and give them the same
-- texture as the player frame's health bar. Blizzard can reset the texture, so it's
-- re-applied whenever a bar's texture changes.
local swingTimerNames = { "SwingTimerMainHandFrame", "SwingTimerOffHandFrame", "SwingTimerRangedFrame" }

-- Blizzard's default player frame health bar fill
local HEALTH_BAR_ATLAS = "UI-HUD-UnitFrame-Player-PortraitOn-Bar-Health"

local function GetSwingStatusBar(frame)
	if frame.StatusBar then return frame.StatusBar end
	if frame.SetStatusBarTexture then return frame end
end

local function ApplyHealthTexture(statusBar)
	statusBar.hepApplying = true
	statusBar:SetStatusBarTexture(HEALTH_BAR_ATLAS)
	-- Remove the atlas's baked-in green so only the swing bar's own color shows
	statusBar:SetStatusBarDesaturated(true)
	statusBar.hepApplying = nil
end

local function StyleSwingTimers()
	for _, frameName in ipairs(swingTimerNames) do
		local frame = _G[frameName]
		if frame then
			if frame.Border then
				frame.Border:SetAlpha(0)
			end

			local statusBar = GetSwingStatusBar(frame)
			if statusBar then
				if not statusBar.hepHooked then
					statusBar.hepHooked = true
					hooksecurefunc(statusBar, "SetStatusBarTexture", function(self)
						if not self.hepApplying then
							ApplyHealthTexture(self)
						end
					end)
				end
				ApplyHealthTexture(statusBar)
			end
		end
	end
end

local swingTimerFrame = CreateFrame("Frame")
swingTimerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
swingTimerFrame:RegisterEvent("ADDON_LOADED")
swingTimerFrame:SetScript("OnEvent", StyleSwingTimers)
