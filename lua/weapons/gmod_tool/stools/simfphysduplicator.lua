TOOL.Category = "simfphys"
TOOL.Name = "#Vehicle Duplicator"
TOOL.Command = nil
TOOL.ConfigName = ""

if SERVER then
    util.AddNetworkString("sphys_dupe")
    local recv_interval_start = 0 -- first second of current interval
    local recv_interval_len = 1 -- in seconds, length of interval before resetting recv_interval_(start,count)
    local recv_interval_count = 0 -- current count of messages received in interval
    local recv_max = 500 -- maximum number of messages to receive during one interval
    local recv_stop = 0 -- is the net.Receive stopped (activates short-circuit)
    local recv_delay_after_stop = 3600 -- how long to wait (in seconds) before allowing messages again

    net.Receive("sphys_dupe", function(length, ply)
        if (recv_stop == 1) then return end -- if stopped, -- short-circuit

        -- check if a new interval has come
        if (recv_interval_start + recv_interval_len < os.time()) then
            recv_interval_start = os.time() -- reset time
            recv_interval_count = 0 -- reset message count
        end

        recv_interval_count = recv_interval_count + 1

        -- check if below threshold
        if (recv_interval_count > recv_max) then
            -- if over threshold, activate short-circuit
            recv_stop = 1

            -- and create a timer to deactivate the short-circuit in recv_delay_after_stop seconds
            timer.Simple(recv_delay_after_stop, function()
                recv_stop = 0
            end)

            -- warn server about attack
            PrintMessage(HUD_PRINTTALK, "WARNING: " .. ply:Nick() .. " [" .. ply:SteamID() .. "] is attacking sphys_dupe. simfphys duplicator is disabled for " .. tostring(recv_delay_after_stop) .. " seconds.")
        end

        ply.TOOLMemory = net.ReadTable()
        ply:SelectWeapon("gmod_tool")
    end)
end

