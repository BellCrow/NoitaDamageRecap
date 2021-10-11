dofile_once("mods/damage_recap/files/damage_recap_util.lua")
dofile_once("mods/damage_recap/files/damage_recap_constants.lua")


function death( damage_type_bit_field, damage_message, entity_thats_responsible, drop_items )
    local total_damage_as_string = get_value(damage_value_storage_key)
    print("Total damage taken: " .. total_damage_as_string)
end
