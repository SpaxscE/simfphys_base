include("shared.lua")

function ENT:Initialize()
    self.SmoothRPM = 0
    self.OldDist = 0
    self.PitchOffset = 0
    self.OldActive = false
    self.OldGear = 0
    self.OldThrottle = 0
    self.FadeThrottle = 0
    self.SoundMode = 0
    self.DamageSnd = CreateSound(self, "simulated_vehicles/engine_damaged.wav")
    self.EngineSounds = {}
end

function ENT:Think()
    local curtime = CurTime()
    local Active = self:GetActive()
    local Throttle = self:GetThrottle()
    local LimitRPM = self:GetLimitRPM()
    self:ManageSounds(Active, Throttle, LimitRPM)
    self.RunNext = self.RunNext or 0

    if self.RunNext < curtime then
        self:ManageEffects(Active, Throttle, LimitRPM)
        self:CalcFlasher()
        self.RunNext = curtime + 0.06
    end

    self:SetPoseParameters(curtime)
    self:SetNextClientThink(curtime)

    return true
end

function ENT:CalcFlasher()
    self.Flasher = self.Flasher or 0
    local flashspeed = self.turnsignals_damaged and 0.06 or 0.0375
    self.Flasher = self.Flasher and self.Flasher + flashspeed or 0

    if self.Flasher >= 1 then
        self.Flasher = self.Flasher - 1
    end

    self.flashnum = math.min(math.abs(math.cos(math.rad(self.Flasher * 360)) ^ 2 * 1.5), 1)
    if not self.signal_left and not self.signal_right then return end

    if LocalPlayer() == self:GetDriver() then
        local fl_snd = self.flashnum > 0.9

        if fl_snd ~= self.fl_snd then
            self.fl_snd = fl_snd

            if fl_snd then
                self:EmitSound("simulated_vehicles/sfx/flasher_on.ogg")
            else
                self:EmitSound("simulated_vehicles/sfx/flasher_off.ogg")
            end
        end
    end
end

function ENT:GetFlasher()
    self.flashnum = self.flashnum or 0

    return self.flashnum
end

function ENT:SetPoseParameters(curtime)
    self.sm_vSteer = self.sm_vSteer and self.sm_vSteer + (self:GetVehicleSteer() - self.sm_vSteer) * 0.3 or 0
    self:SetPoseParameter("vehicle_steer", self.sm_vSteer)

    if not istable(self.pp_data) then
        self.ppNextCheck = self.ppNextCheck or curtime + 0.5

        if self.ppNextCheck < curtime then
            self.ppNextCheck = curtime + 0.5
            net.Start("simfphys_request_ppdata", true)
            net.WriteEntity(self)
            net.SendToServer()
        end
    else
        if not self.CustomWheels then
            for i = 1, table.Count(self.pp_data) do
                local Wheel = self.pp_data[i].entity

                if IsValid(Wheel) then
                    local addPos = Wheel:GetDamaged() and self.pp_data[i].dradius or 0
                    local Pose = (self.pp_data[i].pos - self:WorldToLocal(Wheel:GetPos()).z + addPos) / self.pp_data[i].travel
                    self:SetPoseParameter(self.pp_data[i].name, Pose)
                end
            end
        end
    end

    self:InvalidateBoneCache()
end

function ENT:GetEnginePos()
    local Attachment = self:GetAttachment(self:LookupAttachment("vehicle_engine"))
    local pos = self:GetPos()

    if Attachment then
        pos = Attachment.Pos
    end

    if not self.EnginePos then
        local vehiclelist = list.Get("simfphys_vehicles")[self:GetSpawn_List()]

        if vehiclelist then
            self.EnginePos = vehiclelist.Members.EnginePos or false
        else
            self.EnginePos = false
        end
    elseif isvector(self.EnginePos) then
        pos = self:LocalToWorld(self.EnginePos)
    end

    return pos
end

function ENT:GetRPM()
    local RPM = self.SmoothRPM and self.SmoothRPM or 0

    return RPM
end

