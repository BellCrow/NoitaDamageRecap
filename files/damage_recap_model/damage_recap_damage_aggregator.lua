damage_recap_damage_aggregator = {}
damage_recap_damage_aggregator.__index = damage_recap_damage_aggregator

function damage_recap_damage_aggregator:new()
    local instance = {}
    setmetatable(instance, damage_recap_damage_aggregator)
    instance.damages = {}
    --set fields like this
    --instance.int_value = int_argument
    return instance
end

function damage_recap_damage_aggregator:add_damage(str_damage_type, num_damage)
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    if self.damages[str_damage_type] == nil then
        self.damages[str_damage_type] = num_damage
    else
        self.damages[str_damage_type] = self.damages[str_damage_type] + num_damage
    end
end

function damage_recap_damage_aggregator:to_string()
    --access fields/properties like:
    --self.fieldName
    --call methods like:
    --self:methodName
    local damage_stats = "-------Damage entries: ".. table.getn(self.damages) .."-------\n"
    
    for damage_type, damage in pairs(self.damages)do
        
        damage_stats = damage_stats .. damage_type .. " -> " .. tostring(damage) .. "\n"
    end
    damage_stats = damage_stats .. "---------------------------"
    return damage_stats
end