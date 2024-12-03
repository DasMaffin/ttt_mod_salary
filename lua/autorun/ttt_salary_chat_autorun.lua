if SERVER then 
    if not ULib then
        local success, err = pcall(function()
            include("ulib/init.lua") -- Dynamically load ULib
        end)
        if not success then
            error("[Salary Mod] Failed to load ULib: " .. tostring(err))
        end
    end
    AddCSLuaFile("cl_mod_salary.lua")
    include("sv_mod_salary.lua")
else
    include("cl_mod_salary.lua")
end