dofile("mods/damage_recap/files/Model/DamageAggregator.lua")
dofile("mods/damage_recap/files/Lib/Util.lua")
dofile("mods/damage_recap/files/Lib/VariableStorage.lua")
dofile("mods/damage_recap/files/Constants.lua")

-- is a noita constant name. no real violation of guidelines
---@diagnostic disable-next-line: lowercase-global
function death( damageTypeBitField, damageMessage, entityThatsResponsible, dropItems )
    -- probably should offer some more insight here into the damage, that was taken
end
