-- PartyArrow
-- Original author: Jayama
-- Original addon: PlayerArrow
-- Modifications by: TC Conway
-- Changes: Updated for WoW Midnight (12.x), interface bump, ton of improvements (map scaling, class arrows, better distance formatting, UI improvements, etc)
-- Date: 2026-01-24


-- Core state
-- ## SavedVariables: PartyArrowDB
if not PartyArrowDB then PartyArrowDB = {} end
local f = CreateFrame("Frame")

SLASH_PARTYARROW1 = "/partyarrow"
SLASH_PARTYARROW2 = "/pa"

local arrowBox = nil
local arrowFrames = {}
local partyMembers = {}
local arrowBoxLocked = PartyArrowDB and PartyArrowDB.locked or false
local paTitle = "|cffffff78PartyArrow|r"
local ShowArrows
local L = PartyArrowLocals or {}
local function Loc(key, fallback)
    return L[key] or fallback or key
end
local VISIBILITY_ALWAYS = "always"
local VISIBILITY_GROUP = "group"
local VISIBILITY_HIDDEN = "hidden"
local function NormalizeVisibilityMode()
    local mode = PartyArrowDB and PartyArrowDB.visibilityMode
    if mode == VISIBILITY_ALWAYS or mode == VISIBILITY_GROUP or mode == VISIBILITY_HIDDEN then
        return mode
    end
    if PartyArrowDB and PartyArrowDB.visible == false then
        return VISIBILITY_HIDDEN
    end
    return VISIBILITY_ALWAYS
end


-- Distance formatting
local function yardsToMeters(yards)
    return yards * 0.9144
end

local function humanizeYardsKilometers(yards)
    local meters = yardsToMeters(yards)
    local km = math.floor(meters / 1000)
    local remaining = math.floor(meters % 1000)
    return km, remaining
end

local function formatDistanceMeters(distanceYards)
    local km, meters = humanizeYardsKilometers(distanceYards)
    if km == 0 then
        return string.format("%dm", meters)
    else
        return string.format("%dkm %dm", km, meters)
    end
end


-- Map scaling
local MAP_SCALES = PartyArrow_MAP_SCALES or {}

local function GetEffectiveMapScale(mapID)
    if C_Map.GetMapWorldSize then
        local width = C_Map.GetMapWorldSize(mapID)
        if width then
            return width
        end
    end
    if MAP_SCALES[mapID] then
        return MAP_SCALES[mapID]
    end
    local mapInfo = C_Map.GetMapInfo(mapID)
    if mapInfo and mapInfo.parentMapID and MAP_SCALES[mapInfo.parentMapID] then
        return MAP_SCALES[mapInfo.parentMapID]
    end
    return 1000 -- fallback
end


-- UI layout and persistence
local function SaveArrowBoxPosition()
    if not arrowBox then return end
    local point, relativeTo, relativePoint, xOfs, yOfs = arrowBox:GetPoint()
    PartyArrowDB.point = point
    PartyArrowDB.relativePoint = relativePoint
    PartyArrowDB.xOfs = xOfs or 0
    PartyArrowDB.yOfs = yOfs or 0
end

local function RestoreArrowBoxPosition()
    if not arrowBox then return end
    local db = PartyArrowDB or {}
    local point = db.point or "CENTER"
    local relativePoint = db.relativePoint or "CENTER"
    local xOfs = db.xOfs or 0
    local yOfs = db.yOfs or 100
    arrowBox:ClearAllPoints()
    arrowBox:SetPoint(point, UIParent, relativePoint, xOfs, yOfs)
end

local function CreateArrowBox()
    if arrowBox then return end
    arrowBox = CreateFrame("Frame", "PartyArrowBox", UIParent, BackdropTemplateMixin and "BackdropTemplate")
    arrowBox:SetSize(400, 100)
    arrowBox:SetMovable(true)
    arrowBox:EnableMouse(not arrowBoxLocked)
    if arrowBoxLocked then
        arrowBox:RegisterForDrag()
    else
        arrowBox:RegisterForDrag("LeftButton")
    end
    arrowBox:SetScript("OnDragStart", function(self) self:StartMoving() end)
    arrowBox:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SaveArrowBoxPosition()
    end)
    -- Add a visible background
    if arrowBox.SetBackdrop then
        arrowBox:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        arrowBox:SetBackdropColor(0, 0, 0, 0.7)
    else
        -- fallback: add a texture if SetBackdrop is unavailable
        local bg = arrowBox:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.7)
    end
    arrowBox.emptyText = arrowBox:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    arrowBox.emptyText:SetPoint("CENTER", arrowBox, "CENTER", 0, 0)
    local font, size, flags = arrowBox.emptyText:GetFont()
    if font and size then
        arrowBox.emptyText:SetFont(font, size + 2, flags)
    end
    arrowBox.emptyText:SetTextColor(0.7, 0.7, 0.7)
    arrowBox.emptyText:SetText(Loc("EMPTY_GROUP_MESSAGE", "Please join a group first"))
    arrowBox.emptyText:Hide()
    RestoreArrowBoxPosition() -- Only restore position once, on creation
    arrowBox:Hide()
