TOOL.Category = "simfphys"
TOOL.Name = "#Sound Editor - Engine"
TOOL.Command = nil
TOOL.ConfigName = ""
TOOL.ClientConVar["Idle"] = "simulated_vehicles/misc/e49_idle.wav"
TOOL.ClientConVar["IdlePitch"] = 1
TOOL.ClientConVar["Mid"] = "simulated_vehicles/misc/gto_onlow.wav"
TOOL.ClientConVar["MidPitch"] = 1
TOOL.ClientConVar["MidVolume"] = 0.75
TOOL.ClientConVar["MidFadeOutRPMpercent"] = 68
TOOL.ClientConVar["MidFadeOutRate"] = 0.4
TOOL.ClientConVar["High"] = "simulated_vehicles/misc/nv2_onlow_ex.wav"
TOOL.ClientConVar["HighPitch"] = 1
TOOL.ClientConVar["HighVolume"] = 1
TOOL.ClientConVar["HighFadeInRPMpercent"] = 26.6
TOOL.ClientConVar["HighFadeInRate"] = 0.266
TOOL.ClientConVar["Throttle"] = "simulated_vehicles/valve_noise.wav"
TOOL.ClientConVar["ThrottlePitch"] = 0.65
TOOL.ClientConVar["ThrottleVolume"] = 1
TOOL.ClientConVar["Type"] = "0"
TOOL.ClientConVar["ShiftDown"] = ""
TOOL.ClientConVar["ShiftUp"] = ""
TOOL.ClientConVar["RevDown"] = ""

if CLIENT then
    language.Add("tool.simfphyssoundeditor.name", "Engine Sound Editor")
    language.Add("tool.simfphyssoundeditor.desc", "A tool used to edit engine sounds on simfphys vehicles")
    language.Add("tool.simfphyssoundeditor.0", "Left click apply settings. Right click copy settings. Reload to reset")
    language.Add("tool.simfphyssoundeditor.1", "Left click apply settings. Right click copy settings. Reload to reset")

    presets.Add("simfphys_sound", "Jalopy", {
        simfphyssoundeditor_High = "simulated_vehicles/jalopy/jalopy_high.wav",
        simfphyssoundeditor_HighFadeInRate = "0.40",
        simfphyssoundeditor_HighFadeInRPMpercent = "55.00",
        simfphyssoundeditor_HighPitch = "0.75",
        simfphyssoundeditor_HighVolume = "0.90",
        simfphyssoundeditor_Idle = "simulated_vehicles/jalopy/jalopy_idle.wav",
        simfphyssoundeditor_IdlePitch = "0.95",
        simfphyssoundeditor_Mid = "simulated_vehicles/jalopy/jalopy_mid.wav",
        simfphyssoundeditor_MidFadeOutRate = "0.25",
        simfphyssoundeditor_MidFadeOutRPMpercent = "55.00",
        simfphyssoundeditor_MidPitch = "1.00",
        simfphyssoundeditor_MidVolume = "1.00",
        simfphyssoundeditor_ThrottlePitch = "0.00",
        simfphyssoundeditor_ThrottleVolume = "0.00",
        simfphyssoundeditor_Type = "0",
        simfphyssoundeditor_ShiftDown = "",
        simfphyssoundeditor_ShiftUp = "",
        simfphyssoundeditor_RevDown = ""
    })

    presets.Add("simfphys_sound", "APC", {
        simfphyssoundeditor_High = "simulated_vehicles/misc/v8high2.wav",
        simfphyssoundeditor_HighFadeInRate = "0.19",
        simfphyssoundeditor_HighFadeInRPMpercent = "58.00",
        simfphyssoundeditor_HighPitch = "1.00",
        simfphyssoundeditor_HighVolume = "0.75",
        simfphyssoundeditor_Idle = "simulated_vehicles/misc/nanjing_loop.wav",
        simfphyssoundeditor_IdlePitch = "1.00",
        simfphyssoundeditor_Mid = "simulated_vehicles/misc/m50.wav",
        simfphyssoundeditor_MidFadeOutRate = "0.48",
        simfphyssoundeditor_MidFadeOutRPMpercent = "58.00",
        simfphyssoundeditor_MidPitch = "1.00",
        simfphyssoundeditor_MidVolume = "1.00",
        simfphyssoundeditor_ThrottlePitch = "0.00",
        simfphyssoundeditor_ThrottleVolume = "0.00",
        simfphyssoundeditor_Type = "0",
        simfphyssoundeditor_ShiftDown = "",
        simfphyssoundeditor_ShiftUp = "",
        simfphyssoundeditor_RevDown = ""
    })
