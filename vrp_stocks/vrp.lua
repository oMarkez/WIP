MySQL = module("vrp_mysql", "MySQL")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

MySQL.createCommand("vRP/vrp_stocks_column", [[
CREATE TABLE IF NOT EXISTS vrp_stocks(
  user_id INTEGER,
  stockname VARCHAR(100),
  antal INTEGER,
  kobttil INTEGER,
  CONSTRAINT PK_stock PRIMARY KEY(user_id)
);
]])

MySQL.createCommand("vRP/set_user_stocks", "INSERT IGNORE INTO vrp_stocks(user_id,stockname,antal,kobttil) VALUES(@user_id,@stockname,@antal,@kobttil")
MySQL.createCommand("vRP/get_user_stocks", "SELECT * FROM vrp_stocks WHERE user_id = @user_id, stockname = @stock")
MySQL.createCommand("vRP/get_all_user_stocks", "SELECT * FROM vrp_stocks WHERE user_id = @user_id")
MySQL.createCommand("vRP/remove_user_stocks", "DELETE FROM vrp_stocks WHERE user_id = @user_id, stockname = @stock")
MySQL.createCommand("vRP/edit_user_stocks", "UPDATE vrp_stocks SET antal = @antal WHERE user_id = @user_id, stockname = @stock")

MySQL.createCommand("vRP/get_vstock", "SELECT stockname,pris,timestamp FROM stocks WHERE stockname = @stock")

MySQL.query("vRP/vrp_stocks_column")

mstocks = {}
count = 0

Citizen.CreateThread(function()
	while true do
		Wait(0)
		for i,v in pairs(stocks) do
			if count < i then
				local titel = v.titel
				MySQL.query("vRP/get_vstock", {stock = titel}, function(rows, affected)
					for k,v in pairs(rows) do
						mstocks[v.stockname] = {pris = v.pris,timestamp = v.timestamp}
						count = count + 1
					end
				end)
			else
				local time = 60000 * resetTime - 10000
				Citizen.Wait(time)
				count = 0
				for k,v in pairs(mstocks) do
					mstocks[k] = nil
				end

			end
		end
	end
end)

local ch_nothing = {function(player,choice)
	return
end}

local ch_buyaktie = {function(player,choice)
	local user_id = vRP.getUserId({player})
	vRP.prompt({player,"Aktie du ønsker at købe:","",function(player,aktie)
		if aktie ~= nil and aktie ~= "" then
			for k,v in pairs(mstocks) do
				if k == aktie then
					local pris = v.pris
					vRP.prompt({player,"Antal du ønsker at købe til"..pris.." DKK stykket","",function(player,antal)
						if antal ~= 0 and antal ~= "" then
							local pris = math.ceil(antal * schoice[1])
							if vRP.tryPayment({user_id,pris}) then
								MySQL.execute("vRP/set_user_stocks", {user_id = user_id, stockname = aktie, antal = antal, kobttil = pris})
								vRPclient.notify(player,{"Du har købt"..antal.." "..aktie.." Aktier til "..pris})
							else
								vRPclient.notify(player,{"Du har ikke nok penge!"})
							end
						else
							vRPclient.notify(player,{"Ugyldigt antal"})
						end
					end})
				end
			end
		else
			vRPclient.notify(player,{"Ugyldig aktie"})
		end
	end})
end, "Køb aktie"}

local ch_sell = {function(player,choice)
	local user_id = vRP.getUserId({player})
	vRP.prompt({player,"Aktie du vil sælge:","",function(player,aktie)
		if aktie ~= nil and aktie ~= "" then
			for k,v in pairs(mstocks) do
				if k == aktie then
					MySQL.query("vRP/get_user_stocks", {user_id = user_id, stock = aktie}, function(rows, affected)
						if #rows > 0 then
							for ind,val in pairs(rows) do
								vRP.prompt({player,"Antal du ønsker at sælge til "..v.pris.." DKK","",function(player,antal)
									if antal ~= 0 and antal ~= "" then
										if val.antal > antal then
											local payout = math.ceil(antal * v.pris)
											local change = math.floor(val.antal - antal)
											MySQL.execute("vRP/edit_user_stocks", {user_id = user_id, stock = aktie, antal = change})
										elseif val.antal == antal then
											local payout = math.ceil(antal * v.pris)
											local change = math.floor(val.antal - antal)
											MySQL.execute("vRP/remove_user_stocks", {user_id = user_id, stock = aktie})
										elseif val.antal < antal then
											vRPclient.notify(player, {"Du har ikke så mange af denne aktie!"})
										end
									else
										vRPclient.notify(player,{"Ugyldigt antal"})
									end
								end})
							end
						end
					end)
				end
			end
		else
			vRPclient.notify(player,{"Ugyldig aktie"})
		end
	end})
end, "Sælg aktie"}

local ch_portfolie = {function(player,choice)
	local user_id = vRP.getUserId({player})
	local menu = {}
    menu2.name = "Aktier"
    menu2.css = {top = "75px", header_color = "rgba(255,216,0,0.75)"}
	menu2.onclose = function(player) vRP.openMainMenu({player}) end -- nest menu

	MySQL.query("vRP/get_all_user_stocks", {user_id = user_id}, function(rows, affected)
		if #rows > 0 then
			for k,v in pairs(rows) do
				for ind,val in pairs(mstocks) do
					local sampris = val.pris*v.antal
					menu[v.stockname] = {ch_nothing, "<em>Aktie Navn:</em>"..v.stockname.."<br /><em>Antal:</em>"..v.antal.."<br /><em>Købt til:</em>"..v.kobttil.."<br /><em>Pris nu:</em>"..val.pris.."<br /><em>Samlet pris nu:</em>"..sampris.."<br />"}
				end
			end
		else
			menu["Du har ingen aktier!"] = {ch_nothing, "Du har desværre ingen aktier! :("}
		end
	end)
	vRP.openMenu({player, menu2})
end, "Se din portfolie"}

local ch_mine_aktier = {function(player,choice) 
	vRP.closeMenu({player})
	player = player
	SetTimeout(350, function()
		vRP.buildMenu({"Mine Aktier", {player = player}, function(menu2)
			menu2.name = "Mine Aktier"
			menu2.css={top="75px",header_color="rgba(235,0,0,0.75)"}
			menu2.onclose = function(player) vRP.openMenu({player, menu}) end
			
			menu2["Køb"] = {ch_buyaktie, "Køb Aktier"}
			menu2["Sælg"] = {ch_sell, "Sælg dine aktier"}
			menu2["Portfolie"] = {ch_portfolie,"Se din aktie portfolie"}

			vRP.openMenu({player, menu2})
		end})
	end)
end, "Mine Aktier"}

local ch_stock_menu = {function(player,choice)
    local user_id = vRP.getUserId({player})
    local menu = {}
    menu.name = "Aktier"
    menu.css = {top = "75px", header_color = "rgba(255,216,0,0.75)"}
    menu.onclose = function(player) vRP.openMainMenu({player}) end -- nest menu
    
	for i,value in pairs(mstocks) do
		local string = value.pris.." DKK"
		menu[i] = {ch_nothing, string}
	end
    vRP.openMenu({player, menu})
end,"Aktie Menu"}

vRP.registerMenuBuilder({"main", function(add, data)
    local user_id = vRP.getUserId({data.player})
    if user_id ~= nil then
        local choices = {}
        if vRP.hasGroup({user_id, "user"}) then
			choices["Aktier"] = ch_stock_menu
			choices["Mine Aktier"] = ch_mine_aktier
    	end
    add(choices)
    end
end})









