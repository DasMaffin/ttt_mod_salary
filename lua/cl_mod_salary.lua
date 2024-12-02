
-- -- Register a chat command that listens for "!salary"
-- hook.Add("PlayerSay", "SalaryChatCommand", function(ply, text, teamChat)
--     -- Check if the text matches the command
--     if string.lower(text) == "!salary" then
--         -- Print "salary" to the console
--         print("Salary")
        
--         -- Optionally, send a message back to the player
--         ply:ChatPrint("You called for your salary!")
        
--         -- Return false to prevent the chat message from showing up
--         return ""
--     end
-- end)

-- Include this file in ULX commands
function ulx.salary(ply)
    print("YEET!")
    -- Get all roles
    if not ROLES then
        ULib.tsay(ply, "ROLES table not found.")
        return
    end

    -- Print each role to the console
    for roleName, roleData in pairs(ROLES) do
        print("Role: " .. roleName .. " | Color: " .. tostring(roleData.color))
    end

    -- Notify the player that roles are being displayed
    ulx.fancyLogAdmin(ply, "#A has called the !salary command")
end

-- Add ULX command for !salary
local salaryCommand = ulx.command("Custom", "ulx salary", ulx.salary, "!salary")
salaryCommand:defaultAccess(ULib.ACCESS_ALL) -- Everyone can use it
salaryCommand:help("Displays all roles in the console.")
