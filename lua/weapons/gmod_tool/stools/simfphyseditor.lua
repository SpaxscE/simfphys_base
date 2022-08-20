TOOL.Category = "simfphys"
TOOL.Name = "#Vehicle Editor"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["steerspeed"] = 8
TOOL.ClientConVar["fadespeed"] = 535
TOOL.ClientConVar["faststeerangle"] = 0.3
TOOL.ClientConVar["soundpreset"] = 0
TOOL.ClientConVar["idlerpm"] = 800
TOOL.ClientConVar["maxrpm"] = 6200
TOOL.ClientConVar["powerbandstart"] = 2000
TOOL.ClientConVar["powerbandend"] = 6000
TOOL.ClientConVar["maxtorque"] = 280
TOOL.ClientConVar["turbocharged"] = "0"
TOOL.ClientConVar["supercharged"] = "0"
TOOL.ClientConVar["revlimiter"] = "0"
TOOL.ClientConVar["diffgear"] = 0.65
TOOL.ClientConVar["traction"] = 43
TOOL.ClientConVar["tractionbias"] = -0.02
TOOL.ClientConVar["brakepower"] = 45
TOOL.ClientConVar["powerdistribution"] = 1
TOOL.ClientConVar["efficiency"] = 1.25

if CLIENT then
    language.Add("tool.simfphyseditor.name", "simfphys vehicle editor")
    language.Add("tool.simfphyseditor.desc", "A tool used to edit simfphys vehicles")
    language.Add("tool.simfphyseditor.0", "Left click apply settings. Right click copy settings. Reload to reset")
    language.Add("tool.simfphyseditor.1", "Left click apply settings. Right click copy settings. Reload to reset")
    language.Add("tool.simfphyseditor.steerspeed", "Steer Speed")
    language.Add("tool.simfphyseditor.steerspeed.help", "How fast the steering will move to its target angle")
    language.Add("tool.simfphyseditor.fastspeed", "Fast Steercone Fadespeed")
    language.Add("tool.simfphyseditor.fastspeed.help", "At wich speed (gmod units per second) we want to fade from slow steer angle to fast steer angle")
    language.Add("tool.simfphyseditor.faststeerang", "Fast Steer Angle")
    language.Add("tool.simfphyseditor.faststeerang.help", "Steering angle at high speeds.")
    language.Add("tool.simfphyseditor.tractionbias", "Tractionbias")
    language.Add("tool.simfphyseditor.tractionbias.help", "A negative value will get more understeer, a positive value more oversteer. NOTE: this will not affect under/oversteer caused by engine power.")
    language.Add("tool.simfphyseditor.powerdist", "Powerdistribution")
    language.Add("tool.simfphyseditor.powerdist.help", "How much power goes to the front and rear wheels,   1 = rear wheel drive    -1 = front wheel drive     0 = all wheel drive with power distributed equally on front and rear wheels.")
    language.Add("tool.simfphyseditor.efficiency", "Efficiency")
    language.Add("tool.simfphyseditor.efficiency.help", "This defines how good the wheels can put the engine power to the ground. Also may affect max torque and hand brake performance.  Its a cheap way to make your car accelerate faster without having to deal with griploss.")
    language.Add("tool.simfphyseditor.turbo", "Turbocharged")
    language.Add("tool.simfphyseditor.turbo.help", "Enables Turbo sounds and increases torque at high RPM")
    language.Add("tool.simfphyseditor.blower", "Supercharged")
    language.Add("tool.simfphyseditor.blower.help", "Enables Supercharger sounds and increases torque at low to mid RPM")
    language.Add("tool.simfphyseditor.revlimiter", "Revlimiter")
    language.Add("tool.simfphyseditor.revlimiter.help", "Enables bouncy revlimiter. NOTE: This does not work if Limit RPM is less than 2500!")
end

function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not simfphys.IsCar(ent) then return false end
    if CLIENT then return true end
    ent:SetSteerSpeed(math.Clamp(self:GetClientNumber("steerspeed"), 1, 16))
    ent:SetFastSteerConeFadeSpeed(math.Clamp(self:GetClientNumber("fadespeed"), 1, 5000))
    ent:SetFastSteerAngle(math.Clamp(self:GetClientNumber("faststeerangle"), 0, 1))
    ent:SetEngineSoundPreset(math.Clamp(self:GetClientNumber("soundpreset"), -1, 14))
    ent:SetIdleRPM(math.Clamp(self:GetClientNumber("idlerpm"), 1, 25000))
    ent:SetLimitRPM(math.Clamp(self:GetClientNumber("maxrpm"), 4, 25000))
    ent:SetPowerBandStart(math.Clamp(self:GetClientNumber("powerbandstart"), 2, 25000))
    ent:SetPowerBandEnd(math.Clamp(self:GetClientNumber("powerbandend"), 3, 25000))
    ent:SetMaxTorque(math.Clamp(self:GetClientNumber("maxtorque"), 20, 1000))
    ent:SetTurboCharged(self:GetClientInfo("turbocharged") == "1")
    ent:SetSuperCharged(self:GetClientInfo("supercharged") == "1")
    ent:SetRevlimiter(self:GetClientInfo("revlimiter") == "1")
    ent:SetDifferentialGear(math.Clamp(self:GetClientNumber("diffgear"), 0.2, 6))
    ent:SetMaxTraction(math.Clamp(self:GetClientNumber("traction"), 5, 1000))
    ent:SetTractionBias(math.Clamp(self:GetClientNumber("tractionbias"), -0.99, 0.99))
    ent:SetBrakePower(math.Clamp(self:GetClientNumber("brakepower"), 0.1, 500))
    ent:SetPowerDistribution(math.Clamp(self:GetClientNumber("powerdistribution"), -1, 1))
    ent:SetEfficiency(math.Clamp(self:GetClientNumber("efficiency"), 0.2, 4))

    return true
