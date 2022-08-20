local LockedPitch = 5

if CLIENT then
    cvars.AddChangeCallback("cl_simfphys_ms_lockedpitch", function(convar, oldValue, newValue)
        LockedPitch = tonumber(newValue)
    end)

    LockedPitch = GetConVar("cl_simfphys_ms_lockedpitch"):GetFloat()
end

local function GetViewOverride(ent)
    if not IsValid(ent) then return Vector(0, 0, 0) end

    if not ent.customview then
        local vehiclelist = list.Get("simfphys_vehicles")[ent:GetSpawn_List()]

        if vehiclelist then
            ent.customview = vehiclelist.Members.FirstPersonViewPos or Vector(0, -9, 5)
        else
            ent.customview = Vector(0, -9, 5)
        end
    end

    return ent.customview
end

hook.Add("CalcVehicleView", "simfphysViewOverride", function(Vehicle, ply, view)
    local vehiclebase = ply:GetSimfphys()
    if not IsValid(vehiclebase) then return end
    local IsDriverSeat = ply:IsDrivingSimfphys()
    if Vehicle.GetThirdPersonMode == nil or ply:GetViewEntity() ~= ply then return end
    ply.simfphys_smooth_out = 0

    if not Vehicle:GetThirdPersonMode() then
        local viewoverride = GetViewOverride(vehiclebase)
        local X = viewoverride.X
        local Y = viewoverride.Y
        local Z = viewoverride.Z
        view.origin = IsDriverSeat and view.origin + Vehicle:GetForward() * X + Vehicle:GetRight() * Y + Vehicle:GetUp() * Z or view.origin + Vehicle:GetUp() * 5

        return view
    end

    local mn, mx = vehiclebase:GetRenderBounds()
    local radius = (mn - mx):Length()
    local radius = radius + radius * Vehicle:GetCameraDistance()
    local TargetOrigin = view.origin + (view.angles:Forward() * -radius)
    local WallOffset = 4

    local tr = util.TraceHull({
        start = view.origin,
        endpos = TargetOrigin,
        filter = function(e)
            local c = e:GetClass()
            local collide = not c:StartWith("prop_physics") and not c:StartWith("prop_dynamic") and not c:StartWith("prop_ragdoll") and not e:IsVehicle() and not c:StartWith("gmod_") and not c:StartWith("player")

            return collide
        end,
        mins = Vector(-WallOffset, -WallOffset, -WallOffset),
        maxs = Vector(WallOffset, WallOffset, WallOffset),
    })

    view.origin = tr.HitPos
    view.drawviewer = true

    if tr.Hit and not tr.StartSolid then
        view.origin = view.origin + tr.HitNormal * WallOffset
    end

    return view
end)

hook.Add("StartCommand", "simfphys_lockview", function(ply, ucmd)
    if not ply:IsDrivingSimfphys() then return end
    local vehicle = ply:GetVehicle()
    if not IsValid(vehicle) then return end
    local vehiclebase = ply:GetSimfphys()
    if not IsValid(vehiclebase) then return end
    if not (ply:GetInfoNum("cl_simfphys_mousesteer", 0) == 1) then return end
    local ang = ucmd:GetViewAngles()

    if ply.Freelook then
        vehicle.lockedpitch = ang.p
        vehicle.lockedyaw = ang.y

        return
    end

    vehicle.lockedpitch = vehicle.lockedpitch or 0
    vehicle.lockedyaw = vehicle.lockedyaw or 90
    local dir = 0

    if vehicle.lockedyaw < 90 and vehicle.lockedyaw > -90 then
        dir = math.abs(vehicle.lockedyaw - 90)
    end

    if vehicle.lockedyaw >= 90 then
        dir = -math.abs(vehicle.lockedyaw - 90)
    end

    if vehicle.lockedyaw < -90 and vehicle.lockedyaw >= -270 then
        dir = -math.abs(vehicle.lockedyaw + 270)
    end

    vehicle.lockedyaw = vehicle.lockedyaw + dir * 0.05
    vehicle.lockedpitch = vehicle.lockedpitch + (LockedPitch - vehicle.lockedpitch) * 0.05

    if ply:GetInfoNum("cl_simfphys_ms_lockpitch", 0) == 1 then
        ang.p = vehicle.lockedpitch
    end

    ang.y = vehicle.lockedyaw
    ucmd:SetViewAngles(ang)
end)