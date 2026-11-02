-- Make the minimap coords font bigger.
local _, ns = ...

local CoordText = MinimapCluster.MinimapContainer.PlayerCoords.CoordText
local CoordFont, _, CoordFlags = CoordText:GetFont()
CoordText:SetFont(CoordFont, 14, CoordFlags)

-- Enlarge the bar along the top of the minimap.

local TopBarScale = 1.5

-- Keyed by frame, so checking whether a frame is a piece is a single lookup.
local TopBarPieces = {}
for _, piece in pairs({
	MinimapCluster.BorderTop,
	MinimapCluster.Tracking or MiniMapTracking,
	MinimapCluster.ZoneTextButton or MinimapZoneTextButton,
	GameTimeFrame,
	AddonCompartmentFrame,
}) do
	TopBarPieces[piece] = true
end

local function ScaleTopBarPiece(piece)
	-- Skip pieces whose parent is also being scaled, so they aren't scaled twice.
	if piece.SetScale and not TopBarPieces[piece:GetParent()] then
		piece:SetScale(TopBarScale)
	end
end

for piece in pairs(TopBarPieces) do
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
ns.RegisterEvent("PLAYER_ENTERING_WORLD", PlaceCoords)

-- The game resets these positions when the header position is changed in Edit Mode.
if MinimapCluster.SetHeaderUnderneath then
	hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", PlaceCoords)
end

-- The clock comes from Blizzard_TimeManager, which may load after this addon.
local function ScaleClock()
	TopBarPieces[TimeManagerClockButton] = true
	ScaleTopBarPiece(TimeManagerClockButton)
end

local function WaitForClock(event, addOnName)
	if addOnName == "Blizzard_TimeManager" and TimeManagerClockButton then
		ScaleClock()
		ns.UnregisterEvent("ADDON_LOADED", WaitForClock)
	end
end

if TimeManagerClockButton then
	ScaleClock()
else
	ns.RegisterEvent("ADDON_LOADED", WaitForClock)
end