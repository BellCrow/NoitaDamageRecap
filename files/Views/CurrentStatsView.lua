dofile("mods/damage_recap/files/Lib/Widgets/Table.lua")
dofile("mods/damage_recap/files/Model/DamageDatabase.lua")

local function isMaterialDamage(damageName)
    -- damage names we get from noita that are cause by materials are given like: 
    -- "damage from material: lava" thus need to be parsed in a way. this methods
    -- determines if this damage entry is such a damage instance
    return string.find(damageName,":") ~= nil
end

local function getMaterialDamageShortName(damageName)
    -- converts a damage text like "damage from material: lava" into just the string "lava"
    if(not isMaterialDamage(damageName)) then
        error("Tried to get damage material name of damage type that is not material damage. Damage name: " .. tostring(self:GetName()))
    end
    local damageNameSeparatorIndex = string.find(damageName,":")
    local normalizedDamageString = string.sub(damageName, damageNameSeparatorIndex + 2)
    normalizedDamageString = normalizedDamageString:gsub(" ","")
    normalizedDamageString = string.lower(normalizedDamageString)
    return normalizedDamageString
end

local function convertDamageTypeToReadableString(damageName)
    --logic to convert the damage types given by the noita
    -- runtime like "$fire_damage" and "damage from material: lava"
    -- into string that are properly formed for formatted
    -- outputting on the screen
    local normalizedDamageString = damageName
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

    if(not isMaterialDamage(damageName)) then
        -- we have to do a lookup of the damage type in our translation table
        for compareDamageType, translation in pairs(damageTypeTranslationTable) do
            if(compareDamageType == normalizedDamageString) then
                normalizedDamageString = translation
                break
            end
        end
    else
        normalizedDamageString = getMaterialDamageShortName(damageName)
    end
    return normalizedDamageString
end

---@param damageInstances table<number, DamageInstance>
---@return table<string,number>
local function reduceToAggregatedDamageTypes(damageInstances)
    local aggregatedEntries = {}

    -- aggregate by raw damage name
    for _, damageInstance in pairs(damageInstances) do
        local normalizedDamageName = ""
        if(isMaterialDamage(damageInstance:GetDamageName()))then
            normalizedDamageName = getMaterialDamageShortName(damageInstance:GetDamageName())
        else
            normalizedDamageName = damageInstance:GetDamageName()
        end

        if(aggregatedEntries[normalizedDamageName] == nil ) then
            aggregatedEntries[normalizedDamageName] = 0
        end
        aggregatedEntries[normalizedDamageName] = aggregatedEntries[normalizedDamageName] + damageInstance:GetDamageAmount()
    end
    return aggregatedEntries
end

---@param damageInstances table<number, DamageInstance>
---@return table<number,table<string,number>>
local function aggregateByDamageType(damageInstances)
    local aggregatedEntries = reduceToAggregatedDamageTypes(damageInstances)

    -- translated raw damage name into human readable
    -- strings and assign an index for the table widget to print
    local printableTable = {}
    local conversionIndex = 1
    for damageName, damageAmount in pairs(aggregatedEntries) do
        printableTable[conversionIndex] = {}
        printableTable[conversionIndex][convertDamageTypeToReadableString(damageName)] = string.format("%.2f",damageAmount)
        conversionIndex = conversionIndex + 1
    end
    return printableTable
end

---@param damageInstances table<number, DamageInstance>
---@return table<number,table<string,number>>
local function aggregateBySimplifiedDamageTypes(damageInstances)
    local aggregatedEntries = reduceToAggregatedDamageTypes(damageInstances)
    
    -- these are the damage types to which all other damage types need to be reduced
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
        -- the values here must map to the keys of the reduced_damage_table map
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

        -- material damage types
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
    
    -- reducing the damages to the desired simpler types
    for damageName, damageAmount in pairs(aggregatedEntries) do
        local reducedDamageName = damageReduceMap[damageName]
        if(reducedDamageName == nil) then
            -- corner case, where a damage type is not yet mapped in the reduction map.
            -- we create a placeholder for the ui so we dont get errors and get to know the missing id

            -- remove the leading $ ($ must be escaped therefore the $$) to prevent translation error while printing to gui
            reducedDamageName = damageName:gsub("$$", "")
            reducedDamageTable[reducedDamageName] = 0
        end
        if(reducedDamageTable[reducedDamageName] == nil)then
            reducedDamageTable[reducedDamageName] = 0
        end
        reducedDamageTable[reducedDamageName] = reducedDamageTable[reducedDamageName] + damageAmount
    end

    -- mapping the reduced damage calues to the format the table widget needs
    local returnTable = {}
    local iterationIndex = 1
    for damageName, damageAmount in pairs(reducedDamageTable) do
        if(damageAmount ~= 0)then
            returnTable[iterationIndex] = {}
            returnTable[iterationIndex] = {[damageName] = string.format("%.2f",damageAmount)}
            iterationIndex = iterationIndex + 1
        end
    end

    return returnTable
