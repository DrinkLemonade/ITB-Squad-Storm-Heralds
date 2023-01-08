local function init(self)
	--init variables
	local path = mod_loader.mods[modApi.currentMod].scriptPath
	--libs
	local sprites = require(path .."libs/sprites")
	local palettes = require(self.scriptPath .."libs/customPalettes")
	local mod = mod_loader.mods[modApi.currentMod]
	local resourcePath = mod.resourcePath
	local scriptPath = mod.scriptPath

	--Achievements
	modApi.achievements:add{
	id = "machin_ach_pounce",
	name = "Tacklepounce",
	image = resourcePath.."img/achievements/pounce.png",
	tooltip = "Kill 5 Enemies with Propeller Legs in one mission.",--\n\nProgress: $ kills",
	objective = true,--might change this to a trackable progress achievement in the future
	squad = "Machin_StormHeraldsSquad"
	}
	modApi.achievements:add{
	id = "machin_ach_chainsmoke",
	name = "Chain Smoker",
	image = resourcePath.."img/achievements/chainsmoke.png",
	tooltip = "Have Zeus Artillery chain through 40 Smoke tiles in one game.\n\nProgress: $ tiles",
	objective = 40,
	squad = "Machin_StormHeraldsSquad"
	}
	modApi.achievements:add{
	id = "machin_ach_fulmination",
	name = "Fulmination (Is A Cool Word)",
	image = resourcePath.."img/achievements/fulmination.png",
	tooltip = "Use Smoke Detonator on at least 3 units at once (harming Enemies, shielding Allies or both).",
	objective = true,
	squad = "Machin_StormHeraldsSquad"
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
	
	--[[When Smoke Detonator is used on adjacent tiles, it uses one explosion for every direction (N/E/S/W)
	For oblique tiles however (NE/NW/SE/SW), I'd need to draw a custom explosion direction and add it as an animation.
	I've done so, but only for the left-facing explosion. Making the other 3 would be significant busywork for little gain.
	Maybe some day? I'm sure some mod in the future will have a use for diagonal explosions.
	Until then, my left-facing explosion can be found in the mod's effects folder.
	--Animations
	for i = DIR_START, DIR_END do 
	ANIMS["diagburst_"..i] = ANIMS.Animation:new{
		Image = "effects/diagburst_"..i..".png",
		NumFrames = 9,
		Time = 1,
		PosX = 0,
		PosY = 0,
		LOG("Added anim")
	}
	end]]
	
	--Palette
	palettes.addPalette({
		ID = "Machin_StormHeralds",
		Name = "Storm Heralds",
		PlateHighlight = {122, 205,  250},
		PlateLight     = {208, 183,  123},
		PlateMid       = {170, 107,  102},
		PlateDark      = { 110,  62,  67},
		PlateOutline   = { 69,  40,  43},
		PlateShadow    = { 34,  39,  54},
		BodyColor      = {58, 61,  80}, 
		BodyHighlight  = {104, 109, 111}, 
	})
	
	--Scripts
	require(self.scriptPath.."weapons")
	require(self.scriptPath.."pawns")
	require(self.scriptPath.."hooks")
	require(self.scriptPath .. "hooks"):load()

	--Weapon Texts
	modApi:addWeapon_Texts(require(self.scriptPath .. "weapons_text"))
	
	--Weapon Icons
	modApi:appendAsset("img/weapons/MachinPropellerLegsIcon.png",self.resourcePath.."img/weapons/MachinPropellerLegsIcon.png")
	modApi:appendAsset("img/weapons/MachinZeusArtilleryIcon.png",self.resourcePath.."img/weapons/MachinZeusArtilleryIcon.png")
	modApi:appendAsset("img/weapons/MachinConfusionFumesIcon.png",self.resourcePath.."img/weapons/MachinConfusionFumesIcon.png")
	modApi:appendAsset("img/weapons/MachinFulminantSmokeIcon.png",self.resourcePath.."img/weapons/MachinFulminantSmokeIcon.png")
	
	local a = ANIMS
	a.machin_zap_bolt = a.BaseUnit:new{Image = "effects/machin_zap_bolt.png", PosX = -14, PosY = -90, NumFrames = 1, Time = 0.25, Loop = false}

	modApi:addWeaponDrop{id = "Machin_Prime_PropellerLegs", pod = true, shop = true }
	modApi:addWeaponDrop{id = "Machin_Ranged_ZeusArtillery", pod = true, shop = true }
	-- Proximity Fumes is kinda boring on its own, so we don't add it by default
	modApi:addWeaponDrop{id = "Machin_Science_ConfusionFumes", pod = false, shop = false }
	-- Smoke Detonator is useless to most squads. But it's ok as a shop option for squads that'd make use of it, or in case there's a smoke weapon for sale.
	modApi:addWeaponDrop{id = "Machin_Science_FulminantSmoke", pod = false, shop = true }

end
local function load(self,options,version)
	--Machin_StormHeralds_ModApiExt:load(self, options, version)

	--needed for achievement hooks too?
	require(self.scriptPath .. "hooks"):load()
    require(self.scriptPath .. "weapons"):load() -- add achievement hooks/functions
	modApi:addSquad(
		{
			id = "Machin_StormHeraldsSquad",
			"Storm Heralds",
			"Machin_StrikeMech",
			"Machin_JoltMech",
			"Machin_DoomMech"
		},
		"Storm Heralds",
		"These Mechs use clouds of smoke first to hold back the Vek, then to unleash wrathful storms upon them.",
		self.resourcePath.."/squadIcon.png"
	)
end

return {
    id = "Machin - Storm Heralds",
    name = "Storm Heralds",
	icon = "modIcon.png",
	description = "These Mechs use smoke to deliver wrathful lightning and blast the Vek to pieces.",
    version = "1.1.0",
	requirements = { "kf_ModUtils" },
	dependencies = { modApiExt = "1.17" },
    init = init,
	metadata = metadata,
    load = load
}