function ENT:DamageEffects()
    local Pos = self:GetEnginePos()
    local Scale = self:GetCurHealth() / self:GetMaxHealth()
    local smoke = self:OnSmoke() and Scale <= 0.5
    local fire = self:OnFire()

    if self.wasSmoke ~= smoke then
        self.wasSmoke = smoke

        if smoke then
            self.smokesnd = CreateSound(self, "ambient/gas/steam2.wav")
            self.smokesnd:PlayEx(0.2, 90)
        else
            if self.smokesnd then
                self.smokesnd:Stop()
            end
        end
    end

    if self.wasFire ~= fire then
        self.wasFire = fire

        if fire then
            self:EmitSound("ambient/fire/mtov_flame2.wav")
            self.firesnd = CreateSound(self, "ambient/fire/fire_small1.wav")
            self.firesnd:Play()
        else
            if self.firesnd then
                self.firesnd:Stop()
            end
        end
    end

    if smoke then
        if Scale <= 0.5 then
            local effectdata = EffectData()
            effectdata:SetOrigin(Pos)
            effectdata:SetEntity(self)
            util.Effect("simfphys_engine_smoke", effectdata)
        end
    end

    if fire then
        local effectdata = EffectData()
        effectdata:SetOrigin(Pos)
        effectdata:SetEntity(self)
        util.Effect("simfphys_engine_fire", effectdata)
    end
end

function ENT:ManageEffects(Active, fThrottle, LimitRPM)
    self:DamageEffects()
    Active = Active and (self:GetFlyWheelRPM() ~= 0)
    if not Active then return end
    if not self.ExhaustPositions then return end
    local Scale = fThrottle * (0.2 + math.min(self:GetRPM() / LimitRPM, 1) * 0.8) ^ 2

    for i = 1, table.Count(self.ExhaustPositions) do
        if self.ExhaustPositions[i].OnBodyGroups then
            if self:BodyGroupIsValid(self.ExhaustPositions[i].OnBodyGroups) then
                local effectdata = EffectData()
                effectdata:SetOrigin(self.ExhaustPositions[i].pos)
                effectdata:SetAngles(self.ExhaustPositions[i].ang)
                effectdata:SetMagnitude(Scale)
                effectdata:SetEntity(self)
                util.Effect("simfphys_exhaust", effectdata)
            end
        else
            local effectdata = EffectData()
            effectdata:SetOrigin(self.ExhaustPositions[i].pos)
            effectdata:SetAngles(self.ExhaustPositions[i].ang)
            effectdata:SetMagnitude(Scale)
            effectdata:SetEntity(self)
            util.Effect("simfphys_exhaust", effectdata)
        end
    end
end

