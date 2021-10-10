dofile_once("mods/damage_stats/files/damage_stats_util.lua")
dofile_once("mods/damage_stats/files/damage_stats_constants.lua")


function damage_received( damage, desc, entity_who_caused, is_fatal)

    local player_entity = get_player_entity()

    local storage_component = get_storage_component()
    print("Storage component value:" .. tostring(storage_component))
    
    print(tostring(damage * 25).." damage taken from ".. desc )
    

end