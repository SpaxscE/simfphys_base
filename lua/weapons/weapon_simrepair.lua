AddCSLuaFile()
SWEP.Category = "simfphys"
SWEP.Spawnable = true
SWEP.AdminSpawnable = false
SWEP.ViewModel = "models/weapons/c_physcannon.mdl"
SWEP.WorldModel = "models/weapons/w_physics.mdl"
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 53
SWEP.Weight = 42
SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.HoldType = "physgun"
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

if (CLIENT) then
    SWEP.PrintName = "Vehicle Repair Tool"
    SWEP.Purpose = "repairs simfphys vehicles"
    SWEP.Instructions = "Primary to repair"
    SWEP.Author = "Blu"
    SWEP.Slot = 1
    SWEP.SlotPos = 9
    SWEP.IconLetter = "k"
    SWEP.WepSelectIcon = surface.GetTextureID("weapons/s_repair")
    --SWEP.DrawWeaponInfoBox 	= false
end

function SWEP:Initialize()
    self.Weapon:SetHoldType(self.HoldType)
end

function SWEP:OwnerChanged()
end

function SWEP:Think()
end

function SWEP:PrimaryAttack()
    self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)
    local Owner = self:GetOwner()
    local Trace = Owner:GetEyeTrace()
    local ent = Trace.Entity
    if not IsValid(ent) then return end
    local class = ent:GetClass():lower()
    local IsVehicle = class == "gmod_sent_vehicle_fphysics_base"
    local IsWheel = class == "gmod_sent_vehicle_fphysics_wheel"

    if IsVehicle then
        local Dist = (Trace.HitPos - Owner:GetPos()):Length()

        if (Dist <= 100) then
            self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
            Owner:SetAnimation(PLAYER_ATTACK1)

            if (SERVER) then
                local MaxHealth = ent:GetMaxHealth()
                local Health = ent:GetCurHealth()

                if Health < MaxHealth then
                    local NewHealth = math.min(Health + 30, MaxHealth)

                    if NewHealth > (MaxHealth * 0.6) then
                        ent:SetOnFire(false)
                        ent:SetOnSmoke(false)
                    end

                    if NewHealth > (MaxHealth * 0.3) then
                        ent:SetOnFire(false)

                        if NewHealth <= (MaxHealth * 0.6) then
                            ent:SetOnSmoke(true)
                        end
                    end

                    ent:SetCurHealth(NewHealth)
                    local effect = ents.Create("env_spark")
                    effect:SetKeyValue("targetname", "target")
                    effect:SetPos(Trace.HitPos + Trace.HitNormal * 2)
                    effect:SetAngles(Trace.HitNormal:Angle())
                    effect:Spawn()
                    effect:SetKeyValue("spawnflags", "128")
                    effect:SetKeyValue("Magnitude", 1)
                    effect:SetKeyValue("TrailLength", 0.2)
                    effect:Fire("SparkOnce")
                    effect:Fire("kill", "", 0.08)
                else
                    self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
                    sound.Play(Sound("hl1/fvox/beep.wav"), self:GetPos(), 75)
                    net.Start("simfphys_lightsfixall")
                    net.WriteEntity(ent)
                    net.Broadcast()
                    ent:OnRepaired()
                    hook.Run("simfphysOnRepaired", ent)

                    if istable(ent.Wheels) then
                        for i = 1, table.Count(ent.Wheels) do
                            local Wheel = ent.Wheels[i]

                            if IsValid(Wheel) then
                                Wheel:SetDamaged(false)
                            end
                        end
                    end
                end
            end
        end
    elseif IsWheel then
        local Dist = (Trace.HitPos - Owner:GetPos()):Length()

        if (Dist <= 100) then
            self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
            Owner:SetAnimation(PLAYER_ATTACK1)

            if (SERVER) then
                if ent:GetDamaged() then
                    ent:SetDamaged(false)
                    local effect = ents.Create("env_spark")
                    effect:SetKeyValue("targetname", "target")
                    effect:SetPos(Trace.HitPos + Trace.HitNormal * 2)
                    effect:SetAngles(Trace.HitNormal:Angle())
                    effect:Spawn()
                    effect:SetKeyValue("spawnflags", "128")
                    effect:SetKeyValue("Magnitude", 1)
                    effect:SetKeyValue("TrailLength", 0.2)
                    effect:Fire("SparkOnce")
                    effect:Fire("kill", "", 0.08)
                else
                    self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
                    sound.Play(Sound("hl1/fvox/beep.wav"), self:GetPos(), 75)
                end
            end
        end
    end
end

function SWEP:DrawHUD()
    if (LocalPlayer():InVehicle()) then return end
    local screenw = ScrW()
    local screenh = ScrH()
    local Widescreen = (screenw / screenh) > (4 / 3)
    local sizex = screenw * (Widescreen and 1 or 1.32)
    local sizey = screenh
    local xpos = sizex * 0.02
    local ypos = sizey * 0.85
    local Trace = self:GetOwner():GetEyeTrace()
    local ent = Trace.Entity
    draw.RoundedBox(0, xpos, ypos, sizex * 0.118, sizey * 0.02, Color(0, 0, 0, 80))

    if (not IsValid(ent)) then
        draw.SimpleText("0 / 0", "simfphysfont", xpos + sizex * 0.059, ypos + sizey * 0.01, Color(255, 235, 0, 255), 1, 1)

        return
    end

    local IsVehicle = ent:GetClass():lower() == "gmod_sent_vehicle_fphysics_base"

    if (IsVehicle) then
        local MaxHealth = ent:GetMaxHealth()
        local Health = ent:GetCurHealth()
        draw.RoundedBox(0, xpos, ypos, ((sizex * 0.118) / MaxHealth) * Health, sizey * 0.02, Color((Health < MaxHealth * 0.6) and 255 or 0, (Health >= MaxHealth * 0.3) and 255 or 0, 0, 100))
        draw.SimpleText(Health .. " / " .. MaxHealth, "simfphysfont", xpos + sizex * 0.059, ypos + sizey * 0.01, Color(255, 235, 0, 255), 1, 1)
    else
        draw.SimpleText("0 / 0", "simfphysfont", xpos + sizex * 0.059, ypos + sizey * 0.01, Color(255, 235, 0, 255), 1, 1)
    end
end

function SWEP:SecondaryAttack()
    return false
end

function SWEP:Deploy()
    self.Weapon:SendWeaponAnim(ACT_VM_DRAW)

    return true
end

function SWEP:Holster()
    return true
end