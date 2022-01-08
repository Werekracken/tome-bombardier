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

if not Talents.talents_types_def["spell/bombardier-explosives"] then
    newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-explosives", name = _t("explosives", "talent type"), description = _t"Manipulate gems to turn them into explosive magical bombs." }
    load("/data-bombardier/talents/spells/bombardier-explosives.lua")
end
if not Talents.talents_types_def["spell/bombardier-flame-alchemy"] then
    newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-flame-alchemy", name = _t("flame alchemy", "talent type"), description = _t"Alchemical control over fire." }
    load("/data-bombardier/talents/spells/bombardier-flame-alchemy.lua")
end
if not Talents.talents_types_def["spell/bombardier-caustic-alchemy"] then
    newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-caustic-alchemy", name = _t("caustic alchemy", "talent type"), description = _t"Alchemical control over acid." }
    load("/data-bombardier/talents/spells/bombardier-caustic-alchemy.lua")
end
if not Talents.talents_types_def["spell/bombardier-ice-alchemy"] then
    newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-ice-alchemy", name = _t("ice alchemy", "talent type"), description = _t"Alchemical control over ice." }
    load("/data-bombardier/talents/spells/bombardier-ice-alchemy.lua")
end
if not Talents.talents_types_def["spell/bombardier-lightning-alchemy"] then
    newTalentType{ allow_random=true, no_silence=true, is_spell=true, mana_regen=true, type="spell/bombardier-lightning-alchemy", name = _t("lightning alchemy", "talent type"), min_lev = 10, description = _t"Alchemical control over lightning energies." }
    load("/data-bombardier/talents/spells/bombardier-lightning-alchemy.lua")
end
