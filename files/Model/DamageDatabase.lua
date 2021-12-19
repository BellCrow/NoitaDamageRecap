DamageDatabase = {}
DamageDatabase.__index = DamageDatabase
function DamageDatabase:new()
    local instance = {}
    setmetatable(instance, DamageDatabase)
    instance.damageEntries = {}
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

function DamageDatabase:getExistingDamageInstance(damageInstance)
    for index, damageInstanceIterator in ipairs(self.damageEntries) do
        if(damageInstance:IsTypeEqualToOtherDamageInstance(damageInstanceIterator)) then
            return damageInstanceIterator
        end
    end
    return nil
end

function DamageDatabase:AddEntry(damageInstance)
end