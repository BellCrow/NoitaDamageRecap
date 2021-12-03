dofile("mods/damage_recap/files/Lib/Util.lua")

local VARIABLE_STORAGE_ENTITY_NAME = "DAMAGE_RECAP_MOD_VARIABLE_STORAGE_ENTITY"

-- value storage code was offered by https://github.com/ExtolsSuperSauce/Forge_Perks
-- subsequently a bit reworked by me though
local function __internal_add_new_variable(entityId, variableName, initialValue)
    EntityAddComponent2(
        entityId,
        "VariableStorageComponent",
        {
            name = variableName,
            value_string = initialValue
        }
    )
end

local function __get_storage_component(entityId)
    local components = EntityGetComponent(entityId, "VariableStorageComponent")
    if (components == nil) then
        print("__get_storage_component: No VariableStorageComponent entity found. Creating one...")
        components = {
            EntityAddComponent(entityId, "VariableStorageComponent")
        }
    end
    return components
end

local function __set_value(entityId, variableName, newValue)
    local components = __get_storage_component(entityId)
    local variableExists = false
    for _, comp_id in pairs(components) do
        local varName = ComponentGetValue2(comp_id, "name")
        if (varName == variableName) then
            variableExists = true
            ComponentSetValue2(comp_id, "value_string", newValue)
        end
    end

    if not variableExists then
        __internal_add_new_variable(entityId, variableName, newValue)
    end
end

local function __get_value(entityId, variableName)
    local value = nil
    local components = __get_storage_component(entityId)
    local variableFound = false
    for _, compId in pairs(components) do
        local var_name = ComponentGetValue2(compId, "name")

        if (var_name == variableName) then
            variableFound = true
            value = ComponentGetValue2(compId, "value_string")
        else
        end
    end
    if (not variableFound) then
        error("Tried to access non existant variable " .. tostring(variableName), 2)
    end
    return value
end
--end variable storage code

local VariableStorage = {}
VariableStorage.__index = VariableStorage

function VariableStorage:New(entityId)
    local instance = {}
    setmetatable(instance, VariableStorage)
    instance.entityId = entityId
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

-- adds a new or updates an existing variable in the mapping or adds one if it does not exist yet
function VariableStorage:SetValue(key, value)
    __set_value(self.entityId, key, value)
end

function VariableStorage:GetValue(key)
    return __get_value(self.entityId, key)
end

function VariableStorage:ExistsValue(strKey)
    local components = __get_storage_component(self.entityId)
    local variableFound = false
    for _, compId in pairs(components) do
        local varName = ComponentGetValue2(compId, "name")

        if (varName == strKey) then
            variableFound = true
        end
    end
    return variableFound
end

local function getStorageEntity()
    local entityId = EntityGetWithName(VARIABLE_STORAGE_ENTITY_NAME)
    if(entityId == 0) then
        entityId = EntityCreateNew(VARIABLE_STORAGE_ENTITY_NAME)
    end
    return entityId
end

function GetVariableStorage()
    local storageEntityId = getStorageEntity()
    return VariableStorage:New(storageEntityId)
end
