if SERVER then
	AddCSLuaFile()
	AddCSLuaFile("syncedflashlight/cl_init.lua")

	include("syncedflashlight/init.lua")
else
	include("syncedflashlight/cl_init.lua")
end
