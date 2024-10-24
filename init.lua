-- Namespace
local addonName, core = ...

-- Slash commands table
core.commands = {
        -- for future work ["config"] = core.Config.Toggle,
        --["reminder"] = core.Reminders.ToggleDisplay,
        
        ["add"] = core.Reminders.Insert,
        ["display"] = core.Reminders.Display,
        ["delete"] = core.Reminders.Delete,
        ["help"] = function()
            print(" ")
            core:Print("List of slash commands:")
            core:Print("|cff00cc66/imrem help|r - displays this message")
            core:Print("|cff00cc66/imrem add|r - adds a new reminder")
            core:Print("|cff00cc66/imrem display|r - displays one or more reminders")
            core:Print("|cff00cc66/imrem delete|r - deletes one or more reminders")
            print(" ")
        end
}

-- Takes an input string and returns the separated arguments. Quotes denote a single string.
local function ParseCommandArgs(inputText)
    
    -- List of args parsed from the function
    local args = {}

    -- Repeat while there is any more text to parse
    while inputText and #inputText > 0 do
        local i, j
        local quotePattern = "^%s*%b\"\""
        local normalArgPattern = "[%w%p]+"

        -- First try to find quoted string
        i, j = string.find(inputText, quotePattern)
        -- If found a quoted string
        if i and j then
            
            -- Set "i" to the first quote instead of the first space, since the found string could start with a space.
            i = string.find(inputText, "\"")

            -- If there is something between the quotes then insert it into args and shorten inputText
            if j - i > 1 then
                table.insert(args, string.sub(inputText, i + 1, j - 1))
            -- Otherwise insert an empty string
            else
                table.insert(args, "")
            end
        -- If no quoted string found, then find the first string of non-space characters
        else
            i, j = string.find(inputText, normalArgPattern)
            -- If such a sequence exists, then insert it into the table
            if i and j then
                table.insert(args, string.sub(inputText, i, j))
            end
        end
        -- If the end index of the found string is before the end of the string, set inputText to the remaining text and loop again. Otherwise break out of loop.
        if j < #inputText then
            inputText = string.sub(inputText, j + 1)
        else
            break
        end
    end
    -- for _, arg in ipairs({string.split(' ', inputText)}) do
    --     print("\""..tostring(arg).."\"")
    --     if (#arg > 0) then
    --         table.insert(args, arg)
    --     end
    -- end

    return args
end

-- Handles all slash commands by searching core.commands table
local function HandleSlashCommands(input)
    -- If user just typed "/reminder" then display help message

    if (#input == 0) then
        core.commands.help()
        return
    end
    
    -- Get args from the input

    local args = ParseCommandArgs(input)

    -- DEBUGGING CODE
    -- for _, arg in ipairs(args) do
    --     print("_"..tostring(arg).."_")
    -- end

    -- Search the core.commands table for a function matching the args
    local path = core.commands

    for id, arg in ipairs(args) do
        if (path[arg:lower()]) then
            -- If function, then call the function with the rest of the args
            if (type(path[arg:lower()]) == "function") then
                path[arg:lower()](select(id + 1, unpack(args)))
                return
            -- If table then search that table
            elseif (type(path[arg:lower()]) == "table") then
                path = path[arg]
            end
        -- If there is no command matching these args, then display help message
        else
            core.commands.help()
            return
        end
    end
end

function core:GetAddonName()
    return addonName
end

-- Prints to the console with the addon name in the theme color
function core:Print(...)
    local hex = select(4, self.Config:GetThemeColor())
    local prefix = string.format("|cff%s%s|r", hex:upper(), core:GetAddonName()..": ")
    DEFAULT_CHAT_FRAME:AddMessage(string.join("", prefix, ...))
end

-- Makes shortcuts, registers slash commands, and displays welcome message
-- Is called when the addon is loaded
function core:Init(event, name)
    -- Make sure the addon being loaded is this addon
    
    if (event == "ADDON_LOADED") then

        if (name ~= core:GetAddonName()) then return end

        -- Shortcut to allow moving through chat windows with arrow keys to edit message
        for i = 1, NUM_CHAT_WINDOWS do
            _G["ChatFrame"..i.."EditBox"]:SetAltArrowKeyMode(false)
        end

        -- Shortcut for reload
        SLASH_RELOADUI1 = "/rl"
        SlashCmdList.RELOADUI = ReloadUI

        SLASH_FRAMESTK1 = "/fs"
        SlashCmdList.FRAMESTK = function()
            LoadAddOn('Blizzard_DebugTools')
            FrameStackTooltip_Toggle()
        end

        -- Command for this addon
        SLASH_Reminder1 = "/imrem"
        SlashCmdList.Reminder = HandleSlashCommands
        -- Print welcome message
        core:Print("Welcome back, " .. UnitName("player") .. ".")
    elseif (event == "ZONE_CHANGED_NEW_AREA") then
        local zoneID = C_Map.GetBestMapForUnit("player")
        
        -- If there are reminders in this zone then print them
        if (core.Reminders.list[zoneID]) then
            -- Check if there is a reminder in this zone's reminder list
            local listNotEmpty
            for _, _ in ipairs(core.Reminders.list) do
                listNotEmpty = true
                break
            end
            core:Print("You have reminders in this zone!")
            core.Reminders:DisplayZoneReminders(zoneID)
        end
    end
end

-- Create frame for registering to events
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:SetScript("OnEvent", core.Init)

core.Reminders:SetupFrame()