function ENT:ManageSounds(Active, fThrottle, LimitRPM)
    local FlyWheelRPM = self:GetFlyWheelRPM()
    local Active = Active and (FlyWheelRPM ~= 0)
    local IdleRPM = self:GetIdleRPM()
    local IsCruise = self:GetIsCruiseModeOn()
    local CurDist = (LocalPlayer():GetPos() - self:GetPos()):Length()
    local Throttle = IsCruise and math.Clamp(self:GetThrottle() ^ 3, 0.01, 0.7) or fThrottle
    local Gear = self:GetGear()
    local Clutch = self:GetClutch()
    local FadeRPM = LimitRPM * 0.5
    local FT = FrameTime()
    local Rate = 3.33 * FT
    self.FadeThrottle = self.FadeThrottle + math.Clamp(Throttle - self.FadeThrottle, -Rate, Rate)
    self.PitchOffset = self.PitchOffset + ((CurDist - self.OldDist) * 0.23 - self.PitchOffset) * 0.5
    self.OldDist = CurDist
    self.SmoothRPM = self.SmoothRPM + math.Clamp(FlyWheelRPM - self.SmoothRPM, -0.972 * FT * LimitRPM, 1.66 * FT * LimitRPM)
    self.OldThrottle2 = self.OldThrottle2 or 0

    if Throttle ~= self.OldThrottle2 then
        self.OldThrottle2 = Throttle

        if Throttle == 0 then
            if self.SmoothRPM > LimitRPM * 0.6 then
                self:Backfire()
            end
        end
    end

    if self:GetRevlimiter() and LimitRPM > 2500 then
        if (self.SmoothRPM >= LimitRPM - 200) and self.FadeThrottle > 0 then
            self.SmoothRPM = self.SmoothRPM - 0.2 * LimitRPM
            self.FadeThrottle = 0.2
            self:Backfire()
        end
    end

    if Active ~= self.OldActive then
        local preset = self:GetEngineSoundPreset()
        local UseGearResetter = self:SetSoundPreset(preset)
        self.SoundMode = UseGearResetter and 2 or 1
        self.OldActive = Active

        if Active then
            local MaxHealth = self:GetMaxHealth()
            local Health = self:GetCurHealth()

            if Health <= (MaxHealth * 0.6) then
                self.DamageSnd:PlayEx(0, 0)
            end

            if self.SoundMode == 2 then
                self.HighRPM = CreateSound(self, self.EngineSounds["HighRPM"])
                self.LowRPM = CreateSound(self, self.EngineSounds["LowRPM"])
                self.Idle = CreateSound(self, self.EngineSounds["Idle"])
                self.HighRPM:PlayEx(0, 0)
                self.LowRPM:PlayEx(0, 0)
                self.Idle:PlayEx(0, 0)
            else
                local IdleSound = self.EngineSounds["IdleSound"]
                local LowSound = self.EngineSounds["LowSound"]
                local HighSound = self.EngineSounds["HighSound"]
                local ThrottleSound = self.EngineSounds["ThrottleSound"]

                if IdleSound then
                    self.Idle = CreateSound(self, IdleSound)
                    self.Idle:PlayEx(0, 0)
                end

                if LowSound then
                    self.LowRPM = CreateSound(self, LowSound)
                    self.LowRPM:PlayEx(0, 0)
                end

                if HighSound then
                    self.HighRPM = CreateSound(self, HighSound)
                    self.HighRPM:PlayEx(0, 0)
                end

                if ThrottleSound then
                    self.Valves = CreateSound(self, ThrottleSound)
                    self.Valves:PlayEx(0, 0)
                end
            end
        else
            self:SaveStopSounds()
        end
    end

    if Active then
        local Volume = 0.25 + 0.25 * ((self.SmoothRPM / LimitRPM) ^ 1.5) + self.FadeThrottle * 0.5
        local Pitch = math.Clamp((20 + self.SmoothRPM / 50 - self.PitchOffset) * self.PitchMulAll, 0, 255)

        if self.DamageSnd then
            self.DamageSnd:ChangeVolume((self.SmoothRPM / LimitRPM) * 0.6 ^ 1.5)
            self.DamageSnd:ChangePitch(100)
        end

        if self.SoundMode == 2 then
            if self.FadeThrottle ~= self.OldThrottle then
                self.OldThrottle = self.FadeThrottle

                if self.FadeThrottle == 0 and Clutch == 0 then
                    if self.SmoothRPM >= FadeRPM then
                        if IsCruise ~= true then
                            if self.LowRPM then
                                self.LowRPM:Stop()
                            end

                            self.LowRPM = CreateSound(self, self.EngineSounds["RevDown"])
                            self.LowRPM:PlayEx(0, 0)
                        end
                    end
                end
            end

            if Gear ~= self.OldGear then
                if self.SmoothRPM >= FadeRPM and Gear > 3 then
                    if Clutch ~= 1 then
                        if self.OldGear < Gear then
                            if self.HighRPM then
                                self.HighRPM:Stop()
                            end

                            self.HighRPM = CreateSound(self, self.EngineSounds["ShiftUpToHigh"])
                            self.HighRPM:PlayEx(0, 0)

                            if self.SmoothRPM > LimitRPM * 0.6 then
                                if math.random(0, 4) >= 3 then
                                    timer.Simple(0.4, function()
                                        if not IsValid(self) then return end
                                        self:Backfire()
                                    end)
                                end
                            end
                        else
                            if self.FadeThrottle > 0 then
                                if self.HighRPM then
                                    self.HighRPM:Stop()
                                end

                                self.HighRPM = CreateSound(self, self.EngineSounds["ShiftDownToHigh"])
                                self.HighRPM:PlayEx(0, 0)
                            end
                        end
                    end
                else
                    if Clutch ~= 1 then
                        if self.OldGear > Gear and self.FadeThrottle > 0 and Gear >= 3 then
                            if self.HighRPM then
                                self.HighRPM:Stop()
                            end

                            self.HighRPM = CreateSound(self, self.EngineSounds["ShiftDownToHigh"])
                            self.HighRPM:PlayEx(0, 0)
                        else
                            if self.HighRPM then
                                self.HighRPM:Stop()
                            end

                            if self.LowRPM then
                                self.LowRPM:Stop()
                            end

                            self.HighRPM = CreateSound(self, self.EngineSounds["HighRPM"])
                            self.LowRPM = CreateSound(self, self.EngineSounds["LowRPM"])
                            self.HighRPM:PlayEx(0, 0)
                            self.LowRPM:PlayEx(0, 0)
                        end
                    end
                end

                self.OldGear = Gear
            end

            self.Idle:ChangeVolume(math.Clamp(math.min((self.SmoothRPM / IdleRPM) * 3, 1.5 + self.FadeThrottle * 0.5) * 0.7 - self.SmoothRPM / 2000, 0, 1))
            self.Idle:ChangePitch(math.Clamp(Pitch * 3, 0, 255))
            self.LowRPM:ChangeVolume(math.Clamp(Volume - (self.SmoothRPM - 2000) / 2000 * self.FadeThrottle, 0, 1))
            self.LowRPM:ChangePitch(math.Clamp(Pitch * self.PitchMulLow, 0, 255))
            local hivol = math.max((self.SmoothRPM - 2000) / 2000, 0) * Volume
            self.HighRPM:ChangeVolume(self.FadeThrottle < 0.4 and hivol * self.FadeThrottle or hivol * self.FadeThrottle * 2.5)
            self.HighRPM:ChangePitch(math.Clamp(Pitch * self.PitchMulHigh, 0, 255))
        else
            if Gear ~= self.OldGear then
                if self.SmoothRPM >= FadeRPM and Gear > 3 then
                    if Clutch ~= 1 then
                        if self.OldGear < Gear then
                            if self.SmoothRPM > LimitRPM * 0.6 then
                                if math.random(0, 4) >= 3 then
                                    timer.Simple(0.4, function()
                                        if not IsValid(self) then return end
                                        self:Backfire()
                                    end)
                                end
                            end
                        end
                    end
                end

                self.OldGear = Gear
            end

            local IdlePitch = self.Idle_PitchMul
            self.Idle:ChangeVolume(math.Clamp(math.min((self.SmoothRPM / IdleRPM) * 3, 1.5 + self.FadeThrottle * 0.5) * 0.7 - self.SmoothRPM / 2000, 0, 1))
            self.Idle:ChangePitch(math.Clamp(Pitch * 3 * IdlePitch, 0, 255))
            local LowPitch = self.Mid_PitchMul
            local LowVolume = self.Mid_VolumeMul
            local LowFadeOutRPM = LimitRPM * (self.Mid_FadeOutRPMpercent / 100)
            local LowFadeOutRate = LimitRPM * self.Mid_FadeOutRate
            self.LowRPM:ChangeVolume(math.Clamp((Volume - math.Clamp((self.SmoothRPM - LowFadeOutRPM) / LowFadeOutRate, 0, 1)) * LowVolume, 0, 1))
            self.LowRPM:ChangePitch(math.Clamp(Pitch * LowPitch, 0, 255))
            local HighPitch = self.High_PitchMul
            local HighVolume = self.High_VolumeMul
            local HighFadeInRPM = LimitRPM * (self.High_FadeInRPMpercent / 100)
            local HighFadeInRate = LimitRPM * self.High_FadeInRate
            self.HighRPM:ChangeVolume(math.Clamp(math.Clamp((self.SmoothRPM - HighFadeInRPM) / HighFadeInRate, 0, Volume) * HighVolume, 0, 1))
            self.HighRPM:ChangePitch(math.Clamp(Pitch * HighPitch, 0, 255))
            local ThrottlePitch = self.Throttle_PitchMul
            local ThrottleVolume = self.Throttle_VolumeMul
            self.Valves:ChangeVolume(math.Clamp((self.SmoothRPM - 2000) / 2000, 0, Volume) * (0.2 + 0.15 * self.FadeThrottle) * ThrottleVolume)
            self.Valves:ChangePitch(math.Clamp(Pitch * ThrottlePitch, 0, 255))
        end
    end
