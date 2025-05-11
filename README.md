🇸🇰 Dokumentácia skriptu pre interakciu s NPC 🗣️
Tento dokument popisuje konfiguráciu a funkčnosť Lua skriptu, ktorý umožňuje hráčom interagovať s nehrateľnými postavami (NPC) v hre. Skript poskytuje systém dialógov 💬, notifikácií 🔔 a voliteľnú integráciu s ox_target 🎯.

Konfigurácia (Config = {}) ⚙️
Globálna tabuľka Config obsahuje rôzne nastavenia skriptu.

Config.NotifyType
Definuje typ notifikačného systému, ktorý sa bude používať. Dostupné možnosti:

"okok": Používa notifikačný systém okokNotify ✅.
"ox": Používa notifikačný systém ox_lib.notify 🟦.
"esx": Používa notifikačný systém ESX.ShowNotification ℹ️.
"custom": Označuje použitie vlastného, nadefinovaného notifikačného systému 🛠️ (v kóde je len print("custom")).
Config.debug
Logická hodnota, ktorá zapína alebo vypína výpisy do konzoly pre účely ladenia 🐞. Ak je nastavená na true, skript bude vypisovať rôzne informácie o svojej činnosti.

Config.Roles
Tabuľka definujúca role NPC a ich vizuálne reprezentácie. Každá rola je kľúč v tejto tabuľke a má nasledujúce atribúty:

label: Textový popis role, ktorý sa zobrazí v používateľskom rozhraní (NUI) 🏷️.
icon: Názov ikony z Font Awesome, ktorá reprezentuje rolu v NUI 🖼️.
Príklad:

Config.Roles = {
    supplier = { label = "Dodávateľ", icon = "fas fa-box-open" },
    dealer = { label = "Predajca", icon = "fas fa-handshake" },
    doctor = { label = "Doktor", icon = "fas fa-user-md" },
    civil = { label = "Občan", icon = "fas fa-user" }
}

Config.Dialogs
Tabuľka obsahujúca definície dialógov, ktoré môžu byť zobrazené hráčom pri interakcii s NPC. Každý dialóg je tabuľka s nasledujúcimi atribútmi:

id: Jedinečný identifikátor dialógu 🔑.
role: Rola NPC, pre ktorú je tento dialóg určený (odkazuje na kľúč v Config.Roles) 👤.
question: Otázka, ktorá sa zobrazí hráčovi 🤔.
chance: Číselná hodnota (0-100) určujúca percentuálnu šancu, že sa tento dialóg vyberie pri interakcii 🎲. Ak nie je definovaná, predvolená hodnota je 100.
options: Tabuľka obsahujúca možnosti odpovedí pre hráča 💬. Každá možnosť má nasledujúce atribúty:
label: Text, ktorý sa zobrazí ako možnosť odpovede 🏷️.
value: Hodnota, ktorá sa odosiela späť do skriptu, keď hráč vyberie túto možnosť 📤.
npcResponse: Text, ktorý povie NPC po vybratí tejto možnosti hráčom 🗣️.
Príklad:
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
    -- Ďalšie dialógy...
}
Poznámka: Dialóg s id = "predajca_drogda" je explicitne vylúčený z náhodného výberu otázok 🚫.

Config.interakce
Tabuľka definujúca nastavenia pre samotnú interakciu s NPC.

name: Názov príkazu, ktorý hráč môže použiť na spustenie interakcie (ak je pouzivat nastavené na true) ⌨️.
pouzivat: Logická hodnota, ktorá určuje, či je možné spustiť interakciu pomocou príkazu /názov (kde názov je hodnota name) ✅/❌.
ox: Logická hodnota, ktorá určuje, či sa má povoliť interakcia cez ox_target 🎯 ✅/❌.
Príklad:
Config.interakce = {
    name = "rozpravat",
    pouzivat = true,
    ox = false
}
Premenné 💾
interakcnaVzdialenost: Lokálna premenná definujúca maximálnu vzdialenosť, z ktorej môže hráč interagovať s NPC (nastavená na 3.0 metre) 📏.
interagovaneNPC: Lokálna tabuľka, ktorá sleduje ID sietí NPC, s ktorými hráč už interagoval, aby sa zabránilo opakovanej interakcii 📝.
aktualnyDialog: Globálna premenná, ktorá ukladá aktuálne vybraný dialóg pre interakciu 💬.
aktivneNPC: Globálna premenná, ktorá ukladá entitu aktuálne interagujúceho NPC 🧍.
closestNPC: Globálna premenná, ktorá (v niektorých kontextoch) ukladá najbližšie NPC 📍.
camera: Lokálna premenná, ktorá ukladá handle kamery vytvorenej pre priblíženie k NPC počas interakcie 📸.
Funkcie ⚙️
ZobrazNUI(data)
Táto funkcia je zodpovedná za zobrazenie používateľského rozhrania (NUI) pre interakciu s NPC 🖥️.

