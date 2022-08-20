local pressedkeys = {}
local chatopen = false
local spawnmenuopen = false
local contextmenuopen = false

local function lockControls(bLock)
    net.Start("simfphys_blockcontrols")
    net.WriteBool(bLock)
    net.SendToServer()
end

hook.Add("OnContextMenuOpen", "simfphys_seatswitching_cmenuopen", function()
    contextmenuopen = true
    lockControls(true)
end)

hook.Add("OnContextMenuClose", "simfphys_seatswitching_cmenuclose", function()
    contextmenuopen = false
    lockControls(false)
end)

hook.Add("OnSpawnMenuOpen", "simfphys_seatswitching_menuopen", function()
    spawnmenuopen = true
    lockControls(true)
end)

hook.Add("OnSpawnMenuClose", "simfphys_seatswitching_menuclose", function()
    spawnmenuopen = false
    lockControls(false)
end)

hook.Add("FinishChat", "simfphys_seatswitching_chatend", function()
    chatopen = false
    lockControls(false)
end)

hook.Add("StartChat", "simfphys_seatswitching_chatstart", function()
    chatopen = true
    lockControls(true)
end)