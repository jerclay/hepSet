-- Sell Grays

local BATCH_SIZE = 10      -- items sold per pass
local BATCH_DELAY = 0.3    -- seconds between passes
local MAX_IDLE_PASSES = 10 -- passes with only locked items before giving up

local selling = false

local function AtMerchant()
	return MerchantFrame ~= nil and MerchantFrame:IsShown()
end

local function SellBatch(idlePasses)

	if not AtMerchant() then
		selling = false
		return
	end

	local sold, pending = 0, false

	for b = 0, 5 do
		for s = 1, C_Container.GetContainerNumSlots(b) do

			local i = C_Container.GetContainerItemInfo(b, s)

			if i ~= nil and i.quality == 0 and not i.hasNoValue then
				if i.isLocked then
					-- Sale already sent, waiting on the server
					pending = true
				elseif sold < BATCH_SIZE then
					local v = {C_Item.GetItemInfo(i.hyperlink)}
					C_Container.UseContainerItem(b, s)
					print(v[1] or i.hyperlink)
					sold = sold + 1
				else
					pending = true
				end
			end

		end
	end

	if sold > 0 then
		idlePasses = 0
	elseif pending then
		idlePasses = idlePasses + 1
	end

	if (sold > 0 or pending) and idlePasses < MAX_IDLE_PASSES then
		C_Timer.After(BATCH_DELAY, function() SellBatch(idlePasses) end)
	else
		selling = false
	end

end

SLASH_SELLGRAYS1 = "/sellgrays"

SlashCmdList["SELLGRAYS"] = function()

	if not AtMerchant() then
		print("Not interacting with vendor.")
		return
	end

	if selling then return end

	selling = true
	SellBatch(0)

end
