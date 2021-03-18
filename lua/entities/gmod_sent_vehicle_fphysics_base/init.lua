AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")
include("spawn.lua")
include("simfunc.lua")
include("numpads.lua")
include("damage.lua")

local function EntityLookup(CreatedEntities)
	return function(id, default)
		if id == nil then return default end
		if id == 0 then return game.GetWorld() end
		local ent = CreatedEntities[id] or (isnumber(id) and ents.GetByIndex(id))
		if IsValid(ent) then return ent else return default end
	end
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	if istable( WireLib ) then
		WireLib.ApplyDupeInfo(ply, ent, info, GetEntByID)
	end
end

function ENT:PreEntityCopy()
	if istable( WireLib ) then
		duplicator.StoreEntityModifier( self, "WireDupeInfo", WireLib.BuildDupeInfo(self) )
	end
end

function ENT:PostEntityPaste(Player,Ent,CreatedEntities)
	if istable( WireLib ) then
		if Ent.EntityMods and Ent.EntityMods.WireDupeInfo then
			WireLib.ApplyDupeInfo(Player, Ent, Ent.EntityMods.WireDupeInfo, EntityLookup(CreatedEntities))
		end
	end
end

function ENT:OnSpawn()
end

function ENT:OnTick()
end

function ENT:OnDelete()
end

function ENT:OnDestroyed()
end

function ENT:OnRepaired()
end

function ENT:Think()
	local Time = CurTime()
	
	self:OnTick()
	
	self.NextTick = self.NextTick or 0
	if self.NextTick < Time then
		self.NextTick = Time + 0.025
		
		if IsValid( self.DriverSeat ) then
			local Driver = self.DriverSeat:GetDriver()
			Driver = IsValid( self.RemoteDriver ) and self.RemoteDriver or Driver
			
			local OldDriver = self:GetDriver()
			if OldDriver ~= Driver then
				if self:GetIsVehicleLocked() then
					self:UnLock()
				end

				self:SetDriver( Driver )
				
				local HadDriver = IsValid( OldDriver )
				local HasDriver = IsValid( Driver )
				
				if HasDriver then
					self:SetActive( true )
					self:SetupControls( Driver )
					
					if Driver:GetInfoNum( "cl_simfphys_autostart", 1 ) > 0 then 
						self:StartEngine()
					end
					
				else
					if self.ems then
						self.ems:Stop()
					end

					if self.horn then
						self.horn:Stop()
					end
					
					if self.PressedKeys then
						for k,v in pairs( self.PressedKeys ) do
							if isbool( v ) then
								self.PressedKeys[k] = false
							end
						end
					end
					
					if self.keys then
						for i = 1, table.Count( self.keys ) do
							numpad.Remove( self.keys[i] )
						end
					end
					
					if HadDriver then
						if OldDriver:GetInfoNum( "cl_simfphys_autostart", 1 ) > 0 then 
							self:StopEngine()
							self:SetActive( false )
						else
							self:ResetJoystick()
							
							if not self:EngineActive() then
								self:SetActive( false )
							end
						end
					else
						self:SetActive( false )
						self:StopEngine()
					end
				end
			end
		end
		
		if self:IsInitialized() then
			self:SetColors()
			self:SimulateVehicle( Time )
			self:ControlLighting( Time )
			self:ControlHorn()
			
			if istable( WireLib ) then
				self:UpdateWireOutputs()
			end
			
			self.NextWaterCheck = self.NextWaterCheck or 0
			if self.NextWaterCheck < Time then
				self.NextWaterCheck = Time + 0.2
				self:WaterPhysics()
			end
			
			if self:GetActive() then
				self:SetPhysics( ((math.abs(self.ForwardSpeed) < 50) and (self.Brake > 0 or self.HandBrake > 0)) )
			else
				self:SetPhysics( true )
			end
		end
	end
	
	self:NextThink( Time )
	
	return true
end

function ENT:ControlHorn()	
	local HornVol = self.HornKeyIsDown and 1 or 0
	self.HornVolume = self.HornVolume and self.HornVolume + math.Clamp(HornVol - self.HornVolume,-0.45,0.8) or 0
	
	if self.horn then
		if self.HornVolume <= 0 then
			if self.horn then
				self.horn:Stop()
				self.horn = nil
			end
		else
			self.horn:ChangeVolume( self.HornVolume ^ 2 )
		end
	end
end

function ENT:createWireIO()
	self.Inputs = WireLib.CreateInputs( self,{"Eject Driver","Eject Passengers","Lock","Engine Start","Engine Stop","Engine Toggle","Steer","Throttle","Gear Up","Gear Down","Set Gear","Clutch","Handbrake","Brake/Reverse"} )
	--self.Inputs = WireLib.CreateSpecialInputs(self, { "blah" }, { "NORMAL" })
	
	self.Outputs = WireLib.CreateSpecialOutputs( self, 
		{ "Active","Health","RPM","Torque","DriverSeat","PassengerSeats","Driver","Gear","Ratio","Lights Enabled","Highbeams Enabled","Foglights Enabled","Sirens Enabled","Turn Signals Enabled","Remaining Fuel" },
		{ "NORMAL","NORMAL","NORMAL","NORMAL","ENTITY","ARRAY","ENTITY","NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","NORMAL","NORMAL" }
	)
end