end

function ENT:Backfire(damaged)
    if not self:GetBackFire() and not damaged then return end
    if not self.ExhaustPositions then return end
    local expos = self.ExhaustPositions

    for i = 1, table.Count(expos) do
        if math.random(1, 3) >= 2 or damaged then
            local Pos = expos[i].pos
            local Ang = expos[i].ang - Angle(90, 0, 0)

            if expos[i].OnBodyGroups then
                if self:BodyGroupIsValid(expos[i].OnBodyGroups) then
                    local effectdata = EffectData()
                    effectdata:SetOrigin(Pos)
                    effectdata:SetAngles(Ang)
                    effectdata:SetEntity(self)
                    effectdata:SetFlags(damaged and 1 or 0)
                    util.Effect("simfphys_backfire", effectdata)
                end
            else
                local effectdata = EffectData()
                effectdata:SetOrigin(Pos)
                effectdata:SetAngles(Ang)
                effectdata:SetEntity(self)
                effectdata:SetFlags(damaged and 1 or 0)
                util.Effect("simfphys_backfire", effectdata)
            end
        end
    end
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:SetSoundPreset(index)
    local vehiclelist = list.Get("simfphys_vehicles")[self:GetSpawn_List()] or false

    if vehiclelist then
        if not self.ExhaustPositions then
            self.ExhaustPositions = vehiclelist.Members.ExhaustPositions
        end
    end

    if index == -1 then
        if vehiclelist then
            local soundoverride = self:GetSoundoverride()
            local data = string.Explode(",", soundoverride)

            if soundoverride ~= "" and data[1] == "1" then
                self.EngineSounds["Idle"] = data[4]
                self.EngineSounds["LowRPM"] = data[6]
                self.EngineSounds["HighRPM"] = data[2]
                self.EngineSounds["RevDown"] = data[8]
                self.EngineSounds["ShiftUpToHigh"] = data[10]
                self.EngineSounds["ShiftDownToHigh"] = data[9]
                self.PitchMulLow = data[7]
                self.PitchMulHigh = data[3]
                self.PitchMulAll = data[5]
            else
                local idle = vehiclelist.Members.snd_idle or ""
                local low = vehiclelist.Members.snd_low or ""
                local mid = vehiclelist.Members.snd_mid or ""
                local revdown = vehiclelist.Members.snd_low_revdown or ""
                local gearup = vehiclelist.Members.snd_mid_gearup or ""
                local geardown = vehiclelist.Members.snd_mid_geardown or ""
                self.EngineSounds["Idle"] = idle ~= "" and idle or false
                self.EngineSounds["LowRPM"] = low ~= "" and low or false
                self.EngineSounds["HighRPM"] = mid ~= "" and mid or false
                self.EngineSounds["RevDown"] = revdown ~= "" and revdown or low
                self.EngineSounds["ShiftUpToHigh"] = gearup ~= "" and gearup or mid
                self.EngineSounds["ShiftDownToHigh"] = geardown ~= "" and geardown or gearup
                self.PitchMulLow = vehiclelist.Members.snd_low_pitch or 1
                self.PitchMulHigh = vehiclelist.Members.snd_mid_pitch or 1
                self.PitchMulAll = vehiclelist.Members.snd_pitch or 1
            end
        else
            local ded = "common/bugreporter_failed.wav"
            self.EngineSounds["Idle"] = ded
            self.EngineSounds["LowRPM"] = ded
            self.EngineSounds["HighRPM"] = ded
            self.EngineSounds["RevDown"] = ded
            self.EngineSounds["ShiftUpToHigh"] = ded
            self.EngineSounds["ShiftDownToHigh"] = ded
            self.PitchMulLow = 0
            self.PitchMulHigh = 0
            self.PitchMulAll = 0
        end

        if self.EngineSounds["Idle"] ~= false and self.EngineSounds["LowRPM"] ~= false and self.EngineSounds["HighRPM"] ~= false then
            self:PrecacheSounds()

            return true
        else
            self:SetSoundPreset(0)

            return false
        end
    end

    if index == 0 then
        local soundoverride = self:GetSoundoverride()
        local data = string.Explode(",", soundoverride)

        if soundoverride ~= "" and data[1] ~= "1" then
            self.EngineSounds["IdleSound"] = data[1]
            self.Idle_PitchMul = data[2]
            self.EngineSounds["LowSound"] = data[3]
            self.Mid_PitchMul = data[4]
            self.Mid_VolumeMul = data[5]
            self.Mid_FadeOutRPMpercent = data[6]
            self.Mid_FadeOutRate = data[7]
            self.EngineSounds["HighSound"] = data[8]
            self.High_PitchMul = data[9]
            self.High_VolumeMul = data[10]
            self.High_FadeInRPMpercent = data[11]
            self.High_FadeInRate = data[12]
            self.EngineSounds["ThrottleSound"] = data[13]
            self.Throttle_PitchMul = data[14]
            self.Throttle_VolumeMul = data[15]
        else
            self.EngineSounds["IdleSound"] = vehiclelist and vehiclelist.Members.Sound_Idle or "simulated_vehicles/misc/e49_idle.wav"
            self.Idle_PitchMul = (vehiclelist and vehiclelist.Members.Sound_IdlePitch) or 1
            self.EngineSounds["LowSound"] = vehiclelist and vehiclelist.Members.Sound_Mid or "simulated_vehicles/misc/gto_onlow.wav"
            self.Mid_PitchMul = (vehiclelist and vehiclelist.Members.Sound_MidPitch) or 1
            self.Mid_VolumeMul = (vehiclelist and vehiclelist.Members.Sound_MidVolume) or 0.75
            self.Mid_FadeOutRPMpercent = (vehiclelist and vehiclelist.Members.Sound_MidFadeOutRPMpercent) or 68
            self.Mid_FadeOutRate = (vehiclelist and vehiclelist.Members.Sound_MidFadeOutRate) or 0.4
            self.EngineSounds["HighSound"] = vehiclelist and vehiclelist.Members.Sound_High or "simulated_vehicles/misc/nv2_onlow_ex.wav"
            self.High_PitchMul = (vehiclelist and vehiclelist.Members.Sound_HighPitch) or 1
            self.High_VolumeMul = (vehiclelist and vehiclelist.Members.Sound_HighVolume) or 1
            self.High_FadeInRPMpercent = (vehiclelist and vehiclelist.Members.Sound_HighFadeInRPMpercent) or 26.6
            self.High_FadeInRate = (vehiclelist and vehiclelist.Members.Sound_HighFadeInRate) or 0.266
            self.EngineSounds["ThrottleSound"] = vehiclelist and vehiclelist.Members.Sound_Throttle or "simulated_vehicles/valve_noise.wav"
            self.Throttle_PitchMul = (vehiclelist and vehiclelist.Members.Sound_ThrottlePitch) or 0.65
            self.Throttle_VolumeMul = (vehiclelist and vehiclelist.Members.Sound_ThrottleVolume) or 1
        end

        self.PitchMulLow = 1
        self.PitchMulHigh = 1
        self.PitchMulAll = 1
        self:PrecacheSounds()

        return false
    end

    if index > 0 then
        local clampindex = math.Clamp(index, 1, table.Count(simfphys.SoundPresets))
        self.EngineSounds["Idle"] = simfphys.SoundPresets[clampindex][1]
        self.EngineSounds["LowRPM"] = simfphys.SoundPresets[clampindex][2]
        self.EngineSounds["HighRPM"] = simfphys.SoundPresets[clampindex][3]
        self.EngineSounds["RevDown"] = simfphys.SoundPresets[clampindex][4]
        self.EngineSounds["ShiftUpToHigh"] = simfphys.SoundPresets[clampindex][5]
        self.EngineSounds["ShiftDownToHigh"] = simfphys.SoundPresets[clampindex][6]
        self.PitchMulLow = simfphys.SoundPresets[clampindex][7]
        self.PitchMulHigh = simfphys.SoundPresets[clampindex][8]
        self.PitchMulAll = simfphys.SoundPresets[clampindex][9]
        self:PrecacheSounds()

        return true
    end

    return false
end

function ENT:PrecacheSounds()
    for index, sound in pairs(self.EngineSounds) do
        if not isbool(sound) then
            if file.Exists("sound/" .. sound, "GAME") then
                util.PrecacheSound(sound)
            else
                print("Warning soundfile \"" .. sound .. "\" not found. Using \"common/null.wav\" instead to prevent fps rape")
                self.EngineSounds[index] = "common/null.wav"
            end
        end
    end
end

function ENT:GetVehicleInfo()
    return self.VehicleInfo
end

function ENT:SaveStopSounds()
    if self.HighRPM then
        self.HighRPM:Stop()
    end

    if self.LowRPM then
        self.LowRPM:Stop()
    end

    if self.Idle then
        self.Idle:Stop()
    end

    if self.Valves then
        self.Valves:Stop()
    end

    if self.DamageSnd then
        self.DamageSnd:Stop()
    end
end

function ENT:OnRemove()
    self:SaveStopSounds()

    if self.smokesnd then
        self.smokesnd:Stop()
    end

    if self.firesnd then
        self.firesnd:Stop()
    end
end