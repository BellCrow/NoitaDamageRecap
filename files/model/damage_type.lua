dofile_once("mods/damage_recap/files/lib/util.lua")

damage_type = {}
damage_type.__index = damage_type
function damage_type:new(str_damage_name)
    local instance = {}
    setmetatable(instance, damage_type)
    --set fields like this
    --instance.int_value = int_argument
    instance.damage_type = str_damage_name
    instance.damage_sum = 0
    instance.damage_instances = {}
    return instance
end

function damage_type:add_damage_instance(num_damage)
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    self.damage_instances[tostring(#self.damage_instances)] = num_damage
    self.damage_sum = self.damage_sum + num_damage
end

function damage_type:get_type()
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    return self.damage_type
end

function damage_type:get_sum()
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    return self.damage_sum
end

function damage_type:get_instances()
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    return self.damage_instances
end

-- region serialization interface
function damage_type:from_table(table_data)
    local instance = {}
    setmetatable(instance, damage_type)
    instance.damage_type = table_data.damage_type
    instance.damage_sum = table_data.damage_sum
    instance.damage_instances = table_data.damage_instances
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

function damage_type:to_table()
    local ret = {}
    ret.damage_type = self:get_type()
    ret.damage_sum = self:get_sum()
    ret.damage_instances = self:get_instances()
    return ret
end
-- endregion


function damage_type:to_string()
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    local ret = ""
    ret = ret .. "Type: " .. self:get_type()
    ret = ret .. "\n"
    ret = ret .. "Sum: " .. self:get_sum()
    ret = ret .. "\n"
    ret = ret .. "Instance count: " .. table_len(self.get_instances())
end