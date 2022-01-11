---@class DamageDatabase
dofile("mods/damage_recap/files/Lib/Util.lua")
dofile("mods/damage_recap/files/Constants.lua")
dofile("mods/damage_recap/files/Model/DamageInstance.lua")

DamageDatabase = {}
DamageDatabase.__index = DamageDatabase
function DamageDatabase:New()
    local instance = {}
    setmetatable(instance, DamageDatabase)
    instance.damageInstances = {}
    instance.nextFreeIndex = 1
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

-- region serialization interface
---@return DamageDatabase
function DamageDatabase.FromTable(table)
    local instance = {}
    setmetatable(instance, DamageDatabase)
    instance.damageInstances = {}
    for i, damageInstance in pairs(table.damageInstances)do
        instance.damageInstances[i] = DamageInstance.FromTable(damageInstance)
    end
    instance.nextFreeIndex = table.nextFreeIndex
    return instance
end

---@return table
function DamageDatabase:ToTable()
    local ret = {}
    ret.damageInstances = {}
    for i, damageInstance in pairs(self.damageInstances) do
        ret.damageInstances[i] = damageInstance:ToTable()
    end
    ret.nextFreeIndex = self.nextFreeIndex
    return ret
end
-- endregion

---@param damageInstance DamageInstance
---@return DamageInstance
function DamageDatabase:GetExistingDamageInstance(damageInstance)
    for _, damageInstanceIterator in ipairs(self.damageInstances) do
        if(damageInstance:IsEqual(damageInstanceIterator)) then
            return damageInstanceIterator
        end
    end
    return nil
end

-- returns the table of damage instances. ordered with an incrementing index
---@return table<number, DamageInstance>
function DamageDatabase:GetEntries()
    return self.damageInstances
end

---@param damageInstance DamageInstance
function DamageDatabase:AddEntry(damageInstance)
    local existingEntry = self:GetExistingDamageInstance(damageInstance)
    if(existingEntry ~= nil) then
        existingEntry:AddDamage(damageInstance:GetDamageAmount())
    else
        self.damageInstances[self.nextFreeIndex] = damageInstance
        self.nextFreeIndex = self.nextFreeIndex + 1
    end
end


-- !!!! This singleton load/save code is NOT thread safe !!!!
---@return DamageDatabase
function DamageDatabase.LoadSingleton()
    local variableStorageVar = GetVariableStorage()
    if(not variableStorageVar:ExistsValue(DamageDatabaseSaveKey)) then
        local ret = DamageDatabase:New()
        DamageDatabase.SaveSingleton(ret)
        return ret
    else
        local damageDatabaseStr = variableStorageVar:GetValue(DamageDatabaseSaveKey)
        local damageDataBase = DamageDatabase.FromTable(DeserializeToTable(damageDatabaseStr))
        return damageDataBase
    end
end

function DamageDatabase.SaveSingleton(damageDatabase)
    local variableStorageVar = GetVariableStorage()
    variableStorageVar:SetValue(DamageDatabaseSaveKey, SerializeFromTable(damageDatabase:ToTable()))
end