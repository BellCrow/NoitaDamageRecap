 -- required by settings as it contains needed enums
dofile("data/scripts/lib/mod_settings.lua")

local mod_id = "damage_recap"

-- these are values needed by noita under these specific names
-- no lua warnings appropriate here
---@diagnostic disable-next-line: lowercase-global
mod_setting_version = 1
---@diagnostic disable-next-line: lowercase-global
mod_settings = {
    {
        id = "_",
        ui_name = "Settings for damage recap",
        not_settings = true
    },
    {
        id = "group_damage_types",
        ui_name = "Group damages",
        ui_description = "Group common damage types as one value in the ui (e.g. lava damage and fire damage)",
        value_default = false,
        scope = MOD_SETTING_SCOPE_RUNTIME
    },
    {
        id = "auto_position_table_on_screen",
        ui_name = "Position output table on screen automatically",
        ui_description = "Depicts whether the table is automatically put on the screen appropriately or if the values for position x and y supplied by the user are used",
        value_default = true,
        scope = MOD_SETTING_SCOPE_RUNTIME
    },
    {
        id = "damage_table_x",
        ui_name = "x coordinate of the table in GUI",
        ui_description = "The x coordinate of the table for damage that are to be printed in the GUI",
        value_default = 5,
        value_min = 0,
        value_max = 2000,
        value_display_multiplier = 1,
        scope = MOD_SETTING_SCOPE_RUNTIME
    },
    {
        id = "damage_table_y",
        ui_name = "y coordinate of the table in GUI",
        ui_description = "The y coordinate of the table for damage that are to be printed in the GUI",
        value_default = 5,
        value_min = 0,
        value_max = 2000,
        value_display_multiplier = 1,
        scope = MOD_SETTING_SCOPE_RUNTIME
    }
}


-- This function is called to ensure the correct setting values are visible to the game via ModSettingGet(). your mod's settings don't work if you don't have a function like this defined in settings.lua.
-- This function is called:
--		- when entering the mod settings menu (init_scope will be MOD_SETTINGS_SCOPE_ONLY_SET_DEFAULT)
-- 		- before mod initialization when starting a new game (init_scope will be MOD_SETTING_SCOPE_NEW_GAME)
--		- when entering the game after a restart (init_scope will be MOD_SETTING_SCOPE_RESTART)
--		- at the end of an update when mod settings have been changed via ModSettingsSetNextValue() and the game is unpaused (init_scope will be MOD_SETTINGS_SCOPE_RUNTIME)
function ModSettingsUpdate( init_scope )
	local old_version = mod_settings_get_version( mod_id ) -- This can be used to migrate some settings between mod versions.
	mod_settings_update( mod_id, mod_settings, init_scope )
end

-- This function should return the number of visible setting UI elements.
-- Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
-- If your mod changes the displayed settings dynamically, you might need to implement custom logic.
-- The value will be used to determine whether or not to display various UI elements that link to mod settings.
-- At the moment it is fine to simply return 0 or 1 in a custom implementation, but we don't guarantee that will be the case in the future.
-- This function is called every frame when in the settings menu.
function ModSettingsGuiCount()
	return mod_settings_gui_count( mod_id, mod_settings )
end

-- This function is called to display the settings UI for this mod. Your mod's settings wont be visible in the mod settings menu if this function isn't defined correctly.
function ModSettingsGui( gui, in_main_menu )
	mod_settings_gui( mod_id, mod_settings, gui, in_main_menu )
end
