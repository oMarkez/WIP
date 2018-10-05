--Settings--
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_cuffcutter")
vRPol = Tunnel.getInterface("vRP_outlawalert","vRP_outlawalert")

local randomname = {"Lisa","Frank","Peter","Bob","Christian","James","Michael","Maria","David","Mary","Robert","Joseph","John","Clark","Taylor","George","Henry"}
local service_name = "police.service"
local rgmsg = {"Help!! Someone is shooting!","I just heard gunfire!","Oh my god, someone is shooting! Please come fast","I JUST HEARD SHOTS, PLEASE COME FAST"}
local rmmsg = {"There are people fighting here, help, quick!","Help! two people are going to beat eachother to death!","Two people fighting, come, quick!"}
local rtmsg = {"Someone just stole a car!","I just witnessed theft of a vehicle, come, quick!","A guy just stole a car"}


RegisterServerEvent('sendServiceAlrt')
AddEventHandler('sendServiceAlrt', function(x,y,z,type))
	if type ~= nil then
		if type == gunshot then
			vRP.sendServiceAlert(randomname[math.random(#randomname)]), service_name,x,y,z,rgmsg[math.random(#rgmsg)])
		elseif type == melee then
			vRP.sendServiceAlert(randomname[math.random(#randomname)]), service_name,x,y,z,rmmsg[math.random(#rgmsg)])
		elseif type == theft then
			vRP.sendServiceAlert(randomname[math.random(#randomname)]), service_name,x,y,z,rtmsg[math.ranbdom(#rtmsg)])
		end
	else
		print("-- [DEBUG] -- TYPE = NIL")
	end
end)
