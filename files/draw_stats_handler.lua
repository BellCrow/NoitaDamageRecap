dofile("mods/damage_recap/files/model/damage_aggregator.lua")
dofile("mods/damage_recap/files/lib/util.lua")
dofile("mods/damage_recap/files/constants.lua")
dofile("mods/damage_recap/files/lib/variable_storage.lua")
dofile("mods/damage_recap/files/views/current_stats_view.lua")


function draw_current_damage_stats()
    local variable_storage_var = get_player_variable_storage()
    local damage_aggregator_str = variable_storage_var:get_value(damage_aggregator_save_key)
    local damage_aggregator = damage_aggregator:from_table(deserialize_to_table(damage_aggregator_str))
    draw_current_damage_as_menu(damage_aggregator)
end
