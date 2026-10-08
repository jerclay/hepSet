-- Create a frame I can toggle for visibility.

hiderFrame = CreateFrame("Frame", "HiderFrame", UIParent)
hiderFrame:SetPoint("TOPLEFT", 0, 0)

function hiderFrame:OnEvent(event, addOnName)

	if addOnName ~= "hepSet" then
		return
	end

	local bars = {"MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft", "MultiBar5", "BagsBar"}

	for _, barName in pairs(bars) do
		local bar = _G[barName]
		bar:SetParent(self)
	end

	self:Hide()

end

hiderFrame:RegisterEvent("ADDON_LOADED")
hiderFrame:SetScript("OnEvent", hiderFrame.OnEvent)

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

SLASH_TOGGLEBARS1 = "/togglebars"
SLASH_TOGGLEBARS2 = "/tb"

SlashCmdList["TOGGLEBARS"] = function()

	if hiderFrame:IsShown() then
		hiderFrame:Hide()
	else
		hiderFrame:Show()
	end

end
