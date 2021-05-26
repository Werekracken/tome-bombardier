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
	name = "Flame Infusion", short_name = "BOMBARDIER_FIRE_INFUSION",
	type = {"spell/bombardier-fire-alchemy", 1},
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
		self:talentTemporaryValue(ret, "inc_damage", {[DamageType.FIRE] = t.getIncrease(self, t)})
		return ret
	end,
	deactivate = function(self, t, p)
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with flames that burn for a few turns.
		In addition all fire damage you do is increased by %d%%.
		You cannot have more than one alchemist infusion sustain active at once.]]):
		format(daminc)
	end,
}

newTalent{
	name = "Fire Power", short_name = "BOMBARDIER_FIRE_POWER",
	type = {"spell/bombardier-fire-alchemy", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 10, 8)) end,
	getPower = function(self, t) return self:combatTalentScale(t, 30, 50) end,
	applyEffect = function(self, t, target)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		if target and self:reactionToward(target) >= 0 then
			target:setEffect(target.EFF_BOMBARDIER_FIRE_POWER, duration, {penetration=power})
		end
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		local power = t.getPower(self, t)
		return ([[While Flame Infusion is active, your bombs invigorate allies and yourself by increasing all damage penetration by %d%% for the next %d turns.
		The duration increases with Spellpower.]]):
		format(power, duration)
	end,
}

newTalent{
	name = "Fire Storm", short_name = "BOMBARDIER_FIRE_STORM",
	type = {"spell/bombardier-fire-alchemy",3},
	require = spells_req3,
	points = 5,
	random_ego = "attack",
	mana = 70,
	cooldown = 20,
	range = 0,
	radius = 3,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t), selffire=false, friendlyfire=false}
	end,
	tactical = { ATTACKAREA = { FIRE = 2 } },
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.05) + self:getTalentLevel(t), 5, 0, 12.67, 7.66)) end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 5, 120) end,
	action = function(self, t)
		-- Add a lasting map effect
		local ef = game.level.map:addEffect(self,
			self.x, self.y, t.getDuration(self, t),
			DamageType.FIRE_FRIENDS, t.getDamage(self, t),
			3,
			5, nil,
			{type="firestorm", only_one=true},
			function(e)
				e.x = e.src.x
				e.y = e.src.y
				return true
			end,
			0, 0
		)
		ef.name = "firestorm"
		game:playSoundNear(self, "talents/fire")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local duration = t.getDuration(self, t)
		return ([[A furious fire storm rages around the caster, doing %0.2f fire damage in a radius of 3 each turn for %d turns.
		You closely control the firestorm, preventing it from harming your party members.
		The damage and duration will increase with your Spellpower.]]):
		format(damDesc(self, DamageType.FIRE, damage), duration)
	end,
}

newTalent{
	name = "Body of Fire", short_name = "BOMBARDIER_BODY_OF_FIRE",
	type = {"spell/bombardier-fire-alchemy",4},
	require = spells_req4,
	mode = "sustained",
	cooldown = 40,
	sustain_mana = 150,
	points = 5,
	proj_speed = 2.4,
	range = 6,
	tactical = { ATTACKAREA = { FIRE = 1.5 },
			SELF = {defend = 1}
	},
	on_pre_use_ai = function(self, t, silent, fake)
		if self.ai_state._advanced_ai then return true end -- let the advanced tactical AI decide to use
		local is_active = self:isTalentActive(t.id)
		local aitarget = self.ai_target.actor
		if not aitarget or self:reactionToward(aitarget) >= 0 then -- no hostile target, keep deactivated
			return is_active
		else -- hostile target, may activate if in range with sufficient mana
			local tx, ty = self:aiSeeTargetPos(aitarget)
			if core.fov.distance(self.x, self.y, tx, ty) <= t.range + 1 then return self:aiCheckSustainedTalent(t) end
			return is_active
		end
	end,
	getFireDamageOnHit = function(self, t) return self:combatTalentSpellDamage(t, 5, 25) end,
	getResistance = function(self, t) return self:combatTalentSpellDamage(t, 5, 45) end,
	getFireDamageInSight = function(self, t) return self:combatTalentSpellDamage(t, 15, 70) end,
	target = function(self, t) return {type="ball", radius=self:getTalentRange(t), range=0, talent=t, friendlyblock=false, friendlyfire=false} end, -- for AI (gets all targets)
	oneTarget = function(self, t) return {type="bolt", range=self:getTalentRange(t), talent=t, display={particle="bolt_fire"}, friendlyblock=false, friendlyfire=false} end, -- only hits one target
	getNumber = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	callbackOnActBase = function(self, t)
		if self:getMana() <= 0 then
			self:forceUseTalent(t.id, {ignore_energy=true})
			return
		end

		local tgts = {}
		local grids = core.fov.circle_grids(self.x, self.y, self:getTalentRange(t), true)
		for x, yy in pairs(grids) do for y, _ in pairs(grids[x]) do
			local a = game.level.map(x, y, Map.ACTOR)
			if a and self:reactionToward(a) < 0 then
				tgts[#tgts+1] = a
			end
		end end

		-- Randomly take targets
		local tg = t.oneTarget(self, t)
		for i = 1, t.getNumber(self, t) do
			if #tgts <= 0 then break end
			local a, id = rng.table(tgts)
			table.remove(tgts, id)

			self:projectile(table.clone(tg), a.x, a.y, DamageType.FIRE, self:spellCrit(t.getFireDamageInSight(self, t)), {type="flame"})
			game:playSoundNear(self, "talents/fire")
		end
	end,
	activate = function(self, t)
		game:playSoundNear(self, "talents/fireflash")
		game.logSeen(self, "#FF8000#%s turns into pure flame!", self.name:capitalize())
		self:addShaderAura("body_of_fire", "awesomeaura", {time_factor=3500, alpha=1, flame_scale=1.1}, "particles_images/wings.png")
		return {
			onhit = self:addTemporaryValue("on_melee_hit", {[DamageType.FIRE]=t.getFireDamageOnHit(self, t)}),
			res = self:addTemporaryValue("resists", {[DamageType.FIRE] = t.getResistance(self, t)}),
		}
	end,
	deactivate = function(self, t, p)
		self:removeShaderAura("body_of_fire")
		game.logSeen(self, "#FF8000#The raging fire around %s calms down and disappears.", self.name)
		self:removeTemporaryValue("on_melee_hit", p.onhit)
		self:removeTemporaryValue("resists", p.res)
		return true
	end,
	info = function(self, t)
		local onhitdam = t.getFireDamageOnHit(self, t)
		local insightdam = t.getFireDamageInSight(self, t)
		local res = t.getResistance(self, t)
		return ([[Turn your body into pure flame, increasing your fire resistance by %d%%, burning any creatures striking you in melee for %0.2f fire damage, and randomly launching up to %d slow-moving fire bolt(s) per turn at targets in sight, each dealing %0.2f fire damage.
		The projectiles safely go through your friends without harming them.
		The damage and resistance will increase with your Spellpower.]]):
		format(res,onhitdam, t.getNumber(self, t), insightdam)
	end,
}