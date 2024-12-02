-- Register a chat command that listens for "!salary"
hook.Add("PlayerSay", "SalaryChatCommand", function(ply, text, teamChat)
    -- Check if the text matches the command
    if string.lower(text) == "!salary" then
        -- Print "salary" to the console
        print("Salary")
        
        -- Optionally, send a message back to the player
        ply:ChatPrint("You called for your salary!")
        
        -- Return false to prevent the chat message from showing up
        return ""
        
    end
end)