if CLIENT then
    language.Add("tool.simfphysduplicator.name", "Vehicle Duplicator")
    language.Add("tool.simfphysduplicator.desc", "Copy, Paste or Save your Vehicles")
    language.Add("tool.simfphysduplicator.0", "Left click to spawn or update. Right click to copy")
    language.Add("tool.simfphysduplicator.1", "Left click to spawn or update. Right click to copy")
    local selecteditem = nil
    local TOOLMemory = {}

    net.Receive("sphys_dupe", function(length)
        TOOLMemory = net.ReadTable()
    end)

    local function GetSaves(panel)
        local saved_vehicles = file.Find("saved_vehicles/*.txt", "DATA")
        local index = 0
        local highlight = false
        local offset = 22

        for k, v in pairs(saved_vehicles) do
            local printname = v

            if not selecteditem then
                selecteditem = printname
            end

            local Button = vgui.Create("DButton", panel)
            Button:SetText(printname)
            Button:SetTextColor(Color(255, 255, 255))
            Button:SetPos(0, index * offset)
            Button:SetSize(280, offset)
            Button.highlight = highlight
            Button.printname = printname

            Button.Paint = function(self, w, h)
                local c_selected = Color(128, 185, 128, 255)
                local c_normal = self.highlight and Color(108, 111, 114, 200) or Color(77, 80, 82, 200)
                local c_hovered = Color(41, 128, 185, 255)
                local c_ = (selecteditem == self.printname) and c_selected or (self:IsHovered() and c_hovered or c_normal)
                draw.RoundedBox(5, 1, 1, w - 2, h - 1, c_)
            end

            Button.DoClick = function(self)
                selecteditem = self.printname
            end

            index = index + 1
            highlight = not highlight
        end
    end

    function TOOL.BuildCPanel(panel)
        if not file.Exists("saved_vehicles", "DATA") then
            file.CreateDir("saved_vehicles")
        end

        local Frame = vgui.Create("DFrame", panel)
        Frame:SetPos(10, 30)
        Frame:SetSize(280, 320)
        Frame:SetTitle("")
        Frame:SetVisible(true)
        Frame:ShowCloseButton(false)
        Frame:SetDraggable(false)

        Frame.Paint = function(self, w, h)
            draw.RoundedBox(5, 0, 0, w, h, Color(115, 115, 115, 255))
            draw.RoundedBox(5, 1, 1, w - 2, h - 2, Color(234, 234, 234, 255))
        end

        local ScrollPanel = vgui.Create("DScrollPanel", Frame)
        ScrollPanel:SetSize(280, 320)
        ScrollPanel:SetPos(0, 0)
        GetSaves(ScrollPanel)
        local Button = vgui.Create("DButton", panel)
        Button:SetText("Save")
        Button:SetPos(10, 350)
        Button:SetSize(280, 20)

        Button.DoClick = function(self)
            if isstring(TOOLMemory.SpawnName) then
                local Frame = vgui.Create("DFrame")
                Frame:SetPos(gui.MouseX() - 100, gui.MouseY() - 30)
                Frame:SetSize(280, 50)
                Frame:SetTitle("Save As...")
                Frame:SetVisible(true)
                Frame:ShowCloseButton(true)
                Frame:MakePopup()
                Frame:SetDraggable(true)
                local TextEntry = vgui.Create("DTextEntry", Frame)
                TextEntry:SetPos(5, 25)
                TextEntry:SetSize(270, 20)

                TextEntry.OnEnter = function()
                    local Name = TextEntry:GetValue()

                    if Name ~= "" then
                        local DataString = ""

                        for k, v in pairs(TOOLMemory) do
                            if k == "SubMaterials" then
                                local mats = ""
                                local first = true

                                for k, v in pairs(v) do
                                    if first then
                                        first = false
                                        mats = mats .. v
                                    else
                                        mats = mats .. "," .. v
                                    end
                                end

                                DataString = DataString .. k .. "=" .. mats .. "#"
                            else
                                DataString = DataString .. k .. "=" .. tostring(v) .. "#"
                            end
                        end

                        local words = string.Explode("", DataString)
                        local shit = {}

                        for k, v in pairs(words) do
                            shit[k] = string.char(string.byte(v) + 20)
                        end

                        file.Write("saved_vehicles/" .. Name .. ".txt", string.Implode("", shit))
                        ScrollPanel:Clear()
                        selecteditem = Name .. ".txt"
                        GetSaves(ScrollPanel)
                    end

                    Frame:Close()
                end
            end
        end

        local Button = vgui.Create("DButton", panel)
        Button:SetText("Load")
        Button:SetPos(10, 370)
        Button:SetSize(280, 20)

        Button.DoClick = function(self)
            if isstring(selecteditem) then
                if not file.Exists("saved_vehicles/" .. selecteditem, "DATA") then
                    ScrollPanel:Clear()
                    selecteditem = nil
                    GetSaves(ScrollPanel)

                    return
                end

                local DataString = file.Read("saved_vehicles/" .. selecteditem, "DATA")
                local words = string.Explode("", DataString)
                local shit = {}

                for k, v in pairs(words) do
                    shit[k] = string.char(string.byte(v) - 20)
                end

                local Data = string.Explode("#", string.Implode("", shit))
                table.Empty(TOOLMemory)

                for _, v in pairs(Data) do
                    local Var = string.Explode("=", v)
                    local name = Var[1]
                    local variable = Var[2]

                    if name and variable then
                        if name == "SubMaterials" then
                            TOOLMemory[name] = {}
                            local submats = string.Explode(",", variable)

                            for i = 0, (table.Count(submats) - 1) do
                                TOOLMemory[name][i] = submats[i + 1]
                            end
                        else
                            TOOLMemory[name] = variable
                        end
                    end
                end

                net.Start("sphys_dupe")
                net.WriteTable(TOOLMemory)
                net.SendToServer()
            end
        end

        local Button = vgui.Create("DButton", panel)
        Button:SetText("Delete")
        Button:SetPos(10, 430)
        Button:SetSize(280, 20)

        Button.DoClick = function(self)
            if isstring(selecteditem) then
                file.Delete("saved_vehicles/" .. selecteditem)
            end

            ScrollPanel:Clear()
            selecteditem = nil
            GetSaves(ScrollPanel)
        end

        local Button = vgui.Create("DButton", panel)
        Button:SetText("Refresh")
        Button:SetPos(10, 390)
        Button:SetSize(280, 20)

        Button.DoClick = function(self)
            ScrollPanel:Clear()
            selecteditem = nil
            GetSaves(ScrollPanel)
        end
    end