VyberOtazku(): Lokálna vnorená funkcia, ktorá náhodne vyberie dialóg z Config.Dialogs na základe definovanej šance (chance) 🎲. Vyberá len dialógy, ktorých id nie je "predajca_drogda" 🚫. Ak sa žiadny dialóg nevyberie na základe šance, vráti sa prvý dialóg z Config.Dialogs 🥇.
GetNpcRoleInfo(role): Lokálna vnorená funkcia, ktorá na základe role NPC vráti informácie o nej z Config.Roles (label a ikonu) 👤🖼️. Ak rola neexistuje, vráti predvolené hodnoty 🤔❓.
Vyberie sa náhodný dialóg pomocou VyberOtazku() a uloží sa do aktualnyDialog 💬.
Získajú sa informácie o role NPC pomocou GetNpcRoleInfo() 👤.
Nastaví sa fokus NUI na true a odošle sa správa do NUI s typom 'otvor_menu' obsahujúca meno NPC (data.meno), otázku (aktualnyDialog.question), možnosti odpovedí (aktualnyDialog.options), rolu (roleInfo.label) a ikonu (roleInfo.icon) 📤.
GetNpcRoleInfo(role)
Táto funkcia (definovaná aj mimo ZobrazNUI) slúži na rovnaký účel ako vnorená funkcia s rovnakým názvom v ZobrazNUI - vracia informácie o role NPC z Config.Roles 👤🖼️.

SkryNUI()
Táto funkcia zatvorí NUI a obnoví stav hry ❌🖥️.

