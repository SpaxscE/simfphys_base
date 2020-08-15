--DO NOT EDIT OR REUPLOAD THIS FILE

local NEXT_THINK = 0
local CURRENT_STEP = 0
local MAX_STEP = 0
local NPC_LIST = {}
local VEHICLE_LIST = {}

local NPCsStored = {}
local NextNPCsGetAll = 0

hook.Add( "OnEntityCreated", "!!11!!!simfphysEntitySorter", function( ent )
	timer.Simple( FrameTime(), function() 
		if not IsValid( ent ) then return end

		if isfunction( ent.IsNPC ) and ent:IsNPC() then table.insert( NPCsStored, ent ) end
	end )
end )

local function GetNPCs()
	local Time = CurTime()
	
	if NextNPCsGetAll < Time then
		NextNPCsGetAll = Time + FrameTime()

		for index, npc in ipairs( NPCsStored ) do
			if not IsValid( npc ) then
				NPCsStored[ index ] = nil
			end
		end
	end

	return NPCsStored
end

hook.Add( "Think", "!!!!!!!simfphysNPCRelationshipHandler", function()
	local TIME = CurTime()

	if NEXT_THINK < TIME then
		NEXT_THINK = TIME + 0.02 -- lets make sure we build relationship for only one vehicle per 0.02  seconds so it doesn't destroy your servers fps

		if CURRENT_STEP >= MAX_STEP then
			NPC_LIST = GetNPCs() -- get all npcs
			VEHICLE_LIST = ents.FindByClass( "gmod_sent_vehicle_fphysics_base" ) -- get all vehicles

			NEXT_THINK = TIME + 2 -- wait 2 seconds after each loop so it doesn't spam expensive Get-functions on tick
			
			CURRENT_STEP = 0 -- reset steps
			
			MAX_STEP = table.Count( VEHICLE_LIST )

		else
			CURRENT_STEP = CURRENT_STEP + 1

			local VEHICLE = VEHICLE_LIST[ CURRENT_STEP ]
			if not IsValid( VEHICLE ) then return end

			for _, NPC in ipairs( NPC_LIST ) do
				if IsValid( NPC ) then
					local Enemy = NPC:GetEnemy()
					if IsValid( Enemy ) then
						if Enemy:IsPlayer() then
							NPC.simfphysLastEnemy = Enemy

							if VEHICLE == Enemy:GetSimfphys() then
								NPC:AddEntityRelationship( VEHICLE, D_HT, 99 )
								for _, wheel in ipairs( VEHICLE.Wheels ) do
									if IsValid( wheel ) then
										NPC:AddEntityRelationship( wheel, D_HT, 99 )
									end
								end
							end
						else
							if Enemy:GetClass() == "gmod_sent_vehicle_fphysics_wheel" then
								Enemy = Enemy:GetBaseEnt()
							end

							if Enemy == VEHICLE then
								if IsValid( NPC.simfphysLastEnemy ) then
									if NPC.simfphysLastEnemy:GetSimfphys() ~= VEHICLE then
										NPC:AddEntityRelationship( VEHICLE, D_LI, 99 )
										for _, wheel in ipairs( VEHICLE.Wheels ) do
											if IsValid( wheel ) then
												NPC:AddEntityRelationship( wheel, D_LI, 99 )
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end
end)
