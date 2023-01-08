local path = mod_loader.mods[modApi.currentMod].scriptPath
local palettes = require(path.."libs/customPalettes")

local pawnColor = palettes.getOffset("Machin_StormHeralds")
--Mechs
--Whirlwind Mech
Machin_StrikeMech = Pawn:new {
	Name = "Pounce Mech",
	Class = "Prime",
	Image = "Machin_Strike_Mech",
	ImageOffset = pawnColor,
	Health = 3,
	MoveSpeed = 4,
	SkillList = {"Machin_Prime_PropellerLegs"},
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	SoundLocation = "/mech/prime/inferno_mech/",
	Massive = true,
	Flying = false
}
AddPawn("Machin_StrikeMech")
--Jolt Mech
Machin_JoltMech = Pawn:new {
	Name = "Jolt Mech",
	Class = "Ranged",
	Image = "Machin_Jolt_Mech",
	--	Image = "Jolt_Mech",
	ImageOffset = pawnColor,
	Health = 2,
	MoveSpeed = 3,
	SkillList = {"Machin_Ranged_ZeusArtillery"},
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	SoundLocation = "/mech/distance/trimissile_mech/",
	Massive = true,
	Flying = false
}
AddPawn("Machin_JoltMech")
--Doom Mech
Machin_DoomMech = Pawn:new {
	Name = "Fulminant Mech",
	Class = "Science",
	Image = "Machin_Fulminant_Mech",
	ImageOffset = pawnColor,
	Health = 3,
	MoveSpeed = 4,
	SkillList = {"Machin_Science_ConfusionFumes", "Machin_Science_FulminantSmoke"},
	DefaultTeam = TEAM_PLAYER,
	ImpactMaterial = IMPACT_METAL,
	Massive = true,
	SoundLocation = "/mech/science/hydrant_mech/",
	Flying = true,
	Armor = true,
}
AddPawn("Machin_DoomMech")