function ENT:TriggerInput( name, value )
	if name == "Engine Start" then
		if value >= 1 then
			self:SetActive( true )
			self:StartEngine()
		end
	end
	
	if name == "Engine Stop" then
		if value >= 1 then
			self:SetActive( false )
			self:StopEngine()
		end
	end
	
	if name == "Engine Toggle" then
		if value >= 1 then
			if self:GetActive() then
				if not self:EngineActive() then
					self:StartEngine()
				else
					self:StopEngine()
					self:SetActive( false )
				end
			else
				self:SetActive( true )
				self:StartEngine()
			end
		end
	end
	
	if name == "Lock" then
		if value >= 1 then
			self:Lock()
		else
			self:UnLock()
		end
	end
	
	if name == "Eject Driver" then
		local Driver = self:GetDriver()
		if IsValid( Driver ) then
			Driver:ExitVehicle()
		end
	end
	
	if name == "Eject Passengers" then
		if istable( self.pSeat ) then
			for i = 1, table.Count( self.pSeat ) do
				if IsValid( self.pSeat[i] ) then
					
					local Driver = self.pSeat[i]:GetDriver()
					
					if IsValid( Driver ) then
						Driver:ExitVehicle()
					end
				end
			end
		end
	end
	
	if name == "Steer" then
		self:SteerVehicle( math.Clamp( value, -1 , 1) * self.VehicleData["steerangle"] )
		for i = 1, table.Count(self.Wheels) do
			local Wheel = self.Wheels[i]
			if IsValid( Wheel ) then
				Wheel:PhysWake()
			end
		end
	end
	
	if name == "Throttle" then
		self.PressedKeys["joystick_throttle"] = math.Clamp( value, 0, 1 )
	end
	
	if name == "Brake/Reverse" then
		self.PressedKeys["joystick_brake"] = math.Clamp( value, 0, 1 )
	end

	if name == "Gear Up" then
		if value >= 1 then
			self.CurrentGear = math.Clamp(self.CurrentGear + 1,1,table.Count( self.Gears ) )
			self:SetGear( self.CurrentGear )
		end
	end
	
	if name == "Gear Down" then
		if value >= 1 then
			self.CurrentGear = math.Clamp(self.CurrentGear - 1,1,table.Count( self.Gears ) )
			self:SetGear( self.CurrentGear )
		end
	end
	
	if name == "Set Gear" then
		self:ForceGear( math.Round( value, 0 ) )
	end
	
	if name == "Clutch" then
		self.PressedKeys["joystick_clutch"] = math.Clamp( value, 0, 1 )
	end
	
	if name == "Handbrake" then
		self.PressedKeys["joystick_handbrake"] = (value > 0) and 1 or 0
	end
end

function ENT:ForceGear( desGear )
	self.CurrentGear = math.Clamp( math.Round( desGear, 0 ),1,table.Count( self.Gears ) )
	self:SetGear( self.CurrentGear )
end

function ENT:UpdateWireOutputs()
	WireLib.TriggerOutput(self, "Active", self:EngineActive() and 1 or 0 )
	WireLib.TriggerOutput(self, "Health", self:GetCurHealth() )
	
	WireLib.TriggerOutput(self, "Driver", self:GetDriver() )
	WireLib.TriggerOutput(self, "Torque", self.Torque )
	WireLib.TriggerOutput(self, "RPM", self:GetEngineRPM() )
	
	WireLib.TriggerOutput(self, "Gear", self:GetGear() )
	WireLib.TriggerOutput(self, "Ratio",self:GetGear() == 2 and 0 or (self.GearRatio or 0) )
	
	WireLib.TriggerOutput(self, "Lights Enabled", self:GetLightsEnabled() and 1 or 0 )
	WireLib.TriggerOutput(self, "Highbeams Enabled", self:GetLampsEnabled() and 1 or 0 )
	WireLib.TriggerOutput(self, "Foglights Enabled", self:GetFogLightsEnabled() and 1 or 0 )
	WireLib.TriggerOutput(self, "Sirens Enabled", self:GetEMSEnabled() and 1 or 0 )
	WireLib.TriggerOutput(self, "Turn Signals Enabled", self:GetTSEnabled())
	WireLib.TriggerOutput(self, "Remaining Fuel", self:GetFuel())
end

function ENT:OnActiveChanged( name, old, new)
	if new == old then return end
	
	if not self:IsInitialized() then return end
	
	local TurboCharged = self:GetTurboCharged()
	local SuperCharged = self:GetSuperCharged()
	
	if new == true then
		
		self.HandBrakePower = self:GetMaxTraction() + 20 - self:GetTractionBias() * self:GetMaxTraction()
		
		if self:GetEMSEnabled() then
			if self.ems then
				self.ems:Play()
			end
		end
		
		if TurboCharged then
			self.Turbo = CreateSound(self, self.snd_spool or "simulated_vehicles/turbo_spin.wav")
			self.Turbo:PlayEx(0,0)
		end
		
		if SuperCharged then
			self.Blower = CreateSound(self, self.snd_bloweroff or "simulated_vehicles/blower_spin.wav")
			self.BlowerWhine = CreateSound(self, self.snd_bloweron or "simulated_vehicles/blower_gearwhine.wav")
			
			self.Blower:PlayEx(0,0)
			self.BlowerWhine:PlayEx(0,0)
		end
	else
		self:StopEngine()
		
		if TurboCharged then
			self.Turbo:Stop()
		end

		if SuperCharged then
			self.Blower:Stop()
			self.BlowerWhine:Stop()
		end
		
		self:SetIsBraking( false )
	end
	
	if istable( self.Wheels ) then
		for i = 1, table.Count( self.Wheels ) do
			local Wheel = self.Wheels[ i ]
			if IsValid(Wheel) then
				Wheel:SetOnGround( 0 )
			end
		end
	end
end

function ENT:OnThrottleChanged( name, old, new)
	if new == old then return end
	
	local Health = self:GetCurHealth()
	local MaxHealth = self:GetMaxHealth()
	local Active = self:EngineActive()
	
	if new == 1 then
		if Health < MaxHealth * 0.6 then
			if Active then
				if math.Round(math.random(0,4),0) == 1 then
					self:DamagedStall()
				end
			end
		end
	end
	
	if new == 0 then
		if self:GetTurboCharged() then
			if (self.SmoothTurbo > 350) then
				local Volume = math.Clamp( ((self.SmoothTurbo - 300) / 150) ,0, 1) * 0.5
				self.SmoothTurbo = 0
				self.BlowOff:Stop()
				self.BlowOff = CreateSound(self, self.snd_blowoff or "simulated_vehicles/turbo_blowoff.ogg")
				self.BlowOff:PlayEx(Volume,100)
			end
		end
	end
end

