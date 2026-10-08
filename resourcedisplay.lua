function ModifyResourceBar()
    if not PersonalResourceDisplayFrame then return end

    local function ApplyBlackMissingBackground(bar)
        if not bar then return end
        
        -- 1. Get the primary fill texture
        local statusBarTexture = bar:GetStatusBarTexture()
        
        -- 2. Strip the default Blizzard borders/background frames
        if bar.Background then bar.Background:SetAlpha(0) end
        local regions = { bar:GetRegions() }
        for _, region in ipairs(regions) do
            if region:IsObjectType("Texture") and region ~= statusBarTexture and region ~= bar.customBlackBg then
                region:SetTexture(nil)
                region:Hide()
            end
        end

        -- 3. Create or update our explicit black background layer
        if not bar.customBlackBg then
            -- Create the texture on a lower layer ("BACKGROUND") so it sits behind the health/power fills
            bar.customBlackBg = bar:CreateTexture(nil, "BACKGROUND")
            bar.customBlackBg:SetAllPoints(bar)
            bar.customBlackBg:SetColorTexture(0, 0, 0, 0.5) -- Pure Black (RGBA: 0,0,0,1)
        else
            bar.customBlackBg:Show()
        end

    end

    -- Apply the black backdrop to the Health Bar
    if PersonalResourceDisplayFrame.HealthBarsContainer and PersonalResourceDisplayFrame.HealthBarsContainer.healthBar then
        ApplyBlackMissingBackground(PersonalResourceDisplayFrame.HealthBarsContainer.healthBar)
    end
    
    -- Apply the black backdrop to the Main Power Bar
    if PersonalResourceDisplayFrame.PowerBar then
        ApplyBlackMissingBackground(PersonalResourceDisplayFrame.PowerBar)
    end

    -- Apply the black backdrop to the Alternate Power Bar
    if PersonalResourceDisplayFrame.AlternatePowerBar then
        ApplyBlackMissingBackground(PersonalResourceDisplayFrame.AlternatePowerBar)
    end
end

-- Hook into the frame's update cycles so changes persist across spec changes/reloads
if PersonalResourceDisplayFrame then
    PersonalResourceDisplayFrame:HookScript("OnShow", ModifyResourceBar)
    if PersonalResourceDisplayFrame:IsShown() then
        ModifyResourceBar()
    end
end

-- Move the class resource (combo points, soul shards, etc.) above the other bars instead of below them.
-- Blizzard (and other addons) re-anchor the container below the bars from several places, so
-- every time it's anchored we put it back on top of the highest visible bar.
local function AnchorClassFrameOnTop(container)
    if container.hepAnchoring then return end

    local prd = PersonalResourceDisplayFrame
    local topBar
    if not prd.hideHealth and prd.HealthBarsContainer:IsShown() then
        topBar = prd.HealthBarsContainer
    elseif not prd.hidePower and prd.PowerBar:IsShown() then
        topBar = prd.PowerBar
    elseif prd.AlternatePowerBar and prd.AlternatePowerBar:IsShown() then
        topBar = prd.AlternatePowerBar
    end

    container.hepAnchoring = true
    container:ClearAllPoints()
    if topBar then
        -- yOffset is the spacing Blizzard uses below the bars; mirror it for spacing above
        container:SetPoint("BOTTOM", topBar, "TOP", 0, -(container.yOffset or 0))
    else
        container:SetPoint("TOP", prd, "TOP", 0, container.yOffset or 0)
    end
    container.hepAnchoring = nil
end

if PersonalResourceDisplayFrame and PersonalResourceDisplayFrame.ClassFrameContainer then
    local container = PersonalResourceDisplayFrame.ClassFrameContainer
    hooksecurefunc(container, "SetPoint", AnchorClassFrameOnTop)
    AnchorClassFrameOnTop(container)
end
