local function init(self)
	--init variables
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	--libs
	local sprites = require(path .."libs/sprites")
	local palettes = require(self.scriptPath .."libs/customPalettes")
	local mod = mod_loader.mods[modApi.currentMod]
	local resourcePath = mod.resourcePath
	local scriptPath = mod.scriptPath
	
	--ModApiExt
	if modApiExt then
		-- modApiExt already defined. This means that the user has the complete
		-- ModUtils package installed. Use that instead of loading our own one.
		Machin_StormHeralds_ModApiExt = modApiExt
	else
		-- modApiExt was not found. Load our inbuilt version
		local extDir = self.scriptPath.."modApiExt/"
		Machin_StormHeralds_ModApiExt = require(extDir.."modApiExt")
		Machin_StormHeralds_ModApiExt:init(extDir)
	end
	
	--require(self.scriptPath .."achievements/init")
	--require(self.scriptPath .."achievements")
	--require(self.scriptPath .."achievementTriggers"):init()
	
	--Achievements
	--local achvApi = require(self.scriptPath.."/achievements/api")
	modApi.achievements:add{
	id = "machin_ach_pounce",
	name = "Tacklepounce",
	image = resourcePath.."img/achievements/pounce.png",
	tooltip = "Kill 5 Vek with Propeller Legs in one mission.",
	objective = 5,
	squad = "Machin - Storm Heralds"
	}
	modApi.achievements:add{
	id = "machin_ach_chainsmoke",
	name = "Chain Smoker",
	image = resourcePath.."img/achievements/chainsmoke.png",
	tooltip = "Have Zeus Artillery chain through 40 Smoke tiles in one game. (Currently you only need 4 tiles for testing purposes)",
	objective = 40,
	squad = "Machin - Storm Heralds"
	}
	modApi.achievements:add{
	id = "machin_ach_fulmination",
	name = "Fulmination (Is A Cool Word)",
	image = resourcePath.."img/achievements/fulmination.png",
	tooltip = "Use Smoke Detonator on at least 3 units (harming Enemies, shielding Allies or both).",
	objective = true,
	squad = "Machin - Storm Heralds"
	}
	
	--Sprites
	sprites.addMechs(
		{
			Name = "Machin_Strike_Mech",
			Default = {PosX = -17, PosY = -8},
			Broken = {PosX = -17, PosY = -8, NumFrames = 1, Loop = true},
			Animated = {PosX = -17, PosY = -8, NumFrames = 4},
			Submerged = {PosX = -17, PosY = 8},
			SubmergedBroken = {PosX = -17, PosY = 5},
			Icon = {},
		},
		{
			Name = "Machin_Jolt_Mech",
			Default = {PosX = -17, PosY = -9},
			Broken = {PosX = -17, PosY = -9, NumFrames = 1, Loop = true},
			Animated = {PosX = -17, PosY = -9, NumFrames = 4},
			Submerged = {PosX = -16, PosY = -4, NumFrames = 4},
			SubmergedBroken = {PosX = -16, PosY = -4},
			Icon = {},
		},
		{
			Name = "Machin_Fulminant_Mech",
			Default = {PosX = -14, PosY = -15},
			Broken = {PosX = -17, PosY = -16, NumFrames = 1, Loop = true},
			Animated = {PosX = -14, PosY = -15, NumFrames = 4},
			Submerged = {PosX = -14, PosY = -1}, --Unused, cause flying, but I still need it
			SubmergedBroken = {PosX = -17, PosY = -12},
			Icon = {},
		}
	)
	
	--Palette
	palettes.addPalette({
		ID = "Machin_StormHeralds",
		Name = "Storm Heralds",
		PlateHighlight = {122, 205,  250},
		PlateLight     = {208, 183,  123}, --{219, 204,  86}, 
		PlateMid       = {170, 107,  102}, --{212, 212,   0}, 
		PlateDark      = { 110,  62,  67}, --{189, 167,   0}, 
		PlateOutline   = { 69,  40,  43}, --{  2,   2,   1},
		PlateShadow    = { 34,  39,  54},
		BodyColor      = {58, 61,  80}, 
		BodyHighlight  = {104, 109, 111}, 
	})
	
	--Scripts
	require(self.scriptPath.."weapons")
	require(self.scriptPath.."pawns")
	require(self.scriptPath.."animations")
	require(self.scriptPath.."hooks")
	
	--Weapon Texts
	modApi:addWeapon_Texts(require(self.scriptPath .. "weapons_text"))
	
	--Weapon Icons
	modApi:appendAsset("img/weapons/MachinPropellerLegsIcon.png",self.resourcePath.."img/weapons/MachinPropellerLegsIcon.png")
	modApi:appendAsset("img/weapons/MachinZeusArtilleryIcon.png",self.resourcePath.."img/weapons/MachinZeusArtilleryIcon.png")
	modApi:appendAsset("img/weapons/MachinConfusionFumesIcon.png",self.resourcePath.."img/weapons/MachinConfusionFumesIcon.png")
	modApi:appendAsset("img/weapons/MachinFulminantSmokeIcon.png",self.resourcePath.."img/weapons/MachinFulminantSmokeIcon.png")
	--modApi:appendAsset("img/effects/fake_health_bar.png", mod.resourcePath .."img/effects/fake_health_bar.png")
	--modApi:appendAsset("img/effects/machin_zap_bolt.png", mod.resourcePath .."img/effects/machin_zap_bolt.png")

	
	--Weapon Effects
	--modApi:appendAsset("img/effects/spark_shotup.png",self.resourcePath.."img/effects/spark_shotup.png")
	
	local a = ANIMS
	a.machin_zap_bolt = a.BaseUnit:new{Image = "effects/machin_zap_bolt.png", PosX = -14, PosY = -90, NumFrames = 1, Time = 0.25, Loop = false}

	--local shop = require(self.scriptPath .."libs/shop")
	modApi:addWeaponDrop{id = "Machin_Prime_PropellerLegs", pod = true, shop = true }
	modApi:addWeaponDrop{id = "Machin_Ranged_ZeusArtillery", pod = true, shop = true }
	-- Proximity Fumes is kinda boring on its own, so we don't add it by default
	modApi:addWeaponDrop{id = "Machin_Science_ConfusionFumes", pod = false, shop = false }
	-- Smoke Detonator is useless to most squads. But it's ok as a shop option for squads that'd make use of it, or in case there's a smoke weapon for sale.
	modApi:addWeaponDrop{id = "Machin_Science_FulminantSmoke", pod = false, shop = true }

end
local function load(self,options,version)
	Machin_StormHeralds_ModApiExt:load(self, optoins, version)
	--require(self.scriptPath .."weaponPreview/api"):load()

	--needed for achievement hooks too?
	require(self.scriptPath .. "hooks"):load()
    require(self.scriptPath .. "weapons"):load() -- add achievement hooks
	
	modApi:addSquadTrue({"Storm Heralds", "Machin_StrikeMech", "Machin_JoltMech", "Machin_DoomMech"}, "Storm Heralds", "These Mechs weaken the Vek with lightning and smoke, then bring wrathful storms upon them.",self.resourcePath.."/squadIcon.png") --, self.scriptPath.."squadIcon"
end

return {
    id = "Machin - Storm Heralds",
    name = "Storm Heralds",
	icon = "modIcon.png",
	description = "These Mechs use smoke to deliver wrathful lightning and blast the Vek to pieces.",
    version = "1.0.0",
	requirements = { "kf_ModUtils" },
    init = init,
	metadata = metadata,
    load = load
}