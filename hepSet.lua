-- Remove some basics.

-- The stance bar lives in a frame that's never shown, which keeps it hidden without a
-- state driver re-evaluating it for the whole session.
local neverShown = CreateFrame("Frame")
neverShown:Hide()
StanceBar:SetParent(neverShown)

TalkingHeadFrame:SetScale(0.7)
AlertFrame:SetScale(0.5)
AlertFrame:SetPoint("BOTTOM", 1400, 550)
--ZoneTextFrame:ClearAllPoints()
--ZoneTextFrame:SetScale(0.75)
--ZoneTextFrame:SetPoint("TOP", UIParent, "TOP", 0, 10)