end

local function SetArrowBoxLocked(locked)
    arrowBoxLocked = locked and true or false
    PartyArrowDB.locked = arrowBoxLocked
    if not arrowBox then return end
    arrowBox:EnableMouse(not arrowBoxLocked)
    if arrowBoxLocked then
        arrowBox:RegisterForDrag()
    else
        arrowBox:RegisterForDrag("LeftButton")
    end
end

local function ResetPlayerArrow()
    PartyArrowDB.visibilityMode = VISIBILITY_ALWAYS
    PartyArrowDB.visible = true
    PartyArrowDB.point = nil
    PartyArrowDB.relativePoint = nil
    PartyArrowDB.xOfs = nil
    PartyArrowDB.yOfs = nil
    if arrowBox then
        RestoreArrowBoxPosition()
        arrowBox:Show()
    end
    ShowArrows()
    if PartyArrow_UpdateVisibilityDropdown then
        PartyArrow_UpdateVisibilityDropdown()
    end
    print(paTitle, Loc("RESET_DONE", "reset."))
end

local function CreateArrowForMember(index, playerName)
    if arrowFrames[index] then return arrowFrames[index] end
    local frame = CreateFrame("Frame", "PartyArrowFrame"..index, arrowBox)
    frame:SetSize(64, 64)
    frame:SetPoint("LEFT", arrowBox, "LEFT", (index-1)*70, 0)
    -- Create a subframe for the arrow with even inset so it stays square
    local arrowMargin = 6
    frame.arrow = CreateFrame("Frame", nil, frame)
    frame.arrow:SetPoint("TOPLEFT", frame, "TOPLEFT", arrowMargin, -arrowMargin)
    frame.arrow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -arrowMargin, arrowMargin)
    frame.texture = frame.arrow:CreateTexture(nil, "ARTWORK")
    frame.texture:SetAllPoints()
    frame.texture:SetTexture("Interface\\AddOns\\PartyArrow\\images\\arrows\\arrow-default")
    frame.texture:SetBlendMode("BLEND")
    -- Anchor name and distance text to the frame bounds
    frame.nameText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.nameText:SetPoint("BOTTOM", frame, "TOP", 0, 5)
    frame.nameText:SetText(playerName)
    frame.distanceText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.distanceText:SetPoint("TOP", frame, "BOTTOM", 0, -5)
    frame.distanceText:SetText("")
    -- Add a font string for DEAD/OFFLINE status
    frame.statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    frame.statusText:SetPoint("TOP", frame, "BOTTOM", 0, -5)
    frame.statusText:SetText("")
    frame.statusText:Hide()
    frame:Show()
    arrowFrames[index] = frame
    return frame
end

local function GetClassArrowTexture(unit)
    local classFile = select(2, UnitClass(unit))
    if not classFile then
        return "Interface\\AddOns\\PartyArrow\\images\\arrows\\arrow-default"
    end
    local className = string.lower(classFile)
    return "Interface\\AddOns\\PartyArrow\\images\\arrows\\arrow-" .. className
end


-- Party data
local function GatherPartyMembers()
    wipe(partyMembers)
    if IsInRaid() then return end
    for i = 1, GetNumSubgroupMembers() do
        local unit = "party" .. i
        local name = UnitName(unit)
        if name then
            table.insert(partyMembers, {name = name, unit = unit})
        end
    end
end


