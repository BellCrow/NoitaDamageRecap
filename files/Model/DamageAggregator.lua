dofile("mods/damage_recap/files/Lib/Util.lua")
dofile("mods/damage_recap/files/Model/DamageType.lua")
dofile("mods/damage_recap/files/Constants.lua")

DamageAggregator = {}
DamageAggregator.__index = DamageAggregator

function DamageAggregator:New()
    local instance = {}
    setmetatable(instance, DamageAggregator)
    instance.damages = {}
    return instance
end
-- region serialization interface
function DamageAggregator:FromTable(table)
    local instance = {}
    setmetatable(instance, DamageAggregator)
    instance.damages = {}
    for i, damageTable in pairs(table.damages)do
        instance.damages[i] = DamageType:FromTable(damageTable)
    end
    return instance
end

function DamageAggregator:ToTable()
    local ret = {}
    ret.damages = {}
    for i,instance in pairs(self.damages) do
        ret.damages[i] = instance:ToTable()
    end
    return ret
end
-- endregion

function DamageAggregator:AddDamage(name, amount)
    local damageToIncrease = self:getDamageByName(name)

    if damageToIncrease == nil then
        print("New damage type registered: " .. name)
        damageToIncrease = DamageType:New(name)
        self.damages[name] = damageToIncrease
    end
    damageToIncrease:AddDamage(amount)
end

function DamageAggregator:ToString()
    
    local damageStats = "\n-------Damage recap-------\n"
    
    for name, damageTypeInstance in pairs(self.damages)do
        
        damageStats = damageStats .. damageTypeInstance:GetName() .. " -> " .. tostring(damageTypeInstance:GetName()) .. "\n"
    end
    damageStats = damageStats .. "---------------------------"
    return damageStats
end

function DamageAggregator:getDamageByName(strDamageType)
    
    for _, damageType in pairs(self.damages) do
        if(damageType:GetName() == strDamageType) then
            return damageType
        end
    end
    return nil
end

function DamageAggregator:GetDamageTable()
    local ret = {}
    for damageName, damageType in pairs(self.damages)do
        ret[damageName] = damageType
    end
    return ret
end


function LoadSingleton()
    local variableStorageVar = GetVariableStorage()
    local ret = {}
    if(variableStorageVar:ExistsValue(DamageAggregatorSaveKey)) then
        ret = DamageAggregator:New()
        return ret
    else
        local damageAggregatorStr = variableStorageVar:getValue(DamageAggregatorSaveKey)
        local damageAggregatorVar = DamageAggregator:FromTable(DeserializeToTable(damageAggregatorStr))
        return damageAggregatorVar
    end
end