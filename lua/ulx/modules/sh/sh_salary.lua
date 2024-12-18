if SERVER then
    --[[
        Permissions:
        salarymod.manage - allows you to set the salary values for roles.
        salarymod.view - allows you to view which role receives how much salary
    ]]--
    ULib.ucl.registerAccess("salarymod.manage", "superadmin", "Allows managing Salary Mod roles and points.", "Salary Mod")
    ULib.ucl.registerAccess("salarymod.view", "superadmin", "Allows viewing Salary Mod roles and points.", "Salary Mod")
end

local CATEGORY_NAME = "Salary"

-- Define the server-side function
function SetRolePointValues(calling_ply, group, standardPoints, donatorPoints)
    if SERVER then
        -- Ensure only people with the salarymod.manage permission can execute the command
        if IsValid(calling_ply) and not ULib.ucl.query(calling_ply, "salarymod.manage") then
            ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have permission to use this command.")
            return
        end

        if not standardPoints or not donatorPoints then
            print("Invalid points value. Please provide a number.")
            return
        end

        -- Set the point value for the role
        SalaryMod.rolePointValues[group] = { points = standardPoints, donatorPoints = donatorPoints }
        SalaryMod:saveRolePointValues()
        SalaryMod:sendChatMessage(ply, "Set point value for role '" .. group .. "': " .. standardPoints)
    end
end

local roleNames = {
    "Gast",
    "Einsteiger", "Einsteiger+", "Einsteiger++", "Einsteiger+++",
    "Wiederholungstäter", "Wiederholungstäter+", "Wiederholungstäter++", "Wiederholungstäter+++",
    "Dauerkonsument", "Dauerkonsument+", "Dauerkonsument++", "Dauerkonsument+++",
    "Süchtig", "Süchtig+", "Süchtig++", "Süchtig+++",
    "Mega Suchti", "Mega Suchti+", "Mega Suchti++", "Mega Suchti+++",
    "Neugieriger Junkie", "Neugieriger Junkie+", "Neugieriger Junkie++", "Neugieriger Junkie+++",
    "Leichtabhängiger Junkie", "Leichtabhängiger Junkie+", "Leichtabhängiger Junkie++", "Leichtabhängiger Junkie+++",
    "Hardcore Junkie", "Hardcore Junkie+", "Hardcore Junkie++", "Hardcore Junkie+++",
    "Extremabhängiger Junkie", "Extremabhängiger Junkie+", "Extremabhängiger Junkie++", "Extremabhängiger Junkie+++",
    "Head Moderator", "Moderator", "Test Moderator", "Developer", "Test Developer", "Owner", "superadmin"
}

-- Register the ULX command
local setSalaryCommand = ulx.command(CATEGORY_NAME, "ulx setsalary", SetRolePointValues, "!SetSalary")
setSalaryCommand:addParam{type = ULib.cmds.StringArg, label = "Group: ", completes = roleNames, hint = "Groupname", error = "Please select a valid user group!", ULib.cmds.restrictToCompletes}
setSalaryCommand:addParam{type = ULib.cmds.NumArg, hint = "Standard point salary:", min = 0, max = 1000000, error = "Please enter a valid number!"}
setSalaryCommand:addParam{type = ULib.cmds.NumArg, hint = "Donator pooint salary:", min = 0, max = 1000000, error = "Please enter a valid number!"}
setSalaryCommand:defaultAccess("superadmin")
setSalaryCommand:help("Sets the weekly salary amount for the selected group.")