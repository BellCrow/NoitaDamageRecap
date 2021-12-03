dofile_once("mods/damage_recap/files/lib/util.lua")
dofile_once("mods/damage_recap/files/model/damage_type.lua")
dofile_once("mods/damage_recap/files/constants.lua")

damage_aggregator = {}
damage_aggregator.__index = damage_aggregator

function damage_aggregator:new()
    local instance = {}
    setmetatable(instance, damage_aggregator)
    instance.damages = {}
    --set fields like this
    --instance.int_value = int_argument
    return instance
end
-- region serialization interface
function damage_aggregator:from_table(table_data)
    local instance = {}
    setmetatable(instance, damage_aggregator)
    instance.damages = {}
    for i,damage_type_table in pairs(table_data.damages)do
        instance.damages[i] = damage_type:from_table(damage_type_table)
    end
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

function damage_aggregator:to_table()
    local ret = {}
    ret.damages = {}
    for i,instance in pairs(self.damages) do
        ret.damages[i] = instance:to_table()
    end
    return ret
end
-- endregion

function damage_aggregator:add_damage(str_damage_type, num_damage)
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    local damage_type_to_increase = self:get_damage_by_name(str_damage_type)

    if damage_type_to_increase == nil then
        print("New damage type registered: " .. str_damage_type)
        damage_type_to_increase = damage_type:new(str_damage_type)
        self.damages[str_damage_type] = damage_type_to_increase
    end
    damage_type_to_increase:add_damage_instance(num_damage)
end

function damage_aggregator:to_string()
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    local damage_stats = "\n-------Damage recap-------\n"
    
    for damage_name, damage_type in pairs(self.damages)do
        
        damage_stats = damage_stats .. damage_type:get_type() .. " -> " .. tostring(damage_type:get_sum()) .. "\n"
    end
    damage_stats = damage_stats .. "---------------------------"
    return damage_stats
end

function damage_aggregator:get_damage_by_name(str_damage_type)
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    for damage_name, damage_type in pairs(self.damages) do
        if(damage_type:get_type() == str_damage_type) then
            return damage_type
        end
    end
    return nil
end

function damage_aggregator:get_damage_table()
    local ret = {}
    for damage_name, damage_type in pairs(self.damages)do 
        ret[damage_name] = damage_type
    end
    return ret
end


function load_singleton()
    local variable_storage_var = get_variable_storage()
    ret = {}
    if(variable_storage_var:exists_value(damage_aggregator_save_key)) then
        ret = damage_aggregator:new()
        return ret
    else
        local damage_aggregator_str = variable_storage_var:get_value(damage_aggregator_save_key)
        local damage_aggregator_var = damage_aggregator:from_table(deserialize_to_table(damage_aggregator_str))
        return damage_aggregator_var
    end    
end

function save_singleton(damage_aggregator)
    
end