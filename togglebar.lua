-- Toggle a single action bar.

local barNames = {"MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7"}

-- state: nil = toggle, true = show only, false = hide only
function ToggleBar(num, state)

	local bar = _G[barNames[num]]

	if bar == nil then
		print("No action bar " .. tostring(num) .. ".")
		return
	end

	if InCombatLockdown() then
		print("In combat.")
		return
	end

	if state == nil then
		state = not bar:IsShown()
	end

	if state and not bar:IsShown() then
		bar:Show()
	elseif not state and bar:IsShown() then
		bar:Hide()
	end

end

SLASH_TBAR1 = "/tbar"

SlashCmdList["TBAR"] = function(msg)

	local x, y = strsplit(" ", strtrim(msg or ""))
	local num = tonumber(x)
	local state

	if y ~= nil then
		y = strlower(y)
	end

	if y == "on" or y == "1" then
		state = true
	elseif y == "off" or y == "0" then
		state = false
	elseif y ~= nil and y ~= "" then
		num = nil
	end

	if num == nil then
		print("Usage: /tbar <bar number> [on|off|1|0]")
		return
	end

	ToggleBar(num, state)

end