end

function TOOL:LeftClick(trace)
    local ent = trace.Entity
    if not simfphys.IsCar(ent) then return false end

    if SERVER then
        if self:GetClientInfo("Type") == "1" then
            ent:SetEngineSoundPreset(-1)
            local outputstring = {}
            outputstring[1] = self:GetClientInfo("Type")
            outputstring[2] = self:GetClientInfo("High")
            outputstring[3] = self:GetClientInfo("HighPitch")
            outputstring[4] = self:GetClientInfo("Idle")
            outputstring[5] = self:GetClientInfo("IdlePitch")
            outputstring[6] = self:GetClientInfo("Mid")
            outputstring[7] = self:GetClientInfo("MidPitch")
            outputstring[8] = self:GetClientInfo("RevDown")
            outputstring[9] = self:GetClientInfo("ShiftDown")
            outputstring[10] = self:GetClientInfo("ShiftUp")
            ent:SetSoundoverride(string.Implode(",", outputstring))
        else
            local outputstring = {}
            outputstring[1] = self:GetClientInfo("Idle")
            outputstring[2] = self:GetClientInfo("IdlePitch")
            outputstring[3] = self:GetClientInfo("Mid")
            outputstring[4] = self:GetClientInfo("MidPitch")
            outputstring[5] = self:GetClientInfo("MidVolume")
            outputstring[6] = self:GetClientInfo("MidFadeOutRPMpercent")
            outputstring[7] = self:GetClientInfo("MidFadeOutRate")
            outputstring[8] = self:GetClientInfo("High")
            outputstring[9] = self:GetClientInfo("HighPitch")
            outputstring[10] = self:GetClientInfo("HighVolume")
            outputstring[11] = self:GetClientInfo("HighFadeInRPMpercent")
            outputstring[12] = self:GetClientInfo("HighFadeInRate")
            outputstring[13] = self:GetClientInfo("Throttle")
            outputstring[14] = self:GetClientInfo("ThrottlePitch")
            outputstring[15] = self:GetClientInfo("ThrottleVolume")
            ent:SetEngineSoundPreset(0)
            ent:SetSoundoverride(string.Implode(",", outputstring))
        end
    end

    return true
end

