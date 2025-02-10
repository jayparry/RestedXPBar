-- Get the player's current level
local playerLevel = UnitLevel("player")

-- If the player's level is 60 or above, stop further execution of the addon
if playerLevel >= 60 then
    return  -- Stops loading the rest of the addon
end

-- Create the main frame for the XP Bar
local RestedXPBarFrame = CreateFrame("Frame", "RestedXPBarFrame", UIParent)
RestedXPBarFrame:SetWidth(256)  -- Set width for doubled size
RestedXPBarFrame:SetHeight(24)  -- Set height for doubled size
RestedXPBarFrame:SetPoint("CENTER", UIParent, "CENTER")
RestedXPBarFrame:EnableMouse(true)
RestedXPBarFrame:SetMovable(true)
RestedXPBarFrame:RegisterForDrag("LeftButton")
RestedXPBarFrame:SetScript("OnDragStart", function()
	this:StartMoving()
end)
RestedXPBarFrame:SetScript("OnDragStop", function()
	this:StopMovingOrSizing()

end)

-- Set backdrop for visual appeal with adjusted edge and insets
RestedXPBarFrame:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", -- solid background texture
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- lighter border texture that might scale better
    tile = true,
    tileSize = 16, -- tile size, smaller to prevent scaling issues
    edgeSize = 12, -- reducing edge size to ensure it doesn't overlap the content
    insets = { left = 3, right = 3, top = 3, bottom = 3 } -- adjust if necessary to fit the border neatly
})


-- Create the texture for the XP Bar
local RestedXPBarTexture = RestedXPBarFrame:CreateTexture(nil, "OVERLAY")
RestedXPBarTexture:SetTexture(0, 1, 0, 1)  -- Set initial green color using RGBA
RestedXPBarTexture:SetPoint("TOPLEFT", RestedXPBarFrame, "TOPLEFT", 4, -4)
RestedXPBarTexture:SetPoint("BOTTOMRIGHT", RestedXPBarFrame, "BOTTOMLEFT", 4, 4) -- Initially minimal width

-- Create font string for displaying percentage
local percentageText = RestedXPBarFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
percentageText:SetPoint("CENTER", RestedXPBarFrame, "CENTER")
percentageText:SetTextColor(1, 1, 1)  -- White color

-- Function to update the bar based on the rested XP
local function UpdateRestedXPBar()
    local xpExhaustion = GetXPExhaustion() or 0
    local xpMax = UnitXPMax("player")
    local percentage = xpExhaustion / (xpMax * 1.5) * 100

    -- Set the width of the bar based on percentage
    RestedXPBarTexture:SetPoint("BOTTOMRIGHT", RestedXPBarFrame, "BOTTOMLEFT", 4 + 248 * (percentage / 100), 4)

    -- Change color based on percentage threshold
    if percentage < 25 then
        RestedXPBarTexture:SetTexture(1, 0, 0, 1)  -- Red
    elseif percentage >= 25 and percentage < 75 then
        RestedXPBarTexture:SetTexture(1, 1, 0, 1)  -- Yellow
    else
        RestedXPBarTexture:SetTexture(0, 1, 0, 1)  -- Green
    end

    percentageText:SetText(string.format("%.1f%%", percentage))  -- Display percentage text
end

-- Event handling to update XP bar properly
RestedXPBarFrame:RegisterEvent("PLAYER_XP_UPDATE")
RestedXPBarFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
RestedXPBarFrame:RegisterEvent("PLAYER_LEVEL_UP")
RestedXPBarFrame:RegisterEvent("UPDATE_EXHAUSTION")
RestedXPBarFrame:SetScript("OnEvent", function(self, event, ...)
    UpdateRestedXPBar()
end)

-- Function to show the XP bar
local function ShowRestedXPBar()
    RestedXPBarFrame:Show()
end

-- Function to hide the XP bar
local function HideRestedXPBar()
    RestedXPBarFrame:Hide()
    DEFAULT_CHAT_FRAME:AddMessage("RestedXPBar: Bar has been hidden use '/rxb show' to show it again.")
end

-- Register slash commands
SLASH_RESTEDXPBAR1 = "/restedxpbar"
SLASH_RESTEDXPBAR2 = "/rxb"
SlashCmdList["RESTEDXPBAR"] = function(msg)
    if msg == "show" then
        ShowRestedXPBar()
    elseif msg == "hide" then
        HideRestedXPBar()
    else
        DEFAULT_CHAT_FRAME:AddMessage("Usage: /restedxpbar [show|hide]")
        DEFAULT_CHAT_FRAME:AddMessage("       /rxb [show|hide]")
    end
end

-- Initial update on load
UpdateRestedXPBar()
RestedXPBarFrame:Show()  -- Ensure the bar is shown initially
DEFAULT_CHAT_FRAME:AddMessage("RestedXPBar: Loaded successfully")