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
AddEventHandler("twitterLoginAuthenticated", function(data)
	if data.brugernavn then
		print(data.brugernavn)
		SendNUIMessage({
			action = "login",
			brugernavn = data.brugernavn
		})
		lastLoggedIn = data.brugernavn
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
