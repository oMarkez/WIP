vRPcc = {}
Tunnel.bindInterface("vRP_outlawalert",vRPol)
Proxy.addInterface("vRP_outlawalert",vRPol)
vRP = Proxy.getInterface("vRP")

local blipList = {}

RegisterNetEvent('advisor')
AddEventHandler('advisor', function(x,y,z,message)
    local ped = GetPlayerPed(PlayerPedId())
    local blip = AddBlipForCoord(x+0.001,y+0.001,z+0.001)
    SetBlipSprite(blip, 304)
    SetBlipColour(blip, 67)
    SetBlipAlpha(blip, 250)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Alarmcentral")
    EndTextCommandSetBlipName(blip)

    table.insert(blipList, blip)
    
    --Citizen.Trace("x:" .. x .. " y:" .. y .. " z:" .. z)
    PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
    TriggerEvent('chatMessage', '^3[Alarmcentralen]', "^3[Alarmcentralen]", message)
end)

Citizen.CreateThread(function()
    while true do
        local ped = GetPlayerPed(PlayerPedId())
        for k,v in pairs(blipList) do
            RemoveBlip(v)
        end
        blipList = {}
        Citizen.Wait(120000)
    end
end)


Citizen.CreateThread( function()
    while true do
        Wait(0)
        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        if IsPedTryingToEnterALockedVehicle(GetPlayerPed(-1)) or IsPedJacking(GetPlayerPed(-1)) then
                TriggerServerEvent('dispatch', pos.x, pos.y,pos.z,theft)
                Wait(5000)
            end
        end
    end
end)

Citizen.CreateThread( function()
    while true do
        Wait(0)
        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        if IsPedInMeleeCombat(GetPlayerPed(-1)) then 
            TriggerServerEvent('dispatch', pos.x, pos.y,pos.z,melee)
            Wait(3000)
        end
    end
end)

Citizen.CreateThread( function()
    while true do
        Wait(0)
        local pos = GetEntityCoords(GetPlayerPed(-1), true)
        if IsPedShooting(GetPlayerPed(-1)) then
            TriggerServerEvent('dispatch', pos.x, pos.y,pos.z,gunshot)
            Wait(3000)
        end
    end
end)