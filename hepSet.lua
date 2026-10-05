-- Remove some basics.

RegisterStateDriver(StanceBar, "visibility", "hide")
TalkingHeadFrame:SetScale(0.7)
AlertFrame:SetScale(0.5)
AlertFrame:SetPoint("BOTTOM", 1400, 550)
--ZoneTextFrame:ClearAllPoints()
--ZoneTextFrame:SetScale(0.75)
--ZoneTextFrame:SetPoint("TOP", UIParent, "TOP", 0, 10)

if BBFComboPointBarPRD then
	BBFComboPointBarPRD:UnregisterAllEvents()
	BBFComboPointBarPRD:Hide()
end