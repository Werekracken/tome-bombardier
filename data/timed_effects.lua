newEffect{
	name = "BOMBARDIER_FIRE_POWER", image = "talents/bombardier_fire_power.png",
	desc = _t"Fire Power",
	long_desc = function(self, eff) return ("The target has all damage penetration increased by %d%% and all critical strike chances increased by %d%%."):tformat(eff.penetration, eff.crit) end, --luacheck: ignore 212
	type = "magical",
	subtype = { fire=true },
	status = "beneficial",
	parameters = {penetration=30, crit=3},
	on_gain = function(self, err) return _t"#Target# is invigorated by the heat.", _t"+BOMBARDIER_FIRE_POWER" end, --luacheck: ignore 212
	on_lose = function(self, err) return _t"#Target# is no longer invigorated by the heat.", _t"-BOMBARDIER_FIRE_POWER" end, --luacheck: ignore 212
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists_pen", {all=eff.penetration})
		self:effectTemporaryValue(eff, "combat_physcrit", eff.crit)
		self:effectTemporaryValue(eff, "combat_spellcrit", eff.crit)
		self:effectTemporaryValue(eff, "combat_mindcrit", eff.crit)
	end,
	deactivate = function(self, eff) --luacheck: ignore 212
	end,
}

newEffect{
	name = "BOMBARDIER_CAUSTIC_CLEANSE", image = "talents/bombardier_caustic_cleanse.png",
	desc = _t"Caustic Cleanse",
	long_desc = function(self, eff) return ("The target has 1 physical ailment cleansed each turn."):  --luacheck: ignore 212
		tformat() end,
	type = "magical",
	subtype = { acid=true, },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return _t"#Target# is being cleansed of physical ailments.", _t"+BOMBARDIER_CAUSTIC_CLEANSE" end, --luacheck: ignore 212
	on_lose = function(self, err) return _t"#Target#'s is no longer being cleansed.", _t"-BOMBARDIER_CAUSTIC_CLEANSE" end, --luacheck: ignore 212
	activate = function(self, eff) --luacheck: ignore 212
		self:removeEffectsFilter(self, {type="physical", status="detrimental"}, 1)
	end,
	deactivate = function(self, eff) --luacheck: ignore 212
	end,
	on_timeout = function(self, eff)
		local cleanse = self:removeEffectsFilter(self, {type="physical", status="detrimental"}, 1)
		if cleanse > 0 then eff.dur = eff.dur + 1 end
	end,
}

newEffect{
	name = "BOMBARDIER_DYNAMIC_RECHARGE", image = "talents/dynamic_recharge.png",
	desc = _t"Dynamic Recharge",
	long_desc = function(self, eff) return ("All talents on cooldown have %d%% chance to be reduced by 1."):tformat(eff.chance) end, --luacheck: ignore 212
	type = "magical",
	subtype = { lightning=true, },
	status = "beneficial",
	parameters = {chance=35},
	on_gain = function(self, err) return _t"#Target# is feeling energized by the attack.", _t"+BOMBARDIER_DYNAMIC_RECHARGE" end, --luacheck: ignore 212
	on_lose = function(self, err) return _t"#Target# is no longer energized.", _t"-BOMBARDIER_DYNAMIC_RECHARGE" end, --luacheck: ignore 212
	callbackOnActBase = function(self, eff) --luacheck: ignore 212
		local tids = table.keys(self.talents_cd)
		for _, tid in ipairs(tids) do
			if self.talents_cd[tid] > 0 and rng.percent(eff.chance) then
				self.talents_cd[tid] = self.talents_cd[tid] - 1
				if self.talents_cd[tid] <= 0 then self.talents_cd[tid] = nil end
			end
		end
	end,
}
