dofile_once("mods/damage_recap/files/model/damage_aggregator.lua")
dofile_once("mods/damage_recap/files/lib/variable_storage.lua")


function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
    local variable_storage = variable_storage:new(get_player_entity())
    local damage_aggregator_str = variable_storage:get_value(damage_aggregator_save_key)
    local damage_aggregator = damage_aggregator:deserialize(damage_aggregator_str)
    print(damage_aggregator:to_string())
end
