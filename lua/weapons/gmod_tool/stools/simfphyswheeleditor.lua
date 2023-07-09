
TOOL.Category		= "simfphys"
TOOL.Name			= "#Wheel Model Editor"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "frontwheelmodel" ] = "models/props_vehicles/apc_tire001.mdl"
TOOL.ClientConVar[ "rearwheelmodel" ] = "models/props_vehicles/apc_tire001.mdl"
TOOL.ClientConVar[ "sameasfront" ] = 1
TOOL.ClientConVar[ "camber" ] = 0
TOOL.ClientConVar[ "offsetfront" ] = 0
TOOL.ClientConVar[ "offsetrear" ] = 0

if CLIENT then
	language.Add( "tool.simfphyswheeleditor.name", "Wheel Model Editor" )
	language.Add( "tool.simfphyswheeleditor.desc", "Changes the wheels for simfphys vehicles with CustomWheels Enabled" )
	language.Add( "tool.simfphyswheeleditor.0", "Left click apply wheel model. Reload to reset" )
	language.Add( "tool.simfphyswheeleditor.1", "Left click apply wheel model. Reload to reset" )
end

local function GetRight( ent, index, WheelPos )
	local Steer = ent:GetTransformedDirection()
	
	local Right = ent.Right
	
	if WheelPos.IsFrontWheel then
		Right = (IsValid( ent.SteerMaster ) and Steer.Right or ent.Right) * (WheelPos.IsRightWheel and 1 or -1)
	else
		Right = (IsValid( ent.SteerMaster ) and Steer.Right2 or ent.Right) * (WheelPos.IsRightWheel and 1 or -1)
	end
	
	return Right
end

local function SetWheelOffset( ent, offset_front, offset_rear )
	if not IsValid( ent ) then return end
	
	ent.WheelTool_Foffset = offset_front
	ent.WheelTool_Roffset = offset_rear
	
	if not istable( ent.Wheels ) or not istable( ent.GhostWheels ) then return end
	
	for i = 1, table.Count( ent.GhostWheels ) do
		local Wheel = ent.Wheels[ i ]
		local WheelModel = ent.GhostWheels[i]
		local WheelPos = ent:LogicWheelPos( i )
		
		if IsValid( Wheel ) and IsValid( WheelModel ) then
			local Pos = Wheel:GetPos()
			local Right = GetRight( ent, i, WheelPos )
			local offset = WheelPos.IsFrontWheel and offset_front or offset_rear
			
			WheelModel:SetParent( nil )
			
			local physObj = WheelModel:GetPhysicsObject()
			if IsValid( physObj ) then
				physObj:EnableMotion( false )
			end
			
			WheelModel:SetPos( Pos + Right * offset )
			WheelModel:SetParent( Wheel )
		end
	end
end

local function ApplyWheel(ply, ent, data)

	ent.CustomWheelAngleOffset = data[2]
	ent.CustomWheelAngleOffset_R = data[4]
	
	timer.Simple( 0.05, function()
		if not IsValid( ent ) then return end
		
		for i = 1, table.Count( ent.GhostWheels ) do
			local Wheel = ent.GhostWheels[i]
			
			if IsValid( Wheel ) then
				local isfrontwheel = (i == 1 or i == 2)
				local swap_y = (i == 2 or i == 4 or i == 6)
				
				local angleoffset = isfrontwheel and ent.CustomWheelAngleOffset or ent.CustomWheelAngleOffset_R
				
				local model = isfrontwheel and data[1] or data[3]
				
				local fAng = ent:LocalToWorldAngles( ent.VehicleData.LocalAngForward )
				local rAng = ent:LocalToWorldAngles( ent.VehicleData.LocalAngRight )
				
				local Forward = fAng:Forward() 
				local Right = swap_y and -rAng:Forward() or rAng:Forward()
				local Up = ent:GetUp()
				
				local Camber = data[5] or 0
				
				local ghostAng = Right:Angle()
				local mirAng = swap_y and 1 or -1
				ghostAng:RotateAroundAxis(Forward,angleoffset.p * mirAng)
				ghostAng:RotateAroundAxis(Right,angleoffset.r * mirAng)
				ghostAng:RotateAroundAxis(Up,-angleoffset.y)
				
				ghostAng:RotateAroundAxis(Forward, Camber * mirAng)
				
				Wheel:SetModelScale( 1 )
				Wheel:SetModel( model )
				Wheel:SetAngles( ghostAng )
				
				timer.Simple( 0.05, function()
					if not IsValid( Wheel ) or not IsValid( ent ) then return end
					local wheelsize = Wheel:OBBMaxs() - Wheel:OBBMins()
					local radius = isfrontwheel and ent.FrontWheelRadius or ent.RearWheelRadius
					local size = (radius * 2) / math.max(wheelsize.x,wheelsize.y,wheelsize.z)
					
					Wheel:SetModelScale( size )
				end)
			end
		end
	end)
