
TOOL.Category		= "simfphys"
TOOL.Name			= "#Transmission Editor"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "numgears" ] = 5
TOOL.ClientConVar[ "gear_r" ] = -0.1
TOOL.ClientConVar[ "gear_1" ] = 0.1
TOOL.ClientConVar[ "gear_2" ] = 0.2
TOOL.ClientConVar[ "gear_3" ] = 0.3
TOOL.ClientConVar[ "gear_4" ] = 0.4
TOOL.ClientConVar[ "gear_5" ] = 0.5
TOOL.ClientConVar[ "gear_6" ] = 0.6
TOOL.ClientConVar[ "gear_7" ] = 0.7
TOOL.ClientConVar[ "gear_8" ] = 0.8
TOOL.ClientConVar[ "gear_9" ] = 0.9
TOOL.ClientConVar[ "gear_10" ] = 1
TOOL.ClientConVar[ "gear_11" ] = 1.1
TOOL.ClientConVar[ "gear_12" ] = 1.2
TOOL.ClientConVar[ "gear_diff" ] = 0.5
TOOL.ClientConVar[ "forcetype" ] = "0"
TOOL.ClientConVar[ "type" ] = 2

local function SetGears( ply, ent, gears)
	if ( SERVER ) then
		ent.Gears = gears
		duplicator.StoreEntityModifier( ent, "gearmod", gears )
	end
end
duplicator.RegisterEntityModifier( "gearmod", SetGears )

if CLIENT then
	language.Add( "tool.simfphysgeareditor.name", "Transmission Editor" )
	language.Add( "tool.simfphysgeareditor.desc", "A tool used to edit gear ratios on simfphys vehicles" )
	language.Add( "tool.simfphysgeareditor.0", "Left click apply settings. Right click copy settings. Reload to reset" )
	language.Add( "tool.simfphysgeareditor.1", "Left click apply settings. Right click copy settings. Reload to reset" )
end

function TOOL:LeftClick( trace )
	local ent = trace.Entity
	
	if not simfphys.IsCar( ent ) then return false end
	
	if (SERVER) then
		local vname = ent:GetSpawn_List()
		local VehicleList = list.Get( "simfphys_vehicles" )[vname]
		
		local gears = {math.Clamp(self:GetClientNumber( "gear_r" ), -5, -0.001),0}
		local gearCount = math.Clamp( self:GetClientNumber( "numgears" ), 1, 12 )
		for i = 1, gearCount do
			local index = i + 2
			gears[index] = math.Clamp( self:GetClientNumber( "gear_"..i ), 0.001, 5)
		end
		
		SetGears(self:GetOwner(), ent, gears )
		ent:SetDifferentialGear( math.Clamp( self:GetClientNumber( "gear_diff" ),0.2,6 ) )
		
		if tobool( self:GetClientInfo( "forcetype" ) ) then
			ent.ForceTransmission =  math.Clamp( self:GetClientNumber( "type" ), 1, 2 )
		else
			ent.ForceTransmission = nil
		end
	end
	
	return true
end


