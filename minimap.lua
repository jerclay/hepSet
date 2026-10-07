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

-- Lay out the enlarged top bar.

local MinimapGap = 4 -- space between the bottom of the top bar and the minimap
local ClockGap = 2   -- space between the clock and the addon button

-- Stretch the zone text across the space between the tracking and calendar buttons.
local function PlaceZoneText()
	local zoneButton = MinimapCluster.ZoneTextButton
	local tracking = MinimapCluster.Tracking
	if not (zoneButton and tracking and GameTimeFrame and MinimapZoneText) then return end
	
	zoneButton:ClearAllPoints()
	zoneButton:SetPoint("LEFT", tracking, "RIGHT", 2, 0)
	zoneButton:SetPoint("RIGHT", GameTimeFrame, "LEFT", -2, 0)
	
	MinimapZoneText:ClearAllPoints()
	MinimapZoneText:SetPoint("LEFT", zoneButton, "LEFT")
	MinimapZoneText:SetPoint("RIGHT", zoneButton, "RIGHT")
	MinimapZoneText:SetJustifyH("CENTER")
end

-- Center the minimap under the zone text, just below the top bar.
local function PlaceMinimap()
	local container = MinimapCluster.MinimapContainer
	local bar = MinimapCluster.BorderTop
	local zoneButton = MinimapCluster.ZoneTextButton
	if not zoneButton then return end
	
	local barBottom, zoneBottom = bar:GetBottom(), zoneButton:GetBottom()
	if not (barBottom and zoneBottom) then return end
	
	-- Distance from the bottom of the zone text to the bottom of the bar, in the container's scale.
	local drop = (zoneBottom * zoneButton:GetEffectiveScale() - barBottom * bar:GetEffectiveScale()) / container:GetEffectiveScale()
	
	container:ClearAllPoints()
	container:SetPoint("TOP", zoneButton, "BOTTOM", 0, -(drop + MinimapGap))
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

-- Move the clock down beside the addon button.
local function PlaceClock()
	if not (TimeManagerClockButton and AddonCompartmentFrame) then return end
	
	TimeManagerClockButton:ClearAllPoints()
	TimeManagerClockButton:SetPoint("RIGHT", AddonCompartmentFrame, "LEFT", -ClockGap, 0)
end

local function PlaceTopBar()
	PlaceZoneText()
	PlaceMinimap()
	PlaceCoords()
	PlaceClock()
end

-- The positions can only be measured once the UI is on screen.
local layoutWatcher = CreateFrame("Frame")
layoutWatcher:RegisterEvent("PLAYER_ENTERING_WORLD")
layoutWatcher:SetScript("OnEvent", PlaceTopBar)

-- The game resets these positions when the header position is changed in Edit Mode.
if MinimapCluster.SetHeaderUnderneath then
	hooksecurefunc(MinimapCluster, "SetHeaderUnderneath", PlaceTopBar)
end

-- The clock comes from Blizzard_TimeManager, which may load after this addon.
local function ScaleClock()
	table.insert(TopBarPieces, TimeManagerClockButton)
	ScaleTopBarPiece(TimeManagerClockButton)
	PlaceClock()
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
