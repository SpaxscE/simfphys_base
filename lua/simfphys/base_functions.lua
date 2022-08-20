CreateConVar("sv_simfphys_devmode", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "1 = enabled, 0 = disabled   (requires a restart)")

CreateConVar("sv_simfphys_enabledamage", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "1 = enabled, 0 = disabled")

CreateConVar("sv_simfphys_gib_lifetime", "30", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "How many seconds before removing the gibs (0 = never remove)")

CreateConVar("sv_simfphys_playerdamage", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "should players take damage from collisions in vehicles?")

CreateConVar("sv_simfphys_damagemultiplicator", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "vehicle damage multiplicator")

CreateConVar("sv_simfphys_fuel", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "enable fuel? 1 = enabled, 0 = disabled")

CreateConVar("sv_simfphys_fuelscale", "0.1", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "fuel tank size multiplier. 1 = Realistic fuel tank size (about 2-3 hours of fullthrottle driving, Lol, have fun)")

CreateConVar("sv_simfphys_teampassenger", "0", {FCVAR_REPLICATED, FCVAR_ARCHIVE}, "allow players of different teams to enter the same vehicle?, 0 = allow everyone, 1 = team only")

simfphys = istable(simfphys) and simfphys or {}
simfphys.DamageEnabled = false
simfphys.DamageMul = 1
simfphys.pDamageEnabled = false
simfphys.Fuel = true
simfphys.FuelMul = 0.1
simfphys.VERSION = 1.2

simfphys.pSwitchKeys = {
    [KEY_1] = 1,
    [KEY_2] = 2,
    [KEY_3] = 3,
    [KEY_4] = 4,
    [KEY_5] = 5,
    [KEY_6] = 6,
    [KEY_7] = 7,
    [KEY_8] = 8,
    [KEY_9] = 9,
    [KEY_0] = 10
}

simfphys.pSwitchKeysInv = {
    [1] = KEY_1,
    [2] = KEY_2,
    [3] = KEY_3,
    [4] = KEY_4,
    [5] = KEY_5,
    [6] = KEY_6,
    [7] = KEY_7,
    [8] = KEY_8,
    [9] = KEY_9,
    [10] = KEY_0
}

FUELTYPE_NONE = 0
FUELTYPE_PETROL = 1
FUELTYPE_DIESEL = 2
FUELTYPE_ELECTRIC = 3
game.AddParticles("particles/vehicle.pcf")
game.AddParticles("particles/fire_01.pcf")
PrecacheParticleSystem("fire_large_01")
PrecacheParticleSystem("WheelDust")
PrecacheParticleSystem("smoke_gib_01")
PrecacheParticleSystem("burning_engine_01")

cvars.AddChangeCallback("sv_simfphys_enabledamage", function(convar, oldValue, newValue)
    simfphys.DamageEnabled = (tonumber(newValue) ~= 0)
end)

cvars.AddChangeCallback("sv_simfphys_damagemultiplicator", function(convar, oldValue, newValue)
    simfphys.DamageMul = tonumber(newValue)
end)

cvars.AddChangeCallback("sv_simfphys_playerdamage", function(convar, oldValue, newValue)
    simfphys.pDamageEnabled = (tonumber(newValue) ~= 0)
end)

cvars.AddChangeCallback("sv_simfphys_fuel", function(convar, oldValue, newValue)
    simfphys.Fuel = (tonumber(newValue) ~= 0)
end)

cvars.AddChangeCallback("sv_simfphys_fuelscale", function(convar, oldValue, newValue)
    simfphys.FuelMul = tonumber(newValue)
end)

simfphys.DamageEnabled = GetConVar("sv_simfphys_enabledamage"):GetBool()
simfphys.DamageMul = GetConVar("sv_simfphys_damagemultiplicator"):GetFloat()
simfphys.pDamageEnabled = GetConVar("sv_simfphys_playerdamage"):GetBool()
simfphys.Fuel = GetConVar("sv_simfphys_fuel"):GetBool()
simfphys.FuelMul = GetConVar("sv_simfphys_fuelscale"):GetFloat()

