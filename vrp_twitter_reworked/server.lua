local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP")
MySQL = module("MySQL", "vrp_mysql")

MySQL.createCommand("vRP/twitter_column", [[
  CREATE TABLE IF NOT EXISTS vrp_twitter_messages(
    id INTEGER AUTO_INCREMENT,
    user_id INTEGER,
    bruger VARCHAR(50),
    message VARCHAR(2000),
    dato TIMESTAMP
  );
  CREATE TABLE IF NOT EXISTS vrp_twitter_accounts(
    id INTEGER AUTO_INCREMENT,
    user_id INTEGER,
    brugernavn VARCHAR(50),
    kode VARCHAR(100)
    dato TIMESTAMP
  )
]])
MySQL.createCommand("vRP/insert_tweet", "INSERT IGNORE INTO vrp_twitter_messages(bruger,user_id,message) VALUES(@bruger,@user_id,@message)")
MySQL.createCommand("vRP/opret_bruger", "INSERT INTO vrp_twitters_accounts(user_id, brugernavn, kode) VALUES(@user_id, @brugernavn, @kode)")
MySQL.createCommand("vRP/get_tweets", "SELECT * FROM vrp_twitter_messages")
MySQL.createCommand("vRP/delete_old_tweets", "DELETE FROM phone_messages WHERE (DATEDIFF(CURRENT_DATE,dato) > 3)")
MySQL.createCommand("vRP/get_alle_brugere", "SELECT * FROM vrp_twitter_accounts WHERE id = @user_id")
MySQL.createCommand("vRP/get_bruger", "SELECT * FROM vrp_twitter_accounts WHERE brugernavn = @brugernavn, kode = @kode")

MySQL.execute("vRP/twitter_column")
MySQL.execute("vRP/delete_old_tweets")

RegisterServerEvent("sendTweet")
AddEventHandler("sendTweet", function(data)
  if data then 
    local user_id = vRP.getUserId({source})
    if user_id then
      local bruger, dato, tweet = table.unpack(data)
      if bruger ~= nil and dato ~= nil and tweet ~= nil then
        MySQL.execute("vRP/insert_tweet", {bruger = bruger, user_id = user_id, message = tweet})
        TriggerEvent("updateTweets")
      end
    end
  end
end)

RegisterServerEvent("updateTweets")
AddEventHandler("updateTweets", function()
  MySQL.query("vRP/get_tweets", {}, function(rows, affected)
    if #rows > 0 then
      TriggerClientEvent("updateTweets", source, rows)
    end
  end)
end)

RegisterNetEvent("twitterLogin")
AddEventHandler("twitterLogin", function(data)
  local username, kode = table.unpack(data)
  local user_id = vRP.getUserId({source})
  if user_id then
    MySQL.query("vRP/get_bruger", {brugernavn = username, kode = kode}, function(rows, affected)
      if #rows > 0 then
        TriggerClientEvent("twitterLoginAuthenticated", source, rows[1].brugernavn)
      else
        TriggerClientEvent("twitterLoginAuthenticated", source, nil)
      end
    end)
  end
end)

RegisterServerEvent("opretBruger")
AddEventHandler("opretBruger", function(data)
  local username, kode, telefon = table.unpack(data)
  local user_id = vRP.getUserId({source})
  if user_id then
    vRP.getUserIdentity({user_id, function(identity)
      if identity.phone == telefon then
        MySQL.query("vRP/get_alle_brugere", {user_id = user_id}, function(rows, affected)
          if #rows < 5 then
            for k,v in pairs(rows) do
              if v.brugernavn == username then
                TriggerEvent("twitterError", source, "samename")
                return
              end
            end
            MySQL.execute("vRP/opret_bruger", {user_id = user_id, brugernavn = username, kode = kode})
          end
        end)
      end
    end})
  end
end)

vRP.registerMenuBuilder({"main", function(add, data)
	local user_id = vRP.getUserId({data.player})
	if user_id ~= nil then
		local choices = {}
	
		choices["Twitter"] = {function(player,choice)
      TriggerClientEvent("ToggleActionmenu", source)
		}

		add(choices)
	end
end})