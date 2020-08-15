local auto = CreateClientConVar( "cl_simfphys_auto", 1 , true, true )
local sport = CreateClientConVar( "cl_simfphys_sport", 0 , true, true )
local sanic = CreateClientConVar( "cl_simfphys_sanic", 0 , true, true )
local ctenable = CreateClientConVar( "cl_simfphys_ctenable", 1 , true, true )
local ctmul = CreateClientConVar( "cl_simfphys_ctmul", 0.7 , true, true )
local ctang = CreateClientConVar( "cl_simfphys_ctang", 15 , true, true )
local hud = CreateClientConVar( "cl_simfphys_hud", "1", true, false )
local alt_hud = CreateClientConVar( "cl_simfphys_althud", "1", true, false )
local alt_hud_arc = CreateClientConVar( "cl_simfphys_althud_arcs", "0", true, false )

local hud_x = CreateClientConVar( "cl_simfphys_hud_offset_x", "0", true, false )
local hud_y = CreateClientConVar( "cl_simfphys_hud_offset_y", "0", true, false )
local hud_mph = CreateClientConVar( "cl_simfphys_hudmph", "0", true, false )
local hud_mpg = CreateClientConVar( "cl_simfphys_hudmpg", "0", true, false )
local hud_realspeed = CreateClientConVar( "cl_simfphys_hudrealspeed", "0", true, false )
local autostart = CreateClientConVar( "cl_simfphys_autostart", "1", true, true )

local mousesteer = CreateClientConVar( "cl_simfphys_mousesteer", "0", true, true )
local mssensitivity = CreateClientConVar( "cl_simfphys_ms_sensitivity", "1", true, true )
local msretract = CreateClientConVar( "cl_simfphys_ms_return", "1", true, true )
local msdeadzone = CreateClientConVar( "cl_simfphys_ms_deadzone", "3", true, true )
local msexponent = CreateClientConVar( "cl_simfphys_ms_exponent", "1.5", true, true )
local mslockpitch = CreateClientConVar( "cl_simfphys_ms_lockpitch", "0", true, true )
local mshud = CreateClientConVar( "cl_simfphys_ms_hud", "1", true, false )
local k_msfreelook = CreateClientConVar( "cl_simfphys_ms_keyfreelook", KEY_Y, true, true )
local mslockedpitch = CreateClientConVar( "cl_simfphys_ms_lockedpitch", "5", true, true )

local overwrite = CreateClientConVar( "cl_simfphys_overwrite", 0, true, true )
local smoothsteer = CreateClientConVar( "cl_simfphys_smoothsteer", 0, true, true )
local steerspeed = CreateClientConVar( "cl_simfphys_steerspeed", 8, true, true )
local faststeerang = CreateClientConVar( "cl_simfphys_steerangfast", 10, true, true )
local fadespeed = CreateClientConVar( "cl_simfphys_fadespeed", 535, true, true )

CreateClientConVar( "cl_simfphys_hidesprites", "0", true, false )
CreateClientConVar( "cl_simfphys_frontlamps", "1", true, false )
CreateClientConVar( "cl_simfphys_rearlamps", "1", true, false )
CreateClientConVar( "cl_simfphys_shadows", "0", true, false )

local k_fwd = CreateClientConVar( "cl_simfphys_keyforward", KEY_W , true, true )
local k_bck = CreateClientConVar( "cl_simfphys_keyreverse", KEY_S , true, true )
local k_left = CreateClientConVar( "cl_simfphys_keyleft", KEY_A , true, true )
local k_right = CreateClientConVar( "cl_simfphys_keyright", KEY_D , true, true )
local k_wot = CreateClientConVar( "cl_simfphys_keywot", KEY_LSHIFT , true, true )
local k_clth = CreateClientConVar( "cl_simfphys_keyclutch", KEY_LALT , true, true )
local k_gup = CreateClientConVar( "cl_simfphys_keygearup", MOUSE_LEFT , true, true )
local k_gdn = CreateClientConVar( "cl_simfphys_keygeardown", MOUSE_RIGHT , true, true )
local k_hbrk = CreateClientConVar( "cl_simfphys_keyhandbrake", KEY_SPACE , true, true )
local k_cc = CreateClientConVar( "cl_simfphys_cruisecontrol", KEY_R, true, true )
local k_lgts = CreateClientConVar( "cl_simfphys_lights", KEY_F , true, true )
local k_flgts = CreateClientConVar( "cl_simfphys_foglights", KEY_V , true, true )
local k_horn = CreateClientConVar( "cl_simfphys_keyhorn", KEY_H , true, true )
local k_engine = CreateClientConVar( "cl_simfphys_keyengine", KEY_I , true, true )
local k_afwd = CreateClientConVar( "cl_simfphys_key_air_forward", KEY_PAD_8, true, true )
local k_abck = CreateClientConVar( "cl_simfphys_key_air_reverse", KEY_PAD_2, true, true )
local k_aleft = CreateClientConVar( "cl_simfphys_key_air_left", k_left:GetInt(), true, true )
local k_aright = CreateClientConVar( "cl_simfphys_key_air_right", k_right:GetInt(), true, true )
local k_lock = CreateClientConVar( "cl_simfphys_key_lock", KEY_NONE, true, true )
local k_turnmenu = CreateClientConVar( "cl_simfphys_key_turnmenu", KEY_COMMA, true, true )

