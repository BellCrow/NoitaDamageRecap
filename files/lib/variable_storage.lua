dofile("mods/damage_recap/files/lib/util.lua")

local variable_storage_entity_name = "DAMAGE_RECAP_MOD_VARIABLE_STORAGE_ENTITY"

-- value storage code was offered by https://github.com/ExtolsSuperSauce/Forge_Perks
-- subsequently a bit reworked by me though
local function __internal_add_new_variable(entity_id, variable_name, initial_value)
    EntityAddComponent2(
        entity_id,
        "VariableStorageComponent",
        {
            name = variable_name,
            value_string = initial_value
        }
    )
end

local function __get_storage_component(entity_id)
    local variable_storage_component_name = "VariableStorageComponent"
    local components = EntityGetComponent(entity_id, variable_storage_component_name)
    if (components == nil) then
        print("__get_storage_component: No VariableStorageComponent entity found. Creating one...")
        components = {
            EntityAddComponent(entity_id, variable_storage_component_name)
        }
    end
    return components
end

local function __set_value(entity_id, variable_name, new_value)
    local components = __get_storage_component(entity_id)
    local variable_exists = false
    for _, comp_id in pairs(components) do
        local var_name = ComponentGetValue2(comp_id, "name")
        if (var_name == variable_name) then
            variable_exists = true
            ComponentSetValue2(comp_id, "value_string", new_value)
        end
    end

    if not variable_exists then
        print("__set_value: Save key " .. variable_name .. " not found. Adding it...")
        __internal_add_new_variable(entity_id, variable_name, new_value)
    end
end

local function __get_value(entity_id, variable_name)
    local value = nil
    local components = __get_storage_component(entity_id)
    local variable_found = false
    for _, comp_id in pairs(components) do
        local var_name = ComponentGetValue2(comp_id, "name")

        if (var_name == variable_name) then
            variable_found = true
            value = ComponentGetValue2(comp_id, "value_string")
        else
        end
    end
    if (not variable_found) then
        error("Tried to access non existant variable " .. tostring(variable_name), 2)
    end
    return value
end
--end variable storage code

local variable_storage = {}
variable_storage.__index = variable_storage

function variable_storage:new(entity_id)
    local instance = {}
    setmetatable(instance, variable_storage)
    instance.entity_id = entity_id
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

-- adds a new or updates an existing variable in the mapping or adds one if it does not exist yet
function variable_storage:set_value(str_key, str_value)
    __set_value(self.entity_id, str_key, str_value)
end

function variable_storage:get_value(str_key)
    return __get_value(self.entity_id, str_key)
end

function variable_storage:exists_value(str_key)
    local components = __get_storage_component(self.entity_id)
    local variable_found = false
    for _, comp_id in pairs(components) do
        local var_name = ComponentGetValue2(comp_id, "name")

        if (var_name == str_key) then
            variable_found = true
        end
    end
    return variable_found
end

local function get_storage_entity()
    local entity_id = EntityGetWithName(variable_storage_entity_name)
    if(entity_id == 0) then
        entity_id = EntityCreateNew(variable_storage_entity_name)
    end
    return entity_id
end

function get_variable_storage()
    local storage_entity_id = get_storage_entity()
    return variable_storage:new(storage_entity_id)
end