-- Arrow updates
local function UpdateArrows()
    if not arrowBox or not arrowBox:IsShown() then return end
    -- Dynamically adjust box size and arrow positions
    local arrowCount = #partyMembers
    local arrowWidth = 64
    local arrowSpacing = 6
    local boxWidth = arrowCount > 0 and (arrowCount * arrowWidth + (arrowCount - 1) * arrowSpacing) or 64
    arrowBox:SetSize(boxWidth, 110)
    -- Hide unused arrow frames if party shrinks
    for i = #partyMembers + 1, #arrowFrames do
        if arrowFrames[i] then arrowFrames[i]:Hide() end
    end
    for i, member in ipairs(partyMembers) do
        local frame = CreateArrowForMember(i, member.name)
        frame:ClearAllPoints()
        frame:SetPoint("LEFT", arrowBox, "LEFT", (i-1)*(arrowWidth+arrowSpacing), 0)
        frame.nameText:SetText(member.name)
    end

    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        arrowBox:Hide()
        return
    end
    local pos1 = C_Map.GetPlayerMapPosition(mapID, "player")
    if not pos1 then
        arrowBox:Hide()
        return
    end
    for i, member in ipairs(partyMembers) do
        local unit = member.unit
        local frame = arrowFrames[i]
        if not frame then
            frame = CreateArrowForMember(i, member.name)
        end
        if not unit or not UnitIsConnected(unit) then
            frame.texture:Hide()
            frame.distanceText:Hide()
            frame.statusText:SetText("OFFLINE")
            frame.statusText:SetTextColor(0.5, 0.5, 0.5)
            frame.statusText:Show()
            frame:Show()
        elseif UnitIsDeadOrGhost(unit) then
            frame.texture:Hide()
            frame.distanceText:Hide()
            frame.statusText:SetText("DEAD")
            frame.statusText:SetTextColor(1, 0, 0)
            frame.statusText:Show()
            frame:Show()
        else
            frame.texture:Show()
            frame.distanceText:Show()
            frame.statusText:Hide()
            frame.texture:SetTexture(GetClassArrowTexture(unit))
            local pos2 = C_Map.GetPlayerMapPosition(mapID, unit)
            if not pos2 then
                frame:Hide()
            else
                local dx = pos2.x - pos1.x
                local dy = pos2.y - pos1.y
                local angle = math.atan2(dx, dy)
                local facing = GetPlayerFacing() or 0
                local rotation = angle - facing + math.pi
                if frame.texture and frame.texture.SetRotation then
                    frame.texture:SetRotation(rotation)
                    frame:Show()
                end
                local mapScale = GetEffectiveMapScale(mapID)
                local distanceYards = math.sqrt(dx*dx + dy*dy) * mapScale
                frame.distanceText:SetText(formatDistanceMeters(distanceYards))
            end
        end
    end
end


-- Visibility control
local function HideArrows()
    if arrowBox then arrowBox:Hide() end
    for _, frame in ipairs(arrowFrames) do
        frame:Hide()
    end
    if arrowBox and arrowBox.emptyText then
        arrowBox.emptyText:Hide()
    end
    f:SetScript("OnUpdate", nil)
end

ShowArrows = function()
    local mode = NormalizeVisibilityMode()
    if mode == VISIBILITY_HIDDEN then
        HideArrows()
        return
    end
    if mode == VISIBILITY_GROUP and not IsInGroup() then
        HideArrows()
        return
    end
    if not arrowBox then
        CreateArrowBox()
    end
    if not IsInGroup() then
        arrowBox:SetSize(64, 110)
        arrowBox:Show()
        if arrowBox.emptyText then
            arrowBox.emptyText:Show()
        end
        for _, frame in ipairs(arrowFrames) do
            frame:Hide()
        end
        f:SetScript("OnUpdate", nil)
        return
    end
    if IsInRaid() then
        HideArrows()
        return
    end
    GatherPartyMembers()
    if #partyMembers == 0 then
        HideArrows()
        return
    end
    if arrowBox and arrowBox.emptyText then
        arrowBox.emptyText:Hide()
    end
    arrowBox:Show()
    f:SetScript("OnUpdate", UpdateArrows)
end


-- Event wiring
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        arrowBoxLocked = PartyArrowDB.locked or false
        if PartyArrowDB.visible == nil then
            PartyArrowDB.visible = true
        end
        if PartyArrowDB.visibilityMode == nil then
            PartyArrowDB.visibilityMode = PartyArrowDB.visible and VISIBILITY_ALWAYS or VISIBILITY_HIDDEN
        end
        PartyArrow_CreateOptionsPanel()
        ShowArrows()
    elseif event == "GROUP_ROSTER_UPDATE" then
        ShowArrows()
    end
end)

function PartyArrow_GetVisibilityMode()
    return NormalizeVisibilityMode()
end

function PartyArrow_SetVisibilityMode(mode)
    if mode ~= VISIBILITY_ALWAYS and mode ~= VISIBILITY_GROUP and mode ~= VISIBILITY_HIDDEN then
        mode = VISIBILITY_ALWAYS
    end
    PartyArrowDB.visibilityMode = mode
    PartyArrowDB.visible = mode ~= VISIBILITY_HIDDEN
    if mode == VISIBILITY_HIDDEN then
        HideArrows()
    else
        ShowArrows()
    end
    if PartyArrow_UpdateVisibilityDropdown then
        PartyArrow_UpdateVisibilityDropdown()
    end
end


