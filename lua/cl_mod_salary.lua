net.Receive("SalaryModMessage", function()
    local message = net.ReadString() -- Read the message sent from the server
    chat.AddText(Color(0, 255, 0), "[Salary Mod] ", Color(255, 255, 255), message)
end)