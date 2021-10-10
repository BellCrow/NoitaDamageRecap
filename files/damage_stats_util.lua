dofile_once("mods/damage_stats/files/damage_stats_constants.lua")

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
    
    local storage_component_entity = EntityGetComponent(player_entity, "VariableStorageComponent", damage_stats_storage_component_name)
    print("storage componant entity id:" .. tostring(storage_component_entity))
    if storage_component_entity == nil then
        print("Could not find storage component. Create new storage component")
        storage_component_entity = EntityAddComponent2(player_entity, "VariableStorageComponent", damage_stats_table_component_tag_name)   
        print("Created storage: " .. tostring(storage_component_entity))
        storage_component_entity = EntityGetComponent(player_entity, "VariableStorageComponent", damage_stats_storage_component_name)
        print("Test retrieve id: " .. tostring(storage_component_entity))
    end
    return storage_component_entity
end


-- value storage code was offered by https://github.com/ExtolsSuperSauce/Forge_Perks
-- subsequently a bit reworked by me though
function addNewInternalVariable(entity_id, variable_name, variable_type, initial_value)
    if(variable_type == "value_int") then
        EntityAddComponent2(entity_id, "VariableStorageComponent", {
            name=variable_name,
            value_int=initial_value
        })
    elseif(variable_type == "value_string") then
        EntityAddComponent2(entity_id, "VariableStorageComponent", {
            name=variable_name,
            value_string=initial_value
        })
    elseif(variable_type == "value_float") then
        EntityAddComponent2(entity_id, "VariableStorageComponent", {
            name=variable_name,
            value_float=initial_value
        })
    elseif(variable_type == "value_bool") then
        EntityAddComponent2(entity_id, "VariableStorageComponent", {
            name=variable_name,
            value_bool=initial_value
        })
    end
end

function getInternalVariableValue(entity_id, variable_name, variable_type)
    local value = nil
    local components = EntityGetComponent( entity_id, "VariableStorageComponent" )
    if ( components ~= nil ) then
        for key,comp_id in pairs(components) do 
            local var_name = ComponentGetValue2( comp_id, "name" )
            if(var_name == variable_name) then
                value = ComponentGetValue2(comp_id, variable_type)
            end
        end
    end
    return value
end

function setInternalVariableValue(entity_id, variable_name, variable_type, new_value)

    local components = EntityGetComponent( entity_id, "VariableStorageComponent" )    
    if ( components ~= nil ) then
        for key,comp_id in pairs(components) do 
            local var_name = ComponentGetValue2( comp_id, "name" )
            if( var_name == variable_name) then
                ComponentSetValue2( comp_id, variable_type, new_value )
            end
        end
    end
end