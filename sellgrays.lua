-- Sell Grays

local BATCH_SIZE = 10      -- items sold per pass
local BATCH_DELAY = 0.3    -- seconds between passes
local MAX_IDLE_PASSES = 10 -- passes with only locked items before giving up

local selling = false
local idlePasses = 0
local graySlots = {} -- flattened bag, slot pairs found by FindGrays

local function AtMerchant()
	return MerchantFrame ~= nil and MerchantFrame:IsShown()
end

-- Scan the bags once; later passes only re-check the slots found here.
local function FindGrays()

	wipe(graySlots)

	for b = 0, 5 do
		for s = 1, C_Container.GetContainerNumSlots(b) do

			local i = C_Container.GetContainerItemInfo(b, s)

			if i ~= nil and i.quality == 0 and not i.hasNoValue then
				graySlots[#graySlots + 1] = b
				graySlots[#graySlots + 1] = s
			end

		end
	end

end

local function SellBatch()

	if not AtMerchant() then
		selling = false
		return
	end

	local sold, pending = 0, false

	for n = 1, #graySlots, 2 do

		local b, s = graySlots[n], graySlots[n + 1]
		local i = C_Container.GetContainerItemInfo(b, s)

		if i ~= nil and i.quality == 0 and not i.hasNoValue then
			if i.isLocked then
				-- Sale already sent, waiting on the server
				pending = true
			elseif sold < BATCH_SIZE then
				C_Container.UseContainerItem(b, s)
				print(C_Item.GetItemInfo(i.hyperlink) or i.hyperlink)
				sold = sold + 1
			else
				pending = true
			end
		end

	end

	if sold > 0 then
		idlePasses = 0
	elseif pending then
		idlePasses = idlePasses + 1
	end

	if (sold > 0 or pending) and idlePasses < MAX_IDLE_PASSES then
		C_Timer.After(BATCH_DELAY, SellBatch)
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
	idlePasses = 0
	FindGrays()
	SellBatch()

end
