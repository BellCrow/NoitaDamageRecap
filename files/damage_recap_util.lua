dofile_once("mods/damage_recap/files/damage_recap_constants.lua")

--serialization method taken from: https://stackoverflow.com/a/6081639/6857673
function serialize_table(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

function get_player_entity()
    return EntityGetClosestWithTag( 0, 0, "player_unit")
end

function get_storage_component()
    local player_entity = get_player_entity()
    
    local storage_component_entity = EntityGetComponent(player_entity, "VariableStorageComponent", damage_recap_storage_component_name)
    print("storage componant entity id:" .. tostring(storage_component_entity))
    if storage_component_entity == nil then
        print("Could not find storage component. Create new storage component")
        storage_component_entity = EntityAddComponent2(player_entity, "VariableStorageComponent", damage_recap_table_component_tag_name)   
        print("Created storage: " .. tostring(storage_component_entity))
        storage_component_entity = EntityGetComponent(player_entity, "VariableStorageComponent", damage_recap_storage_component_name)
        print("Test retrieve id: " .. tostring(storage_component_entity))
    end
    return storage_component_entity
end

-- stores strings in a string->string mapping
function set_value(key, value)
    player_entity = get_player_entity()
    __set_value(player_entity,key,value)
end

function get_value(key)
    player_entity = get_player_entity()
    return __get_value(player_entity,key)
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
        print("No components found for given type " .. variable_storage_component_name.. ". Creating one.")
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
        print("Variable with name " .. variable_name .. " not found. Created it instead")
    end
end

function __get_value(entity_id, variable_name, variable_type)
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