end

local function ValidateModel( model )
	local v_list = list.Get( "simfphys_vehicles" )
	for listname, _ in pairs( v_list ) do
		if v_list[listname].Members.CustomWheels then
			local FrontWheel = v_list[listname].Members.CustomWheelModel
			local RearWheel = v_list[listname].Members.CustomWheelModel_R
			
			if FrontWheel then 
				FrontWheel = string.lower( FrontWheel )
			end
			
			if RearWheel then 
				RearWheel = string.lower( RearWheel )
			end
			
			if model == FrontWheel or model == RearWheel then
				return true
			end
		end
	end
	
	local list = list.Get( "simfphys_Wheels" )[model]

	if list then 
		return true
	end

	return false
end

local function GetAngleFromSpawnlist( model )
	if not model then print("invalid model") return Angle(0,0,0) end
	
	model = string.lower( model )
	
	local v_list = list.Get( "simfphys_vehicles" )
	for listname, _ in pairs( v_list ) do
		if v_list[listname].Members.CustomWheels then
			local FrontWheel = v_list[listname].Members.CustomWheelModel
			local RearWheel = v_list[listname].Members.CustomWheelModel_R
			
			if FrontWheel then 
				FrontWheel = string.lower( FrontWheel )
			end
			
			if RearWheel then 
				RearWheel = string.lower( RearWheel )
			end
			
			if model == FrontWheel or model == RearWheel then
				local Angleoffset = v_list[listname].Members.CustomWheelAngleOffset
				if Angleoffset then
					return Angleoffset
				end
			end
		end
	end
	
	local list = list.Get( "simfphys_Wheels" )[model]
	local output = list and list.Angle or Angle(0,0,0)
	
	return output
end