function TOOL:RightClick(trace)
    local ent = trace.Entity
    local ply = self:GetOwner()
    if not simfphys.IsCar(ent) then return false end

    if SERVER then
        local SoundType = ent:GetEngineSoundPreset()
        local Sounds = {}
        local vehiclelist = list.Get("simfphys_vehicles")[ent:GetSpawn_List()]

        if SoundType == -1 then
            Sounds.Type = 1
            Sounds.Idle = vehiclelist.Members.snd_idle or ""
            Sounds.Low = vehiclelist.Members.snd_low or ""
            Sounds.High = vehiclelist.Members.snd_mid or ""
            Sounds.RevDown = vehiclelist.Members.snd_low_revdown or Sounds.Low
            Sounds.ShiftUp = vehiclelist.Members.snd_mid_gearup or Sounds.High
            Sounds.ShiftDown = vehiclelist.Members.snd_mid_geardown or Sounds.ShiftUp
            Sounds.Pitch_Low = vehiclelist.Members.snd_low_pitch or 1
            Sounds.Pitch_High = vehiclelist.Members.snd_mid_pitch or 1
            Sounds.Pitch_All = vehiclelist.Members.snd_pitch or 1
        elseif SoundType == 0 then
            Sounds.Type = 0
            local soundoverride = ent:GetSoundoverride()
            local data = string.Explode(",", soundoverride)

            if soundoverride ~= "" then
                Sounds.Idle = data[1]
                Sounds.Pitch_All = data[2]
                Sounds.Low = data[3]
                Sounds.Pitch_Low = data[4]
                Sounds.MidVolume = data[5]
                Sounds.MidFadeOutPercent = data[6]
                Sounds.MidFadeOutRate = data[7]
                Sounds.High = data[8]
                Sounds.Pitch_High = data[9]
                Sounds.HighVolume = data[10]
                Sounds.HighFadeInPercent = data[11]
                Sounds.HighFadeInRate = data[12]
                Sounds.ThrottleSound = data[13]
                Sounds.ThrottlePitch = data[14]
                Sounds.ThrottleVolume = data[15]
            else
                Sounds.Idle = vehiclelist and vehiclelist.Members.Sound_Idle or "simulated_vehicles/misc/e49_idle.wav"
                Sounds.Pitch_All = vehiclelist and vehiclelist.Members.Sound_IdlePitch or 1
                Sounds.Low = vehiclelist and vehiclelist.Members.Sound_Mid or "simulated_vehicles/misc/gto_onlow.wav"
                Sounds.Pitch_Low = vehiclelist and vehiclelist.Members.Sound_MidPitch or 1
                Sounds.MidVolume = vehiclelist and vehiclelist.Members.Sound_MidVolume or 0.75
                Sounds.MidFadeOutPercent = vehiclelist and vehiclelist.Members.Sound_MidFadeOutRPMpercent or 68
                Sounds.MidFadeOutRate = vehiclelist and vehiclelist.Members.Sound_MidFadeOutRate or 0.4
                Sounds.High = vehiclelist and vehiclelist.Members.Sound_High or "simulated_vehicles/misc/nv2_onlow_ex.wav"
                Sounds.Pitch_High = vehiclelist and vehiclelist.Members.Sound_HighPitch or 1
                Sounds.HighVolume = vehiclelist and vehiclelist.Members.Sound_HighVolume or 1
                Sounds.HighFadeInPercent = vehiclelist and vehiclelist.Members.Sound_HighFadeInRPMpercent or 26.6
                Sounds.HighFadeInRate = vehiclelist and vehiclelist.Members.Sound_HighFadeInRate or 0.266
                Sounds.ThrottleSound = vehiclelist and vehiclelist.Members.Sound_Throttle or "simulated_vehicles/valve_noise.wav"
                Sounds.ThrottlePitch = vehiclelist and vehiclelist.Members.Sound_ThrottlePitch or 0.65
                Sounds.ThrottleVolume = vehiclelist and vehiclelist.Members.Sound_ThrottleVolume or 1
            end
        else
            local demSounds = simfphys.SoundPresets[SoundType]
            Sounds.Type = 1
            Sounds.Idle = demSounds[1]
            Sounds.Low = demSounds[2]
            Sounds.High = demSounds[3]
            Sounds.RevDown = demSounds[4]
            Sounds.ShiftUp = demSounds[5]
            Sounds.ShiftDown = demSounds[6]
            Sounds.Pitch_Low = demSounds[7]
            Sounds.Pitch_High = demSounds[8]
            Sounds.Pitch_All = demSounds[9]
        end

        ply:ConCommand("simfphyssoundeditor_High " .. Sounds.High)
        ply:ConCommand("simfphyssoundeditor_HighPitch " .. Sounds.Pitch_High)
        ply:ConCommand("simfphyssoundeditor_Idle " .. Sounds.Idle)
        ply:ConCommand("simfphyssoundeditor_IdlePitch " .. Sounds.Pitch_All)
        ply:ConCommand("simfphyssoundeditor_Mid " .. Sounds.Low)
        ply:ConCommand("simfphyssoundeditor_MidPitch " .. Sounds.Pitch_Low)
        ply:ConCommand("simfphyssoundeditor_Type " .. Sounds.Type)

        if Sounds.Type == 1 then
            ply:ConCommand("simfphyssoundeditor_RevDown " .. Sounds.RevDown)
            ply:ConCommand("simfphyssoundeditor_ShiftDown " .. Sounds.ShiftDown)
            ply:ConCommand("simfphyssoundeditor_ShiftUp	" .. Sounds.ShiftUp)
            ply:ConCommand("simfphyssoundeditor_HighFadeInRate 0.2")
            ply:ConCommand("simfphyssoundeditor_HighFadeInRPMpercent 20")
            ply:ConCommand("simfphyssoundeditor_HighVolume 1")
            ply:ConCommand("simfphyssoundeditor_MidFadeOutRate 0.5")
            ply:ConCommand("simfphyssoundeditor_MidFadeOutRPMpercent 10")
            ply:ConCommand("simfphyssoundeditor_MidVolume 1")
            ply:ConCommand("simfphyssoundeditor_ThrottlePitch 0")
            ply:ConCommand("simfphyssoundeditor_ThrottleVolume 0")
        else
            ply:ConCommand("simfphyssoundeditor_HighFadeInRate " .. Sounds.HighFadeInRate)
            ply:ConCommand("simfphyssoundeditor_HighFadeInRPMpercent " .. Sounds.HighFadeInPercent)
            ply:ConCommand("simfphyssoundeditor_HighVolume " .. Sounds.HighVolume)
            ply:ConCommand("simfphyssoundeditor_MidFadeOutRate " .. Sounds.MidFadeOutRate)
            ply:ConCommand("simfphyssoundeditor_MidFadeOutRPMpercent " .. Sounds.MidFadeOutPercent)
            ply:ConCommand("simfphyssoundeditor_MidVolume " .. Sounds.MidVolume)
            ply:ConCommand("simfphyssoundeditor_Throttle " .. Sounds.ThrottleSound)
            ply:ConCommand("simfphyssoundeditor_ThrottlePitch " .. Sounds.ThrottlePitch)
            ply:ConCommand("simfphyssoundeditor_ThrottleVolume " .. Sounds.ThrottleVolume)
        end
    end

    return true
