dofile_once("mods/damage_recap/files/damage_recap_util.lua")
dofile_once("mods/damage_recap/files/damage_recap_constants.lua")


local is_initialized = false
function initialize()
    if is_initialized then
        return
    end
    is_initialized = true
    print("init damage taken value")
    set_value(damage_value_storage_key, tostring(0))
end

function increase_damage_taken(damage)
    if(damage < 0) then
        print("Heal detected")
        return
    end
    local damage_string = get_value(damage_value_storage_key)
    local current_damage = tonumber(damage_string)
    set_value(damage_value_storage_key, tostring(current_damage + damage))
    print("New total dmg is " .. get_value(damage_value_storage_key))
end

function damage_received( damage, desc, entity_who_caused, is_fatal)

    initialize()
    increase_damage_taken(damage * 25)
    print(tostring(damage * 25).." damage taken from ".. desc )

end

