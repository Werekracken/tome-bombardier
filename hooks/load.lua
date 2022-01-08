local class = require "engine.class"
local Birther = require "engine.Birther"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"

class:bindHook("ToME:load", function(self, data) --luacheck: ignore 212
	ActorTalents:loadDefinition("/data-bombardier/talents/talents.lua")
	ActorTemporaryEffects:loadDefinition("/data-bombardier/timed_effects.lua")
	Birther:loadDefinition("/data-bombardier/birth/mage.lua")
end)
