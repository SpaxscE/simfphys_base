AddCSLuaFile()
ENT.Type = "anim"
ENT.Spawnable = false
ENT.AdminSpawnable = false

if CLIENT then
    local Mat = CreateMaterial("simfphysdamage", "VertexLitGeneric", {
        ["$basetexture"] = "models/player/player_chrome1"
    })

    function ENT:Draw()
        self:DrawModel()
        render.ModelMaterialOverride(Mat)
        render.SetBlend(0.8)
        self:DrawModel()
        render.ModelMaterialOverride()
        render.SetBlend(1)
    end

    net.Receive("simfphys_explosion_fx", function(length)
        local self = net.ReadEntity()

        if IsValid(self) then
            local effectdata = EffectData()
            effectdata:SetOrigin(self:GetPos())
            util.Effect("simfphys_explosion", effectdata)
        end
    end)
end

if SERVER then
    util.AddNetworkString("simfphys_explosion_fx")

    function ENT:Initialize()
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        if not IsValid(self:GetPhysicsObject()) then
            self.RemoveTimer = 0
            self:Remove()

            return
        end

        self:GetPhysicsObject():EnableMotion(true)
        self:GetPhysicsObject():Wake()
        self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
        self:SetRenderMode(RENDERMODE_TRANSALPHA)

        timer.Simple(0.05, function()
            if not IsValid(self) then return end

            if self.MakeSound == true then
                net.Start("simfphys_explosion_fx")
                net.WriteEntity(self)
                net.Broadcast()
                util.ScreenShake(self:GetPos(), 50, 50, 1.5, 700)
                util.BlastDamage(self, Entity(0), self:GetPos(), 300, 200)
                local Light = ents.Create("light_dynamic")
                Light:SetPos(self:GetPos() + Vector(0, 0, 10))
                local Lightpos = Light:GetPos() + Vector(0, 0, 10)
                Light:SetPos(Lightpos)
                Light:SetKeyValue("_light", "220 40 0 255")
                Light:SetKeyValue("style", 1)
                Light:SetKeyValue("distance", 255)
                Light:SetKeyValue("brightness", 2)
                Light:SetParent(self)
                Light:Spawn()
                Light:Fire("TurnOn", "", "0")

                timer.Simple(0.7, function()
                    if not IsValid(self) then return end
                    self.particleeffect = ents.Create("info_particle_system")
                    self.particleeffect:SetKeyValue("effect_name", "fire_large_01")
                    self.particleeffect:SetKeyValue("start_active", 1)
                    self.particleeffect:SetOwner(self)
                    self.particleeffect:SetPos(self:LocalToWorld(self:GetPhysicsObject():GetMassCenter() + Vector(0, 0, 15)))
                    self.particleeffect:SetAngles(self:GetAngles())
                    self.particleeffect:Spawn()
                    self.particleeffect:Activate()
                    self.particleeffect:SetParent(self)
                    self.FireSound = CreateSound(self, "ambient/fire/firebig.wav")
                    self.FireSound:Play()
                end)

                timer.Simple(120, function()
                    if not IsValid(self) then return end

                    if IsValid(Light) then
                        Light:Remove()
                    end

                    if IsValid(self.particleeffect) then
                        self.particleeffect:Remove()
                    end

                    if self.FireSound then
                        self.FireSound:Stop()
                    end
                end)
            else
                self.particleeffect = ents.Create("info_particle_system")
                self.particleeffect:SetKeyValue("effect_name", "fire_small_03")
                self.particleeffect:SetKeyValue("start_active", 1)
                self.particleeffect:SetOwner(self)
                self.particleeffect:SetPos(self:LocalToWorld(self:GetPhysicsObject():GetMassCenter()))
                self.particleeffect:SetAngles(self:GetAngles())
                self.particleeffect:Spawn()
                self.particleeffect:Activate()
                self.particleeffect:SetParent(self)
                self.particleeffect:Fire("Stop", "", math.random(0.5, 3))
            end
        end)

        self.RemoveDis = GetConVar("sv_simfphys_gib_lifetime"):GetFloat()
        self.RemoveTimer = CurTime() + self.RemoveDis
    end

    function ENT:Think()
        if self.RemoveTimer < CurTime() and self.RemoveDis > 0 then
            self:Remove()
        end

        self:NextThink(CurTime() + 0.2)

        return true
    end

    function ENT:OnRemove()
        if self.FireSound then
            self.FireSound:Stop()
        end
    end

    function ENT:OnTakeDamage(dmginfo)
        self:TakePhysicsDamage(dmginfo)
    end

    function ENT:PhysicsCollide(data, physobj)
    end
end