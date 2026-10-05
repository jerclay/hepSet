-- Remove some basics.

RegisterStateDriver(StanceBar, "visibility", "hide")
TalkingHeadFrame:SetScale(0.7)
AlertFrame:SetScale(0.5)
AlertFrame:SetPoint("BOTTOM", 1400, 550)
--ZoneTextFrame:ClearAllPoints()
--ZoneTextFrame:SetScale(0.75)
--ZoneTextFrame:SetPoint("TOP", UIParent, "TOP", 0, 10)

-- Make the minimap coords font bigger.

local CoordText = MinimapCluster.MinimapContainer.PlayerCoords.CoordText
local CoordFont, _, CoordFlags = CoordText:GetFont()
CoordText:SetFont(CoordFont, 14, CoordFlags)