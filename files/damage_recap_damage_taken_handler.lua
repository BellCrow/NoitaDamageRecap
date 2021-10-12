dofile_once("mods/damage_recap/files/damage_recap_util.lua")
dofile_once("mods/damage_recap/files/damage_recap_constants.lua")
dofile_once("mods/damage_recap/files/damage_recap_model/damage_recap_damage_aggregator.lua")
dofile_once("mods/damage_recap/files/lib/damage_recap_variable_storage.lua")


local damage_aggregator = nil

function damage_received( damage, desc, entity_who_caused, is_fatal)

    
    if damage_aggregator == nil then
        print("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT")
        damage_aggregator = damage_recap_damage_aggregator:new()
    end
    print(tostring(damage * 25).." damage taken from ".. desc )
    damage_aggregator:add_damage(desc, damage * 25)
    print("Damage table: " .. damage_aggregator:to_string())

end
