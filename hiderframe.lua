-- Create a frame I can toggle for visibility.
local _, ns = ...

local hiderFrame = CreateFrame("Frame", "HiderFrame", UIParent)
hiderFrame:SetPoint("TOPLEFT", 0, 0)

-- Tie the MicroMenu's visibility to hiderFrame. The MicroMenu isn't reparented
-- because Blizzard moves it between parents (e.g. onto the vehicle bar), so
-- instead it follows hiderFrame's show/hide and is re-hidden if anything else shows it.
hiderFrame:SetScript("OnShow", function()
	MicroMenu:Show()
end)

hiderFrame:SetScript("OnHide", function()
	MicroMenu:Hide()
end)

MicroMenu:HookScript("OnShow", function(self)
	if not hiderFrame:IsShown() then
		self:Hide()
	end
end)

-- The bars already exist when this file runs, so they can be moved in right away.
for n = 1, ns.HIDDEN_BAR_COUNT do
	_G[ns.actionBarNames[n]]:SetParent(hiderFrame)
end
BagsBar:SetParent(hiderFrame)

hiderFrame:Hide()

SLASH_TOGGLEBARS1 = "/togglebars"

SlashCmdList["TOGGLEBARS"] = function()

	-- hiderFrame holds protected action bars, so it can't be shown or hidden in combat.
	if InCombatLockdown() then
		print("In combat.")
		return
	end

	if hiderFrame:IsShown() then
		hiderFrame:Hide()
	else
		hiderFrame:Show()
	end

end
