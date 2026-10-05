-- Sell Grays

SLASH_SELLGRAYS1 = "/sellgrays"

SlashCmdList["SELLGRAYS"] = function()
	
	local c, i, v = 0
	
	for b = 0, 5 do
		for s = 1, C_Container.GetContainerNumSlots(b) do
			
			i = C_Container.GetContainerItemInfo(b, s)
			
			if i ~= nil and i.quality == 0 then
				v = {C_Item.GetItemInfo(C_Container.GetContainerItemLink(b, s))}
				C_Container.UseContainerItem(b, s)
				print(v[1])
			end
			
		end
	end
	
end