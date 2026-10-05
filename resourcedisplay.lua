function ModifyPRD()
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
        
        -- Ensure the standard directional orientation is active (Right-to-Left depletion)
        bar:SetOrientation("HORIZONTAL")
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
    PersonalResourceDisplayFrame:HookScript("OnShow", ModifyPRD)
    if PersonalResourceDisplayFrame:IsShown() then
        ModifyPRD()
    end
end