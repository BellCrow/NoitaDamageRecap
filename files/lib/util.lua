dofile_once("mods/damage_recap/files/constants.lua")
dofile_once("mods/damage_recap/files/lib/json_serializer.lua")

--serialization method taken from: https://stackoverflow.com/a/6081639/6857673
function serialize_table(val)
    -- skipnewlines = skipnewlines or false
    -- depth = depth or 0

    -- local tmp = string.rep(" ", depth)

    -- if name then tmp = tmp .. name .. " = " end

    -- if type(val) == "table" then
    --     tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

    --     for k, v in pairs(val) do
    --         tmp =  tmp .. serialize_table(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
    --     end

    --     tmp = tmp .. string.rep(" ", depth) .. "}"
    -- elseif type(val) == "number" then
    --     tmp = tmp .. tostring(val)
    -- elseif type(val) == "string" then
    --     tmp = tmp .. string.format("%q", val)
    -- elseif type(val) == "boolean" then
    --     tmp = tmp .. (val and "true" or "false")
    -- else
    --     tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    -- end

    -- return tmp
    return json_encode(val)

end

function deserialize_table(str_serialized_table)
    return json_decode(str_serialized_table)
end

function get_player_entity()
    return EntityGetClosestWithTag( 0, 0, "player_unit")
end