function ENT:WaterPhysics()
	if self:WaterLevel() <= 1 then self.IsInWater = false return end
	
	if self:GetDoNotStall() then 
		
		self:SetOnFire( false )
		self:SetOnSmoke( false )
		
		return
	end
	
	if not self.IsInWater then
		if self:EngineActive() then
			self:EmitSound( "vehicles/jetski/jetski_off.wav" )
		end
		
		self.IsInWater = true
		self.EngineIsOn = 0
		self.EngineRPM = 0
		self:SetFlyWheelRPM( 0 )
		
		self:SetOnFire( false )
		self:SetOnSmoke( false )
	end
	
	local phys = self:GetPhysicsObject()
	phys:ApplyForceCenter( -self:GetVelocity() * 0.5 * phys:GetMass() )
end

function ENT:SetColors()
	if self.ColorableProps then
		
		local Color = self:GetColor()
		local dot = Color.r * Color.g * Color.b * Color.a
		
		if dot ~= self.OldColor then
			
			for i, prop in pairs( self.ColorableProps ) do
				if IsValid(prop) then
					prop:SetColor( Color )
					prop:SetRenderMode( self:GetRenderMode() )
				end
			end
			
			self.OldColor = dot
		end
	end
end

function ENT:ControlLighting( curtime )
	if (self.NextLightCheck or 0) < curtime then
		
		if self.LightsActivated ~= self.DoCheck then
			self.DoCheck = self.LightsActivated
			
			if self.LightsActivated then
				self:SetLightsEnabled(true)
			end
		end
	end
end

function ENT:SetTSInternal(mode)
	self.TSMode = mode
end

function ENT:GetTSEnabled()
	if self.TSMode != nil then return self.TSMode else return 0 end
end

function ENT:GetEngineData()
	local LimitRPM = math.max(self:GetLimitRPM(),4)
	local Powerbandend = math.Clamp(self:GetPowerBandEnd(),3,LimitRPM - 1)
	local Powerbandstart = math.Clamp(self:GetPowerBandStart(),2,Powerbandend - 1)
	local IdleRPM = math.Clamp(self:GetIdleRPM(),1,Powerbandstart - 1)
	local Data = {
		IdleRPM = IdleRPM,
		Powerbandstart = Powerbandstart,
		Powerbandend = Powerbandend,
		LimitRPM = LimitRPM,
	}
	return Data
end

function ENT:SimulateVehicle( curtime )
	local Active = self:GetActive()
	
	local EngineData = self:GetEngineData()
	
	local LimitRPM = EngineData.LimitRPM
	local Powerbandend = EngineData.Powerbandend
	local Powerbandstart = EngineData.Powerbandstart
	local IdleRPM = EngineData.IdleRPM
	
	self.Forward =  self:LocalToWorldAngles( self.VehicleData.LocalAngForward ):Forward() 
	self.Right = self:LocalToWorldAngles( self.VehicleData.LocalAngRight ):Forward() 
	self.Up = self:GetUp()
	
	self.Vel = self:GetVelocity()
	self.VelNorm = self.Vel:GetNormalized()
	
	self.MoveDir = math.acos( math.Clamp( self.Forward:Dot(self.VelNorm) ,-1,1) ) * (180 / math.pi)
	self.ForwardSpeed = math.cos(self.MoveDir * (math.pi / 180)) * self.Vel:Length()
	
	if self.poseon then
		self.cpose = self.cpose or self.LightsPP.min
		local anglestep = math.abs(math.max(self.LightsPP.max or self.LightsPP.min)) / 3
		self.cpose = self.cpose + math.Clamp(self.poseon - self.cpose,-anglestep,anglestep)
		self:SetPoseParameter(self.LightsPP.name, self.cpose)
	end
	
	self:SetPoseParameter("vehicle_guage", (math.abs(self.ForwardSpeed) * 0.0568182 * 0.75) / (self.SpeedoMax or 120))
	
	if self.RPMGaugePP then
		local flywheelrpm = self:GetFlyWheelRPM()
		local rpm
		if self:GetRevlimiter() then
			local throttle = self:GetThrottle()
			local maxrpm = self:GetLimitRPM()
			local revlimiter = (maxrpm > 2500) and (throttle > 0)
			rpm = math.Round(((flywheelrpm >= maxrpm - 200) and revlimiter) and math.Round(flywheelrpm - 200 + math.sin(curtime * 50) * 600,0) or flywheelrpm,0)
		else
			rpm = flywheelrpm
		end
	
		self:SetPoseParameter(self.RPMGaugePP,  rpm / self.RPMGaugeMax)
	end
	
	
	if Active then
		local ply = self:GetDriver()
		local IsValidDriver = IsValid( ply )
		
		local GearUp = self.PressedKeys["M1"] and 1 or self.PressedKeys["joystick_gearup"]
		local GearDown = self.PressedKeys["M2"] and 1 or self.PressedKeys["joystick_geardown"]
		
		local W = self.PressedKeys["W"] and 1 or 0
		local A = self.PressedKeys["A"] and 1 or self.PressedKeys["joystick_steer_left"]
		local S = self.PressedKeys["S"] and 1 or 0
		local D = self.PressedKeys["D"] and 1 or self.PressedKeys["joystick_steer_right"]
		
		if IsValidDriver then self:PlayerSteerVehicle( ply, A, D ) end
		
		local aW = self.PressedKeys["aW"] and 1 or self.PressedKeys["joystick_air_w"]
		local aA = self.PressedKeys["aA"] and 1 or self.PressedKeys["joystick_air_a"]
		local aS = self.PressedKeys["aS"] and 1 or self.PressedKeys["joystick_air_s"]
		local aD = self.PressedKeys["aD"] and 1 or self.PressedKeys["joystick_air_d"]
		
		local cruise = self:GetIsCruiseModeOn()
		
		local k_sanic = IsValidDriver and ply:GetInfoNum( "cl_simfphys_sanic", 0 ) or 1
		local sanicmode = isnumber( k_sanic ) and k_sanic or 0
		local k_Shift = self.PressedKeys["Shift"]
		local Shift = (sanicmode == 1) and (k_Shift and 0 or 1) or (k_Shift and 1 or 0)
		
		local sportsmode = IsValidDriver and ply:GetInfoNum( "cl_simfphys_sport", 0 ) or 1
		local k_auto = IsValidDriver and ply:GetInfoNum( "cl_simfphys_auto", 0 ) or 1
		local transmode = (k_auto == 1)
		
		local Alt = self.PressedKeys["Alt"] and 1 or 0
		local Space = self.PressedKeys["Space"] and 1 or self.PressedKeys["joystick_handbrake"]
		
		if cruise then
			if (self.PressedKeys["joystick_gearup"] + self.PressedKeys["joystick_geardown"] + self.PressedKeys["joystick_handbrake"] + self.PressedKeys["joystick_throttle"] + self.PressedKeys["joystick_clutch"] + self.PressedKeys["joystick_brake"]) > 0 then
				self:SetIsCruiseModeOn( false )
			end
			
			if k_Shift then
				self.cc_speed = math.Round(self:GetVelocity():Length(),0) + 70
			end
			if Alt == 1 then
				self.cc_speed = math.Round(self:GetVelocity():Length(),0) - 25
			end
		end
		
		self:SimulateTransmission(W,S,Shift,Alt,Space,GearUp,GearDown,transmode,IdleRPM,Powerbandstart,Powerbandend,sportsmode,cruise,curtime)
		
		self:SimulateEngine( IdleRPM, LimitRPM, Powerbandstart, Powerbandend, curtime )
		self:SimulateWheels( math.max(Space,Alt), LimitRPM )
		self:SimulateAirControls( aW, aS, aA, aD )
		
		if self.WheelOnGroundDelay < curtime then
			self:WheelOnGround()
			self.WheelOnGroundDelay = curtime + 0.15
		end
	end
	
	if self.CustomWheels then
		self:PhysicalSteer()
	end
