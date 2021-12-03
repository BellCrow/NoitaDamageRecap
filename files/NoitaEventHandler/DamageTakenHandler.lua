dofile("mods/damage_recap/files/Model/DamageAggregator.lua")
dofile("mods/damage_recap/files/Lib/Util.lua")
dofile("mods/damage_recap/files/Constants.lua")
dofile("mods/damage_recap/files/Lib/VariableStorage.lua")

local damageAggregatorVar = nil

local function Initialize()
    local variableStorageVar = GetVariableStorage()
    local damageAggregatorStr = variableStorageVar:GetValue(DamageAggregatorSaveKey)
    damageAggregatorVar = DamageAggregator:FromTable(DeserializeToTable(damageAggregatorStr))
end

local function SaveDamageAggregation()
    local variableStorageVar = GetVariableStorage()
    local serialized_data = SerializeFromTable(damageAggregatorVar:ToTable())
    variableStorageVar:SetValue(DamageAggregatorSaveKey, serialized_data)
end

local function IsInitialized()
    return damageAggregatorVar ~= nil
end

-- is a noita constant name. no real visloation of guidelines
---@diagnostic disable-next-line: lowercase-global
function damage_received( damage, desc, entityWhoCaused, isFatal)
    if not IsInitialized() then
        Initialize()
    end
    local normalized_damage = damage * 25
    damageAggregatorVar:AddDamage(desc, normalized_damage)
    SaveDamageAggregation()
end

