util.AddNetworkString( "simfphys_mousesteer" )
util.AddNetworkString( "simfphys_blockcontrols" )
	
net.Receive( "simfphys_mousesteer", function( length, ply )
	if not ply:IsDrivingSimfphys() then return end

	local vehicle = net.ReadEntity()
	local Steer = net.ReadFloat()
	
	if not IsValid( vehicle ) or ply:GetSimfphys() ~= vehicle:GetParent() then return end
	
	vehicle.ms_Steer = Steer
end)

net.Receive( "simfphys_blockcontrols", function( length, ply )
	if not IsValid( ply ) then return end
	
	ply.blockcontrols = net.ReadBool()
end)

hook.Add( "PlayerButtonDown", "!!!simfphysButtonDown", function( ply, button )
	local vehicle = ply:GetSimfphys()
	
	if not IsValid( vehicle ) then return end
	
	if button == KEY_1 then
		if ply == vehicle:GetDriver() then
			if vehicle:GetIsVehicleLocked() then
				vehicle:UnLock()
			else
				vehicle:Lock()
			end
		else
			if not IsValid( vehicle:GetDriver() ) then
				ply:ExitVehicle()
				
				local DriverSeat = vehicle:GetDriverSeat()
				
				if IsValid( DriverSeat ) then
					timer.Simple( FrameTime(), function()
						if not IsValid( vehicle ) or not IsValid( ply ) then return end
						if IsValid( vehicle:GetDriver() ) or not IsValid( DriverSeat ) then return end
						
						ply:EnterVehicle( DriverSeat )
						
						timer.Simple( FrameTime() * 2, function()
							if not IsValid( ply ) or not IsValid( vehicle ) then return end
							ply:SetEyeAngles( Angle(0,vehicle:GetAngles().y,0) )
						end)
					end)
				end
			end
		end
	else
		for _, Pod in ipairs( vehicle:GetPassengerSeats() ) do
			if IsValid( Pod ) then
				if Pod:GetNWInt( "pPodIndex", 3 ) == simfphys.pSwitchKeys[ button ] then
					if not IsValid( Pod:GetDriver() ) then
						ply:ExitVehicle()
					
						timer.Simple( FrameTime(), function()
							if not IsValid( Pod ) or not IsValid( ply ) then return end
							if IsValid( Pod:GetDriver() ) then return end
							
							ply:EnterVehicle( Pod )
						end)
					end
				end
			end
		end
	end
end )
