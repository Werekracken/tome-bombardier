local class = require "engine.class"
local Birther = require "engine.Birther"
local ActorTalents = require "engine.interface.ActorTalents"
local ActorTemporaryEffects = require "engine.interface.ActorTemporaryEffects"

class:bindHook("ToME:load", function(self, data)
	Birther:loadDefinition("/data-bombardier/birth/mage.lua")
	ActorTalents:loadDefinition("/data-bombardier/talents/talents.lua")
	ActorTemporaryEffects:loadDefinition("/data-bombardier/timed_effects.lua")
end)
