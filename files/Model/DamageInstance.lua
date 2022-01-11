---@class DamageInstance
DamageInstance = {}
DamageInstance.__index = DamageInstance
function DamageInstance:New(causingEntityName,damageName,damageAmount)
    local instance = {}
    setmetatable(instance, DamageInstance)
    instance.causingEntityName = causingEntityName
    instance.damageName = damageName
    instance.damageAmount = damageAmount
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

function DamageInstance:GetCausingEntityName()
    return self.causingEntityName
end

function DamageInstance:GetDamageName()
    return self.damageName
end

function DamageInstance:GetDamageAmount()
    return self.damageAmount
end

---@param damageAmount number
function DamageInstance:AddDamage(damageAmount)
    self.damageAmount = self.damageAmount + damageAmount
end

---@param otherDamageInstance DamageInstance
function DamageInstance:IsEqual(otherDamageInstance)
    local isEqual = true;
    isEqual = isEqual and otherDamageInstance:GetCausingEntityName() == self:GetCausingEntityName()
    isEqual = isEqual and otherDamageInstance:GetDamageName() == self:GetDamageName()
    return isEqual
end

-- region serialization interface
---@return DamageDatabase
function DamageInstance.FromTable(table)
    local instance = {}
    setmetatable(instance, DamageInstance)
    instance.causingEntityName = table.causingEntityName
    instance.damageName = table.damageName
    instance.damageAmount = table.damageAmount
    return instance
end

---@return table
function DamageInstance:ToTable()
    local ret = {}
    ret.causingEntityName = self.causingEntityName
    ret.damageName = self.damageName
    ret.damageAmount = self.damageAmount
    return ret
end
-- endregion