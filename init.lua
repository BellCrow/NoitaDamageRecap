
damage_recap_damageTypeTable = {}
function OnPlayerSpawned(player_entity)
    componentId = EntityAddComponent(player_entity,"LuaComponent",
    {
        execute_every_n_frame="-1",
        script_damage_received = "mods/damage_recap/files/damage_recap_damage_taken_handler.lua",
        script_death = "mods/damage_recap/files/damage_recap_death_handler.lua",
        remove_after_executed="0"
    })
    print("Added damage stats hook:" .. componentId)
    
end