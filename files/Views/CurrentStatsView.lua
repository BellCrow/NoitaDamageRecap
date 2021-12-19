dofile("mods/damage_recap/files/Lib/Widgets/Table.lua")

local function shouldGroupDamage()
    local shouldGroupDamage = ModSettingGet("damage_recap.group_damage_types")
    return shouldGroupDamage
end

local function convertDamageTypeToReadableString(damageEntry)
    --logic to convert the damage types given by the noita
    -- runtime like "$fire_damage" and "damage from material: lava"
    -- into string that are properly formed for formatted
    -- outputting on the screen
    local normalizedDamageString = damageEntry:GetName()
    local damageTypeTranslationTable = {
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

    if(not damageEntry:IsMaterialDamage()) then
        -- we have to do a lookup of the damage type in our translation table
        for compareDamageType, translation in pairs(damageTypeTranslationTable) do
            if(compareDamageType == normalizedDamageString) then
                normalizedDamageString = translation
                break
            end
        end
    else
        normalizedDamageString = damageEntry:GetMaterialDamageShortName()
    end
    return normalizedDamageString
end

local function translateDamageTable(damageTable)
    local translatedDamageTable = {}
    for _, damageEntry in pairs(damageTable) do
        local damage_type = convertDamageTypeToReadableString(damageEntry)
        local damage_sum = damageEntry:GetSum()
        translatedDamageTable[damage_type] = damage_sum
    end
    return translatedDamageTable
end

local function translateAndGroupDamageTable(damageTable)

    --these are the damage types to which all other damage types need to be reduced
    local reducedDamageTable = {
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
    local damageReduceMap = {
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

    local returnTable = {}
    for _,damage in pairs(damageTable) do
        local transformedDamageType = ""
        if(damage:IsMaterialDamage())then
            transformedDamageType = damage:GetMaterialDamageShortName()
        else
            transformedDamageType = damage:GetName()
        end
        

        local reducedDamageType = damageReduceMap[transformedDamageType]
        if(reducedDamageType == nil) then
            -- corner case, where a damage type is not yet mapped in the reduction map.
            -- we create a placeholder for the ui so we dont get errors and get to know the missing id
           

            reducedDamageType = transformedDamageType 
            if(damage:IsMaterialDamage())then
                 -- remove the leading $ to prevent translation error while printing to gui
                transformedDamageType = string.sub(transformedDamageType, 2)
            end 
            reducedDamageTable[reducedDamageType] = 0
        end
        reducedDamageTable[reducedDamageType] = reducedDamageTable[reducedDamageType] + damage:GetSum()
        if(reducedDamageTable[reducedDamageType] ~= 0) then
            returnTable[reducedDamageType] = reducedDamageTable[reducedDamageType]
        end
    end
    
    return returnTable
end

function DrawCurrentDamageAsMenu(damageAggregator)
    
    local damageTable = damageAggregator:GetDamageTable()

    local printableDamageTable = {}

    if(shouldGroupDamage()) then
        printableDamageTable = translateAndGroupDamageTable(damageTable)
    else
        printableDamageTable = translateDamageTable(damageTable)
    end

    local guiHandle = GuiCreate()
    GuiStartFrame(guiHandle)

    local tableEntries = {}
    local conversionIndex = 1
    for damageName, damageAmount in pairs(printableDamageTable) do
        tableEntries[conversionIndex] = {}
        tableEntries[conversionIndex][tostring(damageName)] = string.format("%.2f",damageAmount)

        conversionIndex = conversionIndex + 1
    end
    
    local printTable = Table:New(tableEntries)
    printTable:SetHeader("Damages")
    if(ModSettingGet("damage_recap.auto_position_table_on_screen")) then
        printTable:SetLayoutMode(LAYOUT_ALIGNMENT)
        printTable:SetHorizontalAlignment(LAYOUT_HORIZONTAL_RIGHT)
        printTable:SetVerticalAlignment(LAYOUT_VERTICAL_BOTTOM)
    else
        printTable:SetLayoutMode(LAYOUT_ABSOLUTE)
        printTable:SetPosition(tonumber(ModSettingGet("damage_recap.damage_table_x")), tonumber (ModSettingGet("damage_recap.damage_table_y")))
    end

    printTable:Print(guiHandle)
end


