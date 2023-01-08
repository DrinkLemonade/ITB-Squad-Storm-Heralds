local this = {}
function this:load()
	local hook = function()
		LOG("Resetting Chain Smoker achievement...")
		modApi.achievements:reset("Machin - Storm Heralds", machin_ach_chainsmoke)
	end
	modApi:addPostStartGameHook(hook)
end
return this