local k_list = {
	{k_fwd,KEY_W,"Forward"},
	{k_bck,KEY_S,"Reverse"},
	{k_left,KEY_A,"Steer Left"},
	{k_right,KEY_D,"Steer Right"},
	{k_wot,KEY_LSHIFT,"Throttle Modifier"},
	{k_clth,KEY_LALT,"Clutch"},
	{k_gup,MOUSE_LEFT,"Gear Up"},
	{k_gdn,MOUSE_RIGHT,"Gear Down"},
	{k_hbrk,KEY_SPACE,"Handbrake"},
	{k_cc,KEY_R,"Cruise Control"},
	{k_lgts,KEY_F,"Lights"},
	{k_flgts,KEY_V,"Foglights"},
	{k_horn,KEY_H,"Horn / Siren"},
	{k_engine,KEY_I,"Start/Stop Engine"},
	{k_afwd,KEY_PAD_8,"Tilt Backward"},
	{k_abck,KEY_PAD_2,"Tilt Forward"},
	{k_aleft,KEY_A,"Tilt Left"},
	{k_aright,KEY_D,"Tilt Right"},
	{k_lock,KEY_NONE ,"Lock / Unlock"},
	{k_turnmenu, KEY_COMMA, "Turnsignals"},
}

local function simplebinder( x, y, tbl, num, parent)
	local sizex = 500
	local sizey = 40
	
	local kentry = tbl[num]
	local key = kentry[1]
	local setdefault = key:GetInt()
	
	local Shape = vgui.Create( "DShape", parent)
	Shape:SetType( "Rect" )
	Shape:SetPos( x, y )
	Shape:SetSize( 175, sizey )
	Shape:SetColor( Color( 0, 0, 0, 255 ) )
	
	local Shape = vgui.Create( "DShape", parent)
	Shape:SetType( "Rect" )
	Shape:SetPos( x + 1, y + 1 )
	Shape:SetSize( 173 - 2, sizey - 2 )
	Shape:SetColor( Color( 241, 241, 241, 255 ) )

	local binder = vgui.Create( "DBinder", parent)
	binder:SetPos( 175 + x, y )
	binder:SetSize( 500 - 175, sizey )
	binder:SetValue( setdefault )
	function binder:SetSelectedNumber( num )
		self.m_iSelectedNumber = num
		self:ConVarChanged( num ) 
		self:UpdateText() 
		self:OnChange( num ) 
		key:SetInt( num )
	end
	
	local TextLabel = vgui.Create( "DPanel", parent)
	TextLabel:SetPos( x, y )
	TextLabel:SetSize( 175, sizey )
	TextLabel.Paint = function()
		draw.SimpleText( kentry[3], "DSimfphysFont", 175 * 0.5, sizey * 0.5, Color( 100, 100, 100, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	end
	return binder
end

local function simplebinder_old( x, y, tbl, num, parent, sizex, sizey)
	local kentry = tbl[num]
	local key = kentry[1]
	local setdefault = key:GetInt()
	
	local sizex = sizex or 400
	local sizey = sizey or 40
	
	local Shape = vgui.Create( "DShape", parent)
	Shape:SetType( "Rect" )
	Shape:SetPos( x, y )
	Shape:SetSize( sizex, sizey )
	Shape:SetColor( Color( 0, 0, 0, 255 ) )
	
	local Shape = vgui.Create( "DShape", parent)
	Shape:SetType( "Rect" )
	Shape:SetPos( x + 1, y + 1 )
	Shape:SetSize( sizex - 2, sizey - 2 )
	Shape:SetColor( Color( 241, 241, 241, 255 ) )

	local binder = vgui.Create( "DBinder", parent)
	binder:SetPos( sizex * 0.5 + x, y )
	binder:SetSize( sizex * 0.5, sizey )
	binder:SetValue( setdefault )
	function binder:SetSelectedNumber( num )
		self.m_iSelectedNumber = num
		self:ConVarChanged( num ) 
		self:UpdateText() 
		self:OnChange( num ) 
		
		key:SetInt( num )
	end
	
	local TextLabel = vgui.Create( "DPanel", parent)
	TextLabel:SetPos( x, y )
	TextLabel:SetSize( sizex * 0.5, sizey )
	TextLabel.Paint = function()
		draw.SimpleText( kentry[3], "DSimfphysFont", sizex * 0.25, 20, Color( 100, 100, 100, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER ) 
	end
	return binder
end

local function createcheckbox(x, y, label, command, parent, default)
	local boxy = vgui.Create( "DCheckBoxLabel", parent)
	boxy:SetParent( parent )
	boxy:SetPos( x, y )
	boxy:SetText( label )
	boxy:SetConVar( command )
	boxy:SetValue( default )
	boxy:SizeToContents()
	return boxy
end

local function createslider(x, y, sizex, sizey, label, command, parent,min,max,default)
	local slider = vgui.Create( "DNumSlider", parent)
	slider:SetPos( x, y )
	slider:SetSize( sizex, sizey )
	slider:SetText( label )
	slider:SetMin( min )
	slider:SetMax( max )
	slider:SetDecimals( 2 )
	slider:SetConVar( command )
	slider:SetValue( default )
	return slider
end

local function buildclientsettingsmenu( self )
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 20 )
	Shape:SetSize( 350, 180 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	createcheckbox(25,25,"Show Hud","cl_simfphys_hud",self.PropPanel,hud:GetInt())
	createcheckbox(210,25,"Racing Hud","cl_simfphys_althud",self.PropPanel,alt_hud:GetInt())
	createcheckbox(210,45,"HQ Racing Hud\n(will cause problems\nwith multicore!)","cl_simfphys_althud_arcs",self.PropPanel,alt_hud_arc:GetInt())
	createcheckbox(25,45,"MPH instead of KMH","cl_simfphys_hudmph",self.PropPanel,hud_mph:GetInt())
	createcheckbox(25,65,"Speed relative to \nplayersize instead \nworldsize","cl_simfphys_hudrealspeed",self.PropPanel,hud_realspeed:GetInt())
	createcheckbox(25,110,"Fuel consumption \nin MPG instead \nof L/100KM","cl_simfphys_hudmpg",self.PropPanel,hud_mpg:GetInt())
	createslider(30,155,345,20,"Hud offset X","cl_simfphys_hud_offset_x",self.PropPanel,-1,1,hud_x:GetFloat())
	createslider(30,175,345,20,"Hud offset Y","cl_simfphys_hud_offset_y",self.PropPanel,-1,1,hud_y:GetFloat())
	
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 210 )
	Shape:SetSize( 350, 85 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	createcheckbox(25,215,"Hide Sprites","cl_simfphys_hidesprites",self.PropPanel,0)
	createcheckbox(25,235,"Front Projected Textures","cl_simfphys_frontlamps",self.PropPanel,0)
	createcheckbox(25,255,"Rear Projected Textures","cl_simfphys_rearlamps",self.PropPanel,0)
	createcheckbox(25,275,"Enable Shadows","cl_simfphys_shadows",self.PropPanel,0)
	
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 305 )
	Shape:SetSize( 350, 85 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	createcheckbox(25,310,"Always Fullthrottle","cl_simfphys_sanic",self.PropPanel,sanic:GetInt())
	createcheckbox(25,330,"Engine Auto Start/Stop","cl_simfphys_autostart",self.PropPanel,autostart:GetInt())
	createcheckbox(25,350,"Automatic Transmission","cl_simfphys_auto",self.PropPanel,auto:GetInt())
	createcheckbox(25,370,"Automatic Sportmode (late up and downshifts)","cl_simfphys_sport",self.PropPanel,sport:GetInt())
	
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 400 )
	Shape:SetSize( 350, 115 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	
	local ctitem_1 = createcheckbox(25,405,"Enable Countersteer","cl_simfphys_ctenable",self.PropPanel,ctenable:GetInt())
	local ctitem_2 = createslider(30,425,345,40,"Countersteer Mul","cl_simfphys_ctmul",self.PropPanel,0.1,2,ctmul:GetFloat())
	local ctitem_3 = createslider(30,445,345,40,"Countersteer MaxAng","cl_simfphys_ctang",self.PropPanel,1,90,ctang:GetFloat())
	
	local Reset = vgui.Create( "DButton" )
	Reset:SetParent( self.PropPanel )
	Reset:SetText( "Reset" )	
	Reset:SetPos( 25, 485 )
	Reset:SetSize( 340, 25 )
	Reset.DoClick = function()
		ctitem_1:SetValue( 1 )
		ctitem_2:SetValue( 0.7 )
		ctitem_3:SetValue( 15 )
		ctenable:SetInt( 1 )
		ctmul:SetFloat( 0.7 )
		ctang:SetFloat( 15 )
	end
	
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 525 )
	Shape:SetSize( 350, 165 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	
	local st_item_1 = createcheckbox(25,530,"Use these settings\n(you need to re-enter the vehicle)","cl_simfphys_overwrite",self.PropPanel,overwrite:GetInt())
	local st_item_2 = createslider(30,550,345,40,"steer speed","cl_simfphys_steerspeed",self.PropPanel,1,16,steerspeed:GetFloat())
	local st_item_3 = createslider(30,570,345,40,"fast speed steer angle","cl_simfphys_steerangfast",self.PropPanel,0,90,faststeerang:GetFloat())
	local st_item_4 = createslider(30,595,345,40,"fade speed(units/seconds)\nfor fast speed steer angle","cl_simfphys_fadespeed",self.PropPanel,1,5000,fadespeed:GetFloat())
	local st_item_5 = createcheckbox(25,635,"extra smooth steering","cl_simfphys_smoothsteer",self.PropPanel,smoothsteer:GetInt())
	
	local Reset = vgui.Create( "DButton" )
	Reset:SetParent( self.PropPanel )
	Reset:SetText( "Reset" )	
	Reset:SetPos( 25, 660 )
	Reset:SetSize( 340, 25 )
	Reset.DoClick = function()
		st_item_1:SetValue( 0 )
		st_item_2:SetValue( 8 )
		st_item_3:SetValue( 10 )
		st_item_4:SetValue( 535 )
		st_item_5:SetValue( 0 )
		
		overwrite:SetInt( 0 )
		steerspeed:SetFloat( 8 )
		faststeerang:SetFloat( 10 )
		fadespeed:SetFloat( 535 )
		smoothsteer:SetInt( 0 )
	end
end


local function buildcontrolsmenu( self )
	local Background = vgui.Create( "DShape", self.PropPanel)
	Background:SetType( "Rect" )
	Background:SetPos( 20, 40 )
	Background:SetColor( Color( 0, 0, 0, 200 ) )
	
	local TextLabel = vgui.Create( "DPanel", self.PropPanel)
	TextLabel:SetPos( 0, 0 )
	TextLabel:SetSize( 600, 40 )
	TextLabel.Paint = function()
		draw.SimpleTextOutlined( "You need to re-enter the vehicle in order for the changes to take effect!", "DSimfphysFont_hint", 300, 20, Color( 255, 0, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER , 1,Color( 0, 0, 0, 255 ) ) 
	end
	
	local yy = 45
	local binders = {}
	for i = 1, table.Count( k_list ) do
		binders[i] = simplebinder(25,yy,k_list,i,self.PropPanel)
		yy = yy + 45
	end
	
	local ResetButton = vgui.Create( "DButton" )
	ResetButton:SetParent( self.PropPanel )
	ResetButton:SetText( "Reset" )	
	ResetButton:SetPos( 25, yy + 10 )
	ResetButton:SetSize( 500, 25 )
	ResetButton.DoClick = function()
		for i = 1, table.Count( binders ) do
			local kentry = k_list[i]
			local key = kentry[1]
			local default = kentry[2]
			
			key:SetInt( default )
			binders[i]:SetValue( default )
		end
	end
	
	Background:SetSize( 510, yy )
end


local function buildmsmenu( self )
	local Shape = vgui.Create( "DShape", self.PropPanel)
	Shape:SetType( "Rect" )
	Shape:SetPos( 20, 20 )
	Shape:SetSize( 350, 310 )
	Shape:SetColor( Color( 0, 0, 0, 200 ) )
	
	local msitem_1 = createcheckbox(25,25,"Enable Mouse Steering","cl_simfphys_mousesteer",self.PropPanel,mousesteer:GetInt())
	local msitem_2 = createcheckbox(25,55,"Lock Pitch View","cl_simfphys_ms_lockpitch",self.PropPanel,mslockpitch:GetInt())
	local msitem_8 = createcheckbox(25,85,"Show Hud","cl_simfphys_ms_hud",self.PropPanel,mshud:GetInt())
	
	
	local msitem_9 = createslider(60,50,315,40,"","cl_simfphys_ms_lockedpitch",self.PropPanel,-90,90,mslockedpitch:GetFloat())
	
	local msitem_4 = createslider(30,110,345,40,"Deadzone","cl_simfphys_ms_deadzone",self.PropPanel,0,16,msdeadzone:GetFloat())
	local msitem_5 = createslider(30,140,345,40,"Exponent","cl_simfphys_ms_exponent",self.PropPanel,1,4,msexponent:GetFloat())
	local msitem_6 = createslider(30,170,345,40,"Sensitivity","cl_simfphys_ms_sensitivity",self.PropPanel,0.01,10,mssensitivity:GetFloat())
	local msitem_7 = createslider(30,200,345,40,"Return Speed","cl_simfphys_ms_return",self.PropPanel,0,10,msretract:GetFloat())
	
	local msitem_3 = simplebinder_old(25,240,{{k_msfreelook,KEY_Y,"Unlock View"}},1,self.PropPanel,340, 40)
	
	local DermaButton = vgui.Create( "DButton" )
	DermaButton:SetParent( self.PropPanel )
	DermaButton:SetText( "Reset" )	
	DermaButton:SetPos( 25, 300 )
	DermaButton:SetSize( 340, 25 )
	DermaButton.DoClick = function()
		msitem_1:SetValue( 0 )
		msitem_2:SetValue( 0 )
		msitem_3:SetValue( KEY_Y )
		msitem_4:SetValue( 3 )
		msitem_5:SetValue( 1.5 )
		msitem_6:SetValue( 1 )
		msitem_7:SetValue( 1 )
		msitem_8:SetValue( 1 )
		msitem_9:SetValue( 5 )
		
		mshud:SetInt( 1 )
		mousesteer:SetInt( 0 )
		mssensitivity:SetInt( 1 )
		msretract:SetInt( 1 )
		msdeadzone:SetFloat( 3 )
		msexponent:SetFloat( 1.5 )
		mslockpitch:SetInt( 0 )
		k_msfreelook:SetInt( KEY_Y )
		mslockedpitch:SetFloat( 5 )
	end
end

local function buildserversettingsmenu( self )
	local Background = vgui.Create( "DShape", self.PropPanel)
	Background:SetType( "Rect" )
	Background:SetPos( 20, 20 )
	Background:SetColor( Color( 0, 0, 0, 200 ) )
	local y = 0
	
	if LocalPlayer():IsSuperAdmin() then
		y = y + 25
		local CheckBoxTeam = vgui.Create( "DCheckBoxLabel", self.PropPanel)
		CheckBoxTeam:SetPos( 25, y )
		CheckBoxTeam:SetText( "Disallow players of different teams to enter the same vehicle" )
		CheckBoxTeam:SetValue( GetConVar( "sv_simfphys_teampassenger" ) :GetInt() )
		CheckBoxTeam:SizeToContents()
	
		y = y + 25
		local CheckBoxDamage = vgui.Create( "DCheckBoxLabel", self.PropPanel)
		CheckBoxDamage:SetPos( 25, y )
		CheckBoxDamage:SetText( "Enable Damage" )
		CheckBoxDamage:SetValue( GetConVar( "sv_simfphys_enabledamage" ) :GetInt() )
		CheckBoxDamage:SizeToContents()
		
		y = y + 18
		local DamageMul = vgui.Create( "DNumSlider", self.PropPanel)
		DamageMul:SetPos( 30, y )
		DamageMul:SetSize( 345, 30 )
		DamageMul:SetText( "Damage Multiplicator" )
		DamageMul:SetMin( 0 )
		DamageMul:SetMax( 10 )
		DamageMul:SetDecimals( 3 )
		DamageMul:SetValue( GetConVar( "sv_simfphys_damagemultiplicator" ):GetFloat() )
		
		y = y + 32
		local CheckBoxpDamage = vgui.Create( "DCheckBoxLabel", self.PropPanel)
		CheckBoxpDamage:SetPos( 25, y )
		CheckBoxpDamage:SetText( "Enable Player Damage (On Collision)" )
		CheckBoxpDamage:SetValue( GetConVar( "sv_simfphys_playerdamage" ) :GetInt() )
		CheckBoxpDamage:SizeToContents()
		
		y = y + 25
		local GibRemoveTimer = vgui.Create( "DNumSlider", self.PropPanel)
		GibRemoveTimer:SetPos( 30, y )
		GibRemoveTimer:SetSize( 345, 30 )
		GibRemoveTimer:SetText( "Gib Lifetime\n(0 = never remove)" )
		GibRemoveTimer:SetMin( 0 )
		GibRemoveTimer:SetMax( 3600 )
		GibRemoveTimer:SetDecimals( 0 )
		GibRemoveTimer:SetValue( GetConVar( "sv_simfphys_gib_lifetime" ):GetInt() )
		
		y = y + 45
		local CheckBoxFuel = vgui.Create( "DCheckBoxLabel", self.PropPanel)
		CheckBoxFuel:SetPos( 25, y )
		CheckBoxFuel:SetText( "Enable Fuelsystem" )
		CheckBoxFuel:SetValue( GetConVar( "sv_simfphys_fuel" ) :GetInt() )
		CheckBoxFuel:SizeToContents()
		
		y = y + 18
		local ScaleFuel = vgui.Create( "DNumSlider", self.PropPanel)
		ScaleFuel:SetPos( 30, y )
		ScaleFuel:SetSize( 345, 30 )
		ScaleFuel:SetText( "Fuel tank size multiplier" )
		ScaleFuel:SetMin( 0 )
		ScaleFuel:SetMax( 1 )
		ScaleFuel:SetDecimals( 2 )
		ScaleFuel:SetValue( GetConVar( "sv_simfphys_fuelscale" ):GetFloat() )
		
		y = y + 45
		local tractionLabel = vgui.Create( "DLabel", self.PropPanel )
		tractionLabel:SetPos( 25, y )
		tractionLabel:SetText( "Traction Multiplicator for:" )
		tractionLabel:SizeToContents()
		
		local NewTractionData = {}
		local DemSliders = {}
		y = y + 15
		for k, v in ipairs( simfphys.TractionData ) do
			DemSliders[k] = vgui.Create( "DNumSlider", self.PropPanel)
			DemSliders[k]:SetPos( 30, y )
			DemSliders[k]:SetSize( 345, 30 )
			DemSliders[k]:SetText( k )
			DemSliders[k]:SetMin( 0 )
			DemSliders[k]:SetMax( 2 )
			DemSliders[k]:SetDecimals( 2 )
			DemSliders[k]:SetValue( simfphys[k]:GetFloat() )
			DemSliders[k].OnValueChanged = function( item, value )
				NewTractionData[ k ] = value
			end
			y = y + 25
		end
		
		y = y + 30
		local DermaButton = vgui.Create( "DButton" )
		DermaButton:SetParent( self.PropPanel )
		DermaButton:SetText( "Apply" )	
		DermaButton:SetPos( 25, y - 10 )
		DermaButton:SetSize( 340, 25 )
		DermaButton.DoClick = function()
			net.Start("simfphys_settings")
				net.WriteBool( CheckBoxDamage:GetChecked() )
				net.WriteFloat( GibRemoveTimer:GetValue() )
				net.WriteFloat( DamageMul:GetValue() )
				net.WriteBool( CheckBoxpDamage:GetChecked() )
				net.WriteBool( CheckBoxFuel:GetChecked() )
				net.WriteFloat( ScaleFuel:GetValue() )
				net.WriteTable( NewTractionData ) 
				net.WriteBool( CheckBoxTeam:GetChecked() )
			net.SendToServer()
		end
		
		y = y + 30
		local DermaButton = vgui.Create( "DButton" )
		DermaButton:SetParent( self.PropPanel )
		DermaButton:SetText( "Reset" )	
		DermaButton:SetPos( 25, y - 10 )
		DermaButton:SetSize( 340, 25 )
		DermaButton.DoClick = function()
			
			NewTractionData["ice"] = 0.35
			NewTractionData["gmod_ice"] = 0.1
			NewTractionData["slipperyslime"] = 0.2
			NewTractionData["snow"] = 0.7
			NewTractionData["grass"] = 1
			NewTractionData["sand"] = 1
			NewTractionData["dirt"] = 1
			NewTractionData["concrete"] = 1
			NewTractionData["metal"] = 1
			NewTractionData["glass"] = 1
			NewTractionData["gravel"] = 1
			NewTractionData["rock"] = 1
			NewTractionData["wood"] = 1
			
			for k, v in ipairs( NewTractionData ) do
				DemSliders[k]:SetValue( v )
			end
			
			CheckBoxDamage:SetValue( 1 )
			GibRemoveTimer:SetValue( 120 )
			DamageMul:SetValue( 1 )
			CheckBoxpDamage:SetValue( 1 )
			CheckBoxFuel:SetValue( 1 )
			ScaleFuel:SetValue( 0.1 )
			CheckBoxTeam:SetValue( 0 )
			
			net.Start("simfphys_settings")
				net.WriteBool( true )
				net.WriteFloat( 120 )
				net.WriteFloat( 1 )
				net.WriteBool( true )
				net.WriteBool( true )
				net.WriteFloat( 0.1 )
				net.WriteTable( NewTractionData ) 
				net.WriteBool( false )
			net.SendToServer()
		end
	else
		y = y + 25
		local Label = vgui.Create( "DLabel", self.PropPanel )
		Label:SetPos( 30, y )
		Label:SetText( "Damage is "..((GetConVar( "sv_simfphys_enabledamage" ):GetInt() > 0) and "enabled" or "disabled") )
		Label:SizeToContents()

		y = y + 25
		local Label = vgui.Create( "DLabel", self.PropPanel )
		Label:SetPos( 30, y )
		Label:SetText( "Damage Multiplicator is: "..GetConVar( "sv_simfphys_damagemultiplicator" ):GetFloat() )
		Label:SizeToContents()
		
		y = y + 25
		local yes = "Players can take damage from collisions"
		local no = "Players can't take damage from collisions"
		local Label = vgui.Create( "DLabel", self.PropPanel )
		Label:SetPos( 30, y )
		Label:SetText( GetConVar( "sv_simfphys_playerdamage" ):GetBool() and yes or no )
		Label:SizeToContents()
		
		y = y + 25
		local Label = vgui.Create( "DLabel", self.PropPanel )
		local lifetime = GetConVar( "sv_simfphys_gib_lifetime" ):GetInt()
		Label:SetPos( 30, y )
		Label:SetText( (lifetime > 0) and ("Gib Lifetime = "..lifetime.." seconds") or "Gibs never despawn" )
		Label:SizeToContents()
		
		y = y + 25
		local Label = vgui.Create( "DLabel", self.PropPanel )
		Label:SetPos( 30, y )
		Label:SetText( "Vehicles "..(GetConVar( "sv_simfphys_fuel" ):GetBool() and "are running on fuel" or "don't use fuel") )
		Label:SizeToContents()
		
		y = y + 25
		local Label = vgui.Create( "DLabel", self.PropPanel )
		local fuelscale = math.Round( GetConVar( "sv_simfphys_fuelscale" ):GetFloat() , 3 )
		Label:SetPos( 30, y )
		Label:SetText( "Fuel tank size multiplier is: "..fuelscale )
		Label:SizeToContents()
		
		if GetConVar( "sv_simfphys_teampassenger" ):GetBool() then
			y = y + 25
			local Label = vgui.Create( "DLabel", self.PropPanel )
			Label:SetPos( 30, y )
			Label:SetText( "Only players of the same team can enter the same vehicle" )
			Label:SizeToContents()
		end

		y = y + 40
		local Label = vgui.Create( "DLabel", self.PropPanel )
		Label:SetPos( 30, y )
		Label:SetText( "Traction multiplier for..." )
		Label:SizeToContents()

		y = y + 15
		for k, v in ipairs( simfphys.TractionData ) do
			local tractionLabel = vgui.Create( "DLabel", self.PropPanel )
			tractionLabel:SetPos( 105, y )
			tractionLabel:SetText( k )
			tractionLabel:SizeToContents()
			
			local tractionLabel = vgui.Create( "DLabel", self.PropPanel )
			tractionLabel:SetPos( 170, y )
			tractionLabel:SetText( "=" )
			tractionLabel:SizeToContents()
			
			local tractionLabel = vgui.Create( "DLabel", self.PropPanel )
			tractionLabel:SetPos( 185, y )
			tractionLabel:SetText( math.Round(v,2) )
			tractionLabel:SizeToContents()
			
			y = y + 25
		end
		y = y - 25
	end
	
	Background:SetSize( 350, y )
end


hook.Add( "SimfphysPopulateVehicles", "AddEntityContent", function( pnlContent, tree, node )

	local Categorised = {}

	-- Add this list into the tormoil
	local Vehicles = list.Get( "simfphys_vehicles" )
	if Vehicles then
		for k, v in ipairs( Vehicles ) do

			v.Category = v.Category or "Other"
			Categorised[ v.Category ] = Categorised[ v.Category ] or {}
			v.ClassName = k
			v.PrintName = v.Name
			table.insert( Categorised[ v.Category ], v )

		end
	end
	--
	-- Add a tree node for each category
	--
	for CategoryName, v in SortedPairs( Categorised ) do

		-- Add a node to the tree
		local node = tree:AddNode( CategoryName, "icon16/bricks.png" )
		
			-- When we click on the node - populate it using this function
		node.DoPopulate = function( self )
			
			-- If we've already populated it - forget it.
			if self.PropPanel then return end
			
			-- Create the container panel
			self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
			self.PropPanel:SetVisible( false )
			self.PropPanel:SetTriggerSpawnlistChange( false )
			
			for k, ent in SortedPairsByMemberValue( v, "PrintName" ) do
				
				spawnmenu.CreateContentIcon( "simfphys_vehicles", self.PropPanel, {
					nicename	= ent.PrintName or ent.ClassName,
					spawnname	= ent.ClassName,
					material	= "entities/"..ent.ClassName..".png",
					admin		= ent.AdminOnly
				} )
				
			end
			
		end
		
		-- If we click on the node populate it and switch to it.
		node.DoClick = function( self )
			
			self:DoPopulate()
			pnlContent:SwitchPanel( self.PropPanel )
			
		end

	end
	
	-- KEYBOARD
	local node = tree:AddNode( "Controls", "icon16/keyboard.png" )
	node.DoPopulate = function( self )
		if self.PropPanel then return end
		
		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )

		buildcontrolsmenu( self )
	end
	node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end
	
	-- MOUSE STEERING
	local node = tree:AddNode( "Mouse Steering", "icon16/mouse.png" )
	node.DoPopulate = function( self )
		if self.PropPanel then return end
		
		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )

		buildmsmenu( self )
	end
	node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end
	
	-- JOYSTICK
	if istable( jcon ) and file.Exists("lua/bin/gmcl_joystick_win32.dll", "GAME") then
		
		local node = tree:AddNode( "Joystick Configuration", "icon16/joystick.png" )
		node.DoClick = function( self )
			RunConsoleCommand("joyconfig") 
		end
	end
	
	-- CLIENT SETTINGS
	local node = tree:AddNode( "Client Settings", "icon16/wrench.png" )
	node.DoPopulate = function( self )
		if self.PropPanel then return end
		
		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )

		buildclientsettingsmenu( self )
	end
	node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end
	
	-- SERVER SETTINGS
	local node = tree:AddNode( "Server Settings", "icon16/wrench_orange.png" )
	node.DoPopulate = function( self )
		self.PropPanel = vgui.Create( "ContentContainer", pnlContent )
		self.PropPanel:SetVisible( false )
		self.PropPanel:SetTriggerSpawnlistChange( false )

		buildserversettingsmenu( self )
	end
	node.DoClick = function( self )
		self:DoPopulate()
		pnlContent:SwitchPanel( self.PropPanel )
	end

	
	-- Select the first node
	local FirstNode = tree:Root():GetChildNode( 0 )
	if IsValid( FirstNode ) then
		FirstNode:InternalDoClick()
	end

end )

spawnmenu.AddCreationTab( "simfphys", function()

	local ctrl = vgui.Create( "SpawnmenuContentPanel" )
	ctrl:CallPopulateHook( "SimfphysPopulateVehicles" )
	return ctrl

end, "icon16/car.png", 50 )


spawnmenu.AddContentType( "simfphys_vehicles", function( container, obj )
	if not obj.material then return end
	if not obj.nicename then return end
	if not obj.spawnname then return end

	local icon = vgui.Create( "ContentIcon", container )
	icon:SetContentType( "simfphys_vehicles" )
	icon:SetSpawnName( obj.spawnname )
	icon:SetName( obj.nicename )
	icon:SetMaterial( obj.material )
	icon:SetAdminOnly( obj.admin )
	icon:SetColor( Color( 0, 0, 0, 255 ) )
	icon.DoClick = function()
		RunConsoleCommand( "simfphys_spawnvehicle", obj.spawnname )
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	end
	icon.OpenMenu = function( icon )

		local menu = DermaMenu()
			menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
			--menu:AddSpacer()
			--menu:AddOption( "Delete", function() icon:Remove() hook.Run( "SpawnlistContentChanged", icon ) end )
		menu:Open()

	end
	
	if IsValid( container ) then
		container:Add( icon )
	end

	return icon

end )
