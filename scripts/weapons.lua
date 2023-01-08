--Functions and Variables
local path = mod_loader.mods[modApi.currentMod].resourcePath
local mod = mod_loader.mods[modApi.currentMod]
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath

local debugging = true
local test_scenario_counts = true --useful for getting achievements in the test scenario, although it screws with mission hooks

local function CheckRealConditions() -- check that we're not in tip image, attack preview, test scenario, etc.
	if ((IsTestMechScenario() or not mission) and not test_scenario_counts) or modApi:isTipImage() then
		return false
	end
	return true
end

Machin_Prime_PropellerLegs = Prime_TC_Feint:new{  
	Class = "Prime",
	Name = "Propeller Legs",
	Description = "Leap and attack a tile at any range, dealing damage and pushing it.",
	Icon = "weapons/MachinPropellerLegsIcon.png",
	Rarity = 3,
	Explosion = "explodrill",
	LaunchSound = "weapons/titan_fist",
	Range = 8, -- Tooltip?
	PathSize = 1,
	Damage = 1,
	SelfDamage = 0, 
	Push = 1, --Mostly for tooltip, but you could turn it off for some unknown reason
	PowerCost = 0,
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
	if CheckRealConditions() then
			if debugging then LOG("Checking temp killcount...") end
			ret:AddDelay(1.016)
			ret:AddScript("Machin_Prime_PropellerLegs:CheckTempKillcount()")
	end
	return ret
end	
function Machin_Prime_PropellerLegs:ResetTempKillcount()
	if debugging then LOG("Resetting temp killcount...") end
	if not CheckRealConditions() then return end
	--local m = GetCurrentMission()
	m = GetCurrentMission()
	m.propeller_temp_kills = 0
end
function Machin_Prime_PropellerLegs:CheckTempKillcount()	
	if debugging then LOG("We've called CheckTempKillcount. Checking if this is a real mission...") end
	if not CheckRealConditions() then return end
	
	m = GetCurrentMission()
	
	--local m = GetCurrentMission()
	if debugging then LOG("Yes. This isn't a tip image, preview or test scenario.") end
	if debugging then LOG("Kill count is "..m.propeller_kills..", temp count is "..m.propeller_temp_kills) end


	if m.propeller_temp_kills > 0 then
		m.propeller_kills = m.propeller_kills+m.propeller_temp_kills
		Machin_Prime_PropellerLegs:ResetTempKillcount()
		if debugging then LOG("Regular killcount has been updated to: "..m.propeller_kills) end
		if m.propeller_kills >= m.propeller_kills_goal then
			modApi.achievements:trigger("Machin - Storm Heralds","machin_ach_pounce",true)
			if debugging then LOG("That's enough to trigger the achievement!") end
		end
	end
	if debugging then LOG("Kill count is "..m.propeller_kills..", temp count is "..m.propeller_temp_kills) end
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
	PowerCost = 0,
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
	end
	
	local hide_initial_jolt = true
	
	while #todo ~= 0 do
		local current = pop_back(todo)
		
		if not explored[hash(current)] then
			explored[hash(current)] = true
			
			if Board:IsPawnSpace(current) or (self.SmokeChain and Board:IsSmoke(current)) then
				if (self.SmokeChain and Board:IsSmoke(current)) and CheckRealConditions()  then
					ret:AddScript("modApi.achievements:addProgress('Machin - Storm Heralds','machin_ach_chainsmoke', 1)")
					--local logthis = "Added progress on Chain Smoker. Current is: "..tostring(modApi.achievements:getProgress('Machin - Storm Heralds','machin_ach_chainsmoke'))
					--if debugging then ret:AddScript("LOG(logthis)") end
				end
				local direction = GetDirection(current - origin[hash(current)])
				if hide_initial_jolt then
					hide_initial_jolt = false
				else
					damage.sAnimation = "Lightning_Attack_"..direction
				end
				damage.loc = current
				damage.iDamage = self.Damage
				
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
	
	return ret
end

Machin_Science_FulminantSmoke = Skill:new{
	Icon = "weapons/MachinFulminantSmokeIcon.png",
	Class = "Science",
	Name = "Smoke Detonator",
	Description = "Removes Smoke, damaging the tile and four adjacent or oblique tiles. Grid Buildings are immune.", 
	PowerCost = 0,
	Range = 0,
	LaunchSound = "",--"/weapons/void_shocker",-- 
	Damage = 2,
	SelfDamage = 0,
	ShieldFriendly = false,
	TwoClick = true, --Can just revert to 1-click if desired, the way I've set it up :D
	Upgrades = 2,
	UpgradeCost = {2,2},
	TipIndex = 0,
	TipImage = {
		Unit = Point(1,3),
		Enemy = Point(2,1),
		Smoke = Point(2,1),
		Building = Point(1,2),
		Building2 = Point(1,1),
		Target = Point(2,1),
		Second_Click = Point(3,2), 
		Length = 5,
	}
}

Machin_Science_FulminantSmoke_A = Machin_Science_FulminantSmoke:new{
	Damage = 3,
}
Machin_Science_FulminantSmoke_B = Machin_Science_FulminantSmoke:new{
	ShieldFriendly = true,
	TipImage = {
		Unit = Point(1,3),
		Enemy = Point(2,1),
		Smoke = Point(2,1),
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
	if modApi:isTipImage() then 
		if self.TipIndex == 0 then
			self.TipIndex = 1
			oblique = false
		else
			self.TipIndex = 0
			oblique = true
		end
	end
	
	if not modApi:isTipImage() then ret:AddDelay(0.25) end
	
	local damage = SpaceDamage(p2, 0)
	damage.sAnimation = "LightningBolt"..random_int(2)
	ret:AddSound("/props/lightning_strike")
	if not modApi:isTipImage() then ret:AddDelay(1) end
	ret:AddDamage(damage)
	
	local ach_progress = 0 --Fulmination achievement
	
	local nosmoke = SpaceDamage(p2,0)
	nosmoke.iSmoke = EFFECT_REMOVE
	ret:AddDamage(nosmoke)
	
	for i = DIR_START,DIR_END do
		--starfish attack
		local current = p2 + DIR_VECTORS[i]
		if oblique then current = p2 + DIR_VECTORS[i] + DIR_VECTORS[(i+1)%4] end
		
		--regular orthogonal
		if not Board:IsBuilding(current) then
			if self.ShieldFriendly and Board:IsPawnTeam(current, TEAM_PLAYER) then
				damage = SpaceDamage(current, 0)
				
				damage.sAnimation = "exploout0_"..i   
				damage.iShield = 1
				ret:AddDamage(damage)
				
				ach_progress = ach_progress + 1
			else
				damage = SpaceDamage(current, self.Damage)
				--Some day I'd like to use oblique explosion animations. See init.lua. This will have to do though.
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
	
	if debugging then LOG("Checking fulmination... Progress is: "..tostring(ach_progress)) end
	if ach_progress >= 3 and CheckRealConditions() then
		if debugging then LOG("Fulmination triggered!") end
		ret:AddScript("modApi.achievements:trigger('Machin - Storm Heralds','machin_ach_fulmination',true)")
	end
	
	return ret
end 

-- weapon.lua achievement tracker
local this = {}

function this:load(mod, options, version)
	if debugging then LOG("Loading MissionStart, PawnKilled and SkillStart hooks from weapons.lua.") end

	local hook = function(mission)
		if debugging then LOG("Initiating kill counter.") end
		-- Initiate Propeller Legs killcount progress on mission start
		if not CheckRealConditions() then return end
		m = GetCurrentMission()
		m.propeller_temp_kills = 0
		m.propeller_kills = 0
		m.propeller_kills_goal = 5
	end
	modApi:addMissionStartHook(hook)
	
	local hook = function(m, pawn)
		if CheckRealConditions() then
			if pawn:GetTeam() == TEAM_ENEMY then
				if debugging then LOG("Incrementing temp kill counter!") end
				m.propeller_temp_kills = m.propeller_temp_kills+1
			end
		end
	end
	modapiext:addPawnKilledHook(hook)

	local hook = function(mission, pawn, weaponId, p1, p2)
		if CheckRealConditions() then
			--m = GetCurrentMission()
			if debugging then LOG("Resetting temp kill counter") end
			--Someone started using a skill, reset the temp killcount tracker
			Machin_Prime_PropellerLegs:ResetTempKillcount()
		end
	end
	modapiext:addSkillStartHook(hook)
end
return this