end

local function ValidateModel(model)
    local v_list = list.Get("simfphys_vehicles")

    for listname, _ in pairs(v_list) do
        if v_list[listname].Members.CustomWheels then
            local FrontWheel = v_list[listname].Members.CustomWheelModel
            local RearWheel = v_list[listname].Members.CustomWheelModel_R

            if FrontWheel then
                FrontWheel = string.lower(FrontWheel)
            end

            if RearWheel then
                RearWheel = string.lower(RearWheel)
            end

            if model == FrontWheel or model == RearWheel then return true end
        end
    end

    local list = list.Get("simfphys_Wheels")[model]
    if list then return true end

    return false
end

function TOOL:GetVehicleData(ent, ply)
    if not IsValid(ent) then return end

    if not istable(ply.TOOLMemory) then
        ply.TOOLMemory = {}
    end

    table.Empty(ply.TOOLMemory)
    ply.TOOLMemory.SpawnName = ent:GetSpawn_List()
    ply.TOOLMemory.SteerSpeed = ent:GetSteerSpeed()
    ply.TOOLMemory.SteerFadeSpeed = ent:GetFastSteerConeFadeSpeed()
    ply.TOOLMemory.SteerAngFast = ent:GetFastSteerAngle()
    ply.TOOLMemory.SoundPreset = ent:GetEngineSoundPreset()
    ply.TOOLMemory.IdleRPM = ent:GetIdleRPM()
    ply.TOOLMemory.MaxRPM = ent:GetLimitRPM()
    ply.TOOLMemory.PowerStart = ent:GetPowerBandStart()
    ply.TOOLMemory.PowerEnd = ent:GetPowerBandEnd()
    ply.TOOLMemory.PeakTorque = ent:GetMaxTorque()
    ply.TOOLMemory.HasTurbo = ent:GetTurboCharged()
    ply.TOOLMemory.HasBlower = ent:GetSuperCharged()
    ply.TOOLMemory.HasRevLimiter = ent:GetRevlimiter()
    ply.TOOLMemory.HasBulletProofTires = ent:GetBulletProofTires()
    ply.TOOLMemory.MaxTraction = ent:GetMaxTraction()
    ply.TOOLMemory.GripOffset = ent:GetTractionBias()
    ply.TOOLMemory.BrakePower = ent:GetBrakePower()
    ply.TOOLMemory.PowerDistribution = ent:GetPowerDistribution()
    ply.TOOLMemory.Efficiency = ent:GetEfficiency()
    ply.TOOLMemory.HornSound = ent.snd_horn
    ply.TOOLMemory.HasBackfire = ent:GetBackFire()
    ply.TOOLMemory.DoesntStall = ent:GetDoNotStall()
    ply.TOOLMemory.SoundOverride = ent:GetSoundoverride()
    ply.TOOLMemory.FrontHeight = ent:GetFrontSuspensionHeight()
    ply.TOOLMemory.RearHeight = ent:GetRearSuspensionHeight()
    ply.TOOLMemory.Camber = ent.Camber or 0

    if ent.FrontDampingOverride and ent.FrontConstantOverride and ent.RearDampingOverride and ent.RearConstantOverride then
        ply.TOOLMemory.FrontDampingOverride = ent.FrontDampingOverride
        ply.TOOLMemory.FrontConstantOverride = ent.FrontConstantOverride
        ply.TOOLMemory.RearDampingOverride = ent.RearDampingOverride
        ply.TOOLMemory.RearConstantOverride = ent.RearConstantOverride
    end

    if ent.CustomWheels then
        if ent.GhostWheels then
            if IsValid(ent.GhostWheels[1]) then
                ply.TOOLMemory.FrontWheelOverride = ent.GhostWheels[1]:GetModel()
            elseif IsValid(ent.GhostWheels[2]) then
                ply.TOOLMemory.FrontWheelOverride = ent.GhostWheels[2]:GetModel()
            end

            if IsValid(ent.GhostWheels[3]) then
                ply.TOOLMemory.RearWheelOverride = ent.GhostWheels[3]:GetModel()
            elseif IsValid(ent.GhostWheels[4]) then
                ply.TOOLMemory.RearWheelOverride = ent.GhostWheels[4]:GetModel()
            end
        end
    end

    local tsc = ent:GetTireSmokeColor()
    ply.TOOLMemory.TireSmokeColor = tsc.r .. "," .. tsc.g .. "," .. tsc.b
    local Gears = ""

    for _, v in pairs(ent.Gears) do
        Gears = Gears .. v .. ","
    end

    local c = ent:GetColor()
    ply.TOOLMemory.Color = c.r .. "," .. c.g .. "," .. c.b .. "," .. c.a
    local bodygroups = {}

    for k, v in pairs(ent:GetBodyGroups()) do
        bodygroups[k] = ent:GetBodygroup(k)
    end

    ply.TOOLMemory.BodyGroups = string.Implode(",", bodygroups)
    ply.TOOLMemory.Skin = ent:GetSkin()
    ply.TOOLMemory.Gears = Gears
    ply.TOOLMemory.FinalGear = ent:GetDifferentialGear()

    if ent.WheelTool_Foffset then
        ply.TOOLMemory.WheelTool_Foffset = ent.WheelTool_Foffset
    end

    if ent.WheelTool_Roffset then
        ply.TOOLMemory.WheelTool_Roffset = ent.WheelTool_Roffset
    end

    if ent.snd_blowoff then
        ply.TOOLMemory.snd_blowoff = ent.snd_blowoff
    end

    if ent.snd_spool then
        ply.TOOLMemory.snd_spool = ent.snd_spool
    end

    if ent.snd_bloweron then
        ply.TOOLMemory.snd_bloweron = ent.snd_bloweron
    end

    if ent.snd_bloweroff then
        ply.TOOLMemory.snd_bloweroff = ent.snd_bloweroff
    end

    ply.TOOLMemory.backfiresound = ent:GetBackfireSound()
    ply.TOOLMemory.SubMaterials = {}

    for i = 0, (table.Count(ent:GetMaterials()) - 1) do
        ply.TOOLMemory.SubMaterials[i] = ent:GetSubMaterial(i)
    end

    if not IsValid(ply) then return end
    net.Start("sphys_dupe")
    net.WriteTable(ply.TOOLMemory)
    net.Send(ply)
