local path = mod_loader.mods[modApi.currentMod].resourcePath
local mod = mod_loader.mods[modApi.currentMod]
local modApiExt = require(mod.scriptPath.."modApiExt/modApiExt")
local resourcePath = mod.resourcePath
local scriptPath = mod.scriptPath
local previewer = require(scriptPath.."weaponPreview/api")
local hotkey = require(scriptPath.."libs/hotkey")
local function IsTipImage()
	return Board:GetSize() == Point(6,6)
end

local this = {}

function this:load()
	--[[LOG("Loading MissionStart and GameStart hooks")
	
	LOG("loading pawnkilledhook from weapons.lua")
	local hook = function(m, pawn)
	LOG("Pawn killed (hooks.lua)")
		if pawn:GetTeam() == TEAM_ENEMY then
			LOG("Incrementing temp kill counter!")
			m.machin_propeller_temp_kills = m.machin_propeller_temp_kills+1
		end
	end
	modApiExt:addPawnKilledHook(hook)--]]
	
	--[[LOG("Adding Propeller hooks...")
	local hook = function(m, pawn)
		if pawn:GetTeam() == TEAM_ENEMY then
			LOG("Incrementing temp kill counter!")
			m.machin_propeller_temp_kills = m.machin_propeller_temp_kills+1
		end
	end
	modApiExt:addPawnKilledHook(hook)
	
	local hook = function(mission, pawn, weaponId, p1, p2)
		local m = GetCurrentMission()
		if not m or not Board then return end
		
		if not IsTipImage() then
			LOG("Resetting temp kill counter")
			--Someone started using a skill, reset the temp killcount tracker
			Machin_Prime_PropellerLegs:ResetTempKillcount()
		end
	end
	modApiExt:addSkillStartHook(hook)--]]
	
	local hook = function()
		LOG("Resetting Chain Smoker achievement...")
		modApi.achievements:reset("Machin - Storm Heralds", machin_ach_chainsmoke)
	end
	modApi:addPostStartGameHook(hook)
end

return this