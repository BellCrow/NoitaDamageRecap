local USE_PIXEL_POSITION_FOR_GUI_ELEMENT = 1

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
            -- the substring is to remove ht leading $ to prevent translation error while printing to gui

            reducedDamageType = transformedDamageType 
            if(damage:IsMaterialDamage())then
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

local function getDimensionsOfPrintText(printableDamageTable, guiHandle)
    local maxTextWidth = 0
    local textHeightTotal = 0
    for damageName, damageSum in pairs(printableDamageTable) do
        local damageTableEntry = damageName .. " -> " .. string.format("%.2f", damageSum)
        local textWidth, textHeight = GuiGetTextDimensions(guiHandle, damageTableEntry)
        textHeightTotal = textHeightTotal + textHeight
        maxTextWidth = math.max(maxTextWidth, textWidth)
    end
    return maxTextWidth, textHeightTotal
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
    
    local screenWidth, screenHeight = GuiGetScreenDimensions(guiHandle)
    
    local textWidth, textHeight = getDimensionsOfPrintText(printableDamageTable, guiHandle)
    local damageTablePadding = 4
    local damageTableX = 0
    local damageTableY = 0

    if(ModSettingGet("damage_recap.auto_position_table_on_screen")) then
        damageTableX = screenWidth - textWidth - damageTablePadding
        damageTableY = screenHeight - textHeight - damageTablePadding
    else
        damageTableX = ModSettingGet("damage_recap.damage_table_x")
        damageTableY = ModSettingGet("damage_recap.damage_table_y")
    end

    
    GuiLayoutBeginVertical(guiHandle, damageTableX, damageTableY, USE_PIXEL_POSITION_FOR_GUI_ELEMENT)
    -- GuiText(gui_handle, 0, 0, "== Damages taken ==")
    for name, sum in pairs(printableDamageTable) do
        local printEntry = name .. " -> " .. string.format("%.2f", sum)
        GuiText(guiHandle, 0, 0, printEntry)
    end

    GuiLayoutEnd(guiHandle)
end


