dofile_once("mods/damage_recap/files/damage_recap_util.lua")
dofile_once("mods/damage_recap/files/damage_recap_constants.lua")
dofile_once("mods/damage_recap/files/lib/damage_recap_variable_storage.lua")


local player_memory = nil

function increase_damage_taken(damage)
    if(damage < 0) then
        print("Heal detected")
        return
    end
    local damage_string = player_memory:get_value(damage_value_storage_key)
    local current_damage = tonumber(damage_string)
    player_memory:set_value(damage_value_storage_key, tostring(current_damage + damage))
    print("New total dmg is " .. player_memory:get_value(damage_value_storage_key))
end

function damage_received( damage, desc, entity_who_caused, is_fatal)

    if player_memory == nil then
        player_memory = damage_recap_variable_storage:new(get_player_entity())
        player_memory:set_value(damage_value_storage_key, tostring(0))
    end
    increase_damage_taken(damage * 25)
    print(tostring(damage * 25).." damage taken from ".. desc )

end