-- Slash commands
SlashCmdList["PARTYARROW"] = function(msg)
    if not msg or msg:match("^%s*$") then
        PartyArrow_ShowOptionsPanel()
        return
    end
    if msg and msg:match("^%s*help%s*$") then
        print(paTitle, Loc("HELP_HEADER", "commands:"))
        print(paTitle, Loc("HELP_SHOW", "/pa show - show the arrow box"))
        print(paTitle, Loc("HELP_HIDE", "/pa hide - hide the arrow box"))
        print(paTitle, Loc("HELP_INGROUP", "/pa ingroup - show the arrow box only while in a group"))
        print(paTitle, Loc("HELP_LOCK", "/pa lock - lock arrow box movement"))
        print(paTitle, Loc("HELP_UNLOCK", "/pa unlock - unlock arrow box movement"))
        print(paTitle, Loc("HELP_RESET", "/pa reset - reset arrow box position"))
        print(paTitle, Loc("HELP_DEBUG", "/pa debug - show map debug info"))
        return
    end
    if msg and msg:match("^%s*reset%s*$") then
        ResetPlayerArrow()
        return
    end
    if msg and msg:match("^%s*show%s*$") then
        PartyArrow_SetVisibilityMode(VISIBILITY_ALWAYS)
        print(paTitle, Loc("ARROWS_SHOWN", "arrows shown."))
        return
    end
    if msg and msg:match("^%s*hide%s*$") then
        PartyArrow_SetVisibilityMode(VISIBILITY_HIDDEN)
        print(paTitle, Loc("ARROWS_HIDDEN", "arrows hidden."))
        return
    end
    if msg and msg:match("^%s*ingroup%s*$") then
        PartyArrow_SetVisibilityMode(VISIBILITY_GROUP)
        print(paTitle, Loc("ARROWS_INGROUP", "arrows will only show while in a group."))
        return
    end
    if msg and msg:match("^%s*lock%s*$") then
        SetArrowBoxLocked(true)
        print(paTitle, Loc("ARROWS_LOCKED", "arrows locked."))
        return
    end
    if msg and msg:match("^%s*unlock%s*$") then
        SetArrowBoxLocked(false)
        print(paTitle, Loc("ARROWS_UNLOCKED", "arrows unlocked."))
        return
    end
    if msg and msg:match("^%s*debug%s*$") then
        local mapID = C_Map.GetBestMapForUnit("player")
        if not mapID then
            print(paTitle, Loc("DEBUG_NO_MAPID", "no mapID for player."))
            return
        end
        local pos1 = C_Map.GetPlayerMapPosition(mapID, "player")
        if not pos1 then
            print(paTitle, Loc("DEBUG_NO_PLAYER_POS", "no player position on map."))
            return
        end
        local mapInfo = C_Map.GetMapInfo(mapID)
        local mapName = mapInfo and mapInfo.name or "unknown"
        print(paTitle, string.format(Loc("DEBUG_MAPID_POS", "mapID=%s (%s) pos=%.4f,%.4f"), mapID, mapName, pos1.x, pos1.y))
        print(paTitle, string.format(Loc("DEBUG_GROUP_RAID", "inGroup=%s inRaid=%s"),
            tostring(IsInGroup()), tostring(IsInRaid())))
        if C_Map.GetMapWorldSize then
            local width, height = C_Map.GetMapWorldSize(mapID)
            if width and height then
                print(paTitle, string.format(Loc("DEBUG_WORLD_SIZE", "mapWorldSize=%.2f x %.2f"), width, height))
            else
                print(paTitle, Loc("DEBUG_WORLD_SIZE_UNAVAILABLE", "mapWorldSize unavailable."))
            end
        else
            print(paTitle, Loc("DEBUG_WORLD_SIZE_API_UNAVAILABLE", "mapWorldSize API not available."))
        end
        if C_Map.GetWorldPosFromMapPos then
            local posA = CreateVector2D(0, 0)
            local posB = CreateVector2D(1, 0)
            local ax, ay = C_Map.GetWorldPosFromMapPos(mapID, posA)
            local bx, by = C_Map.GetWorldPosFromMapPos(mapID, posB)
            local worldA = nil
            local worldB = nil
            if type(ax) == "table" then
                worldA = ax
            elseif type(ay) == "table" then
                worldA = ay
            elseif ax and ay then
                worldA = { x = ax, y = ay }
            end
            if type(bx) == "table" then
                worldB = bx
            elseif type(by) == "table" then
                worldB = by
            elseif bx and by then
                worldB = { x = bx, y = by }
            end
            if worldA and worldB then
                local dx = worldB.x - worldA.x
                local dy = worldB.y - worldA.y
                local dist = math.sqrt(dx * dx + dy * dy)
                print(paTitle, string.format(Loc("DEBUG_WORLD_WIDTH", "worldWidth=%.2f (from map pos)"), dist))
            else
                print(paTitle, Loc("DEBUG_WORLD_POS_UNAVAILABLE", "world pos conversion unavailable."))
            end
        else
            print(paTitle, Loc("DEBUG_WORLD_POS_API_UNAVAILABLE", "world pos API not available."))
        end
        return
    end
    PartyArrow_ShowOptionsPanel()
end
