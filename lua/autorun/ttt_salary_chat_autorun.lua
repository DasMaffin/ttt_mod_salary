if SERVER then
    include("cl_mod_salary.lua") -- Include the client-side code
else
if SERVER then
    local rolePointValues = {
        ["moderator"] = 50,
        ["admin"] = 100,
        ["superadmin"] = 200,
        ["user"] = 10
    }


    -- Utility function to send chat messages
    local function sendChatMessage(message)
        chat.AddText(Color(0, 255, 0), "[Salary Mod] ", Color(255, 255, 255), message)
    end

    local function saveRolePointValues()
        file.Write("salary_mod/role_point_values.txt", util.TableToJSON(rolePointValues))
        print("Role point values saved.")
    end

    local function loadRolePointValues()
        if file.Exists("salary_mod/role_point_values.txt", "DATA") then
            rolePointValues = util.JSONToTable(file.Read("salary_mod/role_point_values.txt", "DATA"))
            print("Saved role point values loaded.")
        else
            print("No saved role point values found. Using defaults.")
        end
    end

    -- Call this on server startup
    hook.Add("Initialize", "LoadRolePointValues", loadRolePointValues)


    -- Hook to handle "!salary" command
    hook.Add("PlayerSay", "TTTModSalaryCommand", function(ply, text, teamChat, isDead)
        if string.lower(text) == "!salary" then
            -- Get the player's role
            local userRole = ply:GetUserGroup()

            -- Fetch the point value for the role
            local pointsToAdd = rolePointValues[userRole]
            if not pointsToAdd then
                sendChatMessage("Your role is unknown or unhandled: " .. tostring(userRole))
                return true
            end

            print(tostring(ply))
            print(pointsToAdd)

            -- Add points to the player's Pointshop 2 account
            print("You have received " .. pointsToAdd .. " points!")
            ply:PS2_AddStandardPoints(pointsToAdd) -- Adds points and shows a notification

            -- Prevent the message from showing in chat
            return true
        end
    end)


    -- Console command to set point values for roles
    --[[
        console command: modsalary role amount
        This will grant the amount to role when calling !salary
    ]]--
    concommand.Add("modsalary", function(ply, cmd, args)
        -- Ensure only admins can execute the command
        if IsValid(ply) and not ply:IsAdmin() then
            ply:PrintMessage(HUD_PRINTCONSOLE, "You do not have permission to use this command.")
            return
        end

        -- Ensure correct number of arguments
        if #args < 2 then
            print("Usage: modsalary <role> <points>")
            return
        end

        -- Parse arguments
        local role = args[1]
        local points = tonumber(args[2])

        if not points then
            print("Invalid points value. Please provide a number.")
            return
        end

        -- Set the point value for the role
        rolePointValues[role] = points
        print("Set point value for role '" .. role .. "': " .. points)
        saveRolePointValues()
    end)
end