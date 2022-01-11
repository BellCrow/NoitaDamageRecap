dofile("mods/damage_recap/files/Model/DamageDatabase.lua")
dofile("mods/damage_recap/files/Lib/Util.lua")
dofile("mods/damage_recap/files/Constants.lua")
dofile("mods/damage_recap/files/Views/CurrentStatsView.lua")

function DrawCurrentDamageStats()
    local damageDatabase = DamageDatabase.LoadSingleton()
    DrawCurrentDamageAsMenu(damageDatabase)
end
