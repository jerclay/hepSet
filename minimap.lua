-- Make the minimap coords font bigger.

local CoordText = MinimapCluster.MinimapContainer.PlayerCoords.CoordText
local CoordFont, _, CoordFlags = CoordText:GetFont()
CoordText:SetFont(CoordFont, 14, CoordFlags)

-- Enlarge the bar along the top of the minimap.

local TopBarScale = 1.5

local TopBarPieces = {
	MinimapCluster.BorderTop,
	MinimapCluster.Tracking or MiniMapTracking,
	MinimapCluster.ZoneTextButton or MinimapZoneTextButton,
	GameTimeFrame,
	AddonCompartmentFrame,
}

local function IsTopBarPiece(frame)
	for _, piece in pairs(TopBarPieces) do
		if piece == frame then
			return true
		end
	end
	return false
end

local function ScaleTopBarPiece(piece)
	-- Skip pieces whose parent is also being scaled, so they aren't scaled twice.
	if piece.SetScale and not IsTopBarPiece(piece:GetParent()) then
		piece:SetScale(TopBarScale)
	end
end

for _, piece in pairs(TopBarPieces) do
	ScaleTopBarPiece(piece)
end

-- Center the coordinates horizontally, keeping their vertical position.
local function PlaceCoords()
	local coords = MinimapCluster.MinimapContainer.PlayerCoords
	if not coords or coords:GetNumPoints() == 0 then return end
	
	local point, relativeTo, relativePoint, _, y = coords:GetPoint(1)
	point = point:gsub("LEFT", ""):gsub("RIGHT", "")
	relativePoint = relativePoint:gsub("LEFT", ""):gsub("RIGHT", "")
	if point == "" then point = "CENTER" end
	if relativePoint == "" then relativePoint = "CENTER" end
	
	coords:ClearAllPoints()
	coords:SetPoint(point, relativeTo, relativePoint, 0, y)
end

-- The coordinates can only be repositioned once the UI is on screen.
local layoutWatcher = CreateFrame("Frame")
layoutWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
layoutWatcher:SetScript("OnEvent", PlaceCoords)

-- The game resets these positions when the header position is changed in Edit Mode.
if MinimapCluster.SetHeaderUnderneath then
	hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", PlaceCoords)
end

-- The clock comes from Blizzard_TimeManager, which may load after this addon.
local function ScaleClock()
	table.insert(TopBarPieces, TimeManagerClockButton)
	ScaleTopBarPiece(TimeManagerClockButton)
end

if TimeManagerClockButton then
	ScaleClock()
else
	local clockWatcher = CreateFrame("Frame")
	clockWatcher:RegisterEvent("ADDON_LOADED")
	clockWatcher:SetScript("OnEvent", function(self, event, addOnName)
		if addOnName == "Blizzard_TimeManager" and TimeManagerClockButton then
			ScaleClock()
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)
end