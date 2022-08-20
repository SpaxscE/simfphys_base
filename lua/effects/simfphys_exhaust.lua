local Materials = {"particle/smokesprites_0001", "particle/smokesprites_0002", "particle/smokesprites_0003", "particle/smokesprites_0004", "particle/smokesprites_0005", "particle/smokesprites_0006", "particle/smokesprites_0007", "particle/smokesprites_0008", "particle/smokesprites_0009", "particle/smokesprites_0010", "particle/smokesprites_0011", "particle/smokesprites_0012", "particle/smokesprites_0013", "particle/smokesprites_0014", "particle/smokesprites_0015", "particle/smokesprites_0016"}

function EFFECT:Init(data)
    local lPos = data:GetOrigin()
    local lAng = data:GetAngles() - Angle(90, 0, 0)
    local Entity = data:GetEntity()
    local Size = data:GetMagnitude()
    local TurboCharged = Entity:GetTurboCharged()
    local SuperCharged = Entity:GetSuperCharged()

    if IsValid(Entity) then
        local Vel = Entity:GetVelocity()
        local Dir = Entity:LocalToWorldAngles(lAng):Forward()
        local Pos = Entity:LocalToWorld(lPos)
        local emitter = ParticleEmitter(Pos, false)

        if emitter then
            local MaxHealth = Entity:GetMaxHealth()
            local Health = Entity:GetCurHealth()
            local particle = emitter:Add(Materials[math.Round(math.Rand(1, table.Count(Materials)), 0)], Pos)
            local cAdd = (1 - (Health / MaxHealth)) * 100
            local cInt = math.Clamp(100 - 40 * Size, 0, 255)
            local rand = Vector(math.random(-1, 1), math.random(-1, 1), math.random(-1, 1)) * 0.25

            if particle then
                particle:SetVelocity(Vel + (Dir + rand) * (50 + Size * 100))
                particle:SetDieTime(0.4 + Size * 0.6)
                particle:SetAirResistance(200)
                particle:SetStartAlpha(math.max(20 + Size ^ 3 * (20 + cAdd) - Vel:Length() / 800, 0))
                particle:SetStartSize((SuperCharged and TurboCharged) and 4 or 2)
                particle:SetEndSize(10 + Size * 60)
                particle:SetRoll(math.Rand(-1, 1))
                particle:SetColor(math.Clamp(cInt - cAdd, 0, 255), math.Clamp(cInt - cAdd, 0, 255), math.Clamp(cInt - cAdd * 0.5, 0, 255))
                particle:SetGravity(Vector(0, 0, 100) + Vel * 0.5)
                particle:SetCollide(false)
            end

            if SuperCharged and TurboCharged and Size > 0.4 then
                for i = 0, 12 do
                    local Pos2 = Pos + Dir * i * 0.7 * math.random(1, 2) * 0.5
                    local particle1 = emitter:Add("effects/muzzleflash2", Pos2)

                    if particle1 then
                        particle1:SetVelocity(Vel + Dir * (5 + Vel:Length() / 20))
                        particle1:SetDieTime(0.05)
                        particle1:SetStartAlpha(255 * Size)
                        particle1:SetStartSize(math.max(math.random(4, 12) - i * 0.5, 0.1) * Size)
                        particle1:SetEndSize(0)
                        particle1:SetRoll(math.Rand(-1, 1))
                        particle1:SetColor(255, 255, 255)
                        particle1:SetCollide(false)
                    end
                end
            end

            emitter:Finish()
        end
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end