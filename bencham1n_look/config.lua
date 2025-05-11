Config = {}

Config.NotifyType = "okok"
Config.debug = true
Config.Roles = {
    supplier = { label = "Supplier", icon = "fas fa-box-open" },
    dealer = { label = "Dealer", icon = "fas fa-handshake" },
    doctor = { label = "Doctor", icon = "fas fa-user-md" },
    civil = { label = "Citizen", icon = "fas fa-user" }
}
Config.Dialogs = {
    {
        id = "civil_nalada",
        role = "civil",
        question = "Čau chlape , ako sa máš?",
        chance = 60,
        options = {
            {label = "Pohodička, ty?", value = "good", npcResponse = "Ja tiež pohoda!"},
            {label = "Nechaj ma na pokoji", value = "rude", npcResponse = "Chill braško!"}
        }
    },
    {
        id = "pdm_civil",
        role = "civil",
        question = "Možem ti nejako pomôcť?",
        chance = 30,
        options = {
            {label = "Ano,kde je PDM", value = "help_yes", npcResponse = "Dobre super."},
            {label = "Nie, diky", value = "help_no", npcResponse = "Okay, fantazia."},
            {label = "Kto si?", value = "who", npcResponse = "Nikto, obyčajný človek."}
        }
    },
    {
        id = "predajca_drog",
        role = "dealer",
        question = "Čo chceš vole?",
        chance = 30,
        options = {
            {label = "Vieš niečo o drogách", value = "weather_yes", npcResponse = "Aj keby viem nič ti nepoviem."},
            {label = "Čo maš s okom", value = "weather_no", npcResponse = "Vole,  co ta do toho."},
            {label = "Nechať ho tak", value = "weather_noa", npcResponse = "...."}
        }
    }
}


Config.interakce = {
    name = "rozpravat",
    pouzivat = true,
    ox = false
}