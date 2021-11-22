local function should_group_damage()
    local your_value = ModSettingGet("damage_recap.group_damage_types")
    return your_value
end

local function convert_damage_type_to_readable_string(damage_entry)
--logic to convert the damage types given by the noita
    -- runtime like "$fire_damage" and "damage from material: lava"
    -- into string that are properly formed for formatted
    -- outputting on the screen
    local normalized_damage_string = damage_entry:get_type()
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

    if(not damage_entry:is_material_damage()) then
        -- we have to do a lookup of the damage type in our translation table
        for compare_damage_type, translation in pairs(damage_type_translation_table) do
            if(compare_damage_type == normalized_damage_string) then
                normalized_damage_string = translation
                break
            end
        end
    else
        normalized_damage_string = damage_entry:get_material_damage_short_name()
    end
    return normalized_damage_string
end

local function translate_damage_table(damage_table)
    local translated_damage_table = {}
    for _, damage_entry in pairs(damage_table) do
        local damage_type = convert_damage_type_to_readable_string(damage_entry)
        local damage_sum = damage_entry:get_sum()
        translated_damage_table[damage_type] = damage_sum
    end
    return translated_damage_table
end

local function translate_and_group_damage_table(damage_table)
    -- all damage types
    -- ["$damage_sun"] = "Sun",
    -- ["$damage_radioactive"] = "Toxic Sludge/Radio",
    -- ["$damage_projectile"] = "Projectile",
    -- ["$damage_overeating"] = "Overeating",
    -- ["$damage_electricity"] = "Electricity",
    -- ["$damage_explosion"] = "Explosion",
    -- ["$damage_fire"] = "Fire",
    -- ["$damage_melee"] = "Melee",
    -- ["$damage_drill"] = "Drill",
    -- ["$damage_slice"] = "Slice",
    -- ["$damage_ice"] = "Ice",
    -- ["$damage_healing"] = "Healing",
    -- ["$damage_physicshit"] = "Physics hit",
    -- ["$damage_poison"] = "Poison",
    -- ["$damage_water"] = "Water",
    -- ["$damage_fall"] = "Fall",
    -- ["$damage_drowning"] = "Drowning",
    -- ["$damage_kick"] = "Kick"
    
    --these are the damage types to which all other damage types need to be reduced
    local reduced_damage_table = {
        fire = 0,
        chemical = 0,
        meele = 0,
        projectile = 0,
        physical = 0,
        electricity = 0,
        explosion = 0,
        ice = 0,
        curse = 0,
        healing = 0
    }

    -- this mapping defines as which kind of damage 
    -- each original type will be counted as in the reduced map
    local damage_reduce_map = {
        -- the values here mus map the keys of the reduced_damage_table map
        ["$damage_sun"] = "fire",
        ["$damage_radioactive"] = "chemical",
        ["$damage_projectile"] = "projectile",
        ["$damage_overeating"] = "physical",
        ["$damage_electricity"] = "electricity",
        ["$damage_explosion"] = "explosion",
        ["$damage_fire"] = "fire",
        ["$damage_melee"] = "meele",
        ["$damage_drill"] = "physical",
        ["$damage_slice"] = "physical",
        ["$damage_ice"] = "ice",
        ["$damage_healing"] = "healing",
        ["$damage_physicshit"] = "physical",
        ["$damage_poison"] = "chemical",
        ["$damage_water"] = "physical",
        ["$damage_fall"] = "physical",
        ["$damage_drowning"] = "physical",
        ["$damage_kick"] = "physical",

        --material damage types
        ["acid"] = "chemical",
        ["lava"] = "fire",
        ["blood_cold_vapour"] = "chemical",
        ["blood_cold"] = "chemical",
        ["poison"] = "chemical",
        ["radioactive_gas"] = "chemical",
        ["radioactive_gas_static"] = "chemical",
        ["rock_static_radioactive"] = "chemical",
        ["rock_static_poison"]  = "chemical",
        ["ice_radioactive_static"]  = "chemical",
        ["ice_radioactive_glass"]  = "chemical",
        ["ice_acid_static"]  = "chemical",
        ["ice_acid_glass"]  = "chemical",
        ["rock_static_cursed"] = "curse",
        ["magic_gas_hp_regeneration"] = "healing",
        ["gold_radioactive"] = "chemical",
        ["gold_static_radioactive"]  = "chemical",
        ["rock_static_cursed_green"] = "curse",
        ["cursed_liquid"] = "curse",
        ["poo_gas"]  = "chemical",
        ["freezing_vapour"] = "chemical",
        ["toxic_gas"] = "chemical"
    }

    local return_table = {}
    for _,damage in pairs(damage_table) do
        local transformed_damage_type = ""
        if(damage:is_material_damage())then
            transformed_damage_type = damage:get_material_damage_short_name()
            
        else
            transformed_damage_type = damage:get_type()
        end
        

        local reduced_damage_type = damage_reduce_map[transformed_damage_type]
        if(reduced_damage_type == nil) then
            -- corner case, where a damage type is not yet mapped in the reduction map.
            -- we create a placeholder for the ui so we dont get errors and get to know the missing id
            -- the substring is to remove ht leading $ to prevent translation error while printing to gui

            reduced_damage_type = transformed_damage_type 
            if(damage:is_material_damage())then
                transformed_damage_type = string.sub(transformed_damage_type, 2)
            end 
            reduced_damage_table[reduced_damage_type] = 0
        end
        reduced_damage_table[reduced_damage_type] = reduced_damage_table[reduced_damage_type] + damage:get_sum()
        if(reduced_damage_table[reduced_damage_type] ~= 0) then
            return_table[reduced_damage_type] = reduced_damage_table[reduced_damage_type]
        end
    end
    
    return return_table
end

function draw_current_damage_as_menu(damage_aggregator)
    local menu_pos_x = 0
    local menu_pos_y = 10
    local damage_table = damage_aggregator:get_damage_table()

    local printable_damage_table = {}

    if(should_group_damage())then
        printable_damage_table = translate_and_group_damage_table(damage_table)
    else
        printable_damage_table = translate_damage_table(damage_table)
    end

    local gui_handle = GuiCreate()
    GuiLayoutBeginVertical(gui_handle, menu_pos_x, menu_pos_y)
    GuiText(gui_handle, 0, 0, "== Damage table ==")
    for damage_name, damage_sum in pairs(printable_damage_table) do
        local damage_table_entry = damage_name .. " -> " .. string.format("%.2f", damage_sum)
        GuiText(gui_handle, 0, 0, damage_table_entry)
    end
    GuiText(gui_handle, 0, 0, "== End of table ==")

    GuiLayoutEnd(gui_handle)
end


