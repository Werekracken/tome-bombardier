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

newTalent{
	name = "Acid Infusion", short_name = "BOMBARDIER_ACID_INFUSION",
	type = {"spell/bombardier-caustic-alchemy", 1},
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
		self:talentTemporaryValue(ret, "inc_damage", {[DamageType.ACID] = t.getIncrease(self, t)})
		return ret
	end,
	deactivate = function(self, t, p) --luacheck: ignore 212
		return true
	end,
	info = function(self, t)
		local daminc = t.getIncrease(self, t)
		return ([[When you throw your alchemist bombs, you infuse them with explosive acid that has a 25%% chance to disarm for 3 turns.
		In addition all acid damage you do is increased by %d%%.
		You cannot have more than one alchemist infusion sustain active at once.]]):
		format(daminc)
	end,
}

newTalent{
	name = "Caustic Cleanse", short_name = "BOMBARDIER_CAUSTIC_CLEANSE",
	type = {"spell/bombardier-caustic-alchemy", 2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 10, 8)) end,
	applyEffect = function(self, t, target)
		local duration = t.getDuration(self, t)
		if target and self:reactionToward(target) >= 0 then
			target:setEffect(target.EFF_BOMBARDIER_CAUSTIC_CLEANSE, duration, {})
		end
	end,
	info = function(self, t)
		local duration = t.getDuration(self, t)
		return ([[While Acid Infusion is active, your bombs apply a caustic coating to you and allies that lasts for %d turns and will cleanse 1 detrimental physical effect each turn.
		The duration increases with Spellpower.]]):
		format(duration)
	end,
}

newTalent{
	name = "Caustic Mire", short_name = "BOMBARDIER_CAUSTIC_MIRE",
	type = {"spell/bombardier-caustic-alchemy",3},
	require = spells_req3,
	points = 5,
	mana = 50,
	cooldown = 30,
	tactical = { ATTACKAREA = { ACID = 3 }, DISABLE = 2 },
	range = 7,
	radius = 3,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		return {type="ball", range=self:getTalentRange(t), radius=self:getTalentRadius(t)}
	end,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 7, 60) end,
	getDuration = function(self, t) return math.floor(self:combatTalentScale(t, 6, 10)) end,
	getCorrodeDur = function(self, t) return math.floor(self:combatTalentScale(t, 2.3, 3.8)) end,
	getAtk = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
	getArmor = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
	getDefense = function(self, t) return self:combatTalentMindDamage(t, 2, 20) end,
	action = function(self, t)
		local duration = t.getDuration(self, t)
		local cordur = t.getCorrodeDur(self, t)
		local atk = t.getAtk(self, t)
		local armor = t.getArmor(self, t)
		local defense = t.getDefense(self, t)

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local _ _, _, _, x, y = self:canProject(tg, x, y)
		-- Add a lasting map effect
		game.level.map:addEffect(self,
			x, y, duration,
			DamageType.ACID_CORRODE, {dam=self:spellCrit(t.getDamage(self, t)), dur=cordur, atk=atk, armor=armor, defense=defense},
			self:getTalentRadius(t),
			5, nil,
			{zdepth=6, type="mucus"},
			nil, 0, 0
		)

		game:playSoundNear(self, "talents/slime")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		local cordur = t.getCorrodeDur(self, t)
		local duration = t.getDuration(self, t)
		local radius = self:getTalentRadius(t)
		return ([[A radius %d pool of acid spawns at the target location, doing %d Acid damage each turn for %d turns.
		All creatures caught in the mire will be corroded by the acid, reducing their accuracy, armor, and defense for %d turns.
		The damage will increase with your Spellpower.]]):
		format(radius, damDesc(self, DamageType.ACID, damage), duration, cordur)
	end,
}

newTalent{
	name = "Dissolving Acid", short_name = "BOMBARDIER_DISSOLVING_ACID",
	type = {"spell/bombardier-caustic-alchemy",4},
	require = spells_req4,
	points = 5,
	mana = 45,
	cooldown = 12,
	refectable = true,
	range = 10,
	direct_hit = true,
	tactical = { ATTACK = { ACID = 2 }, DISABLE = 2 },
	requires_target = true,
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 25, 320) end,
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, "log")) end,
	action = function(self, t)
		local tg = {type="hit", range=self:getTalentRange(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		local nb = t.getRemoveCount(self,t)
		self:project(tg, x, y, function(px, py)
			local target = game.level.map(px, py, Map.ACTOR)
			if not target then return end
			DamageType:get(DamageType.ACID).projector(self, px, py, DamageType.ACID, (self:spellCrit(t.getDamage(self, t))))

			local effs = {}

			-- Go through all mental and physical effects
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if (e.type == "mental" or e.type == "physical") and e.status == "beneficial" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all mental sustains
			for tid, act in pairs(target.sustain_talents) do
				local tal = self:getTalentFromId(tid)
				if act and tal.is_mind then
					effs[#effs+1] = {"talent", tid}
				end
			end

			for i = 1, nb do
				if #effs == 0 then break end
				local eff = rng.tableRemove(effs)

				if self:checkHit(self:combatSpellpower(), target:combatSpellResist(), 0, 95, 5) then
					target:crossTierEffect(target.EFF_SPELLSHOCKED, self:combatSpellpower())
					if eff[1] == "effect" then
						target:removeEffect(eff[2])
					else
						target:forceUseTalent(eff[2], {ignore_energy=true})
					end
				end
			end

		end, nil, {type="acid"})
		game:playSoundNear(self, "talents/acid")
		return true
	end,
	info = function(self, t)
		local damage = t.getDamage(self, t)
		return ([[Acid erupts all around your target, dealing %d acid damage.
		The acid attack is extremely distracting, and may remove up to %d physical or mental temporary effects or mental sustains (depending on the Spell Save of the target).
		The damage and chance to remove effects will increase with your Spellpower.]]):format(damDesc(self, DamageType.ACID, damage), t.getRemoveCount(self, t))
	end,
}