function TOOL:LeftClick( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	if SERVER then
		if not ent.CustomWheels then return end
	
		local PhysObj = ent:GetPhysicsObject()
		if not IsValid( PhysObj ) then return end
		
		local freezeWhenDone = PhysObj:IsMotionEnabled()
		local freezeWheels = {}
		PhysObj:EnableMotion( false )
		ent:SetNotSolid( true )
		
		local ResetPos = ent:GetPos()
		local ResetAng = ent:GetAngles()
		
		ent:SetPos( ResetPos + Vector(0,0,30) )
		ent:SetAngles( Angle(0,ResetAng.y,0) )
		
		for i = 1, table.Count( ent.Wheels ) do
			local Wheel = ent.Wheels[ i ]
			if IsValid( Wheel ) then
				local wPObj = Wheel:GetPhysicsObject()
				
				if IsValid( wPObj ) then
					freezeWheels[ i ] = {}
					freezeWheels[ i ].dofreeze = wPObj:IsMotionEnabled()
					freezeWheels[ i ].pos = Wheel:GetPos()
					freezeWheels[ i ].ang = Wheel:GetAngles()
					Wheel:SetNotSolid( true )
					wPObj:EnableMotion( true ) 
					wPObj:Wake() 
				end
			end
		end
		
		timer.Simple( 0.25, function()
			if not IsValid( ent ) then return end
			if not IsValid( self ) then return end
			
			local front_model = self:GetClientInfo("frontwheelmodel")
			local front_angle = GetAngleFromSpawnlist(front_model)
			
			local sameasfront = self:GetClientInfo("sameasfront") == "1"
			local camber = self:GetClientInfo("camber")
			
			local rear_model = sameasfront and front_model or self:GetClientInfo("rearwheelmodel")
			local rear_angle = GetAngleFromSpawnlist(rear_model)
			
			local front_offset = self:GetClientInfo("offsetfront")
			local rear_offset = self:GetClientInfo("offsetrear")

			if not front_model or not rear_model or not front_angle or not rear_angle then print("wtf bro how did you do this") return false end

			if not ValidateModel( front_model ) or not ValidateModel( rear_model ) then 
				local ply = self:GetOwner()
				ply:PrintMessage( HUD_PRINTTALK, "selected wheel does not exist on the server")

				return false
			end
			
			if ent.CustomWheels then
				if ent.GhostWheels then
					ent:SteerVehicle( 0 )
					
					for i = 1, table.Count( ent.Wheels ) do
						local Wheel = ent.Wheels[ i ]
						if IsValid( Wheel ) then
							local physobj = Wheel:GetPhysicsObject()
							physobj:EnableMotion( true ) 
							physobj:Wake() 
						end
					end
					
					ent.Camber = camber
					ApplyWheel(self:GetOwner(), ent, {front_model,front_angle,rear_model,rear_angle,camber})
					SetWheelOffset( ent, front_offset, rear_offset )
				end
			end
			
			timer.Simple( 0.25, function()
				if not IsValid( ent ) then return end
				if not IsValid( PhysObj ) then return end
				
				PhysObj:EnableMotion( freezeWhenDone )
				ent:SetNotSolid( false )
				ent:SetPos( ResetPos )
				ent:SetAngles( ResetAng )
		
				for i = 1, table.Count( freezeWheels ) do
					local Wheel = ent.Wheels[ i ]
					if IsValid( Wheel ) then
						local wPObj = Wheel:GetPhysicsObject()
						
						Wheel:SetNotSolid( false )
						
						if IsValid( wPObj ) then
							wPObj:EnableMotion( freezeWheels[i].dofreeze ) 
						end
						
						Wheel:SetPos( freezeWheels[ i ].pos )
						Wheel:SetAngles( freezeWheels[ i ].ang )
					end
				end
			end)
		end)
	end
	return true
end

function TOOL:RightClick( trace )
	return false
end

function TOOL:Reload( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	if SERVER then
		local PhysObj = ent:GetPhysicsObject()
		if not IsValid( PhysObj ) then return end
		
		local freezeWhenDone = PhysObj:IsMotionEnabled()
		local freezeWheels = {}
		PhysObj:EnableMotion( false )
		ent:SetNotSolid( true )
		
		local ResetPos = ent:GetPos()
		local ResetAng = ent:GetAngles()
		
		ent:SetPos( ResetPos + Vector(0,0,30) )
		ent:SetAngles( Angle(0,ResetAng.y,0) )
		
		for i = 1, table.Count( ent.Wheels ) do
			local Wheel = ent.Wheels[ i ]
			if IsValid( Wheel ) then
				local wPObj = Wheel:GetPhysicsObject()
				
				if IsValid( wPObj ) then
					freezeWheels[ i ] = {}
					freezeWheels[ i ].dofreeze = wPObj:IsMotionEnabled()
					freezeWheels[ i ].pos = Wheel:GetPos()
					freezeWheels[ i ].ang = Wheel:GetAngles()
					Wheel:SetNotSolid( true )
					wPObj:EnableMotion( true ) 
					wPObj:Wake() 
				end
			end
		end
		
		timer.Simple( 0.25, function()
			if not IsValid( ent ) then return end
			
			local vname = ent:GetSpawn_List()
			local VehicleList = list.Get( "simfphys_vehicles" )[vname]

			if ent.CustomWheels then
				if ent.GhostWheels then
					ent:SteerVehicle( 0 )
					
					for i = 1, table.Count( ent.Wheels ) do
						local Wheel = ent.Wheels[ i ]
						if IsValid( Wheel ) then
							local physobj = Wheel:GetPhysicsObject()
							physobj:EnableMotion( true ) 
							physobj:Wake() 
						end
					end
					
					local front_model = VehicleList.Members.CustomWheelModel
					local front_angle = VehicleList.Members.CustomWheelAngleOffset
					local rear_model = VehicleList.Members.CustomWheelModel_R and VehicleList.Members.CustomWheelModel_R or front_model
					local rear_angle = VehicleList.Members.CustomWheelAngleOffset
					
					ApplyWheel(self:GetOwner(), ent, {front_model,front_angle,rear_model,rear_angle})
					SetWheelOffset( ent, 0, 0 )
				end
			end
			
			timer.Simple( 0.25, function()
				if not IsValid( ent ) then return end
				if not IsValid( PhysObj ) then return end
				
				PhysObj:EnableMotion( freezeWhenDone )
				ent:SetNotSolid( false )
				ent:SetPos( ResetPos )
				ent:SetAngles( ResetAng )
		
				for i = 1, table.Count( freezeWheels ) do
					local Wheel = ent.Wheels[ i ]
					if IsValid( Wheel ) then
						local wPObj = Wheel:GetPhysicsObject()
						
						Wheel:SetNotSolid( false )
						
						if IsValid( wPObj ) then
							wPObj:EnableMotion( freezeWheels[i].dofreeze ) 
						end
						
						Wheel:SetPos( freezeWheels[ i ].pos )
						Wheel:SetAngles( freezeWheels[ i ].ang )
					end
				end
			end)
		end)
	end
	
	return true
end

local ConVarsDefault = TOOL:BuildConVarList()
function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "#tool.simfphyswheeleditor.name", Description = "#tool.simfphyswheeleditor.desc" } )
	panel:AddControl( "ComboBox", { MenuButton = 1, Folder = "wheeleditor", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )
	
	panel:AddControl( "Slider", 
	{
		Label 	= "Camber",
		Type 	= "Float",
		Min 	= "-60",
		Max 	= "60",
		Command = "simfphyswheeleditor_camber"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Offset (Front)",
		Type 	= "Float",
		Min 	= "-50",
		Max 	= "50",
		Command = "simfphyswheeleditor_offsetfront"
	})
	panel:AddControl( "Slider", 
	{
		Label 	= "Offset (Rear)",
		Type 	= "Float",
		Min 	= "-50",
		Max 	= "50",
		Command = "simfphyswheeleditor_offsetrear"
	})
	
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "Front Wheel Model" } )
	panel:AddControl( "PropSelect", { Label = "", ConVar = "simfphyswheeleditor_frontwheelmodel", Height = 0, Models = list.Get( "simfphys_Wheels" ) } )
	panel:AddControl( "Label",  { Text = "" } )
	panel:AddControl( "Label",  { Text = "Rear Wheel Model" } )
	panel:AddControl( "Checkbox", 
	{
		Label 	= "same as front",
		Command = "simfphyswheeleditor_sameasfront",
	})	
	panel:AddControl( "PropSelect", { Label = "", ConVar = "simfphyswheeleditor_rearwheelmodel", Height = 0, Models = list.Get( "simfphys_Wheels" ) } )

