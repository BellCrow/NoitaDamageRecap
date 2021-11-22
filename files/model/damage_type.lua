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

function damage_type:is_material_damage()
    -- damage types we get from noita that are cause by materials are given like: 
    -- "damage from material: lava" thus need to be parsed in a way. this methods
    -- determines if this damage entry is such a damage type instance
    return string.find(self.damage_type,":") ~= nil
end

function damage_type:get_material_damage_short_name()
    -- converts a damage text like "damage from material: lava" into just the string "lava"
    if(not self:is_material_damage()) then
        error("Tried to get damage material name of damage type that is not material damage. Damage type: " .. tostring(self.damage_type))
    end

    local damage_name_separator_index = string.find(self.damage_type,":")
    local normalized_damage_string = string.sub(self.damage_type, damage_name_separator_index + 2)
    normalized_damage_string = normalized_damage_string:gsub(" ","_")
    string.lower(normalized_damage_string)
    return normalized_damage_string
end

function damage_type:add_damage_instance(num_damage)
    
    self.damage_instances[tostring(#self.damage_instances)] = num_damage
    self.damage_sum = self.damage_sum + num_damage
end

function damage_type:get_type()
    
    return self.damage_type
end

function damage_type:get_sum()
    
    return self.damage_sum
end

function damage_type:get_instances()
    
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
    
    local ret = ""
    ret = ret .. "Type: " .. self:get_type()
    ret = ret .. "\n"
    ret = ret .. "Sum: " .. self:get_sum()
    ret = ret .. "\n"
    ret = ret .. "Instance count: " .. table_len(self.get_instances())
end