dofile("mods/damage_recap/files/Lib/Util.lua")

DamageType = {}
DamageType.__index = DamageType
function DamageType:New(name)
    local instance = {}
    setmetatable(instance, DamageType)
    instance.name = name
    instance.damageSum = 0
    return instance
end

function DamageType:IsMaterialDamage()
    -- damage names we get from noita that are cause by materials are given like: 
    -- "damage from material: lava" thus need to be parsed in a way. this methods
    -- determines if this damage entry is such a damage instance
    return string.find(self.name,":") ~= nil
end

function DamageType:GetMaterialDamageShortName()
    -- converts a damage text like "damage from material: lava" into just the string "lava"
    if(not self:IsMaterialDamage()) then
        error("Tried to get damage material name of damage type that is not material damage. Damage name: " .. tostring(self.name))
    end

    local damageNameSeparatorIndex = string.find(self.name,":")
    local normalizedDamageString = string.sub(self.name, damageNameSeparatorIndex + 2)
    normalizedDamageString = normalizedDamageString:gsub(" ","")
    normalizedDamageString = string.lower(normalizedDamageString)
    return normalizedDamageString
end

function DamageType:AddDamage(damageAmount)
    self.damageSum = self.damageSum + damageAmount
end

function DamageType:GetName()
    return self.name
end

function DamageType:GetSum()
    return self.damageSum
end

-- region serialization interface
function DamageType:FromTable(table_data)
    local instance = {}
    setmetatable(instance, DamageType)
    instance.name = table_data.name
    instance.damageSum = table_data.damageSum
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

function DamageType:ToTable()
    local ret = {}
    ret.name = self:GetName()
    ret.damageSum = self:GetSum()
    return ret
end
-- endregion

function DamageType:ToString()
    local ret = ""
    ret = ret .. "Type: " .. self:GetName()
    ret = ret .. "\n"
    ret = ret .. "Sum: " .. self:GetSum()
end