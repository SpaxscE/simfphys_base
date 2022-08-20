local Materials = {
    "particle/smokesprites_0001",
    "particle/smokesprites_0002",
    "particle/smokesprites_0003",
    "particle/smokesprites_0004",
    "particle/smokesprites_0005",
    "particle/smokesprites_0006",
    "particle/smokesprites_0007",
    "particle/smokesprites_0008",
    "particle/smokesprites_0009",
    "particle/smokesprites_0010",
    "particle/smokesprites_0011",
    "particle/smokesprites_0012",
    "particle/smokesprites_0013",
    "particle/smokesprites_0014",
    "particle/smokesprites_0015",
    "particle/smokesprites_0016"
}

function EFFECT:Init(data)
    local Pos = data:GetOrigin()
    self:Explosion(Pos)
    local random = math.random(1, 3)

    if random == 1 then
        sound.Play("ambient/explosions/explode_3.wav", Pos, 95, 100, 1)
    elseif random == 2 then
        sound.Play("ambient/explosions/explode_8.wav", Pos, 95, 140, 1)
    else
        sound.Play("ambient/explosions/explode_5.wav", Pos, 95, 100, 1)
    end
end

function EFFECT:Explosion(pos)
    local emitter = ParticleEmitter(pos, false)

    if emitter then
        for i = 0, 60 do
            local particle = emitter:Add(Materials[math.random(1, table.Count(Materials))], pos)

            if particle then
                particle:SetVelocity(VectorRand() * 800)
                particle:SetDieTime(math.Rand(0.8, 1.6))
                particle:SetAirResistance(math.Rand(200, 600))
                particle:SetStartAlpha(255)
                particle:SetStartSize(math.Rand(20, 60))
                particle:SetEndSize(math.Rand(80, 140))
                particle:SetRoll(math.Rand(-1, 1))
                particle:SetColor(40, 40, 40)
                particle:SetGravity(Vector(0, 0, 100))
                particle:SetCollide(false)
            end
        end

        for i = 0, 40 do
            local particle = emitter:Add("sprites/flamelet" .. math.random(1, 5), pos)

            if particle then
                particle:SetVelocity(VectorRand() * 1000)
                particle:SetDieTime(0.14)
                particle:SetStartAlpha(255)
                particle:SetStartSize(10)
                particle:SetEndSize(math.Rand(60, 120))
                particle:SetEndAlpha(100)
                particle:SetRoll(math.Rand(-1, 1))
                particle:SetColor(200, 150, 150)
                particle:SetCollide(false)
            end
        end

        for i = 0, 36 do
            local particle = emitter:Add(Materials[math.Round(math.Rand(1, table.Count(Materials)), 0)], pos)

            if particle then
                local ang = i * 10
                local X = math.cos(math.rad(ang))
                local Y = math.sin(math.rad(ang))
                particle:SetVelocity(Vector(X, Y, 0) * math.Rand(4000, 5000))
                particle:SetDieTime(1)
                particle:SetAirResistance(800)
                particle:SetStartAlpha(200)
                particle:SetStartSize(0)
                particle:SetEndSize(math.Rand(40, 100))
                particle:SetRoll(math.Rand(-1, 1))
                particle:SetColor(40, 40, 40)
                particle:SetGravity(Vector(0, 0, 1000))
                particle:SetCollide(false)
            end
        end

        for i = 0, 60 do
            local particle = emitter:Add("effects/fleck_tile" .. math.random(1, 2), pos)
            local vel = VectorRand() * 300
            vel.z = math.Rand(200, 600)

            if particle then
                particle:SetVelocity(vel)
                particle:SetDieTime(math.Rand(3, 5))
                particle:SetAirResistance(10)
                particle:SetStartAlpha(150)
                particle:SetStartSize(5)
                particle:SetEndSize(5)
                particle:SetRoll(math.Rand(-1, 1))
                particle:SetColor(0, 0, 0)
                particle:SetGravity(Vector(0, 0, -600))
                particle:SetCollide(true)
                particle:SetBounce(0.3)
            end
        end

        emitter:Finish()
    end

    local dlight = DynamicLight(math.random(0, 9999))

    if dlight then
        dlight.pos = pos
        dlight.r = 255
        dlight.g = 180
        dlight.b = 100
        dlight.brightness = 8
        dlight.Decay = 2000
        dlight.Size = 300
        dlight.DieTime = CurTime() + 0.1
    end
end

function EFFECT:Think()
    return false
end

function EFFECT:Render()
end