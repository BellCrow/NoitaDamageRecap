dofile_once("mods/damage_stats/files/damage_stats_util.lua")

function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )

    local player_entity = get_player_entity()
    return
    local damage_Types = ""
    for _,value in pairs(damage_stats_damageTypeTable) do
        damage_Types = damage_Types .. "," .. tostring(value)
    end
    print("Current known damage types: " .. damage_Types)
end