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
	MicroMenu:Hide()
	
end

hiderFrame:RegisterEvent("ADDON_LOADED")
hiderFrame:SetScript("OnEvent", hiderFrame.OnEvent)

SLASH_TOGGLEBARS1 = "/togglebars"
SLASH_TOGGLEBARS2 = "/tb"

SlashCmdList["TOGGLEBARS"] = function()
	
	if hiderFrame:IsVisible() then
		hiderFrame:Hide()
		MicroMenu:Hide()
	else
		hiderFrame:Show()
		MicroMenu:Show()
	end
	
end