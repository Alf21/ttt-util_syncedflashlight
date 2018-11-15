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
		flashlight:SetPos(ply:EyePos() + ply:EyeAngles():Forward() * GetGlobalInt("sfl_light_forward_offset", 15))
		flashlight:SetAngles(ply:EyeAngles())
	end
end
hook.Add("CalcView", "SFL_CalcView", CalcView)

local plymeta = FindMetaTable("Player")

plymeta.SFL_FlashlightIsOn = plymeta.FlashlightIsOn
plymeta.FlashlightIsOn = function(self)
	if GetGlobalBool("sfl_enabled", false) then
		return self:GetNWBool("SFL_FlashlightOn")
	else
		return self:SFL_FlashlightIsOn()
	end
end
