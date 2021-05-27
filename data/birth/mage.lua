getBirthDescriptor("class", "Mage").descriptor_choices.subclass["Bombardier"] = "allow"

newBirthDescriptor{
	type = "subclass",
	name = "Bombardier",
	desc = {
		"",
		"Their most important stats are: ",
		"#GOLD#Stat modifiers:",
		"#LIGHT_BLUE# * +0 Strength, +0 Dexterity, +3 Constitution",
		"#LIGHT_BLUE# * +5 Magic, +0 Willpower, +3 Cunning",
		"#GOLD#Life per level:#LIGHT_BLUE# -1",
	},
	power_source = {arcane=true},
	stats = { mag=5, con=3, cun=3, },
	not_on_random_boss = true,
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
		["cunning/survival"]={false, 0},

		--Class
		["spell/bombardier-explosives"]={true, 0.3},
		["spell/bombardier-fire-alchemy"]={true, 0.3},
		["spell/bombardier-acid-alchemy"]={true, 0.3},
		["spell/bombardier-frost-alchemy"]={true, 0.3},
		["technique/combat-techniques-active"]={true, 0.3},
		["spell/enhancement"]={false, 0.3},
		["cunning/dirty"]={false, 0.3},
		["spell/bombardier-energy-alchemy"]={false, 0.3},
	},
	talents = {
		[ActorTalents.T_CREATE_ALCHEMIST_GEMS] = 1,
		[ActorTalents.T_EXTRACT_GEMS] = 1,
		[ActorTalents.T_ARMOUR_TRAINING] = 1,
		[ActorTalents.T_CHANNEL_STAFF] = 1,
		[ActorTalents.T_EARTHEN_BARRIER] = 1,
		[ActorTalents.T_BOMBARDIER_THROW_BOMB] = 1,
		[ActorTalents.T_RUSH] = 1,
	},
	copy = {
		max_life = 100,
		resolvers.auto_equip_filters{QUIVER = {type="alchemist-gem"}},
		resolvers.equipbirth{ id=true,
			{type="weapon", subtype="staff", name="elm staff", autoreq=true, ego_chance=-1000},
			{type="armor", subtype="heavy", name="iron mail armour", autoreq=true, ego_chance=-1000, ego_chance=-1000}
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