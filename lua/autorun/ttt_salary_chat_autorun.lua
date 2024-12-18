AddCSLuaFile("cl_mod_salary.lua")
include("cl_mod_salary.lua")
if SERVER then
    if not file.Exists("salary_mod", "DATA") then
        file.CreateDir("salary_mod")
        print("[Salary Mod] Created folder: salary_mod")
    end
    
    AddCSLuaFile("ulx/modules/sh/sh_salary.lua")
    include("sv_mod_salary.lua")
else
end