end

local function GetRight(ent, index, WheelPos)
    local Steer = ent:GetTransformedDirection()
    local Right = ent.Right

    if WheelPos.IsFrontWheel then
        Right = (IsValid(ent.SteerMaster) and Steer.Right or ent.Right) * (WheelPos.IsRightWheel and 1 or -1)
    else
        Right = (IsValid(ent.SteerMaster) and Steer.Right2 or ent.Right) * (WheelPos.IsRightWheel and 1 or -1)
    end

    return Right
end

local function SetWheelOffset(ent, offset_front, offset_rear)
    if not IsValid(ent) then return end
    ent.WheelTool_Foffset = offset_front
    ent.WheelTool_Roffset = offset_rear
    if not istable(ent.Wheels) or not istable(ent.GhostWheels) then return end

    for i = 1, table.Count(ent.GhostWheels) do
        local Wheel = ent.Wheels[i]
        local WheelModel = ent.GhostWheels[i]
        local WheelPos = ent:LogicWheelPos(i)

        if IsValid(Wheel) and IsValid(WheelModel) then
            local Pos = Wheel:GetPos()
            local Right = GetRight(ent, i, WheelPos)
            local offset = WheelPos.IsFrontWheel and offset_front or offset_rear
            WheelModel:SetParent(nil)
            local physObj = WheelModel:GetPhysicsObject()

            if IsValid(physObj) then
                physObj:EnableMotion(false)
            end

            WheelModel:SetPos(Pos + Right * offset)
            WheelModel:SetParent(Wheel)
        end
    end
end

