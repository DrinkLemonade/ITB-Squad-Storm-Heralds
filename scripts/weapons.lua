--Functions and Variables
local path = mod_loader.mods[modApi.currentMod].resourcePath
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local previewer = require(scriptPath.."weaponPreview/api")
local modApiExt = require(mod.scriptPath.."modApiExt/modApiExt")

--local achvApi = require(path .."scripts/achievements/api")
local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

Machin_Prime_PropellerLegs = Prime_TC_Feint:new{  
	Class = "Prime",
	Name = "Propeller Legs",
	Description = "Leap and attack a tile at any range, dealing damage and pushing it.",
	Icon = "weapons/MachinPropellerLegsIcon.png",
	Rarity = 3,
	Explosion = "explodrill",
	LaunchSound = "weapons/titan_fist",--"/weapons/wind",
	Range = 8, -- Tooltip?
	PathSize = 1,
	Damage = 1,
	SelfDamage = 0, 
	Push = 1, --Mostly for tooltip, but you could turn it off for some unknown reason
	PowerCost = 0, --AE Change
	Upgrades = 2,
	UpgradeCost = {2,3},
	TipImage = {
		Unit = Point(2,3),
		Enemy = Point(3,1),
		Target = Point(2,1),
		Second_Click = Point(3,1),
	}
}

Machin_Prime_PropellerLegs_A = Machin_Prime_PropellerLegs:new{
	Damage = 2,
}
Machin_Prime_PropellerLegs_B = Machin_Prime_PropellerLegs:new{
	Damage = 2,
}
Machin_Prime_PropellerLegs_AB = Machin_Prime_PropellerLegs:new{
	Damage = 3,
}

--I don't like having to copy-paste Spring-Loaded Legs's whole code, but I dunno if there's a better way
function Machin_Prime_PropellerLegs:GetFinalEffect(p1, p2, p3)
	local ret = Prime_TC_Feint.GetFinalEffect(self,p1,p2,p3)
	if not IsTipImage() then
			ret:AddDelay(1.016)
			ret:AddScript("Machin_Prime_PropellerLegs:CheckTempKillcount()")
	end
	return ret
end	
function Machin_Prime_PropellerLegs:ResetTempKillcount()
	local m = GetCurrentMission()
	if not m or not Board then return end
	m.machin_propeller_temp_kills = 0
end
function Machin_Prime_PropellerLegs:CheckTempKillcount()
	LOG("We've called CheckTempKillcount")
	local m = GetCurrentMission()
	--if not m or not Board then return end
	--LOG("We didn't exit prematurely")

	if m.machin_propeller_temp_kills > 0 then
		m.machin_propeller_kills = m.machin_propeller_kills+m.machin_propeller_temp_kills
		LOG("Regular killcount has been updated to:")
		LOG(m.machin_propeller_kills)
		if m.machin_propeller_kills >= m.machin_propeller_kills_goal then
			modApi.achievements:trigger("Machin - Storm Heralds","machin_ach_pounce")
			--ret:AddScript("machin_stormsquad_Chievo('machin_storm_pounce')")
		end
	end
	LOG("Kill count is ")
	LOG(m.machin_propeller_kills)
	LOG("Temp count is")
	LOG(m.machin_propeller_temp_kills)
end
			 

Machin_Ranged_ZeusArtillery = LineArtillery:new{
	Class = "Ranged",
	Name = "Zeus Artillery",
	Description = "Chains damage through adjacent targets and creates Smoke behind the shooter.",
	Icon = "weapons/MachinZeusArtilleryIcon.png",
	Sound = "",
	ArtilleryStart = 2,
	ArtillerySize = 8,
	Explosion = "",
	PowerCost = 0, --AE Change
	BounceAmount = 1,
	Damage = 2,
	LaunchSound = "/weapons/grid_defense",
	ImpactSound = "/weapons/electric_whip",
	Upgrades = 2,
	Push = false,
	SmokeChain = false,
	UpShot = "effects/shotup_grid.png",
	FriendlyDamage = true,

	UpgradeCost = { 1 , 3 },
	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(2,1),
		Enemy2 = Point(2,0),
		Enemy3 = Point(3,0),
	}
}

