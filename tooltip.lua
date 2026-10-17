-- Tooltip anchor

-- Anchor the default tooltip by its bottom center to the Edit Mode tooltip position.
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tooltip, parent)
	if GameTooltipDefaultContainer == nil then return end
	tooltip:ClearAllPoints()
	tooltip:SetPoint("BOTTOM", GameTooltipDefaultContainer, "BOTTOM", 0, 0)
end)