end

---@param entityName string 
---@return string
---Translates a given entityName like $animal_acidshooter_weak into a human readable string that is meant for printing/logging
---The id 0 will be translated to the literal string "World"
---if an the name of an entity cannot be retrieved the string "Unavailable" will be returned
---If the translation of an entity is not available the name of the entity will be returned by the following schema:
---$animal_acidshooter_weak -> acidshooter_weak
---the underscorde is left in to signify that a translation is missing
local function convertNoitaEntityNameToReadableString(entityName)
    --this list is directly taken from the translations/common.csv
    local animalIdToNameTranslations = {
    ["$animal_acidshooter_weak"] =	"Heikko happonuljaska",
    ["$animal_boss_alchemist"] =	"Ylialkemisti",
    ["$animal_boss_centipede"] =	"Kolmisilmä",
    ["$animal_boss_ghost"] =	"Unohdettu",
    ["$animal_boss_ghost_polyp"] =	"Häive",
    ["$animal_boss_pit"] =	"Sauvojen tuntija",
    ["$animal_boss_robot"] =	"Kolmisilmän silmä",
    ["$animal_boss_wizard"] =	"Mestarien mestari",
    ["$animal_chest_leggy"] =	"Jalkamatkatavara",
    ["$animal_cook"] =	"Kokkihiisi",
    ["$animal_coward"] =	"Raukka",
    ["$animal_dark_alchemist"] =	"Pahan muisto",
    ["$animal_drone_lasership"] =	"Jättilaser-lennokki",
    ["$animal_drone_shield"] =	"Turvalennokki",
    ["$animal_enlightened_alchemist"] =	"Valaistunut alkemisti",
    ["$animal_enlightened_laser_dark_wand"] =	"Dark wand",
    ["$animal_enlightened_laser_elec_wand"] =	"Thunder wand",
    ["$animal_enlightened_laser_fire_wand"] =	"Fire wand",
    ["$animal_enlightened_laser_light_wand"] =	"Glowing wand",
    ["$animal_ethereal_being"] =	"Olematon",
    ["$animal_failed_alchemist"] =	"Kadotettu alkemisti",
    ["$animal_failed_alchemist_b"] =	"Epäalkemisti",
    ["$animal_firemage_big"] =	"Suurstendari",
    ["$animal_fish_giga"] =	"Syväolento",
    ["$animal_friend"] =	"Toveri",
    ["$animal_frog_big"] =	"Jättikonna",
    ["$animal_fungus_big"] =	"Itiösieni",
    ["$animal_fungus_giga"] =	"Huhtasieni",
    ["$animal_fungus_nest"] =	"Rihmasto",
    ["$animal_fungus_tiny"] =	"Myrkkynääpikkä",
    ["$animal_fungus_tiny_perk"] =	"Sappitatti",
    ["$animal_gate_monster_a"] =	"Veska",
    ["$animal_gate_monster_b"] =	"Molari",
    ["$animal_gate_monster_c"] =	"Mokke",
    ["$animal_gate_monster_d"] =	"Seula",
    ["$animal_gazer_big"] =	"Kolmisilmän kätyri",
    ["$animal_giantshooter_weak"] =	"Heikko äitinuljaska",
    ["$animal_goblin_bomb"] =	"Sähikäismenninkäinen",
    ["$animal_greed_ghost"] =	"Ghost of Greed",
    ["$animal_hidden"] =	"Vakoilija",
    ["$animal_homunculus"] =	"Homunculus",
    ["$animal_hpcrystal"] =	"Elvytyskristalli",
    ["$animal_icemage"] =	"Pakkasukko",
    ["$animal_lasergun"] =	"Laserkanuuna",
    ["$animal_lukki_dark"] =	"Kammolukki",
    ["$animal_lukki_tiny"] =	"Pikkuhämähäkki",
    ["$animal_lurker"] =	"Varjokupla",
    ["$animal_maggot_tiny"] =	"Limatoukka",
    ["$animal_mine"] =	"Maamiina",
    ["$animal_minipit"] =	"Pienkätyri",
    ["$animal_monk"] =	"Munkki",
    ["$animal_necrobot"] =	"Tuonelankone",
    ["$animal_necrobot_super"] =	"Marraskone",
    ["$animal_necromancer"] =	"Hahmonvaihtaja",
    ["$animal_necromancer_shop"] =	"Stevari",
    ["$animal_necromancer_super"] =	"Skoude",
    ["$animal_neutralizer"] =	"Pysäyttäjä",
    ["$animal_parallel_alchemist"] =	"Alkemistin Varjo",
    ["$animal_parallel_tentacles"] =	"Kolmisilmän Kätyri",
    ["$animal_pebble_physics"] =	"Lohkare",
    ["$animal_physics_pata"] =	"Pata",
    ["$animal_piranha"] =	"Kyrmyniska",
    ["$animal_plague_rats_rat"] =	"Ruttorotta",
    ["$animal_scavenger_glue"] =	"Liimahiisi",
    ["$animal_scavenger_invis"] =	"Häivehiisi",
    ["$animal_scavenger_shield"] =	"Kilpihiisi",
    ["$animal_sentry"] =	"Tarkkailija",
    ["$animal_shaman"] =	"Märkiäinen",
    ["$animal_skycrystal_physics"] =	"Taivaskristalli",
    ["$animal_skygazer"] =	"Taivaankatse",
    ["$animal_slimeshooter_nontoxic"] =	"Limanuljaska",
    ["$animal_slimeshooter_weak"] =	"Heikko limanuljaska",
    ["$animal_snowcrystal"] =	"Haamukivi",
    ["$animal_soldier"] =	"Teloittaja",
    ["$animal_spearbot"] =	"Peitsivartija",
    ["$animal_spiderbot"] =	"Rautalukki",
    ["$animal_statue"] =	"Patsas",
    ["$animal_statue_physics"] =	"Hohtonaamio",
    ["$animal_surge"] =	"Sähikäinen",
    ["$animal_tank_super"] =	"Laser-tankki",
    ["$animal_thunderhound"] =	"Ukkoskoira",
    ["$animal_thundermage_big"] =	"Suur-Ukko",
    ["$animal_thunderskull"] =	"Sähkiö",
    ["$animal_turret_left"] =	"Torjuntalaite",
    ["$animal_turret_right"] =	"Torjuntalaite",
    ["$animal_ultimate_killer"] =	"Kauhuhirviö",
    ["$animal_wand"] =	"Wand",
    ["$animal_wizard_hearty"] =	"Haavoittajamestari",
    ["$animal_wizard_homing"] =	"Kohdennusmestari",
    ["$animal_wizard_neutral"] =	"Maadoittajamestari",
    ["$animal_wizard_returner"] =	"Palauttajamestari",
    ["$animal_wizard_swapper"] =	"Vaihdosmestari",
    ["$animal_wizard_twitchy"] =	"Sätkymestari",
    ["$animal_wizard_weaken"] =	"Turvattomuusmestari",
    ["$animal_wizard_wither"] =	"Kuihduttajamestari",
    ["$animal_wraith"] =	"Hyypiö",
    ["$animal_wraith_glowing"] =	"Hohtava hyypiö",
    ["$animal_wraith_storm"] =	"Ukkoshyypiö",
    ["$animal_acidshooter"] =	"Happonuljaska",
    ["$animal_alchemist"] =	"Alkemisti",
    ["$animal_ant"] =	"Murkku",
    ["$animal_assassin"] =	"Salamurhaajarobotti",
    ["$animal_barfer"] =	"Turvonnu velho",
    ["$animal_bat"] =	"Lepakko",
    ["$animal_bigbat"] =	"Suurlepakko",
    ["$animal_bigfirebug"] =	"Suurtulikärpänen",
    ["$animal_bigzombie"] =	"Mätänevä ruumis",
    ["$animal_bigzombiehead"] =	"Mätänevä pää",
    ["$animal_bigzombietorso"] =	"Mätänevä kroppa",
    ["$animal_blob"] =	"Kiukkumöykky",
    ["$animal_bloodcrystal_physics"] =	"Verikristalli",
    ["$animal_bloom"] =	"Puska",
    ["$animal_boss_centipede_minion"] =	"Kolmisilmän apuri",
    ["$animal_boss_dragon"] =	"Suomuhauki",
    ["$animal_boss_dragon_endcrystal"] =	"Mato",
    ["$animal_boss_limbs"] =	"Kolmisilmän koipi",
    ["$animal_chest_mimic"] =	"Matkija",
    ["$animal_crystal_physics"] =	"Kirottu kristalli",
    ["$animal_darkghost"] =	"Haamu",
    ["$animal_deer"] =	"Nelikoipi",
    ["$animal_drone"] =	"Lennokki",
    ["$animal_drone_physics"] =	"Lennokki",
    ["$animal_duck"] =	"Ankka",
    ["$animal_eel"] =	"Nahkiainen",
    ["$animal_elk"] =	"Poro",
    ["$animal_firebug"] =	"Pikkutulikärpänen",
    ["$animal_firemage"] =	"Eldari",
    ["$animal_firemage_weak"] =	"Stendari",
    ["$animal_fireskull"] =	"Liekkiö",
    ["$animal_fish"] =	"Eväkäs",
    ["$animal_fish_large"] =	"Suureväkäs",
    ["$animal_flamer"] =	"Liekkari",
    ["$animal_fly"] =	"Amppari",
    ["$animal_frog"] =	"Konna",
    ["$animal_fungus"] =	"Laahustussieni",
    ["$animal_gazer"] =	"Helvetinkatse",
    ["$animal_ghost"] =	"Houre",
    ["$animal_ghoul"] =	"Sylkyri",
    ["$animal_giant"] =	"Hiidenkivi",
    ["$animal_giantshooter"] =	"Äitinuljaska",
    ["$animal_healerdrone_physics"] =	"Korjauslennokki",
    ["$animal_icer"] =	"Jäähdytyslaite",
    ["$animal_iceskull"] =	"Jäätiö",
    ["$animal_lasershooter"] =	"Mulkkio",
    ["$animal_longleg"] =	"Hämis",
    ["$animal_lukki"] =	"Hämähäkki",
    ["$animal_lukki_creepy"] =	"Kasvoton Hämähäkki",
    ["$animal_lukki_creepy_long"] =	"Kasvoton Lukki",
    ["$animal_lukki_longleg"] =	"Lukki",
    ["$animal_maggot"] =	"Toukka",
    ["$animal_mimic_physics"] =	"Matkija",
    ["$animal_mine_scavenger"] =	"Miina",
    ["$animal_miner"] =	"Tappurahiisi",
    ["$animal_miner_fire"] =	"Tulihiisi",
    ["$animal_miner_santa"] =	"Jouluhiisi",
    ["$animal_miner_weak"] =	"Tappurahiisiläinen",
    ["$animal_miniblob"] =	"Möykky",
    ["$animal_missilecrab"] =	"Heinäsirkka",
    ["$animal_pebble"] =	"Lohkare",
    ["$animal_pebble_player"] =	"Toveri lohkare",
    ["$animal_phantom_a"] =	"Spiraalikalma",
    ["$animal_phantom_b"] =	"Kiukkukalma",
    ["$animal_player"] =	"Minä",
    ["$animal_playerghost"] =	"Kummitus",
    ["$animal_rat"] =	"Rotta",
    ["$animal_roboguard"] =	"Robottikyttä",
    ["$animal_scavenger_clusterbomb"] =	"Isohiisi",
    ["$animal_scavenger_grenade"] =	"Kranuhiisi",
    ["$animal_scavenger_heal"] =	"Parantajahiisi",
    ["$animal_scavenger_leader"] =	"Toimari",
    ["$animal_scavenger_mine"] =	"Miinankylväjä",
    ["$animal_scavenger_poison"] =	"Myrkkyhiisi",
    ["$animal_scavenger_smg"] =	"Rynkkyhiisi",
    ["$animal_scorpion"] =	"Skorpioni",
    ["$animal_sheep"] =	"Lammas",
    ["$animal_sheep_bat"] =	"Lentolammas",
    ["$animal_sheep_fly"] =	"Suhiseva lammas",
    ["$animal_shooterflower"] =	"Plasmakukka",
    ["$animal_shotgunner"] =	"Haulikkohiisi",
    ["$animal_shotgunner_weak"] =	"Heikko haulikkohiisi",
    ["$animal_skullfly"] =	"Kallokärpänen",
    ["$animal_skullrat"] =	"Kallorotta",
    ["$animal_slimeshooter"] =	"Limanuljaska",
    ["$animal_slimeshooter_boss_limbs"] =	"Äitilimanuljaska",
    ["$animal_sniper"] =	"Snipuhiisi",
    ["$animal_spitmonster"] =	"Helvetin sylkijä",
    ["$animal_tank"] =	"KK-Tankki",
    ["$animal_tank_rocket"] =	"IT-Tankki",
    ["$animal_tentacler"] =	"Turso",
    ["$animal_tentacler_small"] =	"Pikkuturso",
    ["$animal_thundermage"] =	"Ukko",
    ["$animal_turret"] =	"Torjuntalaite",
    ["$animal_wand_ghost"] =	"Taikasauva",
    ["$animal_wizard_dark"] =	"Sokaisunmestari",
    ["$animal_wizard_poly"] =	"Muodonmuutosmestari",
    ["$animal_wizard_tele"] =	"Siirtäjämestari",
    ["$animal_wolf"] =	"Susi",
    ["$animal_worm"] =	"Mato",
    ["$animal_worm_big"] =	"Jättimato",
    ["$animal_worm_end"] =	"Helvetinmato",
    ["$animal_worm_skull"] =	"Kalmamato",
    ["$animal_worm_tiny"] =	"Pikkumato",
    ["$animal_zombie"] =	"Hurtta",
    ["$animal_zombie_weak"] =	"Heikkohurtta",
    ["$world"] =	"World",
    ["$unknown"] =	"Unknown",
   }
   -- $world/$unknown is a meta name i have added so that i can treat damage from materials/the world in the same ways as damage from entities with an identifier
   -- the issue is, that no name is returned if you try to get the name of the damaging entity if the ID 0 (stands for world) is supplied by noita.
   -- for instance if you create a sun and take damage from it the sun will supplie an id in the damage taken handler but no name for the entity can be retrieved (afaik)
   
   if(entityName == nil)then
    return "Unavailable"
   end

   local translatedName = animalIdToNameTranslations[entityName]
   if(translatedName ~= nil) then
    return translatedName
   end
   return entityName:match("%$animal_(.*)")
