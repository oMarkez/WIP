--[[BASE]]--
MySQL = module("vrp_mysql", "MySQL")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vrp_dmvschool")

MySQL.createCommand("vRP/twitter_column", [[
CREATE TABLE IF NOT EXISTS vrp_twitter_messages(
  id INTEGER AUTO_INCREMENT,
  user_id INTEGER,
  bruger VARCHAR(50),
  message VARCHAR(2000),
  dato TIMESTAMP,
  CONSTRAINT pk_twitter_messages PRIMARY KEY(id)
);
CREATE TABLE IF NOT EXISTS vrp_twitter_accounts(
  id INTEGER AUTO_INCREMENT,
  user_id INTEGER,
  brugernavn VARCHAR(50),
  kode VARCHAR(100),
  dato TIMESTAMP,
  CONSTRAINT pk_twitter_accounts PRIMARY KEY(id)
);
]])

MySQL.createCommand("vRP/insert_tweet", "INSERT IGNORE INTO vrp_twitter_messages(bruger,user_id,message) VALUES(@bruger,@user_id,@message)")
MySQL.createCommand("vRP/opret_bruger", "INSERT IGNORE INTO vrp_twitter_accounts(user_id, brugernavn, kode) VALUES(@user_id, @brugernavn, @kode)")
MySQL.createCommand("vRP/get_tweets", "SELECT * FROM vrp_twitter_messages")
MySQL.createCommand("vRP/delete_old_tweets", "DELETE FROM vrp_twitter_messages WHERE (DATEDIFF(CURRENT_DATE,dato) > 3)")
MySQL.createCommand("vRP/get_alle_brugere", "SELECT * FROM vrp_twitter_accounts WHERE id = @user_id")
MySQL.createCommand("vRP/get_bruger", "SELECT * FROM vrp_twitter_accounts WHERE brugernavn = @brugernavn AND kode = @kode")

MySQL.execute("vRP/twitter_column")
MySQL.execute("vRP/delete_old_tweets")

-- transform a string of bytes in a string of hexadecimal digits
local function str2hexa(s)
  local h = string.gsub(s, ".", function(c)
    return string.format("%02x", string.byte(c))
  end)
  return h
end

RegisterServerEvent("sendTweet")
AddEventHandler("sendTweet", function(data)
  print("send tweet")
  if data then 
    for k,v in pairs(data) do print(k,v) end
    local user_id = vRP.getUserId({source})
    if user_id then
      if data.brugernavn ~= nil and data.tweet then
        MySQL.execute("vRP/insert_tweet", {bruger = data.brugernavn, user_id = user_id, message = data.tweet})
        TriggerEvent("updateTweets")
      end
    end
  end
end)

RegisterServerEvent("openedTwitter")
AddEventHandler("openedTwitter", function()
  MySQL.query("vRP/get_tweets", {}, function(rows, affected)
    if #rows > 0 then
      TriggerClientEvent("openTwitter", source, rows)
    end
  end)
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
  local user_id = vRP.getUserId({source})
  local player = vRP.getUserSource({user_id})
  print(data.brugernavn.." - "..data.kode)
  data.kode = str2hexa(data.kode)
  print(data.kode)
  if user_id then
    MySQL.query("vRP/get_bruger", {brugernavn = data.brugernavn, kode = tonumber(data.kode)}, function(rows, affected)
      for k,v in pairs(rows[1]) do print(k,v) end
      if #rows > 0 then
        print("rows > 0")
        TriggerClientEvent("twitterLoginAuthenticated", player, rows[1].brugernavn)
      else
        print("rows < 0")
        TriggerClientEvent("twitterLoginAuthenticated", player, nil)
      end
    end)
  end
end)

RegisterServerEvent("opretBruger")
AddEventHandler("opretBruger", function(data)
  print("opret bruger")
  print(data.kode.." - "..data.brugernavn.." - "..data.telefon)
  data.kode = str2hexa(tostring(data.kode))
  print("-----------")
  print(data.kode)
  local user_id = vRP.getUserId({source})
  if user_id then
    print("user-id")
    vRP.getUserIdentity({user_id, function(identity)
      identity.phone = identity.phone:gsub(" ", "")
      print(identity.phone.." - "..data.telefon)
      if identity.phone == data.telefon then
        print("telefon")
        MySQL.query("vRP/get_alle_brugere", {user_id = user_id}, function(rows, affected)
          if #rows < 5 then
            for k,v in pairs(rows) do
              if v.brugernavn == data.brugernavn then
                print("brugernavn == username")
                TriggerEvent("twitterError", source, "samename")
                return
              end
            end

            print("mysql "..data.brugernavn.." "..data.kode)
            MySQL.execute("vRP/opret_bruger", {user_id = user_id, brugernavn = data.brugernavn, kode = data.kode})
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
      TriggerEvent("openedTwitter", player)
    end,"Skriv i twitter"}

		add(choices)
	end
end})

errormessages = {
	samename = "Du har allerede en bruger med dette navn.",
	notfound = "Brugernavn og/eller kode er forkert."
}

RegisterServerEvent("twitterError")
AddEventHandler("twitterError", function(type)
	if errormessages[type] then
		vRPclient.notify(source, {errormessages[type]})
	end
end)