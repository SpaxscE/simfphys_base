local Materials = {"particle/smokesprites_0001", "particle/smokesprites_0002", "particle/smokesprites_0003", "particle/smokesprites_0004", "particle/smokesprites_0005", "particle/smokesprites_0006", "particle/smokesprites_0007", "particle/smokesprites_0008", "particle/smokesprites_0009", "particle/smokesprites_0010", "particle/smokesprites_0011", "particle/smokesprites_0012", "particle/smokesprites_0013", "particle/smokesprites_0014", "particle/smokesprites_0015", "particle/smokesprites_0016"}

function EFFECT:Init(data)
    local Entity = data:GetEntity()
    local Mul = data:GetMagnitude()
    local Pos = data:GetOrigin()
    local Dir = data:GetNormal()
    local WheelSize = data:GetRadius()
    local Color = data:GetStart()
    local Ran = Vector(math.Rand(-WheelSize, WheelSize), math.Rand(-WheelSize, WheelSize), math.Rand(-WheelSize, WheelSize)) * 0.3
    local OffsetPos = Pos + Ran + Vector(0, 0, WheelSize * 0.2)
    local emitter = ParticleEmitter(Pos, false)

    if emitter then
        if IsValid(Entity) then
            local Vel = Entity:GetVelocity() / 3
            OffsetPos = OffsetPos + Ran * 0.4 + Vector(0, 0, -WheelSize * 0.8)
            local particle = emitter:Add(Materials[math.Round(math.Rand(1, table.Count(Materials)), 0)], OffsetPos)
            Mul = 0.3 + Mul * 0.05
            Color = render.ComputeLighting(Pos, Vector(0, 0, 1))
            Color.x = 55 + (math.Clamp(Color.x, 0, 1)) * 200
            Color.y = 55 + (math.Clamp(Color.y, 0, 1)) * 200
            Color.z = 55 + (math.Clamp(Color.z, 0, 1)) * 200

            if particle then
                particle:SetGravity(Vector(0, 0, 12) + Ran * 0.2)
                particle:SetVelocity(Dir * 10 * (3 - Mul) + Vector(0, 0, 15) + Ran * Mul + Vel)
                particle:SetDieTime(0.5)
                particle:SetStartAlpha(20)
                particle:SetStartSize(WheelSize * 0.7 * Mul)
                particle:SetEndSize(math.Rand(80, 160) * Mul ^ 2)
                particle:SetRoll(math.Rand(-1, 1))
                particle:SetColor(Color.x, Color.y, Color.z)
                particle:SetCollide(false)
            end
        else
            local OffsetPos2 = OffsetPos + Ran * 0.4 + Vector(0, 0, -WheelSize)
            local particle1 = emitter:Add(Materials[math.Round(math.Rand(1, table.Count(Materials)), 0)], OffsetPos)
            local particle2 = emitter:Add(Materials[math.Round(math.Rand(1, table.Count(Materials)), 0)], OffsetPos2)

            if particle1 then
                particle1:SetVelocity(Vector(0, 0, -50))
                particle1:SetDieTime(0.5)
                particle1:SetStartAlpha(255 * Mul ^ 2)
                particle1:SetStartSize(16 * Mul)
                particle1:SetEndSize(32 * Mul)
                particle1:SetRoll(math.Rand(-1, 1))
                particle1:SetColor(Color.x * 0.9, Color.y * 0.9, Color.z * 0.9)
                particle1:SetCollide(true)
            end

            if particle2 then
                particle2:SetGravity(Vector(0, 0, 12) + Ran * 0.2)
                particle2:SetVelocity(Dir * 30 * (3 - Mul) + Vector(0, 0, 15) + Ran * Mul)
                particle2:SetDieTime(math.Rand(2, 4) * Mul)
                particle2:SetStartAlpha(100 * Mul)
                particle2:SetStartSize(WheelSize * 0.7 * Mul)
                particle2:SetEndSize(math.Rand(80, 160) * Mul ^ 2)
                particle2:SetRoll(math.Rand(-1, 1))
                particle2:SetColor(Color.x, Color.y, Color.z)
                particle2:SetCollide(false)
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