function TOOL:RightClick( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
	
	if not simfphys.IsCar( ent ) then return false end
	
	if (SERVER) then
		local vname = ent:GetSpawn_List()
		local VehicleList = list.Get( "simfphys_vehicles" )[vname]
		
		local gears = ent.Gears
		local diffgear = ent:GetDifferentialGear()
		local num = table.Count( gears ) - 2
		
		for i = 3, 13 do
			ply:ConCommand( "simfphysgeareditor_gear_"..(i - 2).." "..(gears[i] or 0.001))
		end
		ply:ConCommand( "simfphysgeareditor_gear_r "..gears[1])
		ply:ConCommand( "simfphysgeareditor_numgears "..num)
		ply:ConCommand( "simfphysgeareditor_gear_diff "..diffgear)
		
		local forcetype = isnumber( ent.ForceTransmission )
		
		ply:ConCommand( "simfphysgeareditor_forcetype "..tostring(forcetype and 1 or 0) )
		
		if forcetype then
			ply:ConCommand( "simfphysgeareditor_type "..ent.ForceTransmission)
		end
	end
	
	return true
end

function TOOL:Reload( trace )
	local ent = trace.Entity
	local ply = self:GetOwner()
	
	if not simfphys.IsCar( ent ) then return false end
	
	if (SERVER) then
		local vname = ent:GetSpawn_List()
		local VehicleList = list.Get( "simfphys_vehicles" )[vname]
		
		SetGears(self:GetOwner(), ent, VehicleList.Members.Gears )
		ent:SetDifferentialGear( VehicleList.Members.DifferentialGear )
		
		ent.ForceTransmission = VehicleList.Members.ForceTransmission
	end
	
	return true
end

local ConVarsDefault = TOOL:BuildConVarList()
function TOOL.BuildCPanel( panel )
	panel:AddControl( "Header", { Text = "#tool.simfphysgeareditor.name", Description = "#tool.simfphysgeareditor.desc" } )
	panel:AddControl( "ComboBox", { MenuButton = 1, Folder = "transeditor", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )
	
	local Frame = vgui.Create( "DPanel", panel )
	Frame:SetPos( 10, 130 )
	Frame:SetSize( 275, 700 )
	Frame.Paint = function( self, w, h )
	end
	
	local Label = vgui.Create( "DLabel", panel )
	Label:SetPos( 15, 80 )
	Label:SetSize( 280, 40 )
	Label:SetText( "Amount Gears" )
	Label:SetTextColor( Color(0,0,0,255) )
	
	local n_slider = vgui.Create( "DNumSlider", panel)
	n_slider:SetPos( 15, 80 )
	n_slider:SetSize( 280, 40 )
	n_slider:SetMin( 1 )
	n_slider:SetMax( 12 )
	n_slider:SetDecimals( 0 )
	n_slider:SetConVar( "simfphysgeareditor_numgears" )
	n_slider.OnValueChanged = function( self, amount )
		Frame:Clear() 
		
		local value = math.Round( amount, 0 )
		local yy = 0
		
		for i = 1, value do
			local Label = vgui.Create( "DLabel", Frame )
			Label:SetPos( 5, yy )
			Label:SetSize( 275, 40 )
			Label:SetText( "Gear "..i )
			Label:SetTextColor( Color(0,0,0,255) )
		
			local g_slider = vgui.Create( "DNumSlider", Frame)
			g_slider:SetPos( 5, yy )
			g_slider:SetSize( 275, 40 )
			g_slider:SetMin( 0.001 )
			g_slider:SetMax( 5 )
			g_slider:SetDecimals( 3 )
			g_slider:SetConVar( "simfphysgeareditor_gear_"..i )
			
			yy = yy + 25
		end
		
		yy = yy + 25
		
		local Label = vgui.Create( "DLabel", Frame )
		Label:SetPos( 5, yy )
		Label:SetSize( 275, 40 )
		Label:SetText( "Reverse" )
		Label:SetTextColor( Color(0,0,0,255) )
		local g_slider = vgui.Create( "DNumSlider", Frame)
		g_slider:SetPos( 5, yy )
		g_slider:SetSize( 275, 40 )
		g_slider:SetMin( -5 )
		g_slider:SetMax( -0.001 )
		g_slider:SetDecimals( 3 )
		g_slider:SetConVar( "simfphysgeareditor_gear_r" )
		
		yy = yy + 50
		
		local Label = vgui.Create( "DLabel", Frame )
		Label:SetPos( 5, yy )
		Label:SetSize( 275, 40 )
		Label:SetText( "Final Gear (Differential)" )
		Label:SetTextColor( Color(0,0,0,255) )
		local g_slider = vgui.Create( "DNumSlider", Frame)
		g_slider:SetPos( 5, yy )
		g_slider:SetSize( 275, 40 )
		g_slider:SetMin( 0.001 )
		g_slider:SetMax( 5 )
		g_slider:SetDecimals( 3 )
		g_slider:SetConVar( "simfphysgeareditor_gear_diff" )
		
		yy = yy + 50
		
		local Label = vgui.Create( "DLabel", Frame )
		Label:SetPos( 30, yy )
		Label:SetSize( 280, 40 )
		Label:SetText( "Force Transmission Type" )
		Label:SetTextColor( Color(0,0,0,255) )
		
		local CheckBox = vgui.Create( "DCheckBoxLabel", Frame )
		CheckBox:SetPos( 5,yy )
		CheckBox:SetText( "" )
		CheckBox:SetConVar( "simfphysgeareditor_forcetype" )
		CheckBox:SetSize( 280, 40 )
		
		yy = yy + 30
		
		local Label = vgui.Create( "DLabel", Frame )
		Label:SetPos( 5, yy )
		Label:SetSize( 275, 40 )
		Label:SetText( "Type \n1 = Automatic\n2 = Manual" )
		Label:SetTextColor( Color(0,0,0,255) )
		local g_slider = vgui.Create( "DNumSlider", Frame)
		g_slider:SetPos( 5, yy )
		g_slider:SetSize( 275, 40 )
		g_slider:SetMin( 1 )
		g_slider:SetMax( 2 )
		g_slider:SetDecimals( 0 )
		g_slider:SetConVar( "simfphysgeareditor_type" )
		
	end
end
