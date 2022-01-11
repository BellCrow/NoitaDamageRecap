dofile("mods/damage_recap/files/Model/DamageDatabase.lua")
dofile("mods/damage_recap/files/Lib/Util.lua")
dofile("mods/damage_recap/files/Constants.lua")
dofile("mods/damage_recap/files/Lib/VariableStorage.lua")

---@type DamageDatabase
local damageDatabase = nil

local function Initialize()
    damageDatabase = DamageDatabase:LoadSingleton()
end

local function IsInitialized()
    return damageDatabase ~= nil
end

-- is a noita constant name. no real violation of guidelines
---@diagnostic disable-next-line: lowercase-global
function damage_received( damage, desc, entityWhoCaused, isFatal)
    if not IsInitialized() then
        Initialize()
    end
    
    local normalizedDamage = damage * 25
    local causingEntityName = ""
    if(entityWhoCaused == 0) then -- 0 is the id that seem to be supplied if you take damage from the world or materials in the world
        causingEntityName = "$world"
    else
        causingEntityName = EntityGetName(entityWhoCaused)
    end
    if(causingEntityName == nil or causingEntityName == "") then
        causingEntityName = "$unknown"
    end
    local damageInstance = DamageInstance:New(causingEntityName, desc, normalizedDamage)
    damageDatabase:AddEntry(damageInstance)
    DamageDatabase.SaveSingleton(damageDatabase)
end

