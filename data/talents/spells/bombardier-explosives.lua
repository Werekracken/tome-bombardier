newTalent{
	name = "Throw Bomb", short_name = "BOMBARDIER_THROW_BOMB",
	type = {"spell/bombardier-explosives",1},
	require = spells_req1,
	points = 5,
	mana = 5,
	cooldown = 4,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9, 0.5, 0, 0, true)) end,
	radius = function(self) return self:callTalent(self.T_BOMBARDIER_EXPLOSION_EXPERT, "getRadius") end,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then return end
		return {type="ball", range=self:getTalentRange(t)+(ammo and ammo.alchemist_bomb and ammo.alchemist_bomb.range or 0), radius=self:getTalentRadius(t), talent=t}
	end,
	tactical = { ATTACKAREA = function(self)
		if self:isTalentActive(self.T_BOMBARDIER_ACID_INFUSION) then return { ACID = 2 }
		elseif self:isTalentActive(self.T_BOMBARDIER_LIGHTNING_INFUSION) then return { LIGHTNING = 2 }
		elseif self:isTalentActive(self.T_BOMBARDIER_FROST_INFUSION) then return { COLD = 2 }
		elseif self:isTalentActive(self.T_BOMBARDIER_FIRE_INFUSION) then return { FIRE = 2 }
		else return { PHYSICAL = 2 }
		end
	end },
	computeDamage = function(self, t, ammo)
		local inc_dam = 0
		local damtype = DamageType.PHYSICAL
		local particle = "ball_physical"
		if self:isTalentActive(self.T_BOMBARDIER_ACID_INFUSION) then damtype = DamageType.ACID_DISARM; particle = "ball_acid"
		elseif self:isTalentActive(self.T_BOMBARDIER_LIGHTNING_INFUSION) then damtype = DamageType.LIGHTNING_DAZE; particle = "ball_lightning_beam"
		elseif self:isTalentActive(self.T_BOMBARDIER_FROST_INFUSION) then damtype = DamageType.ICE_SLOW; particle = "ball_ice"
		elseif self:isTalentActive(self.T_BOMBARDIER_FIRE_INFUSION) then damtype = DamageType.FIRE_STUN; particle = "fireflash"
		end
		inc_dam = inc_dam + (ammo.alchemist_bomb and ammo.alchemist_bomb.power or 0) / 100
		local dam = self:combatTalentSpellDamage(t, 15, 150, ((ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	getDuration = function(self, t) return math.floor(self:combatScale(self:combatSpellpower(0.03) * self:getTalentLevel(t), 2, 0, 10, 8)) end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo then
			game.logPlayer(self, "You need to ready alchemist gems in your quiver.")
			return
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:attr("no_sound", 1)
		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		self:attr("no_sound", -1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		dam = self:spellCrit(dam)
		local prot = 1
		local dam_done = 0

		-- Compare theorical AOE zone with actual zone and adjust damage accordingly
		if self:knowTalent(self.T_BOMBARDIER_EXPLOSION_EXPERT) then
			local nb = 0
			local grids = self:project(tg, x, y, function(tx, ty) end) --luacheck: ignore 212
			if grids then for px, ys in pairs(grids or {}) do for py, _ in pairs(ys) do nb = nb + 1 end end end
			if nb > 0 then
				dam = dam + dam * self:callTalent(self.T_BOMBARDIER_EXPLOSION_EXPERT, "minmax", nb)
			end
		end

		local tmp = {}
		local grids = self:project(tg, x, y, function(tx, ty)
			local d
			local target = game.level.map(tx, ty, Map.ACTOR)
			if tx == self.x and ty == self.y then -- Protect yourself
				d = dam * (1 - prot)
				if self:isTalentActive(self.T_BOMBARDIER_FROST_INFUSION) and self:knowTalent(self.T_BOMBARDIER_ICE_ARMOUR) then
					self:callTalent(self.T_BOMBARDIER_ICE_ARMOUR, "applyEffect", self)
				elseif self:isTalentActive(self.T_BOMBARDIER_ACID_INFUSION) and self:knowTalent(self.T_BOMBARDIER_CAUSTIC_CLEANSE) then
					self:callTalent(self.T_BOMBARDIER_CAUSTIC_CLEANSE, "applyEffect", self)
				elseif self:isTalentActive(self.T_BOMBARDIER_LIGHTNING_INFUSION) and self:knowTalent(self.T_BOMBARDIER_DYNAMIC_RECHARGE) then
					self:callTalent(self.T_BOMBARDIER_DYNAMIC_RECHARGE, "applyEffect", self)
				elseif self:isTalentActive(self.T_BOMBARDIER_FIRE_INFUSION) and self:knowTalent(self.T_BOMBARDIER_FIRE_POWER) then
					self:callTalent(self.T_BOMBARDIER_FIRE_POWER, "applyEffect", self)
				end
			elseif target and self:reactionToward(target) >= 0 then -- Protect allies
				d = dam * (1 - prot)
				if self:isTalentActive(self.T_BOMBARDIER_FROST_INFUSION) and self:knowTalent(self.T_BOMBARDIER_ICE_ARMOUR) then
					self:callTalent(self.T_BOMBARDIER_ICE_ARMOUR, "applyEffect", target)
				elseif self:isTalentActive(self.T_BOMBARDIER_ACID_INFUSION) and self:knowTalent(self.T_BOMBARDIER_CAUSTIC_CLEANSE) then
					self:callTalent(self.T_BOMBARDIER_CAUSTIC_CLEANSE, "applyEffect", target)
				elseif self:isTalentActive(self.T_BOMBARDIER_LIGHTNING_INFUSION) and self:knowTalent(self.T_BOMBARDIER_DYNAMIC_RECHARGE) then
					self:callTalent(self.T_BOMBARDIER_DYNAMIC_RECHARGE, "applyEffect", target)
				elseif self:isTalentActive(self.T_BOMBARDIER_FIRE_INFUSION) and self:knowTalent(self.T_BOMBARDIER_FIRE_POWER) then
					self:callTalent(self.T_BOMBARDIER_FIRE_POWER, "applyEffect", target)
				end
			else
				d = dam
				if target and target:canBe("fear") and self:knowTalent(self.T_BOMBARDIER_CONCUSSIVE_BLAST) then
					self:callTalent(self.T_BOMBARDIER_CONCUSSIVE_BLAST, "applyEffect", target)
				end
			end
			if d <= 0 then return end

			dam_done = dam_done + DamageType:get(damtype).projector(self, tx, ty, damtype, d, tmp)
			if ammo.alchemist_bomb and ammo.alchemist_bomb.splash then
				DamageType:get(DamageType[ammo.alchemist_bomb.splash.type]).projector(self, tx, ty, DamageType[ammo.alchemist_bomb.splash.type], ammo.alchemist_bomb.splash.dam)
			end
			if not target then return end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.stun and rng.percent(ammo.alchemist_bomb.stun.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, ammo.alchemist_bomb.stun.dur, {apply_power=self:combatSpellpower()})
			end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.daze and rng.percent(ammo.alchemist_bomb.daze.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, ammo.alchemist_bomb.daze.dur, {apply_power=self:combatSpellpower()})
			end
		end)

		if ammo.alchemist_bomb and ammo.alchemist_bomb.leech then self:heal(math.min(self.max_life * ammo.alchemist_bomb.leech / 100, dam_done), ammo) end

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, particle, {radius=tg.radius, grids=grids, tx=x, ty=y})

		if ammo.alchemist_bomb and ammo.alchemist_bomb.mana then self:incMana(ammo.alchemist_bomb.mana) end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam, damtype = 1, DamageType.FIRE
		if ammo then dam, damtype = t.computeDamage(self, t, ammo) end
		dam = damDesc(self, damtype, dam)
		return ([[Imbue an alchemist gem with an explosive charge of mana and throw it. Your fine control of the explosion makes it so that it doesn't affect you or your allies.
		The gem will explode for %d %s to enemies.
		Each kind of gem will also provide a specific effect.
		The damage will improve with better gems and with your Spellpower.]]):format(dam, DamageType:get(damtype).name)
	end,
}

newTalent{
	name = "Concussive Blast", short_name = "BOMBARDIER_CONCUSSIVE_BLAST",
	type = {"spell/bombardier-explosives",2},
	require = spells_req2,
	mode = "passive",
	points = 5,
	getPower = function(self, t) return self:combatTalentSpellDamage(t, 5, 40) end,
	applyEffect = function(self, t, target)
		if target then
			target:setEffect(target.EFF_INTIMIDATED, 1, {apply_power = self:combatSpellpower(), power = t.getPower(self, t)})
		end
	end,
	info = function(self, t)
		local power = t.getPower(self, t)
		return ([[Your alchemist bombs intimidate enemies caught in the blast. Attack power, mind power, and spellpower are be reduced by %d for 1 turn (unless fear immune).
		The redutcion power increases with talent level and Spellpower.]]):
		format(power)
	end,
}

newTalent{
	name = "Explosion Expert", short_name = "BOMBARDIER_EXPLOSION_EXPERT",
	type = {"spell/bombardier-explosives",3},
	require = spells_req3,
	mode = "passive",
	points = 5,
	getRadius = function(self, t) return math.max(1, math.floor(self:combatTalentScale(t, 2, 6, 0.5, 0, 0, true))) end,
	minmax = function(self, t, grids)
		local theoretical_nb = (2 * t.getRadius(self, t) + 1)^1.94 -- Maximum grids hit vs. talent level
		if grids then
			local lostgrids = math.max(theoretical_nb - grids, 0)
			local mult = math.max(0,math.log10(lostgrids)) / (6 - math.min(self:getTalentLevelRaw(self.T_BOMBARDIER_EXPLOSION_EXPERT), 5))
			print("Adjusting explosion damage to account for ", lostgrids, " lost tiles => ", mult * 100)
			return mult
		else
			local min = (math.log10(1) / (6 - math.min(self:getTalentLevelRaw(t), 5)))
			local max = (math.log10(theoretical_nb) / (6 - math.min(self:getTalentLevelRaw(t), 5)))
			return min, max
		end
	end,
	info = function(self, t)
		local min, max = t.minmax(self, t)
		return ([[Your alchemist bombs now affect a radius of %d around them.
		Explosion damage may increase by %d%% (if the explosion is not contained) to %d%% if the area of effect is confined.]]):
		format(t.getRadius(self, t), min*100, max*100) --I5
	end,
}

newTalent{
	name = "Shockwave Bomb", short_name = "BOMBARDIER_SHOCKWAVE_BOMB",
	type = {"spell/bombardier-explosives",4},
	require = spells_req4,
	points = 5,
	mana = 32,
	cooldown = 10,
	range = function(self, t) return math.floor(self:combatTalentScale(t, 5, 9, 0.5, 0, 0, true)) end,
	radius = 2,
	direct_hit = true,
	requires_target = true,
	target = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local friendlyfire = false
		return {type="ball", range=self:getTalentRange(t)+(ammo and ammo.alchemist_bomb and ammo.alchemist_bomb.range or 0), radius=self:getTalentRadius(t), friendlyfire=friendlyfire, talent=t}
	end,
	tactical = { ATTACKAREA = { PHYSICAL = 2 }, DISABLE = { knockback = 2 } },
	computeDamage = function(self, t, ammo)
		local damtype = DamageType.SPELLKNOCKBACK
		local particle = "ball_physical"
		local inc_dam = (ammo.alchemist_bomb and ammo.alchemist_bomb.power or 0) / 100
		local dam = self:combatTalentSpellDamage(t, 15, 120, ((ammo.alchemist_power or 0) + self:combatSpellpower()) / 2)
		dam = dam * (1 + inc_dam)
		return dam, damtype, particle
	end,
	action = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		if not ammo or ammo:getNumber() < 2 then
			game.logPlayer(self, "You need to ready at least two alchemist gems in your quiver.")
			return
		end

		local tg = self:getTalentTarget(t)
		local x, y = self:getTarget(tg)
		if not x or not y then return nil end

		self:removeObject(self:getInven("QUIVER"), 1)
		ammo = self:removeObject(self:getInven("QUIVER"), 1)
		if not ammo then return end

		local dam, damtype, particle = t.computeDamage(self, t, ammo)
		dam = self:spellCrit(dam)
		local prot = 1
		local dam_done = 0

		local tmp = {}
		local grids = self:project(tg, x, y, function(tx, ty)
			local d = dam
			-- Protect yourself
			if tx == self.x and ty == self.y then d = dam * (1 - prot) end
			-- Protect allies
			if target and self:reactionToward(target) >= 0 and tx == target.x and ty == target.y then d = dam * (1 - prot) end
			if d == 0 then return end

			local target = game.level.map(tx, ty, Map.ACTOR)
			dam_done = dam_done + DamageType:get(damtype).projector(self, tx, ty, damtype, d, tmp)
			if ammo.alchemist_bomb and ammo.alchemist_bomb.splash then
				DamageType:get(DamageType[ammo.alchemist_bomb.splash.type]).projector(self, tx, ty, DamageType[ammo.alchemist_bomb.splash.type], ammo.alchemist_bomb.splash.dam)
			end
			if not target then return end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.stun and rng.percent(ammo.alchemist_bomb.stun.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_STUNNED, ammo.alchemist_bomb.stun.dur, {apply_power=self:combatSpellpower()})
			end
			if ammo.alchemist_bomb and ammo.alchemist_bomb.daze and rng.percent(ammo.alchemist_bomb.daze.chance) and target:canBe("stun") then
				target:setEffect(target.EFF_DAZED, ammo.alchemist_bomb.daze.dur, {apply_power=self:combatSpellpower()})
			end
		end)

		if ammo.alchemist_bomb and ammo.alchemist_bomb.leech then self:heal(math.min(self.max_life * ammo.alchemist_bomb.leech / 100, dam_done)) end

		local _ _, x, y = self:canProject(tg, x, y)
		game.level.map:particleEmitter(x, y, tg.radius, particle, {radius=tg.radius, grids=grids, tx=x, ty=y})

		if ammo.alchemist_bomb and ammo.alchemist_bomb.mana then self:incMana(ammo.alchemist_bomb.mana) end

		game:playSoundNear(self, "talents/arcane")
		return true
	end,
	info = function(self, t)
		local ammo = self:hasAlchemistWeapon()
		local dam
		if ammo then dam = t.computeDamage(self, t, ammo) end
		dam = damDesc(self, DamageType.PHYSICAL, dam)
		return ([[Crush together two alchemist gems, making them extremely unstable.
		You then throw them to a target area, where they explode on impact, dealing %d physical damage and knocking back any creatures in the blast radius.
		Each kind of gem will also provide a specific effect.
		The damage will improve with better gems and with your Spellpower.]]):format(dam)
	end,
}
