Cfg = {}

-- Aktierne
Cfg.stocks = {
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
Cfg.highPriceRange = {
    min = -15,
    max = 20
}

-- hvis aktien er under 50kr
Cfg.lowPriceRange = {
    min = -2,
    max = 4
}

-- Tid til den opdatere aktiens pris 
Cfg.resetTime = 5