end

list.Set( "simfphys_Wheels", "models/props_phx/wheels/magnetic_large.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/smallwheel.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/normal_tire.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/wheels/breakable_tire.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/wheels/drugster_front.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/wheels/drugster_back.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/wheels/moped_tire.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/wheels/trucktire.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/wheels/trucktire2.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/wheels/747wheel.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/props_phx/wheels/monster_truck.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/bmw.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/wheel_2.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/rim_1.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/wheel_extruded_48.mdl", {Angle = Angle(-90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/wheel_race.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/tractors.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/wheel_rounded_36.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/wheel_rounded_36s.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/wheel_rugged_24.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/wheel_rugged_24w.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/wheel_spike_24.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/mechanics/wheels/wheel_spike_48.mdl", {Angle = Angle(90,0,0)} )
list.Set( "simfphys_Wheels", "models/xeon133/racewheel/race-wheel-30.mdl", {Angle = Angle(0,-90,0)} )
list.Set( "simfphys_Wheels", "models/xeon133/racewheelskinny/race-wheel-30_s.mdl", {Angle = Angle(0,-90,0)} )
list.Set( "simfphys_Wheels", "models/nateswheel/nateswheel.mdl", {Angle = Angle(0,180,0)} )
list.Set( "simfphys_Wheels", "models/xqm/airplanewheel1medium.mdl", {Angle = Angle(0,180,0)} )
list.Set( "simfphys_Wheels", "models/xeon133/offroad/off-road-30.mdl", {Angle = Angle(0,180,0)} )

local LW_Wheels = {
	"models/lonewolfie/wheels/wheel_2015chargerpolice.mdl",
	"models/lonewolfie/wheels/wheel_ametorqthrust.mdl",
	"models/lonewolfie/wheels/wheel_ametorqthrust_eaglest.mdl",
	"models/lonewolfie/wheels/wheel_com_rt_gold.mdl",
	"models/lonewolfie/wheels/wheel_com_th2.mdl",
	"models/lonewolfie/wheels/wheel_cucv_big.mdl",
	"models/lonewolfie/wheels/wheel_cucv_small.mdl",
	"models/lonewolfie/wheels/wheel_fiat595.mdl",
	"models/lonewolfie/wheels/wheel_ham_edition_race.mdl",
	"models/lonewolfie/wheels/wheel_impalapolice.mdl",
	"models/lonewolfie/wheels/wheel_laxaniltc701.mdl",
	"models/lonewolfie/wheels/wheel_miktometdrag_big.mdl",
	"models/lonewolfie/wheels/wheel_miktometdrag_highprofile.mdl",
	"models/lonewolfie/wheels/wheel_miktometdrag_lowprofile.mdl",
	"models/lonewolfie/wheels/wheel_monstertruck.mdl",
	"models/lonewolfie/wheels/wheel_oet_type_rxx.mdl",
	"models/lonewolfie/wheels/wheel_speedline22b.mdl",
	"models/lonewolfie/wheels/wheel_suvpolice.mdl",
	"models/lonewolfie/wheels/wheel_volkte37.mdl",
	"models/lonewolfie/wheels/wheel_wed_sa_97.mdl",
	"models/lonewolfie/wheels/wheel_welddrag.mdl",
	"models/lonewolfie/wheels/wheel_welddrag_big.mdl"
}

for i = 1, table.Count( LW_Wheels ) do
	if file.Exists( LW_Wheels[i], "GAME" ) then
		list.Set( "simfphys_Wheels", LW_Wheels[i], {Angle = Angle(0,90,0)} )
	end
end

timer.Simple( 0.1, function()
	local v_list = list.Get( "simfphys_vehicles" )
	for listname, _ in pairs( v_list ) do
		if (v_list[listname].Members.CustomWheels) then
			local FrontWheel = v_list[listname].Members.CustomWheelModel
			local RearWheel = v_list[listname].Members.CustomWheelModel_R
			if (FrontWheel) then
				if (file.Exists( FrontWheel, "GAME" )) then 
					list.Set( "simfphys_Wheels", FrontWheel, {} )
				end
			end
			if (RearWheel) then
				if (file.Exists( RearWheel, "GAME" )) then 
					list.Set( "simfphys_Wheels", RearWheel, {} )
				end
			end
		end
	end
end)