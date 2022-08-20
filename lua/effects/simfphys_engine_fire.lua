local Materials = {"particle/smokesprites_0001", "particle/smokesprites_0002", "particle/smokesprites_0003", "particle/smokesprites_0004", "particle/smokesprites_0005", "particle/smokesprites_0006", "particle/smokesprites_0007", "particle/smokesprites_0008", "particle/smokesprites_0009", "particle/smokesprites_0010", "particle/smokesprites_0011", "particle/smokesprites_0012", "particle/smokesprites_0013", "particle/smokesprites_0014", "particle/smokesprites_0015", "particle/smokesprites_0016"}

function EFFECT:Init(data)
    local Pos = data:GetOrigin()
    local Entity = data:GetEntity()
    if not IsValid(Entity) then return end
    local Vel = Entity:GetVelocity() * 0.9
    self:DoFX(Pos, Vel)
end

function EFFECT:DoFX(pos, vel)
    local fpos = pos + VectorRand() * 5
    local Spos = pos + VectorRand() * 5
    local emitter = ParticleEmitter(pos, false)

    if emitter then
        local particle = emitter:Add(Materials[math.Round(math.Rand(1, table.Count(Materials)), 0)], pos)
        local vz = math.min(vel:Length(), 600)

        if particle then
            particle:SetVelocity(VectorRand() * 5 + Vector(0, 0, 40 + vz) + vel * 0.1)
            particle:SetDieTime(1)
            particle:SetAirResistance(vz)
            particle:SetStartAlpha(100)
            particle:SetStartSize(25)
            particle:SetEndSize(math.Rand(60, 80))
            particle:SetRoll(math.Rand(-1, 1) * 100)
            particle:SetColor(40, 40, 40)
            particle:SetGravity(Vector(0, 0, 100))
            particle:SetCollide(false)
        end

        particle = emitter:Add("particles/fire1", fpos)

        if particle then
            particle:SetVelocity(Vector(0, 0, 70) + vel)
            particle:SetDieTime(0.6 - (math.min(vel:Length(), 600) / 600) * 0.4)
            particle:SetAirResistance(0)
            particle:SetStartAlpha(255)
            particle:SetStartSize(math.Rand(10, 14))
            particle:SetEndSize(math.Rand(0, 6))
            particle:SetRoll(math.Rand(-1, 1) * 180)
            particle:SetColor(255, 255, 255)
            particle:SetGravity(Vector(0, 0, 70))
            particle:SetCollide(false)
        end

        for i = 0, 3 do
            particle = emitter:Add("particles/flamelet" .. math.random(1, 5), Spos)

            if particle then
                particle:SetVelocity(Vector(0, 0, 40) + vel)
                particle:SetDieTime(0.45 - (math.min(vel:Length(), 600) / 600) * 0.25)
                particle:SetAirResistance(0)
                particle:SetStartAlpha(255)
                particle:SetStartSize(math.Rand(10, 14))
                particle:SetEndSize(math.Rand(0, 6))
                particle:SetRoll(math.Rand(-1, 1) * 180)
                particle:SetColor(255, 255, 255)
                particle:SetGravity(Vector(0, 0, 40))
                particle:SetCollide(false)
            end
        end

        emitter:Finish()
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end