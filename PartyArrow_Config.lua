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

    local showCheck = CreateFrame("CheckButton", "PartyArrowOptionsShowCheck", optionsPanel, "UICheckButtonTemplate")
    showCheck:SetPoint("TOPLEFT", controlsHeader, "BOTTOMLEFT", 0, -6)
    showCheck.text = _G[showCheck:GetName() .. "Text"]
    showCheck.text:SetText(Loc("OPTIONS_SHOW_ARROWS", "Show arrows while in a party"))
    showCheck:SetScript("OnClick", function(self)
        if SlashCmdList and SlashCmdList["PARTYARROW"] then
            SlashCmdList["PARTYARROW"](self:GetChecked() and "show" or "hide")
        end
    end)

    local lockCheck = CreateFrame("CheckButton", "PartyArrowOptionsLockCheck", optionsPanel, "UICheckButtonTemplate")
    lockCheck:SetPoint("TOPLEFT", showCheck, "BOTTOMLEFT", 0, -2)
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
        SlashCmdList["PARTYARROW"]("reset")
    end)

    local function RefreshControls()
        local db = PartyArrowDB or {}
        showCheck:SetChecked(db.visible ~= false)
        lockCheck:SetChecked(db.locked and true or false)
        -- Locking only means something while the box exists, i.e. in a party
        local inParty = PartyArrow_IsInParty and PartyArrow_IsInParty()
        if inParty then
            lockCheck:Enable()
            lockCheck.text:SetFontObject("GameFontNormalSmall")
        else
            lockCheck:Disable()
            lockCheck.text:SetFontObject("GameFontDisableSmall")
        end
    end

    function PartyArrow_RefreshOptionsPanel()
        if optionsPanel:IsShown() then
            RefreshControls()
        end
    end

    optionsPanel:SetScript("OnShow", RefreshControls)

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
