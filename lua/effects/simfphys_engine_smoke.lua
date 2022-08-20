local Materials = {"particle/smokesprites_0001", "particle/smokesprites_0002", "particle/smokesprites_0003", "particle/smokesprites_0004", "particle/smokesprites_0005", "particle/smokesprites_0006", "particle/smokesprites_0007", "particle/smokesprites_0008", "particle/smokesprites_0009", "particle/smokesprites_0010", "particle/smokesprites_0011", "particle/smokesprites_0012", "particle/smokesprites_0013", "particle/smokesprites_0014", "particle/smokesprites_0015", "particle/smokesprites_0016"}

function EFFECT:Init(data)
    local Pos = data:GetOrigin()
    local Ent = data:GetEntity()
    if not IsValid(Ent) then return end
    local Vel = Ent:GetVelocity():Length()
    local emitter = ParticleEmitter(Pos, false)
    local particle = emitter:Add(Materials[math.Round(math.Rand(1, table.Count(Materials)), 0)], Pos)

    if particle then
        particle:SetVelocity(VectorRand() * 100 + Vector(0, 0, math.min(Vel, 600)))
        particle:SetDieTime(1.25)
        particle:SetAirResistance(600)
        particle:SetStartAlpha(math.max(80 - Vel / 100, 0))
        particle:SetStartSize(math.Rand(0, 15))
        particle:SetEndSize(math.Rand(50, 65))
        particle:SetRoll(math.Rand(-1, 1) * 100)
        particle:SetColor(80, 80, 80)
        particle:SetGravity(Vector(0, 0, 500))
        particle:SetCollide(false)
    end

    emitter:Finish()
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end