end

function TOOL:RightClick(trace)
    local ent = trace.Entity
    local ply = self:GetOwner()
    if not simfphys.IsCar(ent) then return false end
    if CLIENT then return true end
    ply:ConCommand("simfphyseditor_steerspeed " .. ent:GetSteerSpeed())
    ply:ConCommand("simfphyseditor_fadespeed " .. ent:GetFastSteerConeFadeSpeed())
    ply:ConCommand("simfphyseditor_faststeerangle " .. ent:GetFastSteerAngle())
    ply:ConCommand("simfphyseditor_soundpreset " .. ent:GetEngineSoundPreset())
    ply:ConCommand("simfphyseditor_idlerpm " .. ent:GetIdleRPM())
    ply:ConCommand("simfphyseditor_maxrpm " .. ent:GetLimitRPM())
    ply:ConCommand("simfphyseditor_powerbandstart " .. ent:GetPowerBandStart())
    ply:ConCommand("simfphyseditor_powerbandend " .. ent:GetPowerBandEnd())
    ply:ConCommand("simfphyseditor_maxtorque " .. ent:GetMaxTorque())
    ply:ConCommand("simfphyseditor_turbocharged " .. (ent:GetTurboCharged() and 1 or 0))
    ply:ConCommand("simfphyseditor_supercharged " .. (ent:GetSuperCharged() and 1 or 0))
    ply:ConCommand("simfphyseditor_revlimiter " .. (ent:GetRevlimiter() and 1 or 0))
    ply:ConCommand("simfphyseditor_diffgear " .. ent:GetDifferentialGear())
    ply:ConCommand("simfphyseditor_traction " .. ent:GetMaxTraction())
    ply:ConCommand("simfphyseditor_tractionbias " .. ent:GetTractionBias())
    ply:ConCommand("simfphyseditor_brakepower " .. ent:GetBrakePower())
    ply:ConCommand("simfphyseditor_powerdistribution " .. ent:GetPowerDistribution())
    ply:ConCommand("simfphyseditor_efficiency " .. ent:GetEfficiency())

    return true
end

function TOOL:Think()
    if CLIENT then
        local ply = self:GetOwner()
        if not IsValid(ply) then return end
        ply.simeditor_nextrequest = isnumber(ply.simeditor_nextrequest) and ply.simeditor_nextrequest or 0
        local ent = ply:GetEyeTrace().Entity
        if not simfphys.IsCar(ent) then return end

        if ply.simeditor_nextrequest < CurTime() then
            net.Start("simfphys_plyrequestinfo")
            net.WriteEntity(ent)
            net.SendToServer()
            ply.simeditor_nextrequest = CurTime() + 0.6
        end
    end
end

