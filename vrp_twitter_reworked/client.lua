local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")

local menuEnabled = false
lastLoggedIn = ""

RegisterNetEvent("ToggleActionmenu")
AddEventHandler("ToggleActionmenu", function()
	ToggleActionMenu()
end)

function ToggleActionMenu()
	menuEnabled = not menuEnabled
	if ( menuEnabled ) then
		SetNuiFocus( true, true )
		SendNUIMessage({
			action = "openTwitter"
		})
	else
		SetNuiFocus( false )
		SendNUIMessage({
			action = "closeTwitter"
		})
	end

	if lastLoggedIn then
		TriggerEvent("twitterLoginAuthenticated", lastLoggedIn)
	end
	TriggerServerEvent("updateTweets")
end

RegisterNUICallback("close", function(data, cb)
  ToggleActionMenu()
  cb("ok")
end)

RegisterNUICallback("sendTweet", function(data,cb)
	if data then
		TriggerServerEvent("sendTweet", data)
		cb("ok")
	end
end)

RegisterNUICallback("validateLogin", function(data, cb)
	if data then
		TriggerServerEvent("twitterLogin", data)
		cb("ok")
	end
end)

RegisterNetEvent("twitterLoginAuthenticated")
AddEventHandler("twitterLoginAuthenticated", function(username)
	if username then
		SendNUIMessage({
			action = "login",
			username = 	username
		})
		lastLoggedIn = username
	else
		TriggerEvent("twitterError", "notfound")
	end
end)

RegisterNUICallback("opret", function(data, cb)
	if data then
		TriggerServerEvent("opretBruger", data)
		cb("ok")
	end
end)

AddEventHandler("onResourceStart", function(resource)
	if resource == GetCurrentResourceName() then
		SendNUIMessage({
			action = "init",
			resourcename = GetCurrentResourceName()
		})
	end
end)

RegisterNetEvent("updateTweets")
AddEventHandler("updateTweets", function(tweets)
	SendNUIMessage({
		action = "updateTweets",
		tweets = tweets
	})
end)

errormessages = {
	samename = "Du har allerede en bruger med dette navn.",
	notfound = "Brugernavn og/eller kode er forkert."
}

RegisterNetEvent("twitterError")
AddEventHandler("twitterError", function(type)
	if errormessages[type] then
		vRPclient.notify(source, {errormessages[type]})
	end
end)