end

function ENT:SetupControls( ply )
	self:ResetJoystick()
	
	if self.keys then
		for i = 1, table.Count( self.keys ) do
			numpad.Remove( self.keys[i] )
		end
	end

	if IsValid(ply) then
		self.cl_SteerSettings = {
			Overwrite = (ply:GetInfoNum( "cl_simfphys_overwrite", 0 ) >= 1),
			TurnSpeed = ply:GetInfoNum( "cl_simfphys_steerspeed", 8 ),
			fadespeed = ply:GetInfoNum( "cl_simfphys_fadespeed", 535 ),
			fastspeedangle = ply:GetInfoNum( "cl_simfphys_steerangfast", 10 ),
			smoothsteer = (ply:GetInfoNum( "cl_simfphys_smoothsteer", 0 ) >= 1),
		}
		
		local W = ply:GetInfoNum( "cl_simfphys_keyforward", 0 )
		local A = ply:GetInfoNum( "cl_simfphys_keyleft", 0 )
		local S = ply:GetInfoNum( "cl_simfphys_keyreverse", 0 )
		local D = ply:GetInfoNum( "cl_simfphys_keyright", 0 )
		
		local aW = ply:GetInfoNum( "cl_simfphys_key_air_forward", 0 )
		local aA = ply:GetInfoNum( "cl_simfphys_key_air_left", 0 )
		local aS = ply:GetInfoNum( "cl_simfphys_key_air_reverse", 0 )
		local aD = ply:GetInfoNum( "cl_simfphys_key_air_right", 0 )
		
		local GearUp = ply:GetInfoNum( "cl_simfphys_keygearup", 0 )
		local GearDown = ply:GetInfoNum( "cl_simfphys_keygeardown", 0 )
		
		local R = ply:GetInfoNum( "cl_simfphys_cruisecontrol", 0 )
		
		local F = ply:GetInfoNum( "cl_simfphys_lights", 0 )
		
		local V = ply:GetInfoNum( "cl_simfphys_foglights", 0 )
		
		local H = ply:GetInfoNum( "cl_simfphys_keyhorn", 0 )
		
		local I = ply:GetInfoNum( "cl_simfphys_keyengine", 0 )
		
		local Shift = ply:GetInfoNum( "cl_simfphys_keywot", 0 )
		
		local Alt = ply:GetInfoNum( "cl_simfphys_keyclutch", 0 )
		local Space = ply:GetInfoNum( "cl_simfphys_keyhandbrake", 0 )
		
		local lock = ply:GetInfoNum( "cl_simfphys_key_lock", 0 )
		
		local w_dn = numpad.OnDown( ply, W, "k_forward",self, true )
		local w_up = numpad.OnUp( ply, W, "k_forward",self, false )
		local s_dn = numpad.OnDown( ply, S, "k_reverse",self, true )
		local s_up = numpad.OnUp( ply, S, "k_reverse",self, false )
		local a_dn = numpad.OnDown( ply, A, "k_left",self, true )
		local a_up = numpad.OnUp( ply, A, "k_left",self, false )
		local d_dn = numpad.OnDown( ply, D, "k_right",self, true )
		local d_up = numpad.OnUp( ply, D, "k_right",self, false )
		
		local aw_dn = numpad.OnDown( ply, aW, "k_a_forward",self, true )
		local aw_up = numpad.OnUp( ply, aW, "k_a_forward",self, false )
		local as_dn = numpad.OnDown( ply, aS, "k_a_reverse",self, true )
		local as_up = numpad.OnUp( ply, aS, "k_a_reverse",self, false )
		local aa_dn = numpad.OnDown( ply, aA, "k_a_left",self, true )
		local aa_up = numpad.OnUp( ply, aA, "k_a_left",self, false )
		local ad_dn = numpad.OnDown( ply, aD, "k_a_right",self, true )
		local ad_up = numpad.OnUp( ply, aD, "k_a_right",self, false )
		
		local gup_dn = numpad.OnDown( ply, GearUp, "k_gup",self, true )
		local gup_up = numpad.OnUp( ply, GearUp, "k_gup",self, false )
		
		local gdn_dn = numpad.OnDown( ply, GearDown, "k_gdn",self, true )
		local gdn_up = numpad.OnUp( ply, GearDown, "k_gdn",self, false )
		
		local shift_dn = numpad.OnDown( ply, Shift, "k_wot",self, true )
		local shift_up = numpad.OnUp( ply, Shift, "k_wot",self, false )
		
		local alt_dn = numpad.OnDown( ply, Alt, "k_clutch",self, true )
		local alt_up = numpad.OnUp( ply, Alt, "k_clutch",self, false )
		
		local space_dn = numpad.OnDown( ply, Space, "k_hbrk",self, true )
		local space_up = numpad.OnUp( ply, Space, "k_hbrk",self, false )
		
		local k_cruise = numpad.OnDown( ply, R, "k_ccon",self, true )
		
		local k_lights_dn = numpad.OnDown( ply, F, "k_lgts",self, true )
		local k_lights_up = numpad.OnUp( ply, F, "k_lgts",self, false )
		
		local k_flights_dn = numpad.OnDown( ply, V, "k_flgts",self, true )
		local k_flights_up = numpad.OnUp( ply, V, "k_flgts",self, false )
		
		local k_horn_dn = numpad.OnDown( ply, H, "k_hrn",self, true )
		local k_horn_up = numpad.OnUp( ply, H, "k_hrn",self, false )
		
		local k_engine_dn = numpad.OnDown( ply, I, "k_eng",self, true )
		local k_engine_up = numpad.OnUp( ply, I, "k_eng",self, false )
		
		local k_lock_dn = numpad.OnDown( ply, lock, "k_lock",self, true )
		local k_lock_up = numpad.OnUp( ply, lock, "k_lock",self, false )
		
		self.keys = {
			w_dn,w_up,
			s_dn,s_up,
			a_dn,a_up,
			d_dn,d_up,
			aw_dn,aw_up,
			as_dn,as_up,
			aa_dn,aa_up,
			ad_dn,ad_up,
			gup_dn,gup_up,
			gdn_dn,gdn_up,
			shift_dn,shift_up,
			alt_dn,alt_up,
			space_dn,space_up,
			k_cruise,
			k_lights_dn,k_lights_up,
			k_horn_dn,k_horn_up,
			k_flights_dn,k_flights_up,
			k_engine_dn,k_engine_up,
			k_lock_dn,k_lock_up,
		}
	end
