util.AddNetworkString( "simfphys_request_ppdata" )
util.AddNetworkString( "simfphys_send_ppdata" )

local function sendppdata( length, ply )
	local ent = net.ReadEntity()
	
	if not IsValid( ent ) then return end
	
	if ent.IsInitialized and not ent:IsInitialized() then return end
	if not istable( ent.Wheels ) then return end
	
	net.Start( "simfphys_send_ppdata", true )
		net.WriteEntity( ent )
		net.WriteBool( ent.CustomWheels )
		
		net.WriteEntity( ent.Wheels[1] )
		net.WriteFloat( ent.posepositions.PoseL_Pos_FL.z )
		net.WriteFloat( ent.VehicleData.suspensiontravel_fl )
		
		net.WriteEntity( ent.Wheels[2] )
		net.WriteFloat( ent.posepositions.PoseL_Pos_FR.z )
		net.WriteFloat( ent.VehicleData.suspensiontravel_fr )
		
		net.WriteEntity( ent.Wheels[3] )
		net.WriteFloat( ent.posepositions.PoseL_Pos_RL.z )
		net.WriteFloat( ent.VehicleData.suspensiontravel_rl )
		
		net.WriteEntity( ent.Wheels[4] )
		net.WriteFloat( ent.posepositions.PoseL_Pos_RR.z )
		net.WriteFloat( ent.VehicleData.suspensiontravel_rr )
	net.Send( ply )
end

--net.Receive("simfphys_request_ppdata", sendppdata)