local function ApplyWheel(ent, data)
    ent.CustomWheelAngleOffset = data[2]
    ent.CustomWheelAngleOffset_R = data[4]

    timer.Simple(0.05, function()
        if not IsValid(ent) then return end

        for i = 1, table.Count(ent.GhostWheels) do
            local Wheel = ent.GhostWheels[i]

            if IsValid(Wheel) then
                local isfrontwheel = (i == 1 or i == 2)
                local swap_y = (i == 2 or i == 4 or i == 6)
                local angleoffset = isfrontwheel and ent.CustomWheelAngleOffset or ent.CustomWheelAngleOffset_R
                local model = isfrontwheel and data[1] or data[3]
                local fAng = ent:LocalToWorldAngles(ent.VehicleData.LocalAngForward)
                local rAng = ent:LocalToWorldAngles(ent.VehicleData.LocalAngRight)
                local Forward = fAng:Forward()
                local Right = swap_y and -rAng:Forward() or rAng:Forward()
                local Up = ent:GetUp()
                local Camber = data[5] or 0
                local ghostAng = Right:Angle()
                local mirAng = swap_y and 1 or -1
                ghostAng:RotateAroundAxis(Forward, angleoffset.p * mirAng)
                ghostAng:RotateAroundAxis(Right, angleoffset.r * mirAng)
                ghostAng:RotateAroundAxis(Up, -angleoffset.y)
                ghostAng:RotateAroundAxis(Forward, Camber * mirAng)
                Wheel:SetModelScale(1)
                Wheel:SetModel(model)
                Wheel:SetAngles(ghostAng)

                timer.Simple(0.05, function()
                    if not IsValid(Wheel) or not IsValid(ent) then return end
                    local wheelsize = Wheel:OBBMaxs() - Wheel:OBBMins()
                    local radius = isfrontwheel and ent.FrontWheelRadius or ent.RearWheelRadius
                    local size = (radius * 2) / math.max(wheelsize.x, wheelsize.y, wheelsize.z)
                    Wheel:SetModelScale(size)
                end)
            end
        end
    end)
end

local function GetAngleFromSpawnlist(model)
    if not model then
        print("invalid model")

        return Angle(0, 0, 0)
    end

    model = string.lower(model)
    local v_list = list.Get("simfphys_vehicles")

    for listname, _ in pairs(v_list) do
        if v_list[listname].Members.CustomWheels then
            local FrontWheel = v_list[listname].Members.CustomWheelModel
            local RearWheel = v_list[listname].Members.CustomWheelModel_R

            if FrontWheel then
                FrontWheel = string.lower(FrontWheel)
            end

            if RearWheel then
                RearWheel = string.lower(RearWheel)
            end

            if model == FrontWheel or model == RearWheel then
                local Angleoffset = v_list[listname].Members.CustomWheelAngleOffset
                if (Angleoffset) then return Angleoffset end
            end
        end
    end

    local list = list.Get("simfphys_Wheels")[model]
    local output = list and list.Angle or Angle(0, 0, 0)

    return output
end