end

function ENT:PlayAnimation( animation )
	local anims = string.Implode( ",", self:GetSequenceList() )
	
	if not animation or not string.match( string.lower(anims), string.lower( animation ), 1 ) then return end
	
	local sequence = self:LookupSequence( animation )
	
	self:ResetSequence( sequence )
	self:SetPlaybackRate( 1 ) 
	self:SetSequence( sequence )
end

function ENT:PhysicalSteer()
	
	if IsValid(self.SteerMaster) then
		local physobj = self.SteerMaster:GetPhysicsObject()
		if not IsValid(physobj) then return end
		
		if physobj:IsMotionEnabled() then
			physobj:EnableMotion(false)
		end
		
		self.SteerMaster:SetAngles( self:LocalToWorldAngles( Angle(0,math.Clamp(-self.VehicleData[ "Steer" ],-self.CustomSteerAngle,self.CustomSteerAngle),0) ) )
	end
	
	if IsValid(self.SteerMaster2) then
		local physobj = self.SteerMaster2:GetPhysicsObject()
		if not IsValid(physobj) then return end
		
		if physobj:IsMotionEnabled() then
			physobj:EnableMotion(false)
		end
		
		self.SteerMaster2:SetAngles( self:LocalToWorldAngles( Angle(0,math.Clamp(self.VehicleData[ "Steer" ],-self.CustomSteerAngle,self.CustomSteerAngle),0) ) )
	end
end

function ENT:IsInitialized()
	return (self.EnableSuspension == 1)
end

function ENT:EngineActive()
	return (self.EngineIsOn == 1)
end

function ENT:IsDriveWheelsOnGround()
	return (self.DriveWheelsOnGround == 1)
end

function ENT:GetRPM()
	local RPM = self.EngineRPM and self.EngineRPM or 0
	return RPM
end

function ENT:GetEngineRPM()
	local flywheelrpm = self:GetRPM()
	local rpm
	if self:GetRevlimiter() then
		local throttle = self:GetThrottle()
		local maxrpm = self:GetLimitRPM()
		local revlimiter = (maxrpm > 2500) and (throttle > 0)
		rpm = math.Round(((flywheelrpm >= maxrpm - 200) and revlimiter) and math.Round(flywheelrpm - 200 + math.sin(CurTime()* 50) * 600,0) or flywheelrpm,0)
	else
		rpm = flywheelrpm
	end
	
	return rpm
end

function ENT:GetDiffGear()
	return math.max(self:GetDifferentialGear(),0.01)
end

function ENT:DamagedStall()
	if not self:GetActive() then return end
	
	local rtimer = 0.8
	
	timer.Simple( rtimer, function()
		if not IsValid( self ) then return end
		net.Start( "simfphys_backfire" )
			net.WriteEntity( self )
		net.Broadcast()
	end)
	
	self:StallAndRestart( rtimer, true )
end

function ENT:StopEngine()
	if self:EngineActive() then
		self:EmitSound( "vehicles/jetski/jetski_off.wav" )

		self.EngineRPM = 0
		self.EngineIsOn = 0
		
		self:SetFlyWheelRPM( 0 )
		self:SetIsCruiseModeOn( false )
	end
end

function ENT:CanStart()
	local FuelSystemOK = true
	
	if simfphys.Fuel then
		FuelSystemOK = self:GetFuel() > 0
	end
	
	local canstart = self:GetCurHealth() > (self:GetMaxHealth() * 0.1) and FuelSystemOK
	
	return canstart
end

