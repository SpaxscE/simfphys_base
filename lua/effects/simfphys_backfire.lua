local Materials = {"particle/smokesprites_0001", "particle/smokesprites_0002", "particle/smokesprites_0003", "particle/smokesprites_0004", "particle/smokesprites_0005", "particle/smokesprites_0006", "particle/smokesprites_0007", "particle/smokesprites_0008", "particle/smokesprites_0009", "particle/smokesprites_0010", "particle/smokesprites_0011", "particle/smokesprites_0012", "particle/smokesprites_0013", "particle/smokesprites_0014", "particle/smokesprites_0015", "particle/smokesprites_0016"}

function EFFECT:Init(data)
    local bdamaged = data:GetFlags() >= 1
    local lPos = data:GetOrigin()
    local lAng = data:GetAngles()
    local Entity = data:GetEntity()
    local Delay = bdamaged and 0 or math.random(0, 0.4)

    timer.Simple(Delay, function()
        if IsValid(Entity) then
            local Vel = Entity:GetVelocity()
            local Pos = Entity:LocalToWorld(lPos) + Vel * FrameTime() * 0.5
            local Ang = Entity:LocalToWorldAngles(lAng)
            local snd1 = "simulated_vehicles/sfx/ex_backfire_damaged_" .. math.Round(math.random(1, 3), 1) .. ".ogg"
            local snd2 = Entity:GetBackfireSound()

            if snd2 == "" then
                snd2 = "simulated_vehicles/sfx/ex_backfire_" .. math.Round(math.random(1, 4), 1) .. ".ogg"
            end

            local snd = bdamaged and snd1 or snd2
            Entity.CurBackFireSound = CreateSound(Entity, snd)
            Entity.CurBackFireSound:Play()

            Entity:CallOnRemove("stopbfsounds", function(Entity)
                if Entity.CurBackFireSound then
                    Entity.CurBackFireSound:Stop()
                end
            end)

            timer.Simple(5, function()
                if not IsValid(Entity) then return end

                if Entity.CurBackFireSound then
                    Entity.CurBackFireSound:Stop()
                end
            end)

            local dlight = DynamicLight(Entity:EntIndex() * math.random(1, 4))

            if dlight then
                dlight.pos = Pos
                dlight.r = 255
                dlight.g = 180
                dlight.b = 100
                dlight.brightness = 2
                dlight.Decay = 1000
                dlight.Size = 120
                dlight.DieTime = CurTime() + 0.5
            end

            local emitter = ParticleEmitter(Pos, false)

            if emitter then
                for i = 0, 12 do
                    local particle1 = emitter:Add("effects/muzzleflash2", Pos)

                    if particle1 then
                        particle1:SetVelocity(Vel + Ang:Forward() * (5 + Vel:Length() / 20))
                        particle1:SetDieTime(0.1)
                        particle1:SetStartAlpha(255)
                        particle1:SetStartSize(math.random(4, 12))
                        particle1:SetEndSize(0)
                        particle1:SetRoll(math.Rand(-1, 1))
                        particle1:SetColor(255, 255, 255)
                        particle1:SetCollide(false)
                    end

                    local particle2 = emitter:Add(Materials[math.Round(math.Rand(1, table.Count(Materials)), 0)], Pos)

                    if particle2 then
                        particle2:SetVelocity(Vel + Ang:Forward() * (10 + Vel:Length() / 20))
                        particle2:SetDieTime(0.3)
                        particle2:SetStartAlpha(60)
                        particle2:SetStartSize(0)
                        particle2:SetEndSize(math.random(8, 20))
                        particle2:SetRoll(math.Rand(-1, 1))
                        particle2:SetColor(100, 100, 100)
                        particle2:SetCollide(false)
                    end

                    if bdamaged then
                        local particle3 = emitter:Add(Materials[math.Round(math.Rand(1, table.Count(Materials)), 0)], Pos)

                        if particle3 then
                            particle3:SetVelocity(Vel + Ang:Forward() * math.random(30, 60))
                            particle3:SetDieTime(0.5)
                            particle3:SetAirResistance(20)
                            particle3:SetStartAlpha(100)
                            particle3:SetStartSize(0)
                            particle3:SetEndSize(math.random(25, 50))
                            particle3:SetRoll(math.Rand(-1, 1))
                            particle3:SetColor(40, 40, 40)
                            particle3:SetCollide(false)
                        end
                    end
                end

                emitter:Finish()
            end
        end
    end)
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end