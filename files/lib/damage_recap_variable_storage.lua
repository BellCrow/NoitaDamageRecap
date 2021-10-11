damage_recap_variable_storage = {}
damage_recap_variable_storage.__index = damage_recap_variable_storage

function damage_recap_variable_storage:new(entity_id)
    local instance = {}
    setmetatable(instance, damage_recap_variable_storage)
    instance.entity_id = entity_id
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

-- adds a new or updates an existing variable in the mapping or adds one if it does not exist yet
function damage_recap_variable_storage:set_value(str_key, str_value)
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    __set_value(self.entity_id,str_key,str_value)
end

function damage_recap_variable_storage:get_value(str_key)
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    return __get_value(self.entity_id, str_key)
end

-- value storage code was offered by https://github.com/ExtolsSuperSauce/Forge_Perks
-- subsequently a bit reworked by me though
function __internal_add_new_variable(entity_id, variable_name, initial_value)
        EntityAddComponent2(entity_id, "VariableStorageComponent", {
            name=variable_name,
            value_string=initial_value
        })
end

function __get_storage_component(entity_id)
    local variable_storage_component_name = "VariableStorageComponent"
    local components = EntityGetComponent( entity_id,  variable_storage_component_name)
    if ( components == nil ) then
        components = 
        {
            EntityAddComponent(entity_id, variable_storage_component_name)
        }
    end
    return components
end

function __set_value(entity_id, variable_name, new_value)
    local components = __get_storage_component(entity_id)
    local variable_exists = false
    for _,comp_id in pairs(components) do 
        local var_name = ComponentGetValue2( comp_id, "name" )
        if( var_name == variable_name) then
            variable_exists = true
            ComponentSetValue2( comp_id, "value_string", new_value )
        end
    end

    if not variable_exists then
        __internal_add_new_variable(entity_id, variable_name, new_value)
    end
end

function __get_value(entity_id, variable_name)
    local value = nil
    local components = __get_storage_component(entity_id)
    local variable_found = false
    for _,comp_id in pairs(components) do 
        local var_name = ComponentGetValue2( comp_id, "name" )
        if(var_name == variable_name) then
            variable_found = true
            value = ComponentGetValue2(comp_id, "value_string")
        end
    end
    if(not variable_found)then
        error("Tried to access non existant variable " .. tostring(variable_name))
    end
    return value
end

