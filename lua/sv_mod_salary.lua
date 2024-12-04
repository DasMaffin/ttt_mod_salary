if SERVER then
    --[[
        Permissions:
        salarymod.manage - allows you to set the salary values for roles.
        salarymod.view - allows you to view which role receives how much salary
    ]]--
    ULib.ucl.registerAccess("salarymod.manage", "superadmin", "Allows managing Salary Mod roles and points.", "Salary Mod")
    ULib.ucl.registerAccess("salarymod.view", "superadmin", "Allows viewing Salary Mod roles and points.", "Salary Mod")

    local rolePointValues = {
    }


    util.AddNetworkString("SalaryModMessage") -- Register the network message

    local function sendChatMessage(ply, message)
        if IsValid(ply) and ply:IsPlayer() then
            print(message)
            net.Start("SalaryModMessage")
            net.WriteString(message)
            net.Send(ply) -- Send the message to the specific player
        end
    end

    local function saveRolePointValues()
        file.Write("salary_mod/role_point_values.txt", util.TableToJSON(rolePointValues))
        print("[Salary Mod] Role point values saved.")
    end

    local function loadRolePointValues()
        if file.Exists("salary_mod/role_point_values.txt", "DATA") then
            rolePointValues = util.JSONToTable(file.Read("salary_mod/role_point_values.txt", "DATA"))
            print("Saved role point values loaded.")
        else
            print("No saved role point values found. Using defaults.")
        end
    end

    local function sendAllRolePointValues(ply)
        local message = "Current Role Point Values:\n"
    
        for role, points in pairs(rolePointValues) do
            message = message .. role .. ": " .. points .. " points\n"
        end
    
        -- Split the message into chunks to avoid exceeding chat limits
        local lines = string.Split(message, "\n")
        for _, line in ipairs(lines) do
            ply:ChatPrint(line) -- Send each line as a separate chat message
        end
    end

    local function tryGrantSalary(ply, salary)
        if not IsValid(ply) or not ply:IsPlayer() then return end
    
        local steamID = ply:SteamID64() -- Use SteamID64 for uniqueness, make string or else the JSON serializer serializes the number in scientific notation.
        local currentTime = os.time()
        local filePath = "salary_mod/player_times.txt"
    
        -- Load or create the data file
        local playerTimes = {}
        if file.Exists(filePath, "DATA") then
            local fileContent = file.Read(filePath, "DATA")
            playerTimes = util.JSONToTable(fileContent, false, true) or {}
        end
    
        -- Calculate the timestamp for the last Monday at 00:01
        local currentDate = os.date("*t", currentTime)
        local daysBackToMonday = (currentDate.wday - 2) % 7
        local lastMondayTimestamp = os.time({
            year = currentDate.year,
            month = currentDate.month,
            day = currentDate.day - daysBackToMonday,
            hour = 0,
            min = 1,
            sec = 0
        })
    
        -- Check if the player exists in the file
        local lastRecordedTime = playerTimes[steamID] or 0
        
        if lastRecordedTime >= lastMondayTimestamp then
            -- Player's last time is after last Monday 00:01, so do nothing
            sendChatMessage(ply, "Your salary has already been granted, dont be greedy!")
            return
        end
    
        -- Update the player's time and save to file
        playerTimes[steamID] = currentTime
        file.Write(filePath, util.TableToJSON(playerTimes, true))
        
        ply:PS2_AddStandardPoints(salary)    
        sendChatMessage(ply, "You received: " .. tostring(salary) .. " Ponitshop points.")
    end
    

    hook.Add("Initialize", "LoadRolePointValues", loadRolePointValues)

    --[[ Chat commands: 
        !salary - gives you your salary
        !salaries - shows a list of all set salary values
    ]]--
    hook.Add("PlayerSay", "TTTModSalaryCommand", function(ply, text, teamChat, isDead)
        if string.lower(text) == "!salary" then
            local userRole = ply:GetUserGroup()

            local pointsToAdd = rolePointValues[userRole]
            if not pointsToAdd then
                sendChatMessage(ply, "Your role is unknown or unhandled: " .. tostring(userRole))
                return ""
            end
            tryGrantSalary(ply, pointsToAdd)
            return "" -- Prevent the message from showing in chat
        elseif string.lower(text) == "!salaries" and IsValid(ply) and ULib.ucl.query(ply, "salarymod.view") then
            sendAllRolePointValues(ply)

            return "" -- Prevent the message from showing in chat
        end        
    end)    
    --[[ Console command to set point values for roles
    console command: modsalary role amount
    This will grant the amount to role when calling !salary
    Arguments:
        role - the ulx role name, by default e.g. user, moderator, operator, superadmin.
        amount - amount of Pontshop 2 points to be awarded to the specified role 
    ]]--
    concommand.Add("modsalary", function(ply, cmd, args)
        -- Ensure only people with the salarymod.manage permission can execute the command
        if IsValid(ply) and not ULib.ucl.query(ply, "salarymod.manage") then
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
        saveRolePointValues()
        sendChatMessage(ply, "Set point value for role '" .. role .. "': " .. points)
    end)
end

