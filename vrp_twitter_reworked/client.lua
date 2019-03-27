local menuEnabled = false
lastLoggedIn = ""

RegisterNetEvent("ToggleActionmenu")
AddEventHandler("ToggleActionmenu", function()
	ToggleActionMenu()
end)

RegisterNetEvent("openTwitter")
AddEventHandler("openTwitter", function(data)
	menuEnabled = not menuEnabled
	if ( menuEnabled ) then
		SetNuiFocus( true, true )
		SendNUIMessage({
			action = "openTwitter",
			tweets = {account = data.bruger, tweet = data.message, date = data.dato}
		})
	else
		SetNuiFocus( false )
		SendNUIMessage({
			action = "closeTwitter"
		})
	end
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
	print(data)
	if data then
		print(data)
		SendNUIMessage({
			action = "login",
			brugernavn = data
		})
		lastLoggedIn = data
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

RegisterNetEvent("updateTweets")
AddEventHandler("updateTweets", function(tweets)
	SendNUIMessage({
		action = "updateTweets",
		tweets = tweets
	})
end)
