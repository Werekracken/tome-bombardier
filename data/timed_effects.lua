newEffect{
	name = "BOMBARDIER_FIRE_POWER", image = "talents/bombardier_fire_power.png",
	desc = _t"Fire Power",
	long_desc = function(self, eff) return ("The target is energized by the heat, increasing all damage penetration by %d%%."):tformat(eff.penetration) end,
	type = "magical",
	subtype = { fire=true },
	status = "beneficial",
	parameters = { },
	on_gain = function(self, err) return _t"#Target# is focusing on penetrating resistances.", _t"+BOMBARDIER_FIRE_POWER" end,
	on_lose = function(self, err) return _t"#Target# is no longer focused on penetrating resistances.", _t"-BOMBARDIER_FIRE_POWER" end,
	activate = function(self, eff)
		self:effectTemporaryValue(eff, "resists_pen", {all=eff.penetration})
	end,
	deactivate = function(self, eff)
	end,
}


newEffect{
	name = "BOMBARDIER_CAUSTIC_CLEANSE", image = "talents/bombardier_caustic_cleanse.png",
	desc = _t"Caustic Cleanse",
	long_desc = function(self, eff) return ("The target has 1 physical ailment cleansed each turn."):
		tformat() end,
	type = "magical",
	subtype = { acid=true, },
	status = "beneficial",
	parameters = {},
	on_gain = function(self, err) return _t"#Target# is being cleansed of physical ailments.", _t"+BOMBARDIER_CAUSTIC_CLEANSE" end,
	on_lose = function(self, err) return _t"#Target#'s is no longer being cleansed.", _t"-BOMBARDIER_CAUSTIC_CLEANSE" end,
	activate = function(self, eff)
		self:removeEffectsFilter(self, {type="physical", status="detrimental"}, 1)
	end,
	deactivate = function(self, eff)
	end,
	on_timeout = function(self, eff)
		local cleanse = self:removeEffectsFilter(self, {type="physical", status="detrimental"}, 1)
		if cleanse > 0 then eff.dur = eff.dur + 1 end
	end,
}