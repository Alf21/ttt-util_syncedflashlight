-- ------------------------------------------------------------------- --
-- --------------------- Third Person Flashlight --------------------- --
-- ------------------------------------------------------------------- --
-- --------------------------- By Wheatley --------------------------- --
-- ------------------------------------------------------------------- --
-- ------------------- Improved by BeltedRose85463 ------------------- --
-- ------------------------------------------------------------------- --
-- -------------- TTT Compatibility and cutted by Alf21 -------------- --
-- ------------------------------------------------------------------- --

local function CalcView(ply, pos, angles, fov, znear, zfar)
	local flashlight = ply:GetNWEntity("SFL_Flashlight")

	if flashlight:IsValid() then
		flashlight:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * GetConVar("rep_sfl_light_forward_offset"):GetInt())
		flashlight:SetAngles(ply:EyeAngles())
	end
end
hook.Add("CalcView", "SFL_CalcView", CalcView)

local plymeta = FindMetaTable("Player")

plymeta.SFL_FlashlightIsOn = plymeta.FlashlightIsOn
plymeta.FlashlightIsOn = function(self)
	if GetConVar("rep_sfl_enabled"):GetInt() ~= 0 then
		return self:GetNWBool("SFL_FlashlightOn")
	else
		return self:SFL_FlashlightIsOn()
	end
end
