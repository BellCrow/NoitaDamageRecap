dofile("mods/damage_recap/files/Model/DamageAggregator.lua")
dofile("mods/damage_recap/files/Lib/Util.lua")
dofile("mods/damage_recap/files/Constants.lua")
dofile("mods/damage_recap/files/Lib/VariableStorage.lua")
dofile("mods/damage_recap/files/Views/CurrentStatsView.lua")

function DrawCurrentDamageStats()
    local variableStorageVar = GetVariableStorage()
    local damageAggregatorStr = variableStorageVar:GetValue(DamageAggregatorSaveKey)
    local damageAggregator = DamageAggregator:FromTable(DeserializeToTable(damageAggregatorStr))
    DrawCurrentDamageAsMenu(damageAggregator)
end