end

function TOOL:Reload(trace)
    local ent = trace.Entity
    if not simfphys.IsCar(ent) then return false end

    if SERVER then
        local vname = ent:GetSpawn_List()
        local VehicleList = list.Get("simfphys_vehicles")[vname]
        ent:SetEngineSoundPreset(VehicleList.Members.EngineSoundPreset)
        ent:SetSoundoverride("")
    end

    return true
end

local function Slider(parent, name, concommand, ypos, min, max, decimals)
    local Label = vgui.Create("DLabel", parent)
    Label:SetPos(50, ypos)
    Label:SetSize(225, 40)
    Label:SetText(name)
    Label:SetTextColor(Color(0, 0, 0, 255))
    local Slider = vgui.Create("DNumSlider", parent)
    Slider:SetPos(50, ypos)
    Slider:SetSize(225, 40)
    Slider:SetMin(min)
    Slider:SetMax(max)
    Slider:SetDecimals(decimals)
    Slider:SetConVar(concommand)
end

local function TextEntry(parent, name, concommand, ypos)
    local Label = vgui.Create("DLabel", parent)
    Label:SetPos(0, ypos)
    Label:SetSize(275, 40)
    Label:SetText(name)
    Label:SetTextColor(Color(0, 0, 0, 255))
    local TextEntry = vgui.Create("DTextEntry", parent)
    TextEntry:SetPos(0, ypos + 30)
    TextEntry:SetSize(275, 20)
    TextEntry:SetText(GetConVar(concommand):GetString())
    TextEntry:SetUpdateOnType(true)

    TextEntry.OnValueChange = function(self, value)
        RunConsoleCommand(concommand, tostring(value))
    end
end

local refresh = false

cvars.AddChangeCallback("simfphyssoundeditor_Idle", function(convar, oldValue, newValue)
    if oldValue ~= newValue then
        refresh = true
    end
end)

cvars.AddChangeCallback("simfphyssoundeditor_RevDown", function(convar, oldValue, newValue)
    if oldValue ~= newValue then
        refresh = true
    end
end)

cvars.AddChangeCallback("simfphyssoundeditor_ShiftUp", function(convar, oldValue, newValue)
    if oldValue ~= newValue then
        refresh = true
    end
end)

