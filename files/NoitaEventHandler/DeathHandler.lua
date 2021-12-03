dofile("mods/damage_recap/files/Model/DamageAggregator.lua")
dofile("mods/damage_recap/files/Lib/Util.lua")
dofile("mods/damage_recap/files/Lib/VariableStorage.lua")
dofile("mods/damage_recap/files/Constants.lua")

-- is a noita constant name. no real visloation of guidelines
---@diagnostic disable-next-line: lowercase-global
function death( damageTypeBitField, damageMessage, entityThatsResponsible, dropItems )
    print("in death handler: Message->".. damageMessage .. " Entity->" .. tostring(entityThatsResponsible))
    local variableStorageVar = GetVariableStorage()
    local damageAggregatorStr = variableStorageVar:GetValue(DamageAggregatorSaveKey)
    local damageAggregatorVar = DamageAggregator:FromTable(DeserializeToTable(damageAggregatorStr))
    print(damageAggregatorVar:ToString())
end
