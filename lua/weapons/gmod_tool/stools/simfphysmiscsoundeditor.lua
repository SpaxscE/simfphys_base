TOOL.Category = "simfphys"
TOOL.Name = "#Sound Editor - Misc"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["TurboBlowOff"] = "simulated_vehicles/turbo_blowoff.ogg"
TOOL.ClientConVar["TurboSpin"] = "simulated_vehicles/turbo_spin.wav"
TOOL.ClientConVar["SuperChargerOn"] = "simulated_vehicles/blower_gearwhine.wav"
TOOL.ClientConVar["SuperChargerOff"] = "simulated_vehicles/blower_spin.wav"
TOOL.ClientConVar["HornSound"] = "simulated_vehicles/horn_1.wav"
TOOL.ClientConVar["BackfireSound"] = ""

if CLIENT then
    language.Add("tool.simfphysmiscsoundeditor.name", "Misc Sound Editor")
    language.Add("tool.simfphysmiscsoundeditor.desc", "A tool used to edit miscellaneous sounds on simfphys vehicles")
    language.Add("tool.simfphysmiscsoundeditor.0", "Left click apply settings. Right click copy settings. Reload to reset")
    language.Add("tool.simfphysmiscsoundeditor.1", "Left click apply settings. Right click copy settings. Reload to reset")

    presets.Add("simfphys_miscsound", "Horn 0 - Out of my way", {
        simfphysmiscsoundeditor_HornSound = "simulated_vehicles/horn_0.wav",
    })

    presets.Add("simfphys_miscsound", "Horn 1", {
        simfphysmiscsoundeditor_HornSound = "simulated_vehicles/horn_1.wav",
    })

    presets.Add("simfphys_miscsound", "Horn 2", {
        simfphysmiscsoundeditor_HornSound = "simulated_vehicles/horn_2.wav",
    })

    presets.Add("simfphys_miscsound", "Horn 3", {
        simfphysmiscsoundeditor_HornSound = "simulated_vehicles/horn_3.wav",
    })

    presets.Add("simfphys_miscsound", "Horn 4", {
        simfphysmiscsoundeditor_HornSound = "simulated_vehicles/horn_4.wav",
    })

    presets.Add("simfphys_miscsound", "Horn 5", {
        simfphysmiscsoundeditor_HornSound = "simulated_vehicles/horn_5.wav",
    })

    presets.Add("simfphys_miscsound", "Horn 6 - Vote Daniels", {
        simfphysmiscsoundeditor_HornSound = "simulated_vehicles/horn_6.wav",
    })

    presets.Add("simfphys_miscsound", "Horn 7", {
        simfphysmiscsoundeditor_HornSound = "simulated_vehicles/horn_7.wav",
    })
end

function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not simfphys.IsCar(ent) then return false end
    ent.snd_blowoff = self:GetClientInfo("TurboBlowOff")
    ent.snd_spool = self:GetClientInfo("TurboSpin")
    ent.snd_bloweroff = self:GetClientInfo("SuperChargerOff")
    ent.snd_bloweron = self:GetClientInfo("SuperChargerOn")
    ent.snd_horn = self:GetClientInfo("HornSound")
    ent:SetBackfireSound(self:GetClientInfo("BackfireSound"))

    return true
end

function TOOL:RightClick(trace)
    local ent = trace.Entity
    local ply = self:GetOwner()
    if not simfphys.IsCar(ent) then return false end

    if SERVER then
        local Sounds = {}
        Sounds.TurboBlowOff = ent.snd_blowoff or "simulated_vehicles/turbo_blowoff.ogg"
        Sounds.TurboSpin = ent.snd_spool or "simulated_vehicles/turbo_spin.wav"
        Sounds.SuperCharger1 = ent.snd_bloweroff or "simulated_vehicles/blower_spin.wav"
        Sounds.SuperCharger2 = ent.snd_bloweron or "simulated_vehicles/blower_gearwhine.wav"
        Sounds.HornSound = ent.snd_horn or "simulated_vehicles/horn_1.wav"
        ply:ConCommand("simfphysmiscsoundeditor_TurboBlowOff " .. Sounds.TurboBlowOff)
        ply:ConCommand("simfphysmiscsoundeditor_TurboSpin " .. Sounds.TurboSpin)
        ply:ConCommand("simfphysmiscsoundeditor_SuperChargerOn " .. Sounds.SuperCharger2)
        ply:ConCommand("simfphysmiscsoundeditor_SuperChargerOff " .. Sounds.SuperCharger1)
        ply:ConCommand("simfphysmiscsoundeditor_HornSound " .. Sounds.HornSound)
        local backfiresound = ent:GetBackfireSound()

        if backfiresound == "" then
            ply:ConCommand("simfphysmiscsoundeditor_BackfireSound simulated_vehicles/sfx/ex_backfire_1.ogg")
        else
            ply:ConCommand("simfphysmiscsoundeditor_BackfireSound " .. backfiresound)
        end
    end

    return true
end

function TOOL:Reload(trace)
    local ent = trace.Entity
    if not simfphys.IsCar(ent) then return false end

    if SERVER then
        local vehiclelist = list.Get("simfphys_vehicles")[ent:GetSpawn_List()]
        ent.snd_blowoff = vehiclelist.Members.snd_blowoff or "simulated_vehicles/turbo_blowoff.ogg"
        ent.snd_spool = vehiclelist.Members.snd_spool or "simulated_vehicles/turbo_spin.wav"
        ent.snd_bloweroff = vehiclelist.Members.snd_bloweroff or "simulated_vehicles/blower_spin.wav"
        ent.snd_bloweron = vehiclelist.Members.snd_bloweron or "simulated_vehicles/blower_gearwhine.wav"
        ent.snd_horn = vehiclelist.Members.snd_horn or "simulated_vehicles/horn_1.wav"
        ent:SetBackfireSound(vehiclelist.Members.snd_backfire or "")
    end

    return true
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(panel)
    panel:AddControl("Header", {
        Text = "#tool.simfphysmiscsoundeditor.name",
        Description = "#tool.simfphysmiscsoundeditor.desc"
    })

    panel:AddControl("ComboBox", {
        MenuButton = 1,
        Folder = "simfphys_miscsound",
        Options = {
            ["#preset.default"] = ConVarsDefault
        },
        CVars = table.GetKeys(ConVarsDefault)
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Textbox", {
        Label = "Turbo blowoff",
        Command = "simfphysmiscsoundeditor_TurboBlowOff"
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Textbox", {
        Label = "Turbo",
        Command = "simfphysmiscsoundeditor_TurboSpin"
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Textbox", {
        Label = "Supercharger 1",
        Command = "simfphysmiscsoundeditor_SuperChargerOn"
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Textbox", {
        Label = "Supercharger 2",
        Command = "simfphysmiscsoundeditor_SuperChargerOff"
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Textbox", {
        Label = "Horn",
        Command = "simfphysmiscsoundeditor_HornSound"
    })

    panel:AddControl("Label", {
        Text = ""
    })

    panel:AddControl("Textbox", {
        Label = "Backfire",
        Command = "simfphysmiscsoundeditor_BackfireSound"
    })
end