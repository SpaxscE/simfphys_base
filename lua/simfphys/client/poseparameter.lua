local function receiveppdata(length)
    local ent = net.ReadEntity()

    if IsValid(ent) then
        ent.CustomWheels = net.ReadBool()

        if not ent.CustomWheels then
            local wheelFL = net.ReadEntity()
            local posFL = net.ReadFloat()
            local travelFL = net.ReadFloat()
            local wheelFR = net.ReadEntity()
            local posFR = net.ReadFloat()
            local travelFR = net.ReadFloat()
            local wheelRL = net.ReadEntity()
            local posRL = net.ReadFloat()
            local travelRL = net.ReadFloat()
            local wheelRR = net.ReadEntity()
            local posRR = net.ReadFloat()
            local travelRR = net.ReadFloat()
            if not IsValid(wheelFL) or not IsValid(wheelFR) or not IsValid(wheelRL) or not IsValid(wheelRR) then return end

            ent.pp_data = {
                [1] = {
                    name = "vehicle_wheel_fl_height",
                    entity = wheelFL,
                    pos = posFL,
                    travel = travelFL,
                    dradius = (wheelFL:BoundingRadius() * 0.28),
                },
                [2] = {
                    name = "vehicle_wheel_fr_height",
                    entity = wheelFR,
                    pos = posFR,
                    travel = travelFR,
                    dradius = (wheelFR:BoundingRadius() * 0.28),
                },
                [3] = {
                    name = "vehicle_wheel_rl_height",
                    entity = wheelRL,
                    pos = posRL,
                    travel = travelRL,
                    dradius = (wheelRL:BoundingRadius() * 0.28),
                },
                [4] = {
                    name = "vehicle_wheel_rr_height",
                    entity = wheelRR,
                    pos = posRR,
                    travel = travelRR,
                    dradius = (wheelRR:BoundingRadius() * 0.28),
                },
            }
        end
    end
end

net.Receive("simfphys_send_ppdata", receiveppdata)