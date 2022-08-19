local function ExitUsingMyTraces( ent, ply, b_ent )
	
	local Center = b_ent:LocalToWorld( b_ent:OBBCenter() )
	local vel = b_ent:GetVelocity()
	local radius = b_ent:BoundingRadius()
	local HullSize = Vector(18,18,0)
	local Filter1 = {ent,ply}
	local Filter2 = {ent,ply,b_ent}
	
	for i = 1, table.Count( b_ent.Wheels ) do
		table.insert(Filter1, b_ent.Wheels[i])
		table.insert(Filter2, b_ent.Wheels[i])
	end
	
	if vel:Length() > 250 then
		local pos = b_ent:GetPos()
		local dir = vel:GetNormalized()
		local targetpos = pos - dir *  (radius + 40)
		
		local tr = util.TraceHull( {
			start = Center,
			endpos = targetpos - Vector(0,0,10),
			maxs = HullSize,
			mins = -HullSize,
			filter = Filter2
		} )
		
		local exitpoint = tr.HitPos + Vector(0,0,10)
		
		if util.IsInWorld( exitpoint ) then
			ply:SetPos(exitpoint)
			ply:SetEyeAngles((pos - exitpoint):Angle())
		end
	else
		local pos = ent:GetPos()
		local targetpos = (pos + ent:GetRight() * 80)
		
		local tr1 = util.TraceLine( {
			start = targetpos,
			endpos = targetpos - Vector(0,0,100),
			filter = {}
		} )
		local tr2 = util.TraceHull( {
			start = targetpos,
			endpos = targetpos + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = Filter1
		} )
		local traceto = util.TraceLine( {start = Center,endpos = targetpos,filter = Filter2} )
		
		local HitGround = tr1.Hit
		local HitWall = tr2.Hit or traceto.Hit
		
		local check0 = (HitWall == true or HitGround == false or util.IsInWorld( targetpos ) == false) and (pos - ent:GetRight() * 80) or targetpos
		local tr = util.TraceHull( {
			start = check0,
			endpos = check0 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = Filter1
		} )
		local traceto = util.TraceLine( {start = Center,endpos = check0,filter = Filter2} )
		local HitWall = tr.Hit or traceto.hit
		
		local check1 = (HitWall == true or HitGround == false or util.IsInWorld( check0 ) == false) and (pos + ent:GetUp() * 100) or check0
		
		local tr = util.TraceHull( {
			start = check1,
			endpos = check1 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = Filter1
		} )
		local traceto = util.TraceLine( {start = Center,endpos = check1,filter = Filter2} )
		local HitWall = tr.Hit or traceto.hit
		local check2 = (HitWall == true or util.IsInWorld( check1 ) == false) and (pos - ent:GetUp() * 100) or check1
		
		local tr = util.TraceHull( {
			start = check2,
			endpos = check2 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = Filter1
		} )
		local traceto = util.TraceLine( {start = Center,endpos = check2,filter = Filter2} )
		local HitWall = tr.Hit or traceto.hit
		local check3 = (HitWall == true or util.IsInWorld( check2 ) == false) and b_ent:LocalToWorld( Vector(0,radius,0) ) or check2
		
		local tr = util.TraceHull( {
			start = check3,
			endpos = check3 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = Filter1
		} )
		local traceto = util.TraceLine( {start = Center,endpos = check3,filter = Filter2} )
		local HitWall = tr.Hit or traceto.hit
		local check4 = (HitWall == true or util.IsInWorld( check3 ) == false) and b_ent:LocalToWorld( Vector(0,-radius,0) ) or check3
		
		local tr = util.TraceHull( {
			start = check4,
			endpos = check4 + Vector(0,0,80),
			maxs = HullSize,
			mins = -HullSize,
			filter = Filter1
		} )
		local traceto = util.TraceLine( {start = Center,endpos = check4,filter = Filter2} )
		local HitWall = tr.Hit or traceto.hit
		local exitpoint = (HitWall == true or util.IsInWorld( check4 ) == false) and b_ent:LocalToWorld( Vector(0,0,0) ) or check4
		
		if util.IsInWorld( exitpoint ) then
			ply:SetPos(exitpoint)
			ply:SetEyeAngles((pos - exitpoint):Angle())
		end
	end
end

local function ExitUsingAttachments( ent, ply, b_ent )
	local Center = b_ent:LocalToWorld( b_ent:OBBCenter() )
	local Filter = {ent,ply,b_ent}
	local LinkedDoorAnims = istable(b_ent.ModelInfo) and istable(b_ent.ModelInfo.LinkDoorAnims)
	
	for i = 1, table.Count( b_ent.Wheels ) do
		table.insert(Filter, b_ent.Wheels[i])
	end

	local IsDriverSeat = ent == b_ent:GetDriverSeat()
	
	if IsDriverSeat then
		if LinkedDoorAnims then
			for i,_ in pairs( b_ent.ModelInfo.LinkDoorAnims ) do
				local seq_att = b_ent.ModelInfo.LinkDoorAnims[ i ].exit
				local attachmentdata = b_ent:GetAttachment( b_ent:LookupAttachment( i ) )
				
				if attachmentdata then
					local targetpos = attachmentdata.Pos
					local targetang = attachmentdata.Ang
					targetang.r = 0
					
					local tr = util.TraceLine( {
						start = Center,
						endpos = targetpos,
						filter = Filter
					} )
					local Hit = tr.Hit
					local InWorld = util.IsInWorld( targetpos )
					local IsBlocked = Hit or not InWorld
					
					if not IsBlocked then
						ply:SetPos( targetpos )
						ply:SetEyeAngles( targetang )
						b_ent:PlayAnimation( seq_att )
						b_ent:ForceLightsOff()
						
						return
					end
				end
			end
		else
			local seq_att = b_ent.Exitpoints[b_ent:GetSeatIndex(ply)]
			if seq_att then
				local attachmentdata = b_ent:GetAttachment( b_ent:LookupAttachment( seq_att ) )
				if attachmentdata then
					local targetpos = attachmentdata.Pos
					local targetang = attachmentdata.Ang
					targetang.r = 0
					
					local tr = util.TraceLine( {
						start = Center,
						endpos = targetpos,
						filter = Filter
					} )
					local Hit = tr.Hit
					local InWorld = util.IsInWorld( targetpos )
					local IsBlocked = Hit or not InWorld

					if not IsBlocked then
						ply:SetPos( targetpos )
						ply:SetEyeAngles( targetang )
						b_ent:PlayAnimation( seq_att )
						b_ent:ForceLightsOff()
						
						return
					end
				end
			end
		end
	end
	
	ExitUsingMyTraces( ent, ply, b_ent )
end

local function Exit_vehicle_simple( ent, ply, b_ent )

	if not IsValid( ent ) then return end
	if not IsValid( ply ) then return end
	if not IsValid( b_ent ) then return end
	
	if istable( b_ent.Exitpoints ) and b_ent:GetVelocity():Length() < 250 then
		ExitUsingAttachments( ent, ply, b_ent )
	else
		ExitUsingMyTraces( ent, ply, b_ent )
	end
end

 local function HandleVehicleExit( ply, vehicle )
	if not IsValid( ply ) then return end
	
	local vehicle = ply:GetVehicle()
	
	if not IsValid( vehicle ) then return end

	if vehicle.fphysSeat then
		local base = vehicle.base
		Exit_vehicle_simple( vehicle, ply, base )
	end
end
hook.Add( "PlayerLeaveVehicle", "simfphysVehicleExit", HandleVehicleExit )