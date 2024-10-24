-- Namespace
local _, core = ...



core.Reminders = {
    -- The frame that shows reminders
    frame = ImmersiveReminder_RemindersFrame,
    -- The storage for reminders
    list = {}
}

--[[ TEST REMINDERS
{
    
    list = {
        [1411] = {
            {title = "Title1", text = "text"},
            {title = "Title1", text = "text"},
            {title = "Title2", text = "text"}
        },
        [1456] = {
            {title = "Title1", text = "text"},
            {title = "Title2", text = "text"}
        },
        [1412] = {
            {title = "Title1", text = "text"},
            {title = "Title2", text = "text"}
        } 
    }
}
--]]

local Reminders = core.Reminders

function Reminders:ToggleDisplay()
    Reminders.frame:SetShown(not Reminders.frame:IsShown())
end

function Reminders:SetupFrame()
    Reminders.frame.ReminderTitle1:SetText("Me")
    Reminders.frame.ReminderTitle1:SetScript("OnClick", core.Config.Toggle)

end

-- DEPRECATED: delete
-- local function GetQuotedString(inputText)
--     if not inputText then return end
    
--     local pattern = "^%s*%b\"\""
--     local i, j
--     i, j = string.find(inputText, pattern)
--     if i == nil then
--         return nil
--     elseif j - 1 == 1 then
--         local remainderText
--         if #inputText > 2 then
--             remainderText = string.sub(inputText, j + 1)
--         end
--         return "", remainderText
--     else
--         local quotedString = string.sub(inputText, i + 1, j - 1)
--         local remainderText
--         if #inputText > #quotedString + 2 then
--             remainderText = string.sub(inputText, j + 1)
--         end
--         return quotedString, remainderText
--     end

-- end