local function BuildMenu(Frame, panel)
    Frame:Clear()
    local checked = GetConVar("simfphyssoundeditor_Type"):GetString() == "1"
    local yy = 0

    if not checked then
        TextEntry(Frame, "Idle Sound:", "simfphyssoundeditor_Idle", yy)
        yy = yy + 50
        Slider(Frame, "Pitch", "simfphyssoundeditor_IdlePitch", yy, 0, 2.55, 2)
        yy = yy + 50
        TextEntry(Frame, "Mid Sound:", "simfphyssoundeditor_Mid", yy)
        yy = yy + 50
        Slider(Frame, "Pitch", "simfphyssoundeditor_MidPitch", yy, 0, 2.55, 3)
        yy = yy + 50
        Slider(Frame, "Volume", "simfphyssoundeditor_MidVolume", yy, 0, 1, 2)
        yy = yy + 50
        Slider(Frame, "Fade out RPM %", "simfphyssoundeditor_MidFadeOutRPMpercent", yy, 0, 100, 0)
        yy = yy + 50
        Slider(Frame, "Fade out rate\n(0 = instant)", "simfphyssoundeditor_MidFadeOutRate", yy, 0, 1, 2)
        yy = yy + 50
        TextEntry(Frame, "High Sound:", "simfphyssoundeditor_High", yy)
        yy = yy + 50
        Slider(Frame, "Pitch", "simfphyssoundeditor_HighPitch", yy, 0, 2.55, 3)
        yy = yy + 50
        Slider(Frame, "Volume", "simfphyssoundeditor_HighVolume", yy, 0, 1, 2)
        yy = yy + 50
        Slider(Frame, "Fade in RPM %", "simfphyssoundeditor_HighFadeInRPMpercent", yy, 0, 100, 0)
        yy = yy + 50
        Slider(Frame, "Fade in rate\n(0 = instant)", "simfphyssoundeditor_HighFadeInRate", yy, 0, 1, 2)
        yy = yy + 50
        TextEntry(Frame, "On Throttle Sound:", "simfphyssoundeditor_Throttle", yy)
        yy = yy + 50
        Slider(Frame, "Pitch", "simfphyssoundeditor_ThrottlePitch", yy, 0, 2.55, 3)
        yy = yy + 50
        Slider(Frame, "Volume", "simfphyssoundeditor_ThrottleVolume", yy, 0, 1, 2)
        yy = yy + 50
    else
        TextEntry(Frame, "Idle:", "simfphyssoundeditor_Idle", yy)
        yy = yy + 100
        TextEntry(Frame, "Gear Up:", "simfphyssoundeditor_ShiftUp", yy)
        yy = yy + 50
        TextEntry(Frame, "Gear Down:", "simfphyssoundeditor_ShiftDown", yy)
        yy = yy + 50
        TextEntry(Frame, "Gear (continue):", "simfphyssoundeditor_High", yy)
        yy = yy + 50
        Slider(Frame, "Pitch (Gear)", "simfphyssoundeditor_HighPitch", yy, 0, 2.55, 3)
        yy = yy + 75
        TextEntry(Frame, "Revdown:", "simfphyssoundeditor_RevDown", yy)
        yy = yy + 50
        TextEntry(Frame, "Revdown (continue):", "simfphyssoundeditor_Mid", yy)
        yy = yy + 50
        Slider(Frame, "Pitch (Revdown)", "simfphyssoundeditor_MidPitch", yy, 0, 2.55, 3)
        yy = yy + 100
        local Label = vgui.Create("DLabel", Frame)
        Label:SetPos(0, yy)
        Label:SetSize(275, 40)
        Label:SetText("Pitch (Master)")
        Label:SetTextColor(Color(0, 0, 0, 255))
        local Slider = vgui.Create("DNumSlider", Frame)
        Slider:SetPos(0, yy)
        Slider:SetSize(275, 40)
        Slider:SetMin(0)
        Slider:SetMax(2.55)
        Slider:SetDecimals(3)
        Slider:SetConVar("simfphyssoundeditor_IdlePitch")
    end
end

local ConVarsDefault = TOOL:BuildConVarList()

function TOOL.BuildCPanel(panel)
    local ply = LocalPlayer()

    panel:AddControl("Header", {
        Text = "#tool.simfphyssoundeditor.name",
        Description = "#tool.simfphyssoundeditor.desc"
    })

    panel:AddControl("ComboBox", {
        MenuButton = 1,
        Folder = "simfphys_sound",
        Options = {
            ["#preset.default"] = ConVarsDefault
        },
        CVars = table.GetKeys(ConVarsDefault)
    })

    local Frame = vgui.Create("DPanel", panel)
    Frame:SetPos(10, 130)
    Frame:SetSize(275, 900)
    Frame.Paint = function(self, w, h) end

    Frame.Think = function(self)
        if refresh then
            refresh = false
            BuildMenu(Frame, panel)
        end
    end

    local Label = vgui.Create("DLabel", panel)
    Label:SetPos(35, 85)
    Label:SetSize(280, 40)
    Label:SetText("Advanced Sound")
    Label:SetTextColor(Color(0, 0, 0, 255))
    local CheckBox = vgui.Create("DCheckBoxLabel", panel)
    CheckBox:SetPos(15, 85)
    CheckBox:SetText("")
    CheckBox:SetConVar("simfphyssoundeditor_Type")
    CheckBox:SetSize(280, 40)

    CheckBox.OnChange = function(self, checked)
        BuildMenu(Frame, panel)
    end
end