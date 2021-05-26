damDesc = Talents.main_env.damDesc

spells_req1 = Talents.main_env.spells_req1
spells_req2 = Talents.main_env.spells_req2
spells_req3 = Talents.main_env.spells_req3
spells_req4 = Talents.main_env.spells_req4
spells_req5 = Talents.main_env.spells_req5
spells_req_high1 = Talents.main_env.spells_req_high1
spells_req_high2 = Talents.main_env.spells_req_high2
spells_req_high3 = Talents.main_env.spells_req_high3
spells_req_high4 = Talents.main_env.spells_req_high4
spells_req_high5 = Talents.main_env.spells_req_high5

if not Talents.talents_types_def["spell/bombardier-staff-combat"] then
    newTalentType{ allow_random=allow_npc, no_silence=true, is_spell=true, type="spell/bombardier-staff-combat", name = _t"Staff Combat", generic = true, description = _t"Harness the power of magical staves." }
    load("/data-bombardier/talents/spells/bombardier-staff-combat.lua")
end
if not Talents.talents_types_def["spell/bombardier-explosives"] then
    newTalentType{ allow_random=allow_npc, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-explosives", name = _t"Explosive Admixtures", description = _t"Manipulate gems to turn them into explosive magical bombs." }
    load("/data-bombardier/talents/spells/bombardier-explosives.lua")
end
if not Talents.talents_types_def["spell/bombardier-fire-alchemy"] then
    newTalentType{ allow_random=truallow_npce, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-fire-alchemy", name = _t"Fire Alchemy", description = _t"Alchemical control over fire." }
    load("/data-bombardier/talents/spells/bombardier-fire-alchemy.lua")
end
if not Talents.talents_types_def["spell/bombardier-acid-alchemy"] then
    newTalentType{ allow_random=allow_npc, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-acid-alchemy", name = _t"Acid Alchemy", description = _t"Alchemical control over acid." }
    load("/data-bombardier/talents/spells/bombardier-acid-alchemy.lua")
end
if not Talents.talents_types_def["spell/bombardier-frost-alchemy"] then
    newTalentType{ allow_random=truallow_npce, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-frost-alchemy", name = _t"Frost Alchemy", description = _t"Alchemical control over frost." } 
    load("/data-bombardier/talents/spells/bombardier-frost-alchemy.lua")
end
if not Talents.talents_types_def["spell/bombardier-energy-alchemy"] then
    newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-energy-alchemy", name = _t"Energy Alchemy", min_lev = 10, description = _t"Alchemical control over lightning energies." }
    load("/data-bombardier/talents/spells/bombardier-energy-alchemy.lua")
end
if not Talents.talents_types_def["spell/mana-alchemy"] then
	newTalentType{ allow_random=allow_npc, no_silence=true, is_spell=true, mana_regen=true, type="spell/mana-alchemy", name = "mana alchemy", generic = true, description = "Alchemical control over magical energies." }
    load("/data-bombardier/talents/spells/mana-alchemy.lua")
end	