function ENT:StartEngine( bIgnoreSettings )
	if not self:CanStart() then return end
	
	if not self:EngineActive() then
		if not bIgnoreSettings then
			self.CurrentGear = 2
		end
			
		if not self.IsInWater then
			self.EngineRPM = self:GetEngineData().IdleRPM
			self.EngineIsOn = 1
		else
			if self:GetDoNotStall() then
				self.EngineRPM = self:GetEngineData().IdleRPM
				self.EngineIsOn = 1
			end
		end
	end
end

function ENT:StallAndRestart( nTimer, bIgnoreSettings )
	nTimer = nTimer or 1
	
	self:StopEngine()
	
	local ply = self:GetDriver()
	if IsValid(ply) and not bIgnoreSettings then
		if ply:GetInfoNum( "cl_simfphys_autostart", 1 ) <= 0 then return end
	end
	
	timer.Simple( nTimer, function()
		if not IsValid(self) then return end
		self:StartEngine( bIgnoreSettings )
	end)
end

function ENT:PlayerSteerVehicle( ply, left, right )
	if IsValid( ply ) then
		local CounterSteeringEnabled = (ply:GetInfoNum( "cl_simfphys_ctenable", 0 ) or 1) == 1
		local CounterSteeringMul =  math.Clamp(ply:GetInfoNum( "cl_simfphys_ctmul", 0 ) or 0.7,0.1,2)
		local MaxHelpAngle = math.Clamp(ply:GetInfoNum( "cl_simfphys_ctang", 0 ) or 15,1,90)
		
		local Ang = self.MoveDir
		
		local TurnSpeed
		local fadespeed
		local fastspeedangle
		local extrasmooth = false
		
		if istable(self.cl_SteerSettings) and self.cl_SteerSettings.Overwrite then
			TurnSpeed = self.cl_SteerSettings.TurnSpeed
			fadespeed = self.cl_SteerSettings.fadespeed
			fastspeedangle = self.cl_SteerSettings.fastspeedangle
			extrasmooth =  self.cl_SteerSettings.smoothsteer
		else
			TurnSpeed = self:GetSteerSpeed()
			fadespeed = self:GetFastSteerConeFadeSpeed()
			fastspeedangle = self:GetFastSteerAngle() * self.VehicleData["steerangle"]
		end
		
		local SlowSteeringRate = (Ang > 20) and ((math.Clamp((self.ForwardSpeed - 150) / 25,0,1) == 1) and 60 or self.VehicleData["steerangle"]) or self.VehicleData["steerangle"]
		local FastSteeringAngle = math.Clamp(fastspeedangle,1,SlowSteeringRate)
		
		local FastSteeringRate = FastSteeringAngle + ((Ang > (FastSteeringAngle-1)) and 1 or 0) * math.min(Ang,90 - FastSteeringAngle)
		
		local Ratio = 1 - math.Clamp((math.abs(self.ForwardSpeed) - fadespeed) / 25,0,1)
		
		local SteerRate = FastSteeringRate + (SlowSteeringRate - FastSteeringRate) * Ratio
		local Steer = ((left + right) > 0 and (right - left) or self:GetMouseSteer()) * SteerRate
		
		local LocalDrift = math.acos( math.Clamp( self.Right:Dot(self.VelNorm) ,-1,1) ) * (180 / math.pi) - 90
		
		local CounterSteer = CounterSteeringEnabled and (math.Clamp(LocalDrift * CounterSteeringMul * (((left + right) == 0) and 1 or 0),-MaxHelpAngle,MaxHelpAngle) * ((self.ForwardSpeed > 50) and 1 or 0)) or 0
		
		local Rate = extrasmooth and math.max( (math.abs(self.SmoothAng) / self.VehicleData["steerangle"]) ^ 1.5 * TurnSpeed, math.max(1 - self.ForwardSpeed / 2000,0.05) ) or TurnSpeed
		
		self.SmoothAng = self.SmoothAng + math.Clamp((Steer - CounterSteer) - self.SmoothAng,-Rate,Rate)
		
		self:SteerVehicle( self.SmoothAng )
	end
end

function ENT:SteerVehicle( steer )
	self.VehicleData[ "Steer" ] = steer
	self:SetVehicleSteer( steer / self.VehicleData["steerangle"] )
end

function ENT:Lock()
	self:SetIsVehicleLocked( true )
	self:EmitSound( "doors/latchlocked2.wav" )
end

function ENT:UnLock()
	self:SetIsVehicleLocked( false )
	self:EmitSound( "doors/latchunlocked1.wav" )
end

function ENT:ForceLightsOff()
	local vehiclelist = list.Get( "simfphys_lights" )[self.LightsTable] or false
	if not vehiclelist then return end
	
	if vehiclelist.Animation then
		if self.LightsActivated then
			self.LightsActivated = false
			self.LampsActivated = false
			
			self:SetLightsEnabled(false)
			self:SetLampsEnabled(false)
		end
	end
end

function ENT:EnteringSequence( ply )
	local LinkedDoorAnims = istable(self.ModelInfo) and istable(self.ModelInfo.LinkDoorAnims)
	if not istable(self.Enterpoints) and not LinkedDoorAnims then return end
	
	local sequence
	local pos
	local dist
	
	if LinkedDoorAnims then
		for i,_ in pairs( self.ModelInfo.LinkDoorAnims ) do
			local seq_ = self.ModelInfo.LinkDoorAnims[ i ].enter
			
			local a_pos = self:GetAttachment( self:LookupAttachment( i ) ).Pos
			local a_dist = (ply:GetPos() - a_pos):Length()
			
			if not sequence then
				sequence = seq_
				pos = a_pos
				dist = a_dist
			else
				if a_dist < dist then
					sequence = seq_
					pos = a_pos
					dist = a_dist
				end
			end
		end
	else
		for i = 1, table.Count( self.Enterpoints ) do
			local a_ = self.Enterpoints[ i ]
			
			local a_pos = self:GetAttachment( self:LookupAttachment( a_ ) ).Pos
			local a_dist = (ply:GetPos() - a_pos):Length()
			
			if i == 1 then
				sequence = a_
				pos = a_pos
				dist = a_dist
			else
				if  (a_dist < dist) then
					sequence = a_
					pos = a_pos
					dist = a_dist
				end
			end
		end
	end
	
	self:PlayAnimation( sequence )
	self:ForceLightsOff()
