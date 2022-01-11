dofile("mods/damage_recap/files/Lib/JsonSerializer.lua")

function SerializeFromTable(table)
    return json_encode(table)
end

function DeserializeToTable(serializedTable)
    return json_decode(serializedTable)
end

function GetTableLen(table)
    local tableCount = 0
    for _,_ in pairs(table) do
        tableCount = tableCount + 1
    end
    return tableCount
end