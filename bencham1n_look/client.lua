local interakcnaVzdialenost = 3.0
local interagovaneNPC = {}

function ZobrazNUI(data)
    local function VyberOtazku()
        local vyber = {}
        for _, dialog in ipairs(Config.Dialogs) do
            if dialog.id ~= "predajca_drogda" then
                local sanca = dialog.chance or 100
                if math.random(1, 100) <= sanca then
                    table.insert(vyber, dialog)
                end
            end
        end

        if #vyber > 0 then
            return vyber[math.random(#vyber)]
        else
            return Config.Dialogs[1] 
        end
    end

    local function GetNpcRoleInfo(role)
        return Config.Roles[role] or { label = "Unknown", icon = "fas fa-question" }
    end

    aktualnyDialog = VyberOtazku()
    local roleInfo = GetNpcRoleInfo(aktualnyDialog.role)

    SetNuiFocus(true, true)
    SendNUIMessage({
        type = 'otvor_menu',
        data = {
            meno = data.meno,
            sprava = aktualnyDialog.question,
            moznosti = aktualnyDialog.options,
            rola = roleInfo.label,
            ikonka = roleInfo.icon
        }
    })
end


local function GetNpcRoleInfo(role)
    return Config.Roles[role] or { label = "Unknown", icon = "fas fa-question" }
end


aktivneNPC = closestNPC

function SkryNUI()
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'zatvor_menu' })
    VypniKameru()

    if aktivneNPC then
        OdomrazNPC(aktivneNPC)
        aktivneNPC = nil
    end
end





RegisterNUICallback('akcia', function(data, cb)
    closestNPC = npc
    PrehrajNPCAnimaciu(closestNPC, data.hodnota)
    if Config.debug == true then
    print('Používateľ vybral:', data.hodnota)
    
    end
    if aktualnyDialog and aktualnyDialog.options then
        for _, option in ipairs(aktualnyDialog.options) do
            if option.value == data.hodnota then
                SendNUIMessage({
                    type = 'npc_response',
                    data = {
                        sprava = option.npcResponse or "..."
                    }
                })
                break
            end
        end
    end

    
    CreateThread(function()
        Wait(5000)
        SkryNUI()
    end)

    cb('ok')
end)

RegisterCommand(Config.interakce.name,function ()
    if Config.interakce.pouzivat == true then
                if Config.debug == true then
        print('Interakcia s pedom')
        end
        TriggerEvent("interagujnpc")
    else  
        print("Iterakce cez command je vypnutá")
    end
end)

RegisterNetEvent('interagujnpc', function()
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local closestNPC = nil
    local closestDistance = interakcnaVzdialenost

    local handle, npc = FindFirstPed()
    local success
    repeat
        if DoesEntityExist(npc) and not IsPedAPlayer(npc) then
            local npcCoords = GetEntityCoords(npc)
            local dist = #(pos - npcCoords)
            if dist < closestDistance then
                closestNPC = npc
                closestDistance = dist
            end
        end
        success, npc = FindNextPed(handle)
    until not success
    EndFindPed(handle)

    if closestNPC and not JeNPCNevhodny(closestNPC) then
        local npcId = NetworkGetNetworkIdFromEntity(closestNPC)

        if interagovaneNPC[npcId] then
            notify("Notifikace","S nim si jiz mluvil", 3000, "error")
            if Config.debug == true then
            print("Už si s týmto NPC hovoril!")
            end
            return
        end

        interagovaneNPC[npcId] = true

        aktivneNPC = closestNPC 





       
        FokusNaNPC(closestNPC)
        
        ZobrazNUI({meno = "Stranger", sprava = "Hey man, how's it going?"})

            TaskPlayAnim(closestNPC, "special_ped@baygor@monologue_3@monologue_3h", "trees_can_talk_7", 8.0, -8.0, 2000, 49, 0, false, false, false)
            FreezniNPC(closestNPC)
    else
        notify("Notifikace", "Nieje u tebe žiadne NPC", 4000, "error")
        if Config.debug == true then
        print("Žiadny NPC nablízku!")
        end
    end
end, false)









local camera = nil

function FokusNaNPC(npc)
    if not DoesEntityExist(npc) then
        return
    end

    
    local camCoords = GetOffsetFromEntityInWorldCoords(npc, 0.0, 1.5, 0.8) 
    local npcCoords = GetEntityCoords(npc)

    
    if not DoesCamExist(camera) then
        camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end

    
    SetCamCoord(camera, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtEntity(camera, npc, 0.0, 0.0, 0.8, true) 
    SetCamActive(camera, true)
    RenderScriptCams(true, true, 500, true, true)
end

function VypniKameru()
    if DoesCamExist(camera) then
        RenderScriptCams(false, true, 500, true, true)
        DestroyCam(camera, false)
        camera = nil
    end
end


function OdomrazNPC(npc)
    if not npc or not DoesEntityExist(npc) then return end

    ClearPedTasks(npc)
    ClearPedSecondaryTask(npc)
    FreezeEntityPosition(npc, false)
    SetBlockingOfNonTemporaryEvents(npc, false)
    SetPedCanRagdoll(npc, true)
    SetPedFleeAttributes(npc, 0, true)
end


function FreezniNPC(npc)
    if not npc or not DoesEntityExist(npc) then return end

    ClearPedTasksImmediately(npc)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetPedCanRagdoll(npc, false)
    SetPedFleeAttributes(npc, 0, false)
end




function notify(title, message, time, type)
    if Config.NotifyType == "ox" then
        lib.notify({
            title = title,
            description = message,
            duration = time,
            type = type
        })
    elseif Config.NotifyType == "esx" then
        ESX.ShowNotification(title, message, type, time)
    elseif Config.NotifyType == "okok" then
        exports['okokNotify']:Alert(title, message, time, type, true)
    elseif Config.NotifyType == "custom" then
        print("custom") 
    end
end


function JeNPCNevhodny(npc)
    if not DoesEntityExist(npc) then return true end

    if IsPedInAnyVehicle(npc, false) then
        notify("Notifikace", "NPC je vo vozidle nemôžeš s nim promluviť", 4000, "error")
         
        if Config.debug then print("NPC je v aute.") end
        return true
    end

    if IsPedDeadOrDying(npc, true) then
        notify("Notifikace", "NPC je zranené alebo mrtve,nemužeš si nim promluviť", 4000, "error")
        if Config.debug then print("NPC je mŕtvy alebo zomiera.") end
        return true
    end

    return false
end









function PrehrajNPCAnimaciu(npc, odpoved)
    local dict = "gestures@m@standing@casual"
    local anim = "gesture_hello" -- predvolené

    -- Vyber animáciu podľa odpovede
    if odpoved == "where" then
        anim = "gesture_point"
    elseif odpoved == "help" then
        anim = "gesture_no"
    elseif odpoved == "nothing" then
        anim = "gesture_hand_down"
    end

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end

    TaskPlayAnim(npc, dict, anim, 8.0, -8.0, 2000, 49, 0, false, false, false)
end






exports.ox_target:addGlobalPed({
    label = 'Hovoriť s pedom',
    icon = 'fas fa-comments',
    onSelect = function(data)
        if Config.interakce.ox == true then
        
        if Config.debug == true then
        print('Interakcia s pedom: ', data.entity)
        end
        TriggerEvent("interagujnpc")
    else 
         if Config.debug == true then
        print('Interakce cez Target je vypnutá')
        end
    end
    end
})