end

function ENT:GetMouseSteer()
	if IsValid(self.DriverSeat) then return (self.DriverSeat.ms_Steer or 0) end
	
	return 0
end

function ENT:Use( ply )
	if not IsValid( ply ) then return end

	if self:GetIsVehicleLocked() or self:HasPassengerEnemyTeam( ply ) then 
		self:EmitSound( "doors/default_locked.wav" )

		return
	end

	self:SetPassenger( ply )
end

function ENT:SetPassenger( ply )
	if not IsValid( ply ) then return end
	
	if not IsValid(self:GetDriver()) and not ply:KeyDown(IN_WALK) then
		ply:SetAllowWeaponsInVehicle( false ) 
		
		if IsValid(self.DriverSeat) then
			self:EnteringSequence( ply )

			local allowed = ply:EnterVehicle( self.DriverSeat )
			if allowed then
				timer.Simple( 0.01, function()
					if IsValid(ply) then
						local angles = Angle(0,90,0)
						ply:SetEyeAngles( angles )
					end
				end)
			end
		end
	else
		if self.PassengerSeats then
			local closestSeat = self:GetClosestSeat( ply )
			
			if not closestSeat or IsValid( closestSeat:GetDriver() ) then
				
				for i = 1, table.Count( self.pSeat ) do
					if IsValid(self.pSeat[i]) then
						
						local HasPassenger = IsValid(self.pSeat[i]:GetDriver())
						
						if not HasPassenger then
							ply:EnterVehicle( self.pSeat[i] )
							break
						end
					end
				end
			else
				ply:EnterVehicle( closestSeat )
			end
		end
	end
end

function ENT:GetClosestSeat( ply )
	local Seat = self.pSeat[1]
	if not IsValid(Seat) then return false end
	
	local Distance = (Seat:GetPos() - ply:GetPos()):Length()
	
	for i = 1, table.Count( self.pSeat ) do
		local Dist = (self.pSeat[i]:GetPos() - ply:GetPos()):Length()
		if (Dist < Distance) then
			Seat = self.pSeat[i]
		end
	end
	
	return Seat
end

function ENT:HasPassengerEnemyTeam( ply )
	if not GetConVar( "sv_simfphys_teampassenger" ):GetBool() then return false end
	
	if not IsValid( ply ) then return true end
	
	local myteam = ply:Team()
	if IsValid( self:GetDriver() ) then
		if self:GetDriver():Team() ~= myteam then
			return true
		end
	end
	
	if self.PassengerSeats then
		for i = 1, table.Count( self.pSeat ) do
			if IsValid(self.pSeat[i]) then
				
				local Passenger = self.pSeat[i]:GetDriver()
				if IsValid( Passenger ) then
					if Passenger:Team() ~= myteam then
						return true
					end
				end
			end
		end
	end
	
	return false
end

function ENT:SetPhysics( enable )
	if enable then
		if not self.PhysicsEnabled then
			for i = 1, table.Count( self.Wheels ) do
				local Wheel = self.Wheels[i]
				if IsValid(Wheel) then
					Wheel:GetPhysicsObject():SetMaterial("jeeptire")
				end
			end
			self.PhysicsEnabled = true
		end
	else
		if self.PhysicsEnabled ~= false then
			for i = 1, table.Count( self.Wheels ) do
				local Wheel = self.Wheels[i]
				if IsValid(Wheel) then
					Wheel:GetPhysicsObject():SetMaterial("friction_00")
					if Wheel:GetPhysicsObject():GetMaterial() ~= "friction_00" then
						print("(SIMFPHYS) ERROR! MISSING ''friction_00'' PHYSPROP-MATERIAL!!! THIS SHOULD NEVER HAPPEN!! CLEAN YOUR GMOD!! DON'T USE CONTENT OF GAMES YOU DON'T OWN!! DON'T EVEN BOTHER REPORTING THIS ISSUE, BECAUSE ONLY YOU CAN FIX THIS AS THIS IS AN ISSUE WITH YOUR GAME!!!!")
						sound.Play( "common/bugreporter_failed.wav", self:GetPos() )
						self:Remove()

						break
					end
				end
			end
			self.PhysicsEnabled = false
		end
	end
end

function ENT:SetSuspension( index , bIsDamaged )
	local bIsDamaged = bIsDamaged or false
	
	local h_mod = index <= 2 and self:GetFrontSuspensionHeight() or self:GetRearSuspensionHeight()
	
	local heights = {
		[1] = self.FrontHeight + self.VehicleData.suspensiontravel_fl * -h_mod,
		[2] = self.FrontHeight + self.VehicleData.suspensiontravel_fr * -h_mod,
		[3] = self.RearHeight + self.VehicleData.suspensiontravel_rl * -h_mod,
		[4] = self.RearHeight + self.VehicleData.suspensiontravel_rr * -h_mod,
		[5] = self.RearHeight + self.VehicleData.suspensiontravel_rl * -h_mod,
		[6] = self.RearHeight + self.VehicleData.suspensiontravel_rr * -h_mod
	}
	local Wheel = self.Wheels[index]
	if not IsValid(Wheel) then return end
	
	local subRadius = bIsDamaged and Wheel.dRadius or 0
	
	local newheight = heights[index] + subRadius

	local Elastic = self.Elastics[index]
	if IsValid(Elastic) then
		Elastic:Fire( "SetSpringLength", newheight )
	end
	
	if self.StrengthenSuspension == true then
		local Elastic2 = self.Elastics[index * 10]
		if IsValid(Elastic2) then
			Elastic2:Fire( "SetSpringLength", newheight )
		end
	end
end