end

---@param damageInstances table<number, DamageInstance>
local function aggregateByEntity(damageInstances)
    local aggregatedEntityDamages = {}
    -- aggregate the damagenumbers by entity who caused the damage
    for _, damageInstance in pairs(damageInstances)do
        if(aggregatedEntityDamages[damageInstance:GetCausingEntityName()] == nil)then
            aggregatedEntityDamages[damageInstance:GetCausingEntityName()] = 0
        end
        aggregatedEntityDamages[damageInstance:GetCausingEntityName()] =
         aggregatedEntityDamages[damageInstance:GetCausingEntityName()] + damageInstance:GetDamageAmount()
    end

    -- translate the noita entity names to human readable
    -- for that can also be passed to the table widget
    local printableTable = {}
    local conversionIndex = 1
    for entityName, damageAmount in pairs(aggregatedEntityDamages) do
        printableTable[conversionIndex] = {}
        printableTable[conversionIndex][convertNoitaEntityNameToReadableString(entityName)] = string.format("%.2f",damageAmount)
        conversionIndex = conversionIndex + 1
    end
    return printableTable
end

---@param damageDatabase DamageDatabase
function DrawCurrentDamageAsMenu(damageDatabase)
    
    local damageTable = damageDatabase:GetEntries()

    local printTable = {}
    
    local aggregationType = ModSettingGet("damage_recap.aggregate_by")
    
    if(aggregationType == "damageType")then
        printTable = aggregateByDamageType(damageTable)
    elseif(aggregationType == "damageTypeSimplified")then
        printTable = aggregateBySimplifiedDamageTypes(damageTable)
    elseif(aggregationType == "causingEntity")then
        printTable = aggregateByEntity(damageTable)
    else
        error("Unknown aggregation type detected:" .. aggregationType)
    end
    local guiHandle = GuiCreate()
    GuiStartFrame(guiHandle)

    local printTable = Table:New(printTable)
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