simfphys.ice = CreateConVar("sv_simfphys_traction_ice", "0.35", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.gmod_ice = CreateConVar("sv_simfphys_traction_gmod_ice", "0.1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.snow = CreateConVar("sv_simfphys_traction_snow", "0.7", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.slipperyslime = CreateConVar("sv_simfphys_traction_slipperyslime", "0.2", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.grass = CreateConVar("sv_simfphys_traction_grass", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.sand = CreateConVar("sv_simfphys_traction_sand", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.dirt = CreateConVar("sv_simfphys_traction_dirt", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.concrete = CreateConVar("sv_simfphys_traction_concrete", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.metal = CreateConVar("sv_simfphys_traction_metal", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.glass = CreateConVar("sv_simfphys_traction_glass", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.gravel = CreateConVar("sv_simfphys_traction_gravel", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.rock = CreateConVar("sv_simfphys_traction_rock", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

simfphys.wood = CreateConVar("sv_simfphys_traction_wood", "1", {FCVAR_REPLICATED, FCVAR_ARCHIVE})

function simfphys.IsCar(ent)
    if not IsValid(ent) then return false end
    local IsVehicle = ent:GetClass():lower() == "gmod_sent_vehicle_fphysics_base"

    return IsVehicle
end

local meta = FindMetaTable("Player")

function meta:IsDrivingSimfphys()
    local Car = self:GetSimfphys()
    local Pod = self:GetVehicle()
    if not IsValid(Pod) or not IsValid(Car) then return false end
    if not Car.GetDriverSeat or not isfunction(Car.GetDriverSeat) then return false end

    return Pod == Car:GetDriverSeat()
end

function meta:GetSimfphys()
    if not self:InVehicle() then return NULL end
    local Pod = self:GetVehicle()
    if not IsValid(Pod) then return NULL end

    if Pod.SPHYSchecked == true then
        return Pod.SPHYSBaseEnt
    elseif Pod.SPHYSchecked == nil then
        local Parent = Pod:GetParent()

        if not IsValid(Parent) then
            Pod.SPHYSchecked = false

            return NULL
        end

        if not simfphys.IsCar(Parent) then
            Pod.SPHYSchecked = false

            return NULL
        end

        Pod.SPHYSchecked = true
        Pod.SPHYSBaseEnt = Parent
        Pod.vehiclebase = Parent -- compatibility for old addons

        return Parent
    else
        return NULL
    end
end

if SERVER then
    util.AddNetworkString("simfphys_settings")
    util.AddNetworkString("simfphys_turnsignal")
    util.AddNetworkString("simfphys_spritedamage")
    util.AddNetworkString("simfphys_lightsfixall")
    util.AddNetworkString("simfphys_backfire")
    util.AddNetworkString("simfphys_plyrequestinfo")

    net.Receive("simfphys_plyrequestinfo", function(length, ply)
        if not IsValid(ply) then return end
        ply.simeditor_nextrequest = isnumber(ply.simeditor_nextrequest) and ply.simeditor_nextrequest or 0
        if ply.simeditor_nextrequest > CurTime() then return end
        ply.simeditor_nextrequest = CurTime() + 0.5
        local ent = ply:GetEyeTrace().Entity
        if not simfphys.IsCar(ent) then return end
        local ent = net.ReadEntity()
        local data = simfphys.BuildVehicleInfo(ent)
        if not data then return end
        net.Start("simfphys_plyrequestinfo")
        net.WriteEntity(ent)
        net.WriteFloat(data["torque"])
        net.WriteFloat(data["horsepower"])
        net.WriteFloat(data["maxspeed"])
        net.WriteFloat(data["weight"])
        net.Send(ply)
    end)

    net.Receive("simfphys_turnsignal", function(length, ply)
        if not ply:IsDrivingSimfphys() then return end
        local ent = net.ReadEntity()
        local mode = net.ReadInt(32)
        if not IsValid(ent) or ply:GetSimfphys() ~= ent then return end
        ent:SetTSInternal(mode)
        net.Start("simfphys_turnsignal")
        net.WriteEntity(ent)
        net.WriteInt(mode, 32)
        net.Broadcast()
    end)

    net.Receive("simfphys_settings", function(length, ply)
        if not IsValid(ply) or not ply:IsSuperAdmin() then return end
        local dmgEnabled = tostring(net.ReadBool() and 1 or 0)
        local giblifetime = tostring(net.ReadFloat())
        local dmgMul = tostring(net.ReadFloat())
        local pdmgEnabled = tostring(net.ReadBool() and 1 or 0)
        local fuel = tostring(net.ReadBool() and 1 or 0)
        local fuelscale = tostring(net.ReadFloat())
        local newtraction = net.ReadTable()
        local teamonly = tostring(net.ReadBool() and 1 or 0)
        RunConsoleCommand("sv_simfphys_enabledamage", dmgEnabled)
        RunConsoleCommand("sv_simfphys_gib_lifetime", giblifetime)
        RunConsoleCommand("sv_simfphys_damagemultiplicator", dmgMul)
        RunConsoleCommand("sv_simfphys_playerdamage", pdmgEnabled)
        RunConsoleCommand("sv_simfphys_fuel", fuel)
        RunConsoleCommand("sv_simfphys_fuelscale", fuelscale)
        RunConsoleCommand("sv_simfphys_teampassenger", teamonly)

        for k, v in pairs(newtraction) do
            RunConsoleCommand("sv_simfphys_traction_" .. k, v)
        end

        simfphys.UpdateFrictionData()
    end)

    function simfphys.BuildVehicleInfo(ent)
        if not simfphys.IsCar(ent) then return false end
        local WheelRad = ent.RearWheelRadius

        if ent.FrontWheelPowered and ent.RearWheelRadius then
            WheelRad = math.max(ent.FrontWheelRadius, ent.RearWheelRadius)
        elseif ent.FrontWheelPowered then
            WheelRad = ent.FrontWheelRadius
        end

        local Mass = 0

        for _, Entity in pairs(constraint.GetAllConstrainedEntities(ent)) do
            local EPOBJ = Entity:GetPhysicsObject()

            if IsValid(EPOBJ) then
                Mass = Mass + EPOBJ:GetMass()
            end
        end

        local data = {}
        data["torque"] = ent:GetMaxTorque() * (WheelRad / 10) * ent:GetEfficiency() * (1 + (ent:GetTurboCharged() and 0.3 or 0) + (ent:GetSuperCharged() and 0.48 or 0))
        data["horsepower"] = (data["torque"] * ent:GetLimitRPM() / 9548.8) * 1.34
        data["maxspeed"] = ((ent:GetLimitRPM() * ent.Gears[table.Count(ent.Gears)] * ent:GetDifferentialGear()) * 3.14 * WheelRad * 2) / 52
        data["weight"] = Mass

        return data
    end

    function simfphys.SpawnVehicleSimple(spawnname, pos, ang)
        if not isstring(spawnname) then
            print("invalid spawnname")

            return NULL
        end

        if not isvector(pos) then
            print("invalid spawn position")

            return NULL
        end

        if not isangle(ang) then
            print("invalid spawn angle")

            return NULL
        end

        local vehicle = list.Get("simfphys_vehicles")[spawnname]

        if not vehicle then
            print("vehicle \"" .. spawnname .. "\" does not exist!")

            return NULL
        end

        local Ent = simfphys.SpawnVehicle(nil, pos, ang, vehicle.Model, vehicle.Class, spawnname, vehicle, true)

        return Ent
    end

    function simfphys.SpawnVehicle(Player, Pos, Ang, Model, Class, VName, VTable, bNoOwner)
        if not bNoOwner then
            if not gamemode.Call("PlayerSpawnVehicle", Player, Model, VName, VTable) then return end
        end

        if not file.Exists(Model, "GAME") then
            Player:PrintMessage(HUD_PRINTTALK, "ERROR: \"" .. Model .. "\" does not exist! (Class: " .. VName .. ")")

            return
        end

        local Ent = ents.Create("gmod_sent_vehicle_fphysics_base")
        if not Ent then return NULL end
        Ent:SetModel(Model)
        Ent:SetAngles(Ang)
        Ent:SetPos(Pos)
        Ent:Spawn()
        Ent:Activate()
        Ent.VehicleName = VName
        Ent.VehicleTable = VTable
        Ent.EntityOwner = Player
        Ent:SetSpawn_List(VName)

        if VTable.Members then
            table.Merge(Ent, VTable.Members)

            if Ent.ModelInfo then
                if Ent.ModelInfo.Bodygroups then
                    for i = 1, table.Count(Ent.ModelInfo.Bodygroups) do
                        Ent:SetBodygroup(i, Ent.ModelInfo.Bodygroups[i])
                    end
                end

                if Ent.ModelInfo.Skin then
                    Ent:SetSkin(Ent.ModelInfo.Skin)
                end

                if Ent.ModelInfo.Color then
                    Ent:SetColor(Ent.ModelInfo.Color)
                    local Color = Ent.ModelInfo.Color
                    local dot = Color.r * Color.g * Color.b * Color.a
                    Ent.OldColor = dot

                    local data = {
                        Color = Color,
                        RenderMode = 0,
                        RenderFX = 0
                    }

                    duplicator.StoreEntityModifier(Ent, "colour", data)
                end
            end

            Ent:SetTireSmokeColor(Vector(180, 180, 180) / 255)
            Ent.Turbocharged = Ent.Turbocharged or false
            Ent.Supercharged = Ent.Supercharged or false
            Ent:SetEngineSoundPreset(Ent.EngineSoundPreset)
            Ent:SetMaxTorque(Ent.PeakTorque)
            Ent:SetDifferentialGear(Ent.DifferentialGear)
            Ent:SetSteerSpeed(Ent.TurnSpeed)
            Ent:SetFastSteerConeFadeSpeed(Ent.SteeringFadeFastSpeed)
            Ent:SetFastSteerAngle(Ent.FastSteeringAngle)
            Ent:SetEfficiency(Ent.Efficiency)
            Ent:SetMaxTraction(Ent.MaxGrip)
            Ent:SetTractionBias(Ent.GripOffset / Ent.MaxGrip)
            Ent:SetPowerDistribution(Ent.PowerBias)
            Ent:SetBackFire(Ent.Backfire or false)
            Ent:SetDoNotStall(Ent.DoNotStall or false)
            Ent:SetIdleRPM(Ent.IdleRPM)
            Ent:SetLimitRPM(Ent.LimitRPM)
            Ent:SetRevlimiter(Ent.Revlimiter or false)
            Ent:SetPowerBandEnd(Ent.PowerbandEnd)
            Ent:SetPowerBandStart(Ent.PowerbandStart)
            Ent:SetTurboCharged(Ent.Turbocharged)
            Ent:SetSuperCharged(Ent.Supercharged)
            Ent:SetBrakePower(Ent.BrakePower)
            Ent:SetLights_List(Ent.LightsTable or "no_lights")
            Ent:SetBulletProofTires(Ent.BulletProofTires or false)
            Ent:SetBackfireSound(Ent.snd_backfire or "")

            if not simfphys.WeaponSystemRegister then
                if simfphys.ManagedVehicles then
                    print("[SIMFPHYS ARMED] IS OUT OF DATE")
                end
            else
                timer.Simple(0.2, function()
                    simfphys.WeaponSystemRegister(Ent)
                end)

                if (simfphys.armedAutoRegister and not simfphys.armedAutoRegister()) or simfphys.RegisterEquipment then
                    print("[SIMFPHYS ARMED]: ONE OF YOUR ADDITIONAL SIMFPHYS-ARMED PACKS IS CAUSING CONFLICTS!!!")
                    print("[SIMFPHYS ARMED]: PRECAUTIONARY RESTORING FUNCTION:")
                    print("[SIMFPHYS ARMED]: simfphys.FireHitScan")
                    print("[SIMFPHYS ARMED]: simfphys.FirePhysProjectile")
                    print("[SIMFPHYS ARMED]: simfphys.RegisterCrosshair")
                    print("[SIMFPHYS ARMED]: simfphys.RegisterCamera")
                    print("[SIMFPHYS ARMED]: simfphys.armedAutoRegister")
                    print("[SIMFPHYS ARMED]: REMOVING FUNCTION:")
                    print("[SIMFPHYS ARMED]: simfphys.RegisterEquipment")
                    print("[SIMFPHYS ARMED]: CLEARING OUTDATED ''RegisterEquipment'' HOOK")
                    print("[SIMFPHYS ARMED]: !!!FUNCTIONALITY IS NOT GUARANTEED!!!")

                    simfphys.FireHitScan = function(data)
                        simfphys.FireBullet(data)
                    end

                    simfphys.FirePhysProjectile = function(data)
                        simfphys.FirePhysBullet(data)
                    end

                    simfphys.RegisterCrosshair = function(ent, data)
                        simfphys.xhairRegister(ent, data)
                    end

                    simfphys.RegisterCamera = function(ent, offset_firstperson, offset_thirdperson, bLocalAng, attachment)
                        simfphys.CameraRegister(ent, offset_firstperson, offset_thirdperson, bLocalAng, attachment)
                    end

                    hook.Remove("PlayerSpawnedVehicle", "simfphys_armedvehicles")
                    simfphys.RegisterEquipment = nil

                    simfphys.armedAutoRegister = function(vehicle)
                        simfphys.WeaponSystemRegister(vehicle)

                        return true
                    end
                end
            end

            duplicator.StoreEntityModifier(Ent, "VehicleMemDupe", VTable.Members)
        end

        if IsValid(Player) then
            gamemode.Call("PlayerSpawnedVehicle", Player, Ent)

            return Ent
        end

        return Ent
    end

    function simfphys.SetOwner(ply, entity)
        if not IsValid(entity) or not IsValid(ply) then return end

        if CPPI then
            if not IsEntity(ply) then return end

            if IsValid(ply) then
                entity:CPPISetOwner(ply)
            end
        end
    end
end

if CLIENT then
    net.Receive("simfphys_plyrequestinfo", function(length)
        local ent = net.ReadEntity()
        if not simfphys.IsCar(ent) then return end
        ent.VehicleInfo = {}
        ent.VehicleInfo["torque"] = net.ReadFloat()
        ent.VehicleInfo["horsepower"] = net.ReadFloat()
        ent.VehicleInfo["maxspeed"] = net.ReadFloat()
        ent.VehicleInfo["weight"] = net.ReadFloat()
    end)
end

function simfphys.UpdateFrictionData()
    simfphys.TractionData = {}

    timer.Simple(0.1, function()
        simfphys.TractionData["ice"] = simfphys.ice:GetFloat()
        simfphys.TractionData["gmod_ice"] = simfphys.gmod_ice:GetFloat()
        simfphys.TractionData["snow"] = simfphys.snow:GetFloat()
        simfphys.TractionData["slipperyslime"] = simfphys.slipperyslime:GetFloat()
        simfphys.TractionData["grass"] = simfphys.grass:GetFloat()
        simfphys.TractionData["sand"] = simfphys.sand:GetFloat()
        simfphys.TractionData["dirt"] = simfphys.dirt:GetFloat()
        simfphys.TractionData["concrete"] = simfphys.concrete:GetFloat()
        simfphys.TractionData["metal"] = simfphys.metal:GetFloat()
        simfphys.TractionData["glass"] = simfphys.glass:GetFloat()
        simfphys.TractionData["gravel"] = simfphys.gravel:GetFloat()
        simfphys.TractionData["rock"] = simfphys.rock:GetFloat()
        simfphys.TractionData["wood"] = simfphys.wood:GetFloat()
    end)
end

simfphys.UpdateFrictionData()

simfphys.SoundPresets = {
    {"simulated_vehicles/gta5_dukes/dukes_idle.wav", "simulated_vehicles/gta5_dukes/dukes_low.wav", "simulated_vehicles/gta5_dukes/dukes_mid.wav", "simulated_vehicles/gta5_dukes/dukes_revdown.wav", "simulated_vehicles/gta5_dukes/dukes_second.wav", "simulated_vehicles/gta5_dukes/dukes_second.wav", 0.8, 1, 0.8},
    {"simulated_vehicles/master_chris_charger69/charger_idle.wav", "simulated_vehicles/master_chris_charger69/charger_low.wav", "simulated_vehicles/master_chris_charger69/charger_mid.wav", "simulated_vehicles/master_chris_charger69/charger_revdown.wav", "simulated_vehicles/master_chris_charger69/charger_second.wav", "simulated_vehicles/master_chris_charger69/charger_shiftdown.wav", 0.75, 0.9, 0.95},
    {"simulated_vehicles/shelby/shelby_idle.wav", "simulated_vehicles/shelby/shelby_low.wav", "simulated_vehicles/shelby/shelby_mid.wav", "simulated_vehicles/shelby/shelby_revdown.wav", "simulated_vehicles/shelby/shelby_second.wav", "simulated_vehicles/shelby/shelby_shiftdown.wav", 0.8, 1, 0.85},
    {"simulated_vehicles/jeep/jeep_idle.wav", "simulated_vehicles/jeep/jeep_low.wav", "simulated_vehicles/jeep/jeep_mid.wav", "simulated_vehicles/jeep/jeep_revdown.wav", "simulated_vehicles/jeep/jeep_second.wav", "simulated_vehicles/jeep/jeep_second.wav", 0.9, 1, 1},
    {"simulated_vehicles/v8elite/v8elite_idle.wav", "simulated_vehicles/v8elite/v8elite_low.wav", "simulated_vehicles/v8elite/v8elite_mid.wav", "simulated_vehicles/v8elite/v8elite_revdown.wav", "simulated_vehicles/v8elite/v8elite_second.wav", "simulated_vehicles/v8elite/v8elite_second.wav", 0.8, 1, 1},
    {"simulated_vehicles/4banger/4banger_idle.wav", "simulated_vehicles/4banger/4banger_low.wav", "simulated_vehicles/4banger/4banger_mid.wav", "simulated_vehicles/4banger/4banger_low.wav", "simulated_vehicles/4banger/4banger_second.wav", "simulated_vehicles/4banger/4banger_second.wav", 0.8, 0.9, 1},
    {"simulated_vehicles/jalopy/jalopy_idle.wav", "simulated_vehicles/jalopy/jalopy_low.wav", "simulated_vehicles/jalopy/jalopy_mid.wav", "simulated_vehicles/jalopy/jalopy_revdown.wav", "simulated_vehicles/jalopy/jalopy_second.wav", "simulated_vehicles/jalopy/jalopy_shiftdown.wav", 0.95, 1.1, 0.9},
    {"simulated_vehicles/alfaromeo/alfaromeo_idle.wav", "simulated_vehicles/alfaromeo/alfaromeo_low.wav", "simulated_vehicles/alfaromeo/alfaromeo_mid.wav", "simulated_vehicles/alfaromeo/alfaromeo_low.wav", "simulated_vehicles/alfaromeo/alfaromeo_second.wav", "simulated_vehicles/alfaromeo/alfaromeo_second.wav", 0.65, 0.8, 1},
    {"simulated_vehicles/generic1/generic1_idle.wav", "simulated_vehicles/generic1/generic1_low.wav", "simulated_vehicles/generic1/generic1_mid.wav", "simulated_vehicles/generic1/generic1_revdown.wav", "simulated_vehicles/generic1/generic1_second.wav", "simulated_vehicles/generic1/generic1_second.wav", 0.8, 1.1, 1},
    {"simulated_vehicles/generic2/generic2_idle.wav", "simulated_vehicles/generic2/generic2_low.wav", "simulated_vehicles/generic2/generic2_mid.wav", "simulated_vehicles/generic2/generic2_revdown.wav", "simulated_vehicles/generic2/generic2_second.wav", "simulated_vehicles/generic2/generic2_second.wav", 1, 1.1, 1},
    {"simulated_vehicles/generic3/generic3_idle.wav", "simulated_vehicles/generic3/generic3_low.wav", "simulated_vehicles/generic3/generic3_mid.wav", "simulated_vehicles/generic3/generic3_revdown.wav", "simulated_vehicles/generic3/generic3_second.wav", "simulated_vehicles/generic3/generic3_second.wav", 0.9, 0.9, 1},
    {"simulated_vehicles/generic4/generic4_idle.wav", "simulated_vehicles/generic4/generic4_low.wav", "simulated_vehicles/generic4/generic4_mid.wav", "simulated_vehicles/generic4/generic4_revdown.wav", "simulated_vehicles/generic4/generic4_gear.wav", "simulated_vehicles/generic4/generic4_shiftdown.wav", 1, 1.1, 1},
    {"simulated_vehicles/generic5/generic5_idle.wav", "simulated_vehicles/generic5/generic5_low.wav", "simulated_vehicles/generic5/generic5_mid.wav", "simulated_vehicles/generic5/generic5_revdown.wav", "simulated_vehicles/generic5/generic5_gear.wav", "simulated_vehicles/generic5/generic5_gear.wav", 0.7, 0.7, 1},
    {"simulated_vehicles/gta5_gauntlet/gauntlet_idle.wav", "simulated_vehicles/gta5_gauntlet/gauntlet_low.wav", "simulated_vehicles/gta5_gauntlet/gauntlet_mid.wav", "simulated_vehicles/gta5_gauntlet/gauntlet_revdown.wav", "simulated_vehicles/gta5_gauntlet/gauntlet_gear.wav", "simulated_vehicles/gta5_gauntlet/gauntlet_gear.wav", 0.95, 1.1, 1}
}

local function PlayerPickup(ply, ent)
    if ent:GetClass():lower() == "gmod_sent_vehicle_fphysics_wheel" then return false end
end

hook.Add("GravGunPickupAllowed", "disableWheelPickup", PlayerPickup)