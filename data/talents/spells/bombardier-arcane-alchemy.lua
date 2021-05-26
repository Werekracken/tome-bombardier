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
	name = "Disperse Magic",
	type = {"spell/bombardier-arcane-alchemy",1},
	require = spells_req1,
	points = 5,
	random_ego = "utility",
	mana = 40,
	cooldown = 25,
	random_boss_rarity = 50,
	-- no_energy = function(self, t) return self:getTalentLevel(t) >= 7 and true or false end,
	tactical = { CURE = function(self, t, aitarget)
			local nb = 0
			for eff_id, p in pairs(self.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then nb = nb + 1 end
			end
			return nb
		end,
		DISABLE = function(self, t, aitarget)
			local nb = 0
			for eff_id, p in pairs(aitarget.tmp) do
				local e = self.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "beneficial" then nb = nb + 1 end
			end
			for tid, act in pairs(aitarget.sustain_talents) do
				if act then
					local talent = aitarget:getTalentFromId(tid)
					if talent.is_spell then nb = nb + 1 end
				end
			end
			return nb^0.5
		end},
	direct_hit = true,
	requires_target = function(self, t) return self:getTalentLevel(t) >= 3 and (self.player or t.tactical.cure(self, t) <= 0) end,
	range = 10,
	getRemoveCount = function(self, t) return math.floor(self:combatTalentScale(t, 1, 5, "log")) end,
	action = function(self, t)
		local target = self

		if self:getTalentLevel(t) >= 3 then
			local tg = {type="hit", range=self:getTalentRange(t)}
			local tx, ty = self:getTarget(tg)
			if tx and ty and game.level.map(tx, ty, Map.ACTOR) then
				local _ _, tx, ty = self:canProject(tg, tx, ty)
				if not tx then return nil end
				target = game.level.map(tx, ty, Map.ACTOR)
				if not target then return nil end

				target = game.level.map(tx, ty, Map.ACTOR)
			else return nil
			end
		end

		local effs = {}

		-- Go through all spell effects
		if self:reactionToward(target) < 0 then
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "beneficial" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end

			-- Go through all sustained spells
			for tid, act in pairs(target.sustain_talents) do
				if act then
					local talent = target:getTalentFromId(tid)
					if talent.is_spell then effs[#effs+1] = {"talent", tid} end
				end
			end
		else
			for eff_id, p in pairs(target.tmp) do
				local e = target.tempeffect_def[eff_id]
				if e.type == "magical" and e.status == "detrimental" then
					effs[#effs+1] = {"effect", eff_id}
				end
			end
		end

		for i = 1, t.getRemoveCount(self, t) do
			if #effs == 0 then break end
			local eff = rng.tableRemove(effs)

			target:dispel(eff[2], self)
		end
		game:playSoundNear(self, "talents/spell_generic")
		return true
	end,
	info = function(self, t)
		local count = t.getRemoveCount(self, t)
		return ([[Removes up to %d magical effects (good effects from foes, and bad effects from friends) from the target.
		At level 3, it can be targeted.
		]]):
		-- At level 7, it takes no turn to cast.
		tformat(count)
	end,
}
