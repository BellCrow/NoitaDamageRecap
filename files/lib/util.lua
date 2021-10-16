dofile_once("mods/damage_recap/files/constants.lua")
dofile_once("mods/damage_recap/files/lib/json_serializer.lua")

function serialize_from_table(table_data)
    return json_encode(table_data)
end

function deserialize_to_table(str_serialized_table)
    return json_decode(str_serialized_table)
end

function get_player_entity()
    return EntityGetClosestWithTag( 0, 0, "player_unit")
end

function table_len(table_to_count)
    local table_count = 0
    for _,_ in pairs(table_to_count) do
        table_count = table_count + 1
    end
    return table_count
end