Nastaví fokus NUI na false a odošle správu do NUI s typom 'zatvor_menu' 📤.
Vypne kameru priblíženú k NPC pomocou VypniKameru() 📸➡️❌.
Ak existuje aktívne interagujúce NPC (aktivneNPC), odomkne ho pomocou OdomrazNPC() 🔓🧍 a nastaví aktivneNPC na nil.
RegisterNUICallback('akcia', function(data, cb)
Táto funkcia spracováva akciu, keď hráč vyberie odpoveď v NUI ✅.

Nastaví closestNPC na aktuálne interagujúce npc (táto premenná nie je v kóde jasne definovaná v kontexte callbacku, pravdepodobne by mala byť prenesená) 🧍➡️📍.
Prehrá animáciu NPC na základe vybranej hodnoty (data.hodnota) pomocou PrehrajNPCAnimaciu() 🎬.
Ak je povolené ladenie (Config.debug == true), vypíše vybranú odpoveď do konzoly 🐞➡️📝.
Prehľadá možnosti aktuálneho dialógu (aktualnyDialog.options) a ak nájde zhodu s vybranou hodnotou (data.hodnota), odošle do NUI správu s typom 'npc_response' obsahujúcu odpoveď NPC (option.npcResponse) 🗣️➡️📤.
Spustí vlákno, ktoré po 5 sekundách zavrie NUI pomocou SkryNUI() ⏱️➡️❌🖥️.
Odošle spätné volanie (cb('ok')) do NUI, čím potvrdí spracovanie akcie 👍➡️🖥️.
RegisterCommand(Config.interakce.name, function ()
Registruje príkaz pre spustenie interakcie s NPC, ak je Config.interakce.pouzivat nastavené na true ⌨️✅. Po vykonaní príkazu spustí udalosť interagujnpc 🚀. Ak je používanie príkazu vypnuté, vypíše správu do konzoly ⌨️❌➡️📝.

RegisterNetEvent('interagujnpc', function()
Táto funkcia sa spustí, keď je vyvolaná udalosť interagujnpc (napríklad po vykonaní príkazu alebo výbere v ox_target) 👂➡️🚀.

Získa ID a pozíciu hráča 👤📍.
Inicializuje premenné pre najbližšie NPC (closestNPC) a jeho vzdialenosť (closestDistance) 🧍📍📏.
Prejde všetky existujúce Pedy (postavy) v hre pomocou FindFirstPed a FindNextPed 🚶.
Pre každé NPC skontroluje, či existuje a či nie je hráčom ✅👤.
Vypočíta vzdialenosť medzi hráčom a NPC 📏.
Ak je vzdialenosť menšia ako interakcnaVzdialenost, uloží toto NPC ako najbližšie (closestNPC) a aktualizuje najbližšiu vzdialenosť 📍➡️🧍.
Po prejdení všetkých NPC skontroluje, či bolo nájdené nejaké najbližšie NPC a či nie je nevhodné na interakciu pomocou JeNPCNevhodny() 🤔🧍.
Ak sa našlo vhodné NPC ✅🧍:
Získa jeho sieťové ID 🆔.
Skontroluje, či už hráč s týmto NPC interagoval (pomocou interagovaneNPC) 📝➡️🤔. Ak áno, zobrazí notifikáciu 🔔🚫 a ukončí funkciu 🛑.
Ak hráč s týmto NPC ešte neinteragoval, pridá jeho ID do interagovaneNPC 📝✅.
Nastaví aktivneNPC na toto NPC 🧍➡️✅.
Zameria kameru na NPC pomocou FokusNaNPC() 📸➡️🧍.
Zobrazí NUI pomocou ZobrazNUI() s predvolenými údajmi o mene a správe 💬➡️🖥️.
Prehrá predvolenú animáciu pre NPC pomocou TaskPlayAnim() 🎬.
Zamrazí NPC pomocou FreezniNPC() 🧊🧍.
Ak sa v blízkosti nenašlo žiadne vhodné NPC 🚫🧍, zobrazí notifikáciu 🔔.
FokusNaNPC(npc)
Táto funkcia priblíži kameru k zadanému NPC 📸➡️🧍.

Skontroluje, či NPC existuje ✅🧍.
Vypočíta pozíciu kamery relatívne k NPC 📐.
Ak kamera ešte neexistuje, vytvorí ju 🆕📸.
Nastaví pozíciu kamery a zameria ju na NPC 📍➡️📸.
Aktivuje a prepne na túto kameru ▶️📸.
VypniKameru()
Táto funkcia deaktivuje a zničí kameru priblíženú k NPC, ak existuje 📸➡️❌.

OdomrazNPC(npc)
Táto funkcia obnoví normálny stav pohybu a animácií zadaného NPC 🧊➡️🔓🧍.

FreezniNPC(npc)
Táto funkcia okamžite zastaví všetky úlohy a animácie zadaného NPC a zamrazí jeho pozíciu ▶️⏸️🧍➡️🧊.

notify(title, message, time, type)
Táto funkcia zobrazí notifikáciu v závislosti od nastavenia Config.NotifyType 🔔. Podporuje "ox" 🟦, "esx" ℹ️, "okok" ✅ a "custom" 🛠️ notifikácie.

JeNPCNevhodny(npc)
Táto funkcia skontroluje, či je dané NPC vhodné na interakciu 🤔🧍. Vráti true, ak NPC neexistuje 👻, nachádza sa vo vozidle 🚗 alebo je mŕtve/umierajúce 💀, a zobrazí príslušnú notifikáciu 🔔🚫. V opačnom prípade vráti false ✅.

PrehrajNPCAnimaciu(npc, odpoved)
Táto funkcia prehrá animáciu pre zadané NPC na základe hráčovej odpovede (odpoved) 🎬🧍. Používa animácie z anim dictionary gestures@m@standing@casual. Predvolená animácia je gesture_hello 👋, ale na základe hodnoty odpoved sa môže zmeniť na gesture_point 👉, gesture_no 🙅 alebo gesture_hand_down ✋⬇️.

exports.ox_target:addGlobalPed(...)
Ak je Config.interakce.ox nastavené na true 🎯✅, táto časť kódu pridá možnosť interakcie s akýmkoľvek NPC do menu ox_target ➕🎯. Po výbere tejto možnosti sa spustí udalosť interagujnpc 🚀.

Použitie 🕹️
Uistite sa, že máte nainštalovaný a spustený zvolený notifikačný systém (definovaný v Config.NotifyType) ✅🔔.
Ak chcete používať interakciu cez príkaz ⌨️, nastavte Config.interakce.pouzivat na true ✅ a použite príkaz definovaný v Config.interakce.name (predvolene /rozpravat) v hre, keď ste v blízkosti NPC (v rámci interakcnaVzdialenost 📏).
Ak chcete používať interakciu cez ox_target 🎯, uistite sa, že máte nainštalovaný ox_target ✅ a nastavte Config.interakce.ox na true ✅. Potom priblížte sa k NPC a otvorte menu ox_target, kde by sa mala zobraziť možnosť "Hovoriť s pedom" 🗣️.
Po spustení interakcie sa zobrazí NUI s otázkou od NPC a možnosťami odpovede 💬➡️🖥️. Po výbere odpovede NPC zareaguje (textom 🗣️ a voliteľne animáciou 🎬) a po krátkej chvíli sa NUI zatvorí ⏱️➡️❌🖥️. S tým istým NPC nebudete môcť interagovať znova, kým sa reštartuje skript alebo sa nevymaže záznam z tabuľky interagovaneNPC 🔄📝.