Machin_Ranged_ZeusArtillery_A = Machin_Ranged_ZeusArtillery:new{
	SmokeChain = true,

	TipImage = {
		Unit = Point(2,3),
		Target = Point(2,1),
		Enemy1 = Point(2,1),
		Smoke = Point(2,0),
		Building = Point(1,1),
		Smoke2 = Point(1,1),
		Enemy2 = Point(3,0),
	}
}

Machin_Ranged_ZeusArtillery_B = Machin_Ranged_ZeusArtillery:new{
	Damage = 3,
}

Machin_Ranged_ZeusArtillery_AB = Machin_Ranged_ZeusArtillery_A:new{
	Damage = 3,
}

function Machin_Ranged_ZeusArtillery:GetSkillEffect(p1, p2)
	local ret = SkillEffect()
	local damage = SpaceDamage(p2,self.Damage)
	local hash = function(point) return point.x + point.y*10 end
	local explored = {[hash(p1)] = true}
	local todo = {p2}
	local origin = { [hash(p2)] = p1 }
	
	ret:AddArtillery(SpaceDamage(p2,0), self.UpShot, FULL_DELAY)
	
	if Board:IsPawnSpace(p2) or (self.SmokeChain and Board:IsSmoke(p2)) then
		ret:AddAnimation(p2,"Lightning_Hit")
		--if self.SmokeChain and Board:IsSmoke(p2) then
			--achvApi:TriggerChievo("chainsmoke", {progress = 0})
		--end
	end
	
	local hide_initial_jolt = true
	
	while #todo ~= 0 do
		local current = pop_back(todo)
		
		if not explored[hash(current)] then
			explored[hash(current)] = true
			
			if Board:IsPawnSpace(current) or (self.SmokeChain and Board:IsSmoke(current)) then
				if (self.SmokeChain and Board:IsSmoke(current)) and not IsTipImage() then
					ret:AddScript("modApi.achievements:addProgress('Machin - Storm Heralds','machin_ach_chainsmoke', 1)")
					LOG("Added progress on Chain Smoker. Current is: "..tostring(modApi.achievements:getProgress('Machin - Storm Heralds','machin_ach_chainsmoke')))
				end
				local direction = GetDirection(current - origin[hash(current)])
				if hide_initial_jolt then
					hide_initial_jolt = false
				else
					damage.sAnimation = "Lightning_Attack_"..direction
				end
				damage.loc = current
				damage.iDamage = self.Damage-- Board:IsSmoke(current) and DAMAGE_ZERO or self.Damage
				
				if Board:IsBuilding(current) then
					damage.iDamage = DAMAGE_ZERO
				end
				
				ret:AddDamage(damage)
				
				if not Board:IsSmoke(current) then
					ret:AddAnimation(current,"Lightning_Hit")
				end
				
				for i = DIR_START, DIR_END do
					local neighbor = current + DIR_VECTORS[i]
					if not explored[hash(neighbor)] then
						todo[#todo + 1] = neighbor
						origin[hash(neighbor)] = current
					end
				end
			end		
		end
	end
	
	--Add smoke at the end so it doesn't mess up the current attack's Smoke Chain	
	local smoke = SpaceDamage(p1 - DIR_VECTORS[GetDirection(p2 - p1)],0)
	smoke.iSmoke = 1
	smoke.sAnimation = "exploout0_"..GetDirection(p1 - p2)
	ret:AddDamage(smoke)
	
	return ret
end	

Machin_Science_ConfusionFumes = Skill:new {
	Range = 1,
	PathSize = 1,
	Class = "Science",
	Name = "Proximity Fumes",
	Description = "Creates Smoke on an adjacent tile.", 
	Icon = "weapons/MachinConfusionFumesIcon.png",
	Explosion = "ExploRepulse3",
	Explo = "airpush_",
	ProjectileArt = "effects/shot_confuse",
	Damage = 0,
	SelfDamage = 0,
	Push = 0,
	Flip = 0,--1,
	PowerCost = 0,
	Upgrades = 0,
	UpgradeCost = {1,2},
	LaunchSound = "",
	ImpactSound = "",
	--CustomTipImage = "Machin_Science_ConfusionFumes_Tip",
	TipImage = StandardTips.Melee,
	LaunchSound = "/weapons/defensive_smoke",
}

function Machin_Science_ConfusionFumes:GetSkillEffect(p1,p2)
	local ret = SkillEffect()
	local direction = GetDirection(p2 - p1)
	local target = p2--GetProjectileEnd(p1,p2,PATH_PROJECTILE)  
	
	local smoke = SpaceDamage(p2,0)
	smoke.iSmoke = 1
	smoke.sAnimation = "exploout0_"..GetDirection(p2 - p1)
	ret:AddDamage(smoke)
	
	--Old Flip + Smoke behind code
	--[[local damage = SpaceDamage(target, self.Damage)
	if self.Flip == 1 then
		damage = SpaceDamage(target,self.Damage,DIR_FLIP)
	end
	ret:AddDamage(damage)
	
	local smoke = SpaceDamage(p1 - DIR_VECTORS[GetDirection(p2 - p1)],0)
	smoke.iSmoke = 1
	smoke.sAnimation = "exploout0_"..GetDirection(p1 - p2)
	ret:AddDamage(smoke)--]]
	
	return ret
end

Machin_Science_FulminantSmoke = Skill:new{
	Icon = "weapons/MachinFulminantSmokeIcon.png",
	Class = "Science",
	Name = "Smoke Detonator",
	Description = "Removes Smoke, damaging the tile and four adjacent or oblique tiles. Grid Buildings are immune.", 
	PowerCost = 0,
	--Limited = 2,
	Range = 0,
	LaunchSound = "/props/lightning_strike",--"/weapons/void_shocker",-- 
	--Explosion = "explo_fire1",  --explo_fire1
	--ZoneTargeting = ZONE_ALL,
	Damage = 2,
	SelfDamage = 0,
	ShieldFriendly = false,
	TwoClick = true, --Can just revert to 1-click if desired, the way I've set it up :D
	--CustomTipImage = "Machin_Science_FulminantSmoke_Tooltip",
	Upgrades = 2,
	UpgradeCost = {2,2},
	TipIndex = 0,
	--CustomTipImage = "Machin_Science_FulminantSmoke_Tip",
	--[[TipImage = {
		Unit = Point(1,3),
		Enemy = Point(1,1),
		Enemy = Point(2,1),
		Smoke = Point(2,1),
		Building = Point(1,2),
		Target = Point(2,1),
		Second_Click = Point(3,2), 
		Length = 5
	}--]]
	TipImage = {
		Unit = Point(1,3),
		Enemy = Point(2,1),
		--Enemy = Point(4,1),
		Smoke = Point(2,1),
		--Smoke2 = Point(2,2),
		Building = Point(1,2),
		Building2 = Point(1,1),
		Target = Point(2,1),
		Second_Click = Point(3,2), 
		Length = 5,
	}
}

--[[Machin_Science_FulminantSmoke_Tip = Machin_Science_FulminantSmoke:new{
	TipImage = {
		Unit = Point(1,3),
		Enemy = Point(2,1),
		--Enemy = Point(4,1),
		Smoke = Point(2,1),
		--Smoke2 = Point(2,2),
		Building = Point(1,2),
		Target = Point(2,1),
		Second_Click = Point(3,2), 
		Length = 5,
	}
}

function Machin_Science_FulminantSmoke_Tip:GetSkillEffect(p1,p2)
	local ret = SkillEffect()

	local damage = SpaceDamage(0)
	damage.bHide = true
	--damage.fDelay = 1.5
	damage.sScript = "Board:GetPawn(Point(1,3)):FireWeapon(Point(2,1),1) Board:GetPawn(Point(1,3)):FireWeapon(Point(3,2),1)"
	--damage.sScript = "Board:GetPawn(Point(4,1)):FireWeapon(Point(2,2),1) Board:GetPawn(Point(1,3)):FireWeapon(Point(2,3),1)"
	ret:AddDamage(damage)
	
	local resetsmoke = SpaceDamage(0)
	resetsmoke.bHide = true
	--resetsmoke.iSmoke = 1
	resetsmoke.fDelay = 1.5
	ret:AddDamage(resetsmoke)
	
	local damage2 = SpaceDamage(0)
	damage2.bHide = true
	damage2.fDelay = 1.5
	damage2.sScript = "Board:GetPawn(Point(2,2)):FireWeapon(Point(2,1),1)"
	--damage2.sScript = "Board:GetPawn(Point(1,3)):FireWeapon(Point(2,2),1)"
	ret:AddDamage(damage2)
	
	return ret
end
--]]
Machin_Science_FulminantSmoke_A = Machin_Science_FulminantSmoke:new{
	Damage = 3,
}
Machin_Science_FulminantSmoke_B = Machin_Science_FulminantSmoke:new{
	ShieldFriendly = true,
	TipImage = {
		Unit = Point(1,3),
		Enemy = Point(2,1),
		--Enemy = Point(4,1),
		Smoke = Point(2,1),
		--Smoke2 = Point(2,2),
		Building = Point(1,2),
		Building2 = Point(1,1),
		Target = Point(2,1),
		Second_Click = Point(3,2),
		Friendly = Point(3,2),
		Friendly2 = Point(3,1),
		Length = 5,
	}
}
Machin_Science_FulminantSmoke_AB = Machin_Science_FulminantSmoke_B:new{
	Damage = 3,
}

function Machin_Science_FulminantSmoke:GetTargetArea(point)
	local ret = PointList()
	local board_size = Board:GetSize()
	for i = 0, 7 do
		for j = 0, 7  do
			local point = Point(i,j)
			if Board:IsSmoke(point) then
				ret:push_back(point)
			end
		end
	end
		
	return ret
end

function Machin_Science_FulminantSmoke:GetSecondTargetArea(p1,p2)
	local ret = PointList()
	local direction = GetDirection(p2 - p1)
	
	--Return adjacent tiles
	for i = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[i]
		if Board:IsValid(curr) then
			ret:push_back(curr)
		end
	end
	--Return oblique tiles
	for i = DIR_START, DIR_END do
		local curr = p2 + DIR_VECTORS[i] + DIR_VECTORS[(i+1)%4]
		if Board:IsValid(curr) then
			ret:push_back(curr)
		end
	end

	return ret
end

function Machin_Science_FulminantSmoke:GetSkillEffect(p1, p2)
	--Not sure if necessary. TC_Feint had it.
	local ret = SkillEffect()
	if not self.TwoClick then ret = Machin_Science_FulminantSmoke:GetFinalEffect(p1,p2,p2) end
	ret:AddDamage(SpaceDamage(p2, 0))
	return ret
end

function Machin_Science_FulminantSmoke:GetFinalEffect(p1, p2, p3)
	local ret = SkillEffect()
	
	local oblique = true --we're hitting oblique by default
	--Take p2's x,y coordinates and look at which p3 is being clicked
	--If we're clicking on x(+/-)1,y0 or  x0,y(+/-)1 compared to p2, that's adjacent. otherwise it's oblique
	--So let's flip negative x or y values back to positive and add x + y. If the result is 1 we're hitting adjacent, otherwise oblique
	if self.TwoClick then
		local get_x = p3.x - p2.x
		local get_y = p3.y - p2.y
		if get_x < 0 then get_x = -get_x end
		if get_y < 0 then get_y = -get_y end
		if get_x + get_y == 1 then oblique = false end --hitting adjacent
	end
	
	--Alternate adjacent and oblique in tip image
	if IsTipImage() then 
		if self.TipIndex == 0 then
			self.TipIndex = 1
			oblique = false
		else
			self.TipIndex = 0
			oblique = true
		end
	end
	
	local delay = SpaceDamage(p2, 0)
	ret:AddDamage(delay)
	if not IsTipImage() then ret:AddDelay(0.5) end
	
	local damage = SpaceDamage(p2, 0)
	local ach_progress = 0 --Fulmination achievement
	--ret:AddBounce(p2, 3)
	damage.sAnimation = "LightningBolt"..random_int(2)
	--damage.sSound = "/weapons/void_shock"--"/props/lightning_strike"
	--damage.sSound = "/weapons/void_shocker"
	ret:AddDamage(damage)
	
	local nosmoke = SpaceDamage(p2,0)
	nosmoke.iSmoke = EFFECT_REMOVE
	ret:AddDamage(nosmoke)
	
	
	
	for i = DIR_START,DIR_END do
		--starfish attack
		local current = p2 + DIR_VECTORS[i]
		if oblique then current = p2 + DIR_VECTORS[i] + DIR_VECTORS[(i+1)%4] end
		
		--regular orthogonal
		--local current = p2 + DIR_VECTORS[i]
		if not Board:IsBuilding(current) then
			if self.ShieldFriendly and Board:IsPawnTeam(current, TEAM_PLAYER) then
				damage = SpaceDamage(current, 0)
				damage.sAnimation = "exploout0_"..i   
				damage.iShield = 1
				ret:AddDamage(damage)
				
				ach_progress = ach_progress + 1
			else--if not Board:IsPawnSpace(p2) then
				damage = SpaceDamage(current, self.Damage)
				--damage.sSound = "/impact/generic/explosion"
				damage.sAnimation = "exploout2_"..i
				ret:AddDamage(damage)
				ret:AddBounce(current, 2)
				
				if Board:IsPawnTeam(current, TEAM_ENEMY) then
					ach_progress = ach_progress + 1
				end
			end
		else
			damage = SpaceDamage(current, DAMAGE_ZERO)
			ret:AddDamage(damage)
		end
	end

		--lazy copy-paste to do this on the center tile, too.
		-- central animation isn't working?
	if not Board:IsBuilding(p2) then
		if self.ShieldFriendly and Board:IsPawnTeam(p2, TEAM_PLAYER) then
			local center = SpaceDamage(p2, 0)
			center.sAnimation = "explo_artillery0" --different animation
			center.iShield = 1
			ret:AddDamage(center)
			
			ach_progress = ach_progress + 1
		else--if not Board:IsPawnSpace(p2) then
			local center = SpaceDamage(p2, self.Damage)
			--center.sSound = "/impact/generic/explosion"
			center.sAnimation = "explo_artillery1" --different animation
			ret:AddDamage(center)
			ret:AddBounce(p2, 2)
			
			if Board:IsPawnTeam(p2, TEAM_ENEMY) then
					ach_progress = ach_progress + 1
			end
		end
	else
		local center = SpaceDamage(p2, DAMAGE_ZERO)
		ret:AddDamage(center)
	end
	
	LOG("Checking fulmination... Progress is: "..tostring(ach_progress))
	if ach_progress >= 3 and not IsTipImage() then--and not IsTestMechScenario() and not IsTipImage() then
		LOG("Fulmination triggered!")
		ret:AddScript("modApi.achievements:trigger('Machin - Storm Heralds','machin_ach_fulmination',true)")
		--ret:AddScript("machin_stormsquad_Chievo('machin_storm_fulmination')")
	end
	if not mission then
		LOG("wtf?")
	end
	
	return ret
end

-- weapon.lua achievement tracker
local this = {}

function this:load(mod, options, version)
	LOG("Loading MissionStart, PawnKilled and SkillStart hooks from weapons.lua.")

	local hook = function()
		LOG("Mission starts hook")
		-- Initiate Propeller Legs killcount progress on mission start
		local m = GetCurrentMission()
		if not m then return end
		LOG("Initializing Propeller variables...")
		m.machin_propeller_temp_kills = 0
		m.machin_propeller_kills = 0
		m.machin_propeller_kills_goal = 5
		--local id = "machin_achv_pounce"
		--m[id] = 0
	end
	modApi:addMissionStartHook(hook)
	
	--modApi:addMissionStartHook(startHook)
	--LOG("Adding Propeller achievement hooks...")
	local hook = function(m, pawn)
	LOG("pawn killed (weapsns hook)")
		if pawn:GetTeam() == TEAM_ENEMY then
			LOG("Incrementing temp kill counter!")
			m.machin_propeller_temp_kills = m.machin_propeller_temp_kills+1
		end
	end
	Machin_StormHeralds_ModApiExt:addPawnKilledHook(hook)

	local hook = function(mission, pawn, weaponId, p1, p2)
		local m = GetCurrentMission()
		if not m or not Board then return end
		
		if not IsTipImage() then
			LOG("Resetting temp kill counter")
			--Someone started using a skill, reset the temp killcount tracker
			Machin_Prime_PropellerLegs:ResetTempKillcount()
		end
	end
	Machin_StormHeralds_ModApiExt:addSkillStartHook(hook)
end
return this