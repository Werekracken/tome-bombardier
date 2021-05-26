-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009 - 2019 Nicolas Casalini
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- Nicolas Casalini "DarkGod"
-- darkgod@te4.org
local Object = require "engine.Object"

newTalent{
	name = "Frost Infusion", short_name = "BOMBARDIER_FROST_INFUSION",
	type = {"spell/bombardier-frost-alchemy", 1},
	mode = "sustained",
	require = spells_req1,
	sustain_mana = 5,
	points = 5,
	cooldown = 10,
	no_energy = true,
	tactical = { BUFF = 2 },
	getIncrease = function(self, t) return self:combatTalentScale(t, 0.05, 0.25) * 100 end,
	sustain_slots = 'alchemy_infusion',
	activate = function(self, t)
		game:playSoundNear(self, "talents/arcane")
		local ret = {}
		self:talentTemporaryValue(ret, "inc_damage", {[DamageType.COLD] = t.getIncrease(self, t)})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with cold damage that can freeze your foes.
		In addition all cold damage you do is increased by %d%%.
		You cannot have more than one alchemist infusion sustain active at once.]]):
		format(daminc)
	end,
}

newTalent{
	name = "Ice Armour", short_name = "BOMBARDIER_ICE_ARMOUR",
	type = {"spell/bombardier-frost-alchemy", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 10, 8)) end,
	getArmor = function(self, t) return self:combatTalentSpellDamage(t, 10, 45) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 70) end,
	applyEffect = function(self, t, target)
		local duration = t.getDuration(self, t)
		local dam = t.getDamage(self, t)
		local armor = t.getArmor(self, t)
		if target and self:reactionToward(target) >= 0 then
			target:setEffect(target.EFF_ICE_ARMOUR, duration, {armor=armor, dam=dam})
		end
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local dam = self and self:damDesc(engine.DamageType.COLD, t.getDamage(self, t)) or 0
		local armor = t.getArmor(self, t)
		return ([[While Frost Infusion is active, your bombs deposit a layer of ice on yourself and allies for %d turns.
		This ice provides %d additional armour, %0.1f Cold damage retaliation against melee attacks, and 50%% of damage is converted to Cold.
		The duration increases with your talent level and Spellpower, and the armor and retaliation with Spellpower.]]):
		format(duration, armor, dam)
	end,
}

newTalent{
	name = "Flash Freeze", short_name = "BOMBARDIER_FLASH_FREEZE",
	type = {"spell/bombardier-frost-alchemy",3},
	require = spells_req3,
	points = 5,
	mana = 30,
	cooldown = 20,
	requires_target = true,
	tactical = { DISABLE = { stun = 1 }, ATTACKAREA = { COLD = 2 } },
	no_energy = true,
	range = 0,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 10, 8)) end,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 2, 6)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 10, 250) end,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), friendlyfire=false, talent=t}
	end,
	action = function(self, t)
		local tg = self:getTalentTarget(t)
		local grids = self:project(tg, self.x, self.y, DamageType.COLDNEVERMOVE, {dur=t.getDuration(self, t), dam=t.getDamage(self, t)})
		game.level.map:particleEmitter(self.x, self.y, tg.radius, "ball_ice", {radius=tg.radius})
		game:playSoundNear(self, "talents/ice")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		return ([[Invoke a blast of cold all around you with a radius of %d, doing %0.1f Cold damage and freezing creatures to the ground for %d turns.
		Affected creatures can still act, but cannot move.
		The duration will increase with your Spellpower.]]):format(radius, damDesc(self, DamageType.COLD, t.getDamage(self, t)), t.getDuration(self, t))
	end,
}

newTalent{
	name = "Ice Core", short_name = "BOMBARDIER_BODY_OF_ICE",
	type = {"spell/bombardier-frost-alchemy",4},
	require = spells_req4,
	mode = "sustained",
	cooldown = 40,
	sustain_mana = 100,
	points = 5,
	range = 6,
	tactical = { DEFEND = 2 },
	critResist = function(self, t) return self:combatTalentScale(t, 10, 50) end,
	getResistance = function(self, t) return self:combatTalentSpellDamage(t, 5, 45) * 0.6 end,
	getAffinity = function(self, t) return self:combatTalentLimit(t, 50, 5, 20) end, -- Limit <50%
	activate = function(self, t)
		game:playSoundNear(self, "talents/ice")
		local ret = {}
		self:addShaderAura("body_of_ice", "crystalineaura", {}, "particles_images/spikes.png")
		ret.particle = self:addParticles(Particles.new("snowfall", 1))
		self:talentTemporaryValue(ret, "resists", {[DamageType.PHYSICAL] = t.getResistance(self, t)})
		self:talentTemporaryValue(ret, "damage_affinity", {[DamageType.COLD] = t.getAffinity(self, t)})
		self:talentTemporaryValue(ret, "ignore_direct_crits", t.critResist(self, t))
		return ret
	end,
	deactivate = function(self, t, p)
		self:removeParticles(p.particle)
		self:removeShaderAura("body_of_ice")
		return true
	end,
	info = function(self, t)
		local resist = t.getResistance(self, t)
		local crit = t.critResist(self, t)
		return ([[Turn your body into pure ice, increasing your Cold damage affinity by %d%% and your physical resistance by %d%%.
		You have a %d%% chance to shrug off all direct critical hits (physical, mental, spell).
		The effects increase with your Spellpower.]]):
		format(t.getAffinity(self, t), resist, crit)
	end,
}