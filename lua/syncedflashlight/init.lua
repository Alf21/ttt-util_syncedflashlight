-- ------------------------------------------------------------------- --
-- --------------------- Third Person Flashlight --------------------- --
-- ------------------------------------------------------------------- --
-- --------------------------- By Wheatley --------------------------- --
-- ------------------------------------------------------------------- --
-- ------------------- Improved by BeltedRose85463 ------------------- --
-- ------------------------------------------------------------------- --
-- -------------- TTT Compatibility and cutted by Alf21 -------------- --
-- ------------------------------------------------------------------- --

AddCSLuaFile("cl_sfl.lua")

local pjs = pjs or {}

CreateConVar("sfl_enabled", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY})
CreateConVar("sfl_light_forward_offset", "15", {FCVAR_ARCHIVE, FCVAR_NOTIFY})

function SFL_ShouldUse()
	if GetConVar("sfl_enabled"):GetInt() ~= 0 then
		return true
	end

	return false
end

function SFL_SetupProjectedTexture(ply)
	if ply.m_bSFLDisabled then return end

	if SERVER then
		pjs[ply] = ents.Create("env_projectedtexture")
		pjs[ply]:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * GetConVar("sfl_light_forward_offset"):GetInt())
		pjs[ply]:SetAngles(ply:EyeAngles())
		pjs[ply]:SetKeyValue("enableshadows", 1)
		pjs[ply]:SetKeyValue("farz", 750)
		pjs[ply]:SetKeyValue("nearz", 10)
		pjs[ply]:SetKeyValue("lightfov", 75)
		pjs[ply]:SetKeyValue("lightcolor", "255 255 255 255")
		pjs[ply]:Spawn()
		pjs[ply]:SetNWBool("SFL_IsFlashlight", true)
		pjs[ply]:Input("SpotlightTexture", NULL, NULL, "effects/flashlight001")

		ply:SetNWEntity("SFL_Flashlight", pjs[ply])
	end
end

function SFL_RemoveProjectedTexture(ply)
	if pjs[ply] then
		ply:SetNWEntity("SFL_Flashlight", NULL)

		SafeRemoveEntity(pjs[ply])

		pjs[ply] = nil
	end
end

function SFL_SwitchFlashlight(ply, state, nosound, override)
	if not override and (ply.IsActive and not ply:IsActive() or not ply:Alive()) then return end

	local newState

	if state then
		newState = state
	else
		newState = not ply:GetNWBool("SFL_FlashlightOn")
	end

	ply:SetNWBool("SFL_FlashlightOn", newState)

	if newState then
		if not pjs[ply] then
			SFL_SetupProjectedTexture(ply)
		end
	elseif pjs[ply] then
		SFL_RemoveProjectedTexture(ply)
	end

	if not nosound and not ply.m_bSFLDisabled then
		ply:SendLua("surface.PlaySound('items/flashlight1.wav')")
	end
end

local plymeta = FindMetaTable("Player")

plymeta.SFL_AllowFlashlight = plymeta.AllowFlashlight
plymeta.AllowFlashlight = function(self, allow)
	self.SFL_FlashlightDisallowed = not allow

	self:SFL_AllowFlashlight(allow)
end

plymeta.SFL_Flashlight = plymeta.Flashlight
plymeta.Flashlight = function(self, isOn)
	if SFL_ShouldUse() then
		SFL_SwitchFlashlight(self, isOn, GetConVar("gamemode"):GetString() == "terrortown")
	else
		self:SetNWBool("SFL_FlashlightOn", isOn)
		self:SFL_Flashlight(isOn)
	end
end

plymeta.SFL_FlashlightIsOn = plymeta.FlashlightIsOn
plymeta.FlashlightIsOn = function(self)
	if SFL_ShouldUse() then
		return self:GetNWBool("SFL_FlashlightOn")
	else
		return self:SFL_FlashlightIsOn()
	end
end

hook.Add("PlayerDisconnected", "SFL_HookPlayerDisconnects", function(ply)
	if IsValid(pjs[ply]) then
		SafeRemoveEntity(pjs[ply])

		pjs[ply] = nil
	end
end)

hook.Add("PlayerSwitchFlashlight", "SFL_SwitchFlashlightHook", function(ply, state)
	if GetConVar("gamemode"):GetString() == "terrortown" then
		if not IsValid(ply) then
			return false
		end

		-- add the flashlight "effect" here, and then deny the switch
		-- this prevents the sound from playing, fixing the exploit
		-- where weapon sound could be silenced using the flashlight sound
		if not SFL_ShouldUse() then
			if state and ply:IsTerror() then
				ply:AddEffects(EF_DIMLIGHT)
			else
				ply:RemoveEffects(EF_DIMLIGHT)
			end
		else
			if ply.SFL_FlashlightDisallowed then
				return false
			end

			SFL_SwitchFlashlight(ply, state and ply:IsTerror(), true)
		end

		return false
	end

	if not SFL_ShouldUse() then
		return true
	end

	if ply.SFL_FlashlightDisallowed then
		return false
	end

	SFL_SwitchFlashlight(ply, nil)

	return false
end)
