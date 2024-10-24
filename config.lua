-- Namespace
local _, core = ...
core.Config = {}
local Config = core.Config
local UIConfig

function Config:Toggle()
    local menu = UIConfig or Config:CreateMenu()
    menu:SetShown(not menu:IsShown())
end

local defaults = {
	theme = {
		r = 0,
		g = 0.8, -- 204/255
		b = 1,
		hex = "00ccff"
	}
}

-- Return the theme color of the addon
function Config:GetThemeColor()
	local color = defaults.theme;
	return color.r, color.g, color.b, color.hex;
end

function Config:CreateMenu()
    UIConfig = CreateFrame("Frame", "MYADDON_Reminder", UIParent, "BasicFrameTemplateWithInset")
    UIConfig:SetSize(300, 360);
    UIConfig:SetPoint("CENTER", UIParent, "CENTER")

    UIConfig.title = UIConfig:CreateFontString(nil, "OVERLAY")
    UIConfig.title:SetFontObject("GameFontHighlight")
    UIConfig.title:SetPoint("LEFT", UIConfig.TitleBg, "LEFT", 5, 0)
    UIConfig.title:SetText("Config")

    UIConfig.deleteButton = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate")
    UIConfig.deleteButton:SetPoint("CENTER", UIConfig, "TOP", 0, -70)
    UIConfig.deleteButton:SetSize(150, 40)
    UIConfig.deleteButton:SetText("Delete Reminder")
    UIConfig.deleteButton:SetNormalFontObject("GameFontNormalLarge")
    UIConfig.deleteButton:SetHighlightFontObject("GameFontHighlightLarge")

    UIConfig.createButton = CreateFrame("Button", nil, UIConfig, "GameMenuButtonTemplate")
    UIConfig.createButton:SetPoint("CENTER", UIConfig, "TOP", 0, -110)
    UIConfig.createButton:SetSize(150, 40)
    UIConfig.createButton:SetText("Create Reminder")
    UIConfig.createButton:SetNormalFontObject("GameFontNormalLarge")
    UIConfig.createButton:SetHighlightFontObject("GameFontHighlightLarge")
    UIConfig:Hide()

    return UIConfig
end