function ENT:OnFrontSuspensionHeightChanged( name, old, new )
	if old == new then return end
	if not self.CustomWheels and new > 0 then new = 0 end
	if not self:IsInitialized() then return end
	
	if IsValid(self.Wheels[1]) then
		local Elastic = self.Elastics[1]
		if IsValid(Elastic) then
			Elastic:Fire( "SetSpringLength", self.FrontHeight + self.VehicleData.suspensiontravel_fl * -new )
		end
		
		if self.StrengthenSuspension == true then
			
			local Elastic2 = self.Elastics[10]
			
			if IsValid(Elastic2) then
				Elastic2:Fire( "SetSpringLength", self.FrontHeight + self.VehicleData.suspensiontravel_fl * -new )
			end
		end
	end
	
	if IsValid(self.Wheels[2]) then
		local Elastic = self.Elastics[2]
		if IsValid(Elastic) then
			Elastic:Fire( "SetSpringLength", self.FrontHeight + self.VehicleData.suspensiontravel_fr * -new )
		end
		
		if self.StrengthenSuspension == true then
			
			local Elastic2 = self.Elastics[20]
			
			if (IsValid(Elastic2)) then
				Elastic2:Fire( "SetSpringLength", self.FrontHeight + self.VehicleData.suspensiontravel_fr * -new )
			end
		end
	end
end

function ENT:OnRearSuspensionHeightChanged( name, old, new )
	if old == new then return end
	if not self.CustomWheels and new > 0 then new = 0 end
	if not self:IsInitialized() then return end
	
	if IsValid(self.Wheels[3]) then
		local Elastic = self.Elastics[3]
		if IsValid(Elastic) then
			Elastic:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rl * -new )
		end
		
		if self.StrengthenSuspension == true then
			
			local Elastic2 = self.Elastics[30]
			
			if IsValid(Elastic2) then
				Elastic2:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rl * -new )
			end
		end
	end
	
	if IsValid(self.Wheels[4]) then
		local Elastic = self.Elastics[4]
		if IsValid(Elastic) then
			Elastic:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rr * -new )
		end
		
		if self.StrengthenSuspension == true then
			
			local Elastic2 = self.Elastics[40]
			
			if IsValid(Elastic2) then
				Elastic2:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rr * -new )
			end
		end
	end
	
	if IsValid(self.Wheels[5]) then
		local Elastic = self.Elastics[5]
		if IsValid(Elastic) then
			Elastic:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rl * -new )
		end
		
		if self.StrengthenSuspension == true then
			
			local Elastic2 = self.Elastics[50]
			
			if IsValid(Elastic2) then
				Elastic2:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rl * -new )
			end
		end
	end
	
	if IsValid(self.Wheels[6]) then
		local Elastic = self.Elastics[6]
		if IsValid(Elastic) then
			Elastic:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rr * -new )
		end
		
		if self.StrengthenSuspension == true then
			
			local Elastic2 = self.Elastics[60]
			
			if IsValid(Elastic2) then
				Elastic2:Fire( "SetSpringLength", self.RearHeight + self.VehicleData.suspensiontravel_rr * -new )
			end
		end
	end
end

function ENT:OnTurboCharged( name, old, new )
	if old == new then return end
	local Active = self:GetActive()
	
	if new == true and Active then
		self.Turbo:Stop()
		self.Turbo = CreateSound(self, self.snd_spool or "simulated_vehicles/turbo_spin.wav")
		self.Turbo:PlayEx(0,0)
		
	elseif new == false then
		if self.Turbo then
			self.Turbo:Stop()
		end
	end
end

function ENT:OnSuperCharged( name, old, new )
	if old == new then return end
	local Active = self:GetActive()
	
	if new == true and Active then
		self.Blower:Stop()
		self.BlowerWhine:Stop()
		
		self.Blower = CreateSound(self, self.snd_bloweroff or "simulated_vehicles/blower_spin.wav")
		self.BlowerWhine = CreateSound(self, self.snd_bloweron or "simulated_vehicles/blower_gearwhine.wav")
	
		self.Blower:PlayEx(0,0)
		self.BlowerWhine:PlayEx(0,0)
	elseif new == false then
		if self.Blower then
			self.Blower:Stop()
		end
		if self.BlowerWhine then
			self.BlowerWhine:Stop()
		end
	end
end

function ENT:OnRemove()
	if self.Wheels then
		for i = 1, table.Count( self.Wheels ) do
			local Ent = self.Wheels[ i ]
			if IsValid(Ent) then
				Ent:Remove()
			end
		end
	end
	if self.keys then
		for i = 1, table.Count( self.keys ) do
			numpad.Remove( self.keys[i] )
		end
	end
	if self.Turbo then
		self.Turbo:Stop()
	end
	if self.Blower then
		self.Blower:Stop()
	end
	if self.BlowerWhine then
		self.BlowerWhine:Stop()
	end
	if self.horn then
		self.horn:Stop()
	end
	if self.ems then
		self.ems:Stop()
	end
	
	self:OnDelete()
end

function ENT:PlayPP( On )
	self.poseon = On and self.LightsPP.max or self.LightsPP.min
end

function ENT:SetOnFire( bOn )
	if bOn == self:OnFire() then return end
	self:SetNWBool( "OnFire", bOn )
	
	if bOn then
		self:DamagedStall()
	end
end

function ENT:SetOnSmoke( bOn )
	if bOn == self:OnSmoke() then return end
	self:SetNWBool( "OnSmoke", bOn )
	
	if bOn then
		self:DamagedStall()
	end
end

function ENT:SetMaxHealth( nHealth )
	self:SetNWFloat( "MaxHealth", nHealth )
end

function ENT:SetCurHealth( nHealth )
	self:SetNWFloat( "Health", nHealth )
end

function ENT:SetMaxFuel( nFuel )
	self:SetNWFloat( "MaxFuel", nFuel )
end

function ENT:SetFuel( nFuel )
	self:SetNWFloat( "Fuel", math.Clamp( nFuel,0,self:GetMaxFuel() ) )
end

function ENT:SetFuelUse( nFuel )
	self:SetNWFloat( "FuelUse", nFuel )
end

function ENT:SetFuelType( fueltype )
	self:SetNWInt( "FuelType", fueltype )
end

function ENT:SetFuelPos( vPos )
	self:SetFuelPortPosition( vPos )
end