function TOOL:LeftClick(trace)
    if CLIENT then return true end
    local Ent = trace.Entity
    local ply = self:GetOwner()
    if not istable(ply.TOOLMemory) then return end
    local vname = ply.TOOLMemory.SpawnName
    local Update = false
    local VehicleList = list.Get("simfphys_vehicles")
    local vehicle = VehicleList[vname]
    if not vehicle then return false end
    ply.LockRightClick = true

    timer.Simple(0.6, function()
        if IsValid(ply) then
            ply.LockRightClick = false
        end
    end)

    local SpawnPos = trace.HitPos + Vector(0, 0, 25) + (vehicle.SpawnOffset or Vector(0, 0, 0))
    local SpawnAng = self:GetOwner():EyeAngles()
    SpawnAng.pitch = 0
    SpawnAng.yaw = SpawnAng.yaw + 180 + (vehicle.SpawnAngleOffset and vehicle.SpawnAngleOffset or 0)
    SpawnAng.roll = 0

    if simfphys.IsCar(Ent) then
        if vname ~= Ent:GetSpawn_List() then
            ply:PrintMessage(HUD_PRINTTALK, vname .. " is not compatible with " .. Ent:GetSpawn_List())

            return
        end

        Update = true
    else
        Ent = simfphys.SpawnVehicle(ply, SpawnPos, SpawnAng, vehicle.Model, vehicle.Class, vname, vehicle)
    end

    if not IsValid(Ent) then return end
    undo.Create("Vehicle")
    undo.SetPlayer(ply)
    undo.AddEntity(Ent)
    undo.SetCustomUndoText("Undone " .. vehicle.Name)
    undo.Finish("Vehicle (" .. tostring(vehicle.Name) .. ")")
    ply:AddCleanup("vehicles", Ent)

    timer.Simple(0.5, function()
        if not IsValid(Ent) then return end
        local tsc = string.Explode(",", ply.TOOLMemory.TireSmokeColor)
        Ent:SetTireSmokeColor(Vector(tonumber(tsc[1]), tonumber(tsc[2]), tonumber(tsc[3])))
        Ent.Turbocharged = tobool(ply.TOOLMemory.HasTurbo)
        Ent.Supercharged = tobool(ply.TOOLMemory.HasBlower)
        Ent:SetEngineSoundPreset(math.Clamp(tonumber(ply.TOOLMemory.SoundPreset), -1, 14))
        Ent:SetMaxTorque(math.Clamp(tonumber(ply.TOOLMemory.PeakTorque), 20, 1000))
        Ent:SetDifferentialGear(math.Clamp(tonumber(ply.TOOLMemory.FinalGear), 0.2, 6))
        Ent:SetSteerSpeed(math.Clamp(tonumber(ply.TOOLMemory.SteerSpeed), 1, 16))
        Ent:SetFastSteerAngle(math.Clamp(tonumber(ply.TOOLMemory.SteerAngFast), 0, 1))
        Ent:SetFastSteerConeFadeSpeed(math.Clamp(tonumber(ply.TOOLMemory.SteerFadeSpeed), 1, 5000))
        Ent:SetEfficiency(math.Clamp(tonumber(ply.TOOLMemory.Efficiency), 0.2, 4))
        Ent:SetMaxTraction(math.Clamp(tonumber(ply.TOOLMemory.MaxTraction), 5, 1000))
        Ent:SetTractionBias(math.Clamp(tonumber(ply.TOOLMemory.GripOffset), -0.99, 0.99))
        Ent:SetPowerDistribution(math.Clamp(tonumber(ply.TOOLMemory.PowerDistribution), -1, 1))
        Ent:SetBackFire(tobool(ply.TOOLMemory.HasBackfire))
        Ent:SetDoNotStall(tobool(ply.TOOLMemory.DoesntStall))
        Ent:SetIdleRPM(math.Clamp(tonumber(ply.TOOLMemory.IdleRPM), 1, 25000))
        Ent:SetLimitRPM(math.Clamp(tonumber(ply.TOOLMemory.MaxRPM), 4, 25000))
        Ent:SetRevlimiter(tobool(ply.TOOLMemory.HasRevLimiter))
        Ent:SetPowerBandEnd(math.Clamp(tonumber(ply.TOOLMemory.PowerEnd), 3, 25000))
        Ent:SetPowerBandStart(math.Clamp(tonumber(ply.TOOLMemory.PowerStart), 2, 25000))
        Ent:SetTurboCharged(Ent.Turbocharged)
        Ent:SetSuperCharged(Ent.Supercharged)
        Ent:SetBrakePower(math.Clamp(tonumber(ply.TOOLMemory.BrakePower), 0.1, 500))
        Ent:SetSoundoverride(ply.TOOLMemory.SoundOverride or "")
        Ent:SetLights_List(Ent.LightsTable or "no_lights")
        Ent:SetBulletProofTires(tobool(ply.TOOLMemory.HasBulletProofTires))
        Ent.snd_horn = ply.TOOLMemory.HornSound
        Ent.snd_blowoff = ply.TOOLMemory.snd_blowoff
        Ent.snd_spool = ply.TOOLMemory.snd_spool
        Ent.snd_bloweron = ply.TOOLMemory.snd_bloweron
        Ent.snd_bloweroff = ply.TOOLMemory.snd_bloweroff
        Ent:SetBackfireSound(ply.TOOLMemory.backfiresound or "")
        local Gears = {}
        local Data = string.Explode(",", ply.TOOLMemory.Gears)

        for i = 1, table.Count(Data) do
            local gRatio = tonumber(Data[i])

            if isnumber(gRatio) then
                if i == 1 then
                    Gears[i] = math.Clamp(gRatio, -5, -0.001)
                elseif i == 2 then
                    Gears[i] = 0
                else
                    Gears[i] = math.Clamp(gRatio, 0.001, 5)
                end
            end
        end

        Ent.Gears = Gears

        if istable(ply.TOOLMemory.SubMaterials) then
            for i = 0, table.Count(ply.TOOLMemory.SubMaterials) do
                Ent:SetSubMaterial(i, ply.TOOLMemory.SubMaterials[i])
            end
        end

        if ply.TOOLMemory.FrontDampingOverride and ply.TOOLMemory.FrontConstantOverride and ply.TOOLMemory.RearDampingOverride and ply.TOOLMemory.RearConstantOverride then
            Ent.FrontDampingOverride = tonumber(ply.TOOLMemory.FrontDampingOverride)
            Ent.FrontConstantOverride = tonumber(ply.TOOLMemory.FrontConstantOverride)
            Ent.RearDampingOverride = tonumber(ply.TOOLMemory.RearDampingOverride)
            Ent.RearConstantOverride = tonumber(ply.TOOLMemory.RearConstantOverride)

            local data = {
                [1] = {Ent.FrontConstantOverride, Ent.FrontDampingOverride},
                [2] = {Ent.FrontConstantOverride, Ent.FrontDampingOverride},
                [3] = {Ent.RearConstantOverride, Ent.RearDampingOverride},
                [4] = {Ent.RearConstantOverride, Ent.RearDampingOverride},
                [5] = {Ent.RearConstantOverride, Ent.RearDampingOverride},
                [6] = {Ent.RearConstantOverride, Ent.RearDampingOverride}
            }

            local elastics = Ent.Elastics

            if elastics then
                for i = 1, table.Count(elastics) do
                    local elastic = elastics[i]

                    if Ent.StrengthenSuspension == true then
                        if IsValid(elastic) then
                            elastic:Fire("SetSpringConstant", data[i][1] * 0.5, 0)
                            elastic:Fire("SetSpringDamping", data[i][2] * 0.5, 0)
                        end

                        local elastic2 = elastics[i * 10]

                        if IsValid(elastic2) then
                            elastic2:Fire("SetSpringConstant", data[i][1] * 0.5, 0)
                            elastic2:Fire("SetSpringDamping", data[i][2] * 0.5, 0)
                        end
                    else
                        if IsValid(elastic) then
                            elastic:Fire("SetSpringConstant", data[i][1], 0)
                            elastic:Fire("SetSpringDamping", data[i][2], 0)
                        end
                    end
                end
            end
        end

        Ent:SetFrontSuspensionHeight(tonumber(ply.TOOLMemory.FrontHeight))
        Ent:SetRearSuspensionHeight(tonumber(ply.TOOLMemory.RearHeight))
        local groups = string.Explode(",", ply.TOOLMemory.BodyGroups)

        for i = 1, table.Count(groups) do
            Ent:SetBodygroup(i, tonumber(groups[i]))
        end

        Ent:SetSkin(ply.TOOLMemory.Skin)
        local c = string.Explode(",", ply.TOOLMemory.Color)
        local Color = Color(tonumber(c[1]), tonumber(c[2]), tonumber(c[3]), tonumber(c[4]))
        local dot = Color.r * Color.g * Color.b * Color.a
        Ent.OldColor = dot
        Ent:SetColor(Color)

        local data = {
            Color = Color,
            RenderMode = 0,
            RenderFX = 0
        }

        duplicator.StoreEntityModifier(Ent, "colour", data)

        if Update then
            local PhysObj = Ent:GetPhysicsObject()
            if not IsValid(PhysObj) then return end
            local freezeWhenDone = PhysObj:IsMotionEnabled()
            local freezeWheels = {}
            PhysObj:EnableMotion(false)
            Ent:SetNotSolid(true)
            local ResetPos = Ent:GetPos()
            local ResetAng = Ent:GetAngles()
            Ent:SetPos(ResetPos + Vector(0, 0, 30))
            Ent:SetAngles(Angle(0, ResetAng.y, 0))

            for i = 1, table.Count(Ent.Wheels) do
                local Wheel = Ent.Wheels[i]

                if IsValid(Wheel) then
                    local wPObj = Wheel:GetPhysicsObject()

                    if IsValid(wPObj) then
                        freezeWheels[i] = {}
                        freezeWheels[i].dofreeze = wPObj:IsMotionEnabled()
                        freezeWheels[i].pos = Wheel:GetPos()
                        freezeWheels[i].ang = Wheel:GetAngles()
                        Wheel:SetNotSolid(true)
                        wPObj:EnableMotion(true)
                        wPObj:Wake()
                    end
                end
            end

            timer.Simple(0.5, function()
                if not IsValid(Ent) then return end
                if not IsValid(PhysObj) then return end
                PhysObj:EnableMotion(freezeWhenDone)
                Ent:SetNotSolid(false)
                Ent:SetPos(ResetPos)
                Ent:SetAngles(ResetAng)

                for i = 1, table.Count(freezeWheels) do
                    local Wheel = Ent.Wheels[i]

                    if IsValid(Wheel) then
                        local wPObj = Wheel:GetPhysicsObject()
                        Wheel:SetNotSolid(false)

                        if IsValid(wPObj) then
                            wPObj:EnableMotion(freezeWheels[i].dofreeze)
                        end

                        Wheel:SetPos(freezeWheels[i].pos)
                        Wheel:SetAngles(freezeWheels[i].ang)
                    end
                end
            end)
        end

        if Ent.CustomWheels then
            if Ent.GhostWheels then
                timer.Simple(Update and 0.25 or 0, function()
                    if not IsValid(Ent) then return end

                    if ply.TOOLMemory.WheelTool_Foffset and ply.TOOLMemory.WheelTool_Roffset then
                        SetWheelOffset(Ent, ply.TOOLMemory.WheelTool_Foffset, ply.TOOLMemory.WheelTool_Roffset)
                    end

                    if not ply.TOOLMemory.FrontWheelOverride and not ply.TOOLMemory.RearWheelOverride then return end
                    local front_model = ply.TOOLMemory.FrontWheelOverride or vehicle.Members.CustomWheelModel
                    local front_angle = GetAngleFromSpawnlist(front_model)
                    local camber = ply.TOOLMemory.Camber or 0
                    local rear_model = ply.TOOLMemory.RearWheelOverride or (vehicle.Members.CustomWheelModel_R and vehicle.Members.CustomWheelModel_R or front_model)
                    local rear_angle = GetAngleFromSpawnlist(rear_model)
                    if not front_model or not rear_model or not front_angle or not rear_angle then return end

                    if ValidateModel(front_model) and ValidateModel(rear_model) then
                        Ent.Camber = camber

                        ApplyWheel(Ent, {front_model, front_angle, rear_model, rear_angle, camber})
                    else
                        ply:PrintMessage(HUD_PRINTTALK, "selected wheel does not exist on the server")
                    end
                end)
            end
        end
    end)

    return true
end

function TOOL:RightClick(trace)
    if CLIENT then return true end
    local ent = trace.Entity
    local ply = self:GetOwner()

    if ply.LockRightClick then
        ply:PrintMessage(HUD_PRINTTALK, "Duplicator is busy")

        return
    end

    if not istable(ply.TOOLMemory) then
        ply.TOOLMemory = {}
    end

    if not IsValid(ent) then
        table.Empty(ply.TOOLMemory)
        net.Start("sphys_dupe")
        net.WriteTable(ply.TOOLMemory)
        net.Send(ply)

        return false
    end

    if not simfphys.IsCar(ent) then return false end
    self:GetVehicleData(ent, ply)

    return true
end

function TOOL:Reload(trace)
    return false
end