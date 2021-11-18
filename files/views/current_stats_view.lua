local function convert_damage_type_to_readable_string(damage_type)
--logic to convert the damage types given by the noita
    -- runtime like "$fire_damage" and "damage from material: lava"
    -- into string that are properly formed for formatted
    -- outputting on the screen
    local normalized_damage_string = damage_type
    local damage_type_translation_table = {
        ["$damage_sun"] = "Sun",
        ["$damage_radioactive"] = "Toxic Sludge/Radio",
        ["$damage_projectile"] = "Projectile",
        ["$damage_overeating"] = "Overeating",
        ["$damage_electricity"] = "Electricity",
        ["$damage_explosion"] = "Explosion",
        ["$damage_fire"] = "Fire",
        ["$damage_melee"] = "Melee",
        ["$damage_drill"] = "Drill",
        ["$damage_slice"] = "Slice",
        ["$damage_ice"] = "Ice",
        ["$damage_healing"] = "Healing",
        ["$damage_physicshit"] = "Physics hit",
        ["$damage_poison"] = "Poison",
        ["$damage_water"] = "Water",
        ["$damage_fall"] = "Fall",
        ["$damage_drowning"] = "Drowning",
        ["$damage_kick"] = "Kick"
    }
    -- if we find a ":" we have a "damage from material: xyz" 
    -- damage type and just have to get the name of the material
    local damage_name_separator_index = string.find(damage_type,":")
    if(not (damage_name_separator_index == nil)) then
        -- + 2 because we get the exact index of the ":" and we want the string after the following space
        normalized_damage_string = string.sub(damage_type, damage_name_separator_index + 2)
    else
        -- otherwise we have to do a lookup of the damage type in our translation table
        for compare_damage_type, translation in pairs(damage_type_translation_table) do
            if(compare_damage_type == damage_type) then
                normalized_damage_string = translation
                break
            end
        end
    
    end

    return normalized_damage_string
end

function draw_current_damage_as_menu(damage_aggregator)
    local menu_pos_x = 0
    local menu_pos_y = 10
    local damage_table = damage_aggregator:get_damage_table()
    local gui_handle = GuiCreate()
    GuiLayoutBeginVertical(gui_handle, menu_pos_x, menu_pos_y)
    GuiText(gui_handle, 0, 0, "== Damage table ==")
    for damage_name, damage_type in pairs(damage_table) do
        local non_localizing_damage_type_name = convert_damage_type_to_readable_string(damage_type:get_type())
        local damage_table_entry = non_localizing_damage_type_name .. " -> " .. string.format("%.2f", damage_type:get_sum())
        GuiText(gui_handle, 0, 0, damage_table_entry)
    end
    GuiText(gui_handle, 0, 0, "== End of table ==")

    GuiLayoutEnd(gui_handle)
end