function TOOL:Reload(trace)
    local ent = trace.Entity
    local ply = self:GetOwner()
    if not simfphys.IsCar(ent) then return false end

    if (SERVER) then
        local vname = ent:GetSpawn_List()
        local VehicleList = list.Get("simfphys_vehicles")[vname]
        ent:SetSteerSpeed(VehicleList.Members.TurnSpeed)
        ent:SetFastSteerConeFadeSpeed(VehicleList.Members.SteeringFadeFastSpeed)
        ent:SetFastSteerAngle(VehicleList.Members.FastSteeringAngle / ent.VehicleData["steerangle"])
        ent:SetEngineSoundPreset(VehicleList.Members.EngineSoundPreset)
        ent:SetIdleRPM(VehicleList.Members.IdleRPM)
        ent:SetLimitRPM(VehicleList.Members.LimitRPM)
        ent:SetPowerBandStart(VehicleList.Members.PowerbandStart)
        ent:SetPowerBandEnd(VehicleList.Members.PowerbandEnd)
        ent:SetMaxTorque(VehicleList.Members.PeakTorque)
        ent:SetTurboCharged(VehicleList.Members.Turbocharged or false)
        ent:SetSuperCharged(VehicleList.Members.Supercharged or false)
        ent:SetRevlimiter(VehicleList.Members.Revlimiter or false)
        ent:SetDifferentialGear(VehicleList.Members.DifferentialGear)
        ent:SetMaxTraction(VehicleList.Members.MaxGrip)
        ent:SetTractionBias(VehicleList.Members.GripOffset / VehicleList.Members.MaxGrip)
        ent:SetBrakePower(VehicleList.Members.BrakePower)
        ent:SetPowerDistribution(VehicleList.Members.PowerBias)
        ent:SetEfficiency(VehicleList.Members.Efficiency)
    end

    return true
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", {
        Text = "#tool.simfphyseditor.name",
        Description = "#tool.simfphyseditor.desc"
    })

    panel:AddControl("ComboBox", {
        MenuButton = 1,
        Folder = "simfphys",
        Options = {
            ["#preset.default"] = ConVarsDefault
        },
        CVars = table.GetKeys(ConVarsDefault)
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Label", {
        Text = "--- Steering ---"
    })

    panel:AddControl("Slider", {
        Label = "#tool.simfphyseditor.steerspeed",
        Type = "Float",
        Min = "1",
        Max = "16",
        Command = "simfphyseditor_steerspeed",
        Help = true
    })

    panel:AddControl("Slider", {
        Label = "#tool.simfphyseditor.fastspeed",
        Type = "Float",
        Min = "1",
        Max = "5000",
        Command = "simfphyseditor_fadespeed",
        Help = true
    })

    panel:AddControl("Slider", {
        Label = "#tool.simfphyseditor.faststeerang",
        Type = "Float",
        Min = "0",
        Max = "1",
        Command = "simfphyseditor_faststeerangle",
        Help = true
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Label", {
        Text = "--- Engine ---"
    })

    panel:AddControl("Slider", {
        Label = "Engine Sound Preset",
        Type = "Int",
        Min = "-1",
        Max = "14",
        Command = "simfphyseditor_soundpreset"
    })

    panel:AddControl("Slider", {
        Label = "Idle RPM",
        Type = "Int",
        Min = "1",
        Max = "25000",
        Command = "simfphyseditor_idlerpm"
    })

    panel:AddControl("Slider", {
        Label = "Limit RPM",
        Type = "Int",
        Min = "4",
        Max = "25000",
        Command = "simfphyseditor_maxrpm"
    })

    panel:AddControl("Slider", {
        Label = "Powerband Start",
        Type = "Int",
        Min = "2",
        Max = "25000",
        Command = "simfphyseditor_powerbandstart"
    })

    panel:AddControl("Slider", {
        Label = "Powerband End",
        Type = "Int",
        Min = "3",
        Max = "25000",
        Command = "simfphyseditor_powerbandend"
    })

    panel:AddControl("Slider", {
        Label = "Max Torque",
        Type = "Float",
        Min = "20",
        Max = "1000",
        Command = "simfphyseditor_maxtorque"
    })

    panel:AddControl("Checkbox", {
        Label = "#tool.simfphyseditor.revlimiter",
        Command = "simfphyseditor_revlimiter",
        Help = true
    })

    panel:AddControl("Checkbox", {
        Label = "#tool.simfphyseditor.turbo",
        Command = "simfphyseditor_turbocharged",
        Help = true
    })

    panel:AddControl("Checkbox", {
        Label = "#tool.simfphyseditor.blower",
        Command = "simfphyseditor_supercharged",
        Help = true
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Label", {
        Text = "--- Transmission ---"
    })

    panel:AddControl("Slider", {
        Label = "DifferentialGear",
        Type = "Float",
        Min = "0.2",
        Max = "6",
        Command = "simfphyseditor_diffgear"
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Label", {
        Text = "--- Wheels ---"
    })

    panel:AddControl("Slider", {
        Label = "Max Traction",
        Type = "Float",
        Min = "5",
        Max = "1000",
        Command = "simfphyseditor_traction"
    })

    panel:AddControl("Slider", {
        Label = "#tool.simfphyseditor.tractionbias",
        Type = "Float",
        Min = "-0.99",
        Max = "0.99",
        Command = "simfphyseditor_tractionbias",
        Help = true
    })

    panel:AddControl("Slider", {
        Label = "Brakepower",
        Type = "Float",
        Min = "0.1",
        Max = "500",
        Command = "simfphyseditor_brakepower"
    })

    panel:AddControl("Slider", {
        Label = "#tool.simfphyseditor.powerdist",
        Type = "Float",
        Min = "-1",
        Max = "1",
        Command = "simfphyseditor_powerdistribution",
        Help = true
    })

    panel:AddControl("Slider", {
        Label = "#tool.simfphyseditor.efficiency",
        Type = "Float",
        Min = "0.2",
        Max = "4",
        Command = "simfphyseditor_efficiency",
        Help = true
    })
end