getBirthDescriptor("class", "Mage").descriptor_choices.subclass["Bombardier"] = "allow"

newBirthDescriptor{
	type = "subclass",
	name = "Bombardier",
	desc = {
		"Bombardiers are a variant of the Alchemist. They use alchemist bombs, but forgo a golem in to focus more on the effects of their bombs and their own combat viability.",
		"Their most important stats are Magic and Cunning, but they find every stat valuable.",
		"",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +2 Strength, +2 Dexterity, +2 Constitution",
		"#LIGHT_BLUE# * +2 Magic, +2 Willpower, +2 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# +2",
	},
	power_source = {arcane=true},
	stats = { str=2, dex=2, con=2, mag=2, wil=2, cun=2 },
	--not_on_random_boss = true,
	birth_example_particles = {
		function(actor)
			actor:addShaderAura("body_of_fire", "awesomeaura", {time_factor=3500, alpha=1, flame_scale=1.1}, "particles_images/wings.png")
		end,
		function(actor)
			actor:addShaderAura("body_of_ice", "crystalineaura", {}, "particles_images/spikes.png")
		end,
	},
	talents_types = {
		--Generic
		["technique/combat-training"]={true, 0.3},
		["spell/stone-alchemy"]={true, 0.3},
		["spell/staff-combat"]={true, 0.3},
		["spell/conveyance"]={false, 0.3},
		["cunning/survival"]={false, 0.0},
		["spell/aegis"]={false, 0.3},

		--Class
		["cunning/trapping"]={true, 0.3},
		["cunning/tactical"]={true, 0.3},
		["spell/enhancement"]={true, 0.3},
		["spell/bombardier-explosives"]={true, 0.3},
		["spell/bombardier-flame-alchemy"]={true, 0.3},
		["spell/bombardier-ice-alchemy"]={true, 0.3},
		["cunning/artifice"]={false, 0.3},
		["spell/bombardier-lightning-alchemy"]={false, 0.3},
		["spell/bombardier-caustic-alchemy"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_CREATE_ALCHEMIST_GEMS] = 1,
		[ActorTalents.T_EXTRACT_GEMS] = 1,
		[ActorTalents.T_WEAPON_COMBAT] = 1,
		[ActorTalents.T_BOMBARDIER_FIRE_INFUSION] = 1,
		[ActorTalents.T_BOMBARDIER_THROW_BOMB] = 1,
	},
	copy = {
		resolvers.auto_equip_filters{QUIVER = {type="alchemist-gem"}},
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="light", name="rough leather armour", autoreq=true, ego_chance=-1000},
		},
		resolvers.inventory{ id=true,
			{type="gem",},
			{type="gem",},
			{type="gem",},
		},
		resolvers.generic(function(self) self:birth_create_alchemist_gems() end),
		birth_create_alchemist_gems = function(self)
			-- Make and wield some alchemist gems
			local t = self:getTalentFromId(self.T_CREATE_ALCHEMIST_GEMS)
			local gem = t.make_gem(self, t, "GEM_AGATE")
			self:wearObject(gem, true, true)
			self:sortInven()
		end,
	},
	copy_add = {
		life_rating = 2,
	},
}