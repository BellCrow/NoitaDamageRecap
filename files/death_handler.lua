dofile_once("mods/damage_recap/files/model/damage_aggregator.lua")
dofile_once("mods/damage_recap/files/lib/util.lua")
dofile_once("mods/damage_recap/files/lib/variable_storage.lua")
dofile_once("mods/damage_recap/files/constants.lua")

function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
    print("in death handler")
    local variable_storage_var = get_player_variable_storage()
    local damage_aggregator_str = variable_storage_var:get_value(damage_aggregator_save_key)
    local damage_aggregator_var = damage_aggregator:from_table(deserialize_to_table(damage_aggregator_str))
    print(damage_aggregator_var:to_string())
end
