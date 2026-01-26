-- Options panel
local optionsPanel = nil
local L = PartyArrowLocals or {}
local function Loc(key, fallback)
    return L[key] or fallback or key
end

function PartyArrow_CreateOptionsPanel()
    if optionsPanel then return optionsPanel end
    optionsPanel = CreateFrame("Frame", "PartyArrowOptionsPanel", UIParent)
    optionsPanel.name = Loc("OPTIONS_TITLE", "PartyArrow")
    local bg = optionsPanel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.35)

    local logo = optionsPanel:CreateTexture(nil, "ARTWORK")
    logo:SetPoint("TOPLEFT", 16, -16)
    logo:SetSize(128, 128)
    logo:SetTexture("Interface\\AddOns\\PartyArrow\\images\\logo")

    local title = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 16, -8)
    title:SetText(Loc("OPTIONS_TITLE", "PartyArrow"))
    title:SetTextColor(1, 0.82, 0)
    local subtitle = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetText(Loc("OPTIONS_SUBTITLE", "Copyright (c) 2026 TC Conway. All rights reserved."))

    local creditsBody = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    creditsBody:SetPoint("TOPLEFT", logo, "BOTTOMLEFT", 0, -24)
    creditsBody:SetPoint("RIGHT", optionsPanel, "RIGHT", -16, 0)
    creditsBody:SetJustifyH("LEFT")
    creditsBody:SetText(Loc("OPTIONS_DETAILS", "|cffffd200Author:|r TCConway\nWith inspiration and original code by Jayama\n\n|cffffd200Special Thanks:|r\nThe WoW addon community and Blizzard."))

    local settingsDivider = optionsPanel:CreateTexture(nil, "ARTWORK")
    settingsDivider:SetPoint("TOPLEFT", creditsBody, "BOTTOMLEFT", 0, -12)
    settingsDivider:SetPoint("RIGHT", optionsPanel, "RIGHT", -16, 0)
    settingsDivider:SetHeight(1)
    settingsDivider:SetColorTexture(1, 1, 1, 0.15)

    local controlsHeader = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    controlsHeader:SetPoint("TOPLEFT", settingsDivider, "BOTTOMLEFT", 0, -12)
    controlsHeader:SetText(Loc("OPTIONS_SETTINGS_HEADER", "Settings"))

    local visibilityLabel = optionsPanel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    visibilityLabel:SetPoint("TOPLEFT", controlsHeader, "BOTTOMLEFT", 0, -8)
    visibilityLabel:SetText(Loc("OPTIONS_VISIBILITY_LABEL", "Arrow Frame visibility"))

    local visibilityDropdown = CreateFrame("Frame", "PartyArrowOptionsVisibilityDropdown", optionsPanel, "UIDropDownMenuTemplate")
    visibilityDropdown:SetPoint("TOPLEFT", visibilityLabel, "BOTTOMLEFT", -16, -6)
    UIDropDownMenu_SetWidth(visibilityDropdown, 200)
    UIDropDownMenu_SetText(visibilityDropdown, "")

    local visibilityOptions = {
        { value = "always", text = Loc("OPTIONS_VISIBILITY_ALWAYS", "Always show") },
        { value = "group", text = Loc("OPTIONS_VISIBILITY_GROUP", "Show only while in a group") },
        { value = "hidden", text = Loc("OPTIONS_VISIBILITY_HIDDEN", "Hide") },
    }

    local function GetVisibilityMode()
        if PartyArrow_GetVisibilityMode then
            return PartyArrow_GetVisibilityMode()
        end
        local db = PartyArrowDB or {}
        if db.visibilityMode then
            return db.visibilityMode
        end
        if db.visible == false then
            return "hidden"
        end
        return "always"
    end

    local function ApplyVisibilityMode(mode)
        if PartyArrow_SetVisibilityMode then
            PartyArrow_SetVisibilityMode(mode)
            return
        end
        local db = PartyArrowDB or {}
        db.visibilityMode = mode
        db.visible = mode ~= "hidden"
        PartyArrowDB = db
    end

    local function UpdateVisibilityDropdown()
        local currentMode = GetVisibilityMode()
        local currentText = visibilityOptions[1].text
        for _, option in ipairs(visibilityOptions) do
            if option.value == currentMode then
                currentText = option.text
                break
            end
        end
        UIDropDownMenu_SetSelectedValue(visibilityDropdown, currentMode)
        UIDropDownMenu_SetText(visibilityDropdown, currentText)
    end

    function PartyArrow_UpdateVisibilityDropdown()
        if not visibilityDropdown then return end
        UpdateVisibilityDropdown()
    end

    UIDropDownMenu_Initialize(visibilityDropdown, function(self, level)
        for _, option in ipairs(visibilityOptions) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = option.text
            info.value = option.value
            info.func = function()
                UIDropDownMenu_SetSelectedValue(visibilityDropdown, option.value)
                UIDropDownMenu_SetText(visibilityDropdown, option.text)
                ApplyVisibilityMode(option.value)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end)

    local lockCheck = CreateFrame("CheckButton", "PartyArrowOptionsLockCheck", optionsPanel, "UICheckButtonTemplate")
    lockCheck:SetPoint("TOPLEFT", visibilityDropdown, "BOTTOMLEFT", 16, -6)
    lockCheck.text = _G[lockCheck:GetName() .. "Text"]
    lockCheck.text:SetText(Loc("OPTIONS_LOCK_FRAME", "Lock arrow box"))
    lockCheck:SetScript("OnClick", function(self)
        if SlashCmdList and SlashCmdList["PARTYARROW"] then
            if self:GetChecked() then
                SlashCmdList["PARTYARROW"]("lock")
            else
                SlashCmdList["PARTYARROW"]("unlock")
            end
        end
    end)

    local resetButton = CreateFrame("Button", "PartyArrowOptionsResetButton", optionsPanel, "UIPanelButtonTemplate")
    resetButton:SetPoint("TOPLEFT", lockCheck, "BOTTOMLEFT", 0, -10)
    resetButton:SetSize(140, 24)
    resetButton:SetText(Loc("OPTIONS_RESET_POSITION", "Reset Position"))
    resetButton:SetScript("OnClick", function()
        if ResetPlayerArrow then
            ResetPlayerArrow()
        elseif SlashCmdList and SlashCmdList["PARTYARROW"] then
            SlashCmdList["PARTYARROW"]("reset")
        end
    end)

    optionsPanel:SetScript("OnShow", function()
        local db = PartyArrowDB or {}
        UpdateVisibilityDropdown()
        lockCheck:SetChecked(db.locked and true or false)
    end)

    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(optionsPanel, "PartyArrow")
        Settings.RegisterAddOnCategory(category)
        optionsPanel.categoryID = category.ID
    else
        InterfaceOptions_AddCategory(optionsPanel)
    end
    return optionsPanel
end

function PartyArrow_ShowOptionsPanel()
    local panel = PartyArrow_CreateOptionsPanel()
    if Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(panel.categoryID or "PartyArrow")
    else
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end
