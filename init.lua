dofile("mods/damage_recap/files/NoitaEventHandler/DrawStatsHandler.lua")
dofile("mods/damage_recap/files/Model/DamageAggregator.lua")
dofile("mods/damage_recap/files/Lib/Util.lua")
dofile("mods/damage_recap/files/Constants.lua")
dofile("mods/damage_recap/files/Lib/VariableStorage.lua")
dofile("mods/damage_recap/files/Lib/Widgets/Table.lua")

-- debug helper
dofile("data/scripts/perks/perk.lua")
dofile("data/scripts/game_helpers.lua")
dofile("data/scripts/perks/perk_list.lua")

-- helper 
local function creativeSuicide(playerEntity)
    local posX, posY = EntityGetTransform( playerEntity )
    EntityLoad("data/entities/items/pickup/sun/sunegg.xml", posX +60, posY - 150)
end

local function activateDebugPlayerState(playerEntity)
    perk_pickup(0, playerEntity, "MOVEMENT_FASTER", false, false, true)
    perk_pickup(0, playerEntity, "MOVEMENT_FASTER", false, false, true)
    perk_pickup(0, playerEntity, "MOVEMENT_FASTER", false, false, true)
    perk_pickup(0, playerEntity, "FASTER_LEVITATION", false, false, true)
    perk_pickup(0, playerEntity, "FASTER_LEVITATION", false, false, true)
    perk_pickup(0, playerEntity, "FASTER_LEVITATION", false, false, true)
    perk_pickup(0, playerEntity, "INVISIBILITY", false, false, true)
    perk_pickup(0, playerEntity, "REPELLING_CAPE", false, false, true)
    perk_pickup(0, playerEntity, "REPELLING_CAPE", false, false, true)
end

function OnPlayerSpawned(playerEntity)
    
    EntityAddComponent(playerEntity,"LuaComponent",
    {
        execute_every_n_frame="-1",
        script_damage_received = "mods/damage_recap/files/NoitaEventHandler/DamageTakenHandler.lua",
        script_death = "mods/damage_recap/files/NoitaEventHandler/DeathHandler.lua",
        remove_after_executed="0"
    })

    if(DebugGetIsDevBuild())then
        creativeSuicide(playerEntity)
        activateDebugPlayerState(playerEntity)
    end
end

function OnWorldPostUpdate()
    -- GamePrint("PostUpdate " .. GameGetFrameNum())
	DrawCurrentDamageStats()

    -- local guiHandle = GuiCreate()
    -- GuiStartFrame(guiHandle)

    -- local tableEntries = {}
    -- tableEntries[1] = {Entry1 = 100}
    -- tableEntries[2] = {Entry2 = 123}
    -- tableEntries[3] = {Entry3 = 144}
    -- tableEntries[4] = {Entry4 = 53}
    -- tableEntries[5] = {Entry5 = 87}
    -- tableEntries[6] = {Entry6 = 113}

    -- local testTable = Table:New(tableEntries)
    -- testTable:SetLayoutMode(LAYOUT_ALIGNMENT)
    -- testTable:SetHeader(nil)
    -- testTable:SetEntrySeparator(" Separator ")
    -- testTable:SetHorizontalAlignment(LAYOUT_HORIZONTAL_RIGHT)
    -- testTable:SetVerticalAlignment(LAYOUT_VERTICAL_BOTTOM)

    -- testTable:Print(guiHandle)
end