-- Creates a reminder and stores it in Reminders.list tabble according to zone
function Reminders.Insert(reminderZoneName, reminderTitle, reminderText)

    -- Ensure user provided zone name
    if not reminderZoneName then
        core:Print("Please provide a valid zone name.")
        core:Print("Usage: \"/imrem add <zone name> <reminder title> <reminder text>\"")
        core:Print("Use quotes to create multiword argument. Type \"current\" for current zone name.")
        return
    end
    reminderZoneName = string.lower(reminderZoneName)
    

    -- Query the zones table to see if a zone of this name exists. If it does, store the zoneID in remidnerZoneID.
    -- A zone name of "current" denotes the player's current zone
    local reminderZoneID
    if core.zones[reminderZoneName] then
        reminderZoneID = core.zones[reminderZoneName]
    elseif reminderZoneName == "current" then
        reminderZoneID = C_Map.GetBestMapForUnit("player")
    else
        core:Print("\""..reminderZoneName.."\" is not a valid zone name. Be sure to type zone name completely, or type \"current\" for the current zone.")
        return
    end

    -- Make sure title exists
    if not reminderTitle then
        core:Print("Please provide a title for the reminder.")
        core:Print("Usage: \"/imrem add <zone name> <reminder title> <reminder text>\"")
        core:Print("Use quotes to create a multiword argument.")
        return
    end

    -- If user didn't type in remidner text then assume an empty string for the text
    reminderText = reminderText or ""

    -- Make reminder
    local newReminder = {title = reminderTitle, text = reminderText}
    
    -- Make sure that there is a table for storing reminders in this zone inside of the Reminders.list table. If it does not exist, create one.
    if not Reminders.list[reminderZoneID] then Reminders.list[reminderZoneID] = {} end
    -- Insert reminder into zone reminder table
    table.insert(Reminders.list[reminderZoneID], newReminder)
    
    -- Get zone name and display inserted message
    local reminderZoneName = C_Map.GetMapInfo(reminderZoneID).name
    core:Print("Inserted reminder in zone "..reminderZoneName..". Title: \""..reminderTitle.."\" Reminder text: \""..reminderText.."\" You now have "..#Reminders.list[reminderZoneID].." reminders in this zone.")
end

-- Deletes remidners in the specified zone with the specified title. Supplying "all" to these paremeters can be used to delete reminders from all zones or with all titles.
function Reminders.Delete(reminderZoneName, reminderTitle)
    -- Ensure user provided zone name
    reminderZoneName = string.lower(reminderZoneName)

    if not reminderZoneName then
        core:Print("Please provide valid zone name to delete reminders from, or type \"all\" to delete reminders from all zones.")
        core:Print("Usage: \"/imrem delete <zone name> <reminder title>\"")
        core:Print("Use quotes to create a multiword argument.")
        return
    end
    -- Ensure user provided title of reminder to delete
    if not reminderTitle then
        core:Print("Please provide valid title of the reminder(s) to delete, or type \"all\" to delete reminders with any title.")
        core:Print("Usage: \"/imrem delete <zone name> <reminder title>\"")
        core:Print("Use quotes to create a multiword argument.")
        return
    end
    
    

    local deleteCount = 0

    -- Different functionality based on if user typed "all" for zone or title
    if reminderZoneName == "all" then
        -- If parameters are "all" "all"
        if (string.lower(reminderTitle) == "all") then
            -- Loop through each reminder in each zone and set them to nil
            for zoneID, reminderList in pairs(Reminders.list) do
                for reminderID, reminder in ipairs(reminderList) do
                    reminderList[reminderID] = nil
                    deleteCount = deleteCount + 1
                end
                -- Set the zone entry to nil so that it doesn't show up when the user displays reminders
                Reminders.list[zoneID] = nil
            end
            core:Print("Deleted all reminders in all zones.")
        -- If parameters are "all" <remidnerTitle>
        else
            -- Loop through all zones and delete reminders with the specified title
            for zoneID, reminderList in pairs(Reminders.list) do
                -- Loop in this way to make sure that table.remove doesn't cause trouble when it shifts all elements down
                for i = #reminderList, 1, -1 do
                    if reminderList[i].title == reminderTitle then
                        table.remove(reminderList, i)
                        deleteCount = deleteCount + 1
                    end
                end
                if (#reminderList == 0) then
                    Reminders.list[zoneID] = nil
                end
            end
            core:Print("Deleted reminders in all zones with title \""..reminderTitle.."\".")
        end  
    else
        local zoneID
        
        -- If user types "current" then use the player's current zone
        if reminderZoneName == "current" then
            zoneID = C_Map.GetBestMapForUnit("player")
            reminderZoneName = C_Map.GetMapInfo(zoneID).name
        else
            -- Otherwise find if the zone the user entered exists
            zoneID = core.zones[reminderZoneName]
            if not zoneID then
                core:Print("\""..reminderZoneName.."\" is not a valid zone name. Be sure to type zone name completely, or type \"current\" for the current zone.")
                core:Print("Usage: \"/imrem delete <zone name> <reminder title>\"")
            core:Print("Use quotes to create a multiword argument.")
                return
            end
        end

        -- Get the reminder list corresponding to the specified zone
        local reminderList = Reminders.list[zoneID]
        if not reminderList then
            core:Print("You have no reminders in zone \""..reminderZoneName.."\"")
            core:Print("Usage: \"/imrem delete <zone name> <reminder title>\"")
            core:Print("Use quotes to create a multiword argument.")
            return
        end

        -- If parameters are <zoneName> all
        if string.lower(reminderTitle) == "all" then
            -- Delete all the reminders in the specified zone
            for reminderID, reminder in ipairs(reminderList) do
                reminderList[reminderID] = nil
                deleteCount = deleteCount + 1
            end
            Reminders.list[zoneID] = nil
            core:Print("Deleted all reminders in zone \""..reminderZoneName.."\".")
        -- If parameters are <zoneName> <reminderTitle>
        else
            -- Deletes all reminders in the specified zone with the specified title
            for i = #reminderList, 1, -1 do
                if reminderList[i].title == reminderTitle then
                    table.remove(reminderList, i)
                    deleteCount = deleteCount + 1
                end
            end
            core:Print("Deleted all reminders in zone \""..reminderZoneName.."\" with title \""..reminderTitle.."\".")
        end  
    end
    core:Print("Deleted "..deleteCount.." reminders total.")
end

-- Displays the title and text of a reminder
function Reminders:DisplayReminder(reminder)
    core:Print("   "..reminder.title.." | "..reminder.text)
end

function Reminders:DisplayZoneReminders(zoneID)
    local reminderList = core.Reminders.list[zoneID] or {}

    local zoneName = C_Map.GetMapInfo(zoneID).name
    core:Print(zoneName..":")

    for _, reminder in ipairs(reminderList) do
        Reminders:DisplayReminder(reminder)
    end
end

-- Displays a specified zone's reminders or all reminders if no zone is specified
function Reminders.Display(zoneName)
    core:Print("----- REMINDERS -----")

    -- Get zoneID if a valid zone was provided
    local zoneID
    if (zoneName) then
        zoneName = string.lower(zoneName)

        -- Set the zone name to current zone, listed zone, or leave as nil otherwise
        if (zoneName == "current") then
            zoneID = C_Map.GetBestMapForUnit("player")
        else
            zoneID = core.zones[zoneName]
        end
    end

    -- Display all zones if zoneID is nil
    if (zoneID) then
        Reminders:DisplayZoneReminders(zoneID)
    else
        for zoneID, reminderList in pairs(core.Reminders.list) do
            print(" ")
            Reminders:DisplayZoneReminders(zoneID)
        end
    end
end

-- function Reminder:CreateMenu()
--     UIReminder = CreateFrame("Frame", "MYADDON_Reminder", UIParent, "BasicFrameTemplateWithInset")
--     UIReminder:SetSize(300, 360);
--     UIReminder:SetPoint("CENTER", UIParent, "CENTER")

--     UIReminder.title = UIReminder:CreateFontString(nil, "OVERLAY")
--     UIReminder.title:SetFontObject("GameFontHighlight")
--     UIReminder.title:SetPoint("LEFT", UIReminder.TitleBg, "LEFT", 5, 0)
--     UIReminder.title:SetText("Reminder!")

--     UIReminder.deleteButton = CreateFrame("Button", nil, UIReminder, "GameMenuButtonTemplate")
--     UIReminder.deleteButton:SetPoint("CENTER", UIReminder, "TOP", 0, -70)
--     UIReminder.deleteButton:SetSize(150, 40)
--     UIReminder.deleteButton:SetText("Delete Reminder")
--     UIReminder.deleteButton:SetNormalFontObject("GameFontNormalLarge")
--     UIReminder.deleteButton:SetHighlightFontObject("GameFontHighlightLarge")

--     UIReminder.createButton = CreateFrame("Button", nil, UIReminder, "GameMenuButtonTemplate")
--     UIReminder.createButton:SetPoint("CENTER", UIReminder, "TOP", 0, -110)
--     UIReminder.createButton:SetSize(150, 40)
--     UIReminder.createButton:SetText("Create Reminder")
--     UIReminder.createButton:SetNormalFontObject("GameFontNormalLarge")
--     UIReminder.createButton:SetHighlightFontObject("GameFontHighlightLarge")
--     UIReminder:Hide()

--     return UIReminder
-- end