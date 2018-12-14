MySQL = module("vrp_mysql", "MySQL")
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")

vRP = Proxy.getInterface("vRP")

-- Aktierne
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
-- hvis atktien er over 50kr
highPriceRange = { min = -18, max = 20}

-- hvis aktien er under 50kr
lowPriceRange = { min = -2, max = 3 }

-- Tid til den opdatere aktiens pris 
resetTime = 1

---------------------------------------------------------SQL---------------------------------------------------------
MySQL.createCommand("vRP/stocks_column", [[
CREATE TABLE IF NOT EXISTS stocks(
  stockname VARCHAR(100),
  pris INTEGER,
  timestamp INTEGER,
  CONSTRAINT PK_stock PRIMARY KEY(stockname)
);
]])

MySQL.createCommand("vRP/update_stock", "INSERT IGNORE INTO stocks(stockname,pris,timestamp) VALUES(@stock,@pris,@timestamp)")
MySQL.createCommand("vRP/update_price", "UPDATE stocks SET pris = @pris WHERE stockname = @stock")
MySQL.createCommand("vRP/get_stock", "SELECT * FROM stocks WHERE stockname = @stock")
MySQL.createCommand("vRP/update_timestamp", "UPDATE stocks SET pris = @pris, timestamp = @time WHERE stockname = @stock")

MySQL.execute("vRP/stocks_column")
---------------------------------------------------------SQL---------------------------------------------------------


---------------------------------------------------------Konstanter---------------------------------------------------------
stockrunned = false
pricerunned = false
changevar = false
---------------------------------------------------------Konstanter---------------------------------------------------------
Citizen.CreateThread(function()
    if stockrunned == false then
        for i,stock in pairs(stocks) do
            runStock(stock.titel)
            --print("ranstock")
            --print("1----------------------")

            if pricerunned == false then
                MySQL.query("vRP/get_stock", {stock = stock.titel}, function(rows, affected)
                    for k,v in pairs(rows) do
                        runPrice(stock.titel,stock.pris,v.pris)
                        --print("ranprice")
                        --print("----------------------")
                    end
                end)
            end
        end
    end
end)

Citizen.CreateThread(function()
    for i,stock in pairs(stocks) do
        local titel = stock.titel
        MySQL.query("vRP/get_stock", {stock = titel}, function(rows, affected)
            for k,v in pairs(rows) do
                local stockn = v.stockname
                local prisn = v.pris
                local timestampn = v.timestamp
                --print(stockn)
                --print("2----------------------")

                if pricerunned == false or stockrunned == false and changevar == false then
                    changeVar(timeout)
                end
            end
        end)
    end
end)

Citizen.CreateThread(function()
    while true do
        local time = 60000 * resetTime - 10000
        Citizen.Wait(time)
        checkUpdate()
    end
end)

function checkUpdate()
    for i,stock in pairs(stocks) do
        local titel = stock.titel    
        MySQL.query("vRP/get_stock", {stock = titel}, function(rows, affected)
            for k,v in pairs(rows) do
                local stock = v.stockname
                local price = v.pris 
                if v.timestamp == nil or v.timestamp == 1 then
                    updateStock(stock,price)
                else
                    if os.time() >= v.timestamp+resetTime*60 then
                        updateStock(stock,price)
                    end
                end
            end
        end) 
    end
end

function runStock(stock)
    local fpris = 0
    local timestamp = 1
    MySQL.execute("vRP/update_stock", {stock = stock, pris = fpris, timestamp = timestamp})
end

function runPrice(stock,spris,dpris)
    if dpris == 0 then
        Citizen.SetTimeout(1000, function()
            MySQL.execute("vRP/update_price", {stock = stock, pris = spris})
        end)
    end
end

function changeVar()
    Citizen.SetTimeout(15000, function()
        stockrunned = true
        pricerunned = true
        changevar = true
    end)
end

function updateStock(stock,price)
    if stock ~= nil then
        if price > 50 then
            local rannum = math.random(highPriceRange.min,highPriceRange.max)
            local change = math.ceil(price + rannum)
            local time = os.time()
            MySQL.execute("vRP/update_timestamp", {pris = change, time = time, stock = stock})
        else
            local rannum = math.random(lowPriceRange.min,lowPriceRange.max)
            local change = math.floor(price + rannum)
            local time = os.time()
            MySQL.execute("vRP/update_timestamp", {pris = change, time = time, stock = stock})
        end
    end
end




