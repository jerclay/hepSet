-- Shared state and a single event frame, so each feature doesn't need its own frame.
local _, ns = ...

-- Action bars in /tbar's numbering. The UI toggle hides the first HIDDEN_BAR_COUNT of them.
ns.actionBarNames = {"MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7"}
ns.HIDDEN_BAR_COUNT = 6

local eventFrame = CreateFrame("Frame")
local handlers = {}

-- handler is called as handler(event, ...)
function ns.RegisterEvent(event, handler)
	if not handlers[event] then
		handlers[event] = {}
		eventFrame:RegisterEvent(event)
	end
	handlers[event][handler] = true
end

-- Safe to call from inside a handler for the same event.
function ns.UnregisterEvent(event, handler)
	local list = handlers[event]
	if not list then return end
	list[handler] = nil
	if next(list) == nil then
		handlers[event] = nil
		eventFrame:UnregisterEvent(event)
	end
end

eventFrame:SetScript("OnEvent", function(_, event, ...)
	local list = handlers[event]
	if not list then return end
	for handler in pairs(list) do
		handler(event, ...)
	end
end)
