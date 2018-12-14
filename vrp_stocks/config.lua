MySQL = module("vrp_mysql", "MySQL")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")
---------------------------------------------------------SQL---------------------------------------------------------
MySQL.createCommand("vRP/stocks_column", [[
CREATE TABLE IF NOT EXISTS stocks(
  stock VARCHAR(100),
  pris INTEGER,
  timestamp INTEGER,
  CONSTRAINT PK_stock PRIMARY KEY(stock)
);
]])

MySQL.createCommand("vRP/update_stock", "INSERT IGNORE INTO stocks(stock,pris) VALUES(@stock,@pris)")
MySQL.createCommand("vRP/update_price", "UPDATE stocks SET pris = @pris WHERE stock = @stock")
MySQL.createCommand("vRP/get_stock", "SELECT pris,timestamp FROM stocks WHERE stock = @stock")
MySQL.createCommand("vRP/update_timestamp", "UPDATE stocks SET pris = @pris, timestamp = @time WHERE stock = @stock")

MySQL.execute("vRP/stocks_column")
---------------------------------------------------------SQL---------------------------------------------------------


---------------------------------------------------------Konstanter---------------------------------------------------------
stockrunned = false
pricerunned = false
---------------------------------------------------------Konstanter---------------------------------------------------------
stocks = {
    [1] = {titel = "Amazon",pris = 2000},
    [2] = {titel = "Facebook", pris = 1000},
    [3] = {titel = "nVidia", pris = 500},
    [4] = {titel = "Johnson's Pizzaria", pris = 20},
    [5] = {titel = "Bennys Pølsevogn", pris = 5},
    [6] = {titel = "Tesla", pris = 1700},
    [7] = {titel = "Netto", pris = 250},
    [8] = {titel = "Irma", pris = 100},
    [9] = {titel = "Jensens bøfhus", pris = 200}
}

local resetTime = 5

Citizen.CreateThread(function()
    for i,stock in pairs(stocks) do
        if stockrunned == false then
            print("stockrunned")
            local stock = stock.titel
            local fpris = 0
            MySQL.execute("vRP/update_stock", {stock = stock, pris = fpris})
        end
    end
end)

Citizen.CreateThread(function()
    for i,stock in pairs(stocks) do
        if pricerunned == false then
            print("pricerunned")
            local stock = stock.titel
            SetTimeout(100, function()
                MySQL.query("vRP/get_stock", {stock = stock}, function(rows, affected)
                    local stockrow = rows[1]
                    if stockrow.pris == 0 then
                        SetTimeout(1000, function()
                            vRP.updatePrice()
                        end)
                    end 
                end)
            end)
        end
    end
end)

Citizen.CreateThread(function()
    for i,stock in pairs(stocks) do 
        timeout = i * 1200
        print(timeout)
        SetTimeout(timeout, function()
            stockrunned = true
            pricerunned = true
        end)
    end
end)

function vRP.updatePrice()
    for i,stock in pairs(stocks) do
        local price = stock.pris
        local stock = stock.titel
        MySQL.execute("vRP/update_price", {stock = stock, pris = price})
    end
end

Citizen.CreateThread(function()
    while true do
        Wait(0)
        for i,stock in pairs(stocks) do
            SetTimeout(5000, function()
                local stock = stock.titel
                MySQL.query("vRP/get_stock", {stock = stock}, function(rows, affected)
                    local stockrow = rows[1]
                    local price = stockrow.pris
                    if stockrow.timestamp == nil then
                        vRP.updateStock(stock,price)
                    elseif stockrow.timestamp ~= nil then
                        stockrow.timestamp = tonumber(stockrow.timestamp) ~= nil and tonumber(stockrow.timestamp) or 0
                        if os.time() >= stockrow.timestamp+resetTime*60 then
                            vRP.updateStock(stock,price)
                        end
                    end
                end)
            end)
        end
    end
end)

function vRP.updateStock(stock,price)
    if stock ~= nil then
        if price > 50 then
            local rannum = math.random(-15,20)
            local diff = math.floor(price / 200)
            local change = math.floor(price + rannum * diff)
            local time = os.time()
            MySQL.execute("vRP/update_timestamp", {pris = change, time = time, stock = stock})
        else
            local rannum = math.random(-2,4)
            local change = math.floor(price + rannum)
            local time = os.time()
            MySQL.execute("vRP/update_timestamp", {pris = change, time = time, stock = stock})
        end
    end
end



                    





