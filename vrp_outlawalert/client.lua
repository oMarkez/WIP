vRPcc = {}
Tunnel.bindInterface("vRP_outlawalert",vRPol)
Proxy.addInterface("vRP_outlawalert",vRPol)
vRP = Proxy.getInterface("vRP")

--Config

--[[local PedModels = {
        "s_m_y_cop_01",
        's_m_y_hwaycop_01',
        's_f_y_cop_01',
        's_m_y_sheriff_01',
        's_f_y_sheriff_01',
        's_m_m_ciasec_01',
        'u_m_m_fibarchitect',
        's_m_y_swat_01',
    }
--]]

Citizen.CreateThread( function()
    while true do
        Wait(0)
        local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
        if IsPedTryingToEnterALockedVehicle(GetPlayerPed(-1)) or IsPedJacking(GetPlayerPed(-1)) then
                TriggerServerEvent('sendServiceAlrt', plyPos.x, plyPos.y, plyPos.z,"theft")
                Wait(5000)
            end
        end
    end
end)

Citizen.CreateThread( function()
    while true do
        Wait(0)
        local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
        if IsPedInMeleeCombat(GetPlayerPed(-1)) then 
            TriggerServerEvent('sendServiceAlrt', plyPos.x, plyPos.y, plyPos.z,"melee")
            Wait(3000)
        end
    end
end)

Citizen.CreateThread( function()
    while true do
        Wait(0)
        local plyPos = GetEntityCoords(GetPlayerPed(-1),  true)
        if IsPedShooting(GetPlayerPed(-1)) then
            TriggerServerEvent('sendServiceAlrt', plyPos.x, plyPos.y, plyPos.z,"gunshot")
            Wait(3000)
        end
    end
end)
