DamageInstance = {}
DamageInstance.__index = DamageInstance
function DamageInstance:new(causingEntityName,damageName,damageAmount)
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

function DamageInstance:AddDamage(damageAmount)
    self.damageAmount = self.damageAmount + damageAmount
end

function DamageInstance:IsTypeEqualToOtherDamageInstance(otherDamageInstance)
    local isEqual = true;
    isEqual = isEqual and otherDamageInstance.GetCausingEntityName() == self:GetCausingEntityName()
    isEqual = isEqual and otherDamageInstance.GetDamageName() == self:GetDamageName()
    return isEqual
end