-- ToME - Tales of Maj'Eyal
-- Copyright (C) 2009, 2010, 2011, 2012 Nicolas Casalini
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
	name = "Mana Charge", short_name = "HP_MANA_CHARGE",
	type = {"spell/mana-alchemy", 1},
	require = spells_req1,
	points = 5,
	mode = "passive",
	getMana = function(self, t) return math.floor(self:combatTalentScale(t, 1, 4.5, 0.75)) end,
	passives = function(self, t, p)
		local mana = t.getMana(self, t)
		self:talentTemporaryValue(p, "mana_regen", mana/10)
		self:talentTemporaryValue(p, "max_mana", mana*10)
	end,
	info = function(self, t)
		local mana = t.getMana(self, t)
		return ([[Increases mana regeneration by +%0.1f and maximum mana by +%d]]):format(mana/10, mana*10)
	end,
}

newTalent{
	name = "Quicken Inscriptions", short_name = "HP_QUICKEN_INSCRIPTIONS",
	type = {"spell/mana-alchemy", 2},
	require = spells_req2,
	points = 5,
	mana = 25,
	cooldown = 30,
	tactical = { BUFF = 2 },
	action = function(self, t)
		self:removeEffect(self.EFF_INFUSION_COOLDOWN)
		self:removeEffect(self.EFF_RUNE_COOLDOWN)
		self:removeEffect(self.EFF_TAINT_COOLDOWN)
		local tids = {}
		for tid, _ in pairs(self.talents_cd) do
			local tt = self:getTalentFromId(tid)
			if (tt.type[1] == "inscriptions/infusions" or tt.type[1] == "inscriptions/runes" or tt.type[1] == "inscriptions/taints") and self:isTalentCoolingDown(tt) then 
				self.talents_cd[tid] = self.talents_cd[tid] - math.floor(self:getTalentLevel(t))
				if self.talents_cd[tid] <= 0 then self.talents_cd[tid] = nil end
			end
		end
		game:playSoundNear(self, "talents/spell_generic2")
		return true
	end,
	info = function(self, t)
		local turns = math.floor(self:getTalentLevel(t))
		return ([[Removes all inscription saturations and reduces the cooldown of your inscriptions by %d turns.
		Doesn't work on Implants.]]):format(turns)
	end,
}

newTalent{
	name = "Glowing Orb", short_name = "HP_GLOWING_ORB",
	type = {"spell/mana-alchemy",3},
	require = spells_req3,
	random_ego = "utility",
	points = 5,
	mana = 20,
	cooldown = 14,
	range = 6,
	radius = function(self, t) return math.floor(self:combatTalentScale(t, 1, 3, 0.75)) end,
	tactical = { DISABLE = 2, ATTACKAREA = { ARCANE = 2 } },
	getDamage = function(self, t) return self:combatTalentSpellDamage(t, 30, 200) end,
	getBlindPower = function(self, t) if self:getTalentLevel(t) >= 5 then return 4 else return 3 end end,
	action = function(self, t)		
		local ammo = self:hasAlchemistWeapon()
		local tg = {type="ball", range=self:getTalentRange(t), selffire=false, radius=self:getTalentRadius(t), talent=t}
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end
		
		local dam=self:spellCrit(t.getDamage(self, t))
		
		if ammo then 
			ammo = self:removeObject(self:getInven("QUIVER"), 1)
			if ammo then
				dam = dam + dam * ammo.material_level / 10
			end
		end
		
		self:project(tg, x, y, DamageType.LITE, dam/20)
		self:project(tg, x, y, DamageType.BLIND, t.getBlindPower(self, t))
		self:project(tg, x, y, DamageType.ARCANE, self:spellCrit(dam))
				
		if core.shader.active(4) then
			game.level.map:particleEmitter(x, y, tg.radius, "shader_ring", {radius=tg.radius*2, life=8}, {type="sparks"})
		else
			-- Lightning ball gets a special treatment to make it look neat
			local sradius = (tg.radius + 0.5) * (engine.Map.tile_w + engine.Map.tile_h) / 2
			local nb_forks = 16
			local angle_diff = 360 / nb_forks
			for i = 0, nb_forks - 1 do
				local a = math.rad(rng.range(0+i*angle_diff,angle_diff+i*angle_diff))
				local tx = x + math.floor(math.cos(a) * tg.radius)
				local ty = y + math.floor(math.sin(a) * tg.radius)
				game.level.map:particleEmitter(x, y, tg.radius, "lightning", {radius=tg.radius, grids=grids, tx=tx-x, ty=ty-y, nb_particles=25, life=8})
			end
		end

		game:playSoundNear(self, "talents/lightning")
		return true
	end,
	info = function(self, t)
		local radius = self:getTalentRadius(t)
		local turn = t.getBlindPower(self, t)
		local dam = t.getDamage(self, t)
		return ([[Charge an alchemist gem (or pebble) and throw it, it will explode with a radius of %d that illuminates the area.
		This light is strong enough to blind for %d turns. It also deals %0.2f arcane damage.
		If an alchemist gem is used, it increases the damage by 10%% per material level.
		The damage will increase with your Spellpower.]]):
		format(radius, turn, damDesc(self, DamageType.ARCANE, dam))
	end,
}


newTalent{
	name = "Inscription Mastery", short_name = "HP_INSCRIPTION_MASTERY",
	type = {"spell/mana-alchemy",4},
	require = spells_req4,
	points = 5,
	mode = "passive",
	getMultiplier = function(self, t) return self:combatTalentScale(t, 15, 40) / 100 end,
	passives = function(self, t, p)
		self:talentTemporaryValue(p, "inscriptions_stat_multiplier", t.getMultiplier(self, t))
	end,
	info = function(self, t)
		local mult = t.getMultiplier(self, t) * 100
		return ([[Improves the contribution of primary stats on your inscriptions (any type) by %d%%.
		Inscription effects also last %d%% longer.]]):format(mult, mult)
	end,
}
