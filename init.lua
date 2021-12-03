dofile("mods/damage_recap/files/draw_stats_handler.lua")
dofile("mods/damage_recap/files/model/damage_aggregator.lua")
dofile("mods/damage_recap/files/lib/util.lua")
dofile("mods/damage_recap/files/constants.lua")
dofile("mods/damage_recap/files/lib/variable_storage.lua")


-- debug helper
dofile("data/scripts/perks/perk.lua")
dofile( "data/scripts/game_helpers.lua" )
dofile("data/scripts/perks/perk_list.lua")

-- helper 
local function creative_suicide(player_entity)
    local pos_x, pos_y = EntityGetTransform( player_entity )
    EntityLoad("data/entities/items/pickup/sun/sunegg.xml", pos_x +60, pos_y - 150)
end

local function activate_debug_player_state(player_entity)
    perk_pickup(0, player_entity, "MOVEMENT_FASTER", false, false, true)
    perk_pickup(0, player_entity, "MOVEMENT_FASTER", false, false, true)
    perk_pickup(0, player_entity, "MOVEMENT_FASTER", false, false, true)
    perk_pickup(0, player_entity, "FASTER_LEVITATION", false, false, true)
    perk_pickup(0, player_entity, "FASTER_LEVITATION", false, false, true)
    perk_pickup(0, player_entity, "FASTER_LEVITATION", false, false, true)
    perk_pickup(0, player_entity, "INVISIBILITY", false, false, true)
    perk_pickup(0, player_entity, "REPELLING_CAPE", false, false, true)
    perk_pickup(0, player_entity, "REPELLING_CAPE", false, false, true)
end

local function create_damage_aggregator()
    --create the initial empy instance of the damage aggregator
    local damage_aggregator_var = damage_aggregator:new()
    local variable_storage_var = get_variable_storage()
    local serialized_data = serialize_from_table(damage_aggregator_var:to_table())
    variable_storage_var:set_value(damage_aggregator_save_key, serialized_data)
end
-- end helper

function OnModPreInit()
	create_damage_aggregator()
end

function OnPlayerSpawned(player_entity)
    
    EntityAddComponent(player_entity,"LuaComponent",
    {
        execute_every_n_frame="-1",
        script_damage_received = "mods/damage_recap/files/damage_taken_handler.lua",
        script_death = "mods/damage_recap/files/death_handler.lua",
        remove_after_executed="0"
    })
    if(DebugGetIsDevBuild())then
        creative_suicide(player_entity)
        activate_debug_player_state(player_entity)
    end
end

function OnWorldPostUpdate()
    -- GamePrint("PostUpdate " .. GameGetFrameNum())
	draw_current_damage_stats()
end

