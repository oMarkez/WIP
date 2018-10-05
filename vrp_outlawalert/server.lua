--Settings--
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_cuffcutter")
vRPol = Tunnel.getInterface("vRP_outlawalert","vRP_outlawalert")

local randomname = {"Lisa","Frank","Peter","Bob","Christian","James","Michael","Maria","David","Mary","Robert","Joseph","John","Clark","Taylor","George","Henry"}
local rgmsg = {"Help!! Someone is shooting!","I just heard gunfire!","Oh my god, someone is shooting! Please come fast","I JUST HEARD SHOTS, PLEASE COME FAST"}
local rmmsg = {"There are people fighting here, help, quick!","Help! two people are going to beat eachother to death!","Two people fighting, come, quick!"}
local rtmsg = {"Someone just stole a car!","I just witnessed theft of a vehicle, come, quick!","A guy just stole a car"}

RegisterServerEvent('dispatch')
AddEventHandler('dispatch', function(x,y,z,message,type)
  local players = {}
  local users = vRP.getUsers({})
  local isPolice = false
  local isEms = false

    for k,v in pairs(users) do
      
        local player = vRP.getUserSource({k})
        
        if player ~= nil then
          local user_id = vRP.getUserId({player})

          isPolice = vRP.hasGroup({user_id,"police"})
		  isEms = vRP.hasGroup({user_id,"ems"})
          if isPolice or isEms then
            table.insert(players,player)
          end
        end
  end

  for k,v in pairs(players) do
	if type ~= nil then
	 if type == melee then			
			message = (randomname[math.random(#randomname)]), rtmsg[math.ranbdom(#rgmsg)])
			TriggerClientEvent('advisor', v, x,y,z,message)
		elseif type == theft then
			message = (randomname[math.random(#randomname)]), rtmsg[math.ranbdom(#rtmsg)])
			TriggerClientEvent('advisor', v, x,y,z,message)
		end
	 else
		print("-- [DEBUG] -- TYPE = NIL")
	 end
    end
end)