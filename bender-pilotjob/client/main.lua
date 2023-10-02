local QBCore = exports['qb-core']:GetCoreObject()
local planeVehicle = nil
local hasBag = false
local currentStop = 0
local deliveryBlip = nil
local amountOfBags = 0
local luggageObject = nil 
local endBlip = nil
local planeBlip = nil 
local canTakeBag = true
local currentStopNum = 0
local PZone = nil
local listen = false
local finished = false
local continueworking = false
local playerJob = {}
-- Handlers

-- Functions

local function setupClient()
    planeVehicle = nil
    hasBag = false
    currentStop = 0
    deliveryBlip = nil
    amountOfBags = 0
    luggageObject = nil
    endBlip = nil
    currentStopNum = 0
    if playerJob.name == Config.Jobname then
        planeBlip = AddBlipForCoord(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y, Config.Locations["main"].coords.z)
        SetBlipSprite(planeBlip, 307)
        SetBlipDisplay(planeBlip, 4)
        SetBlipScale(planeBlip, 1.0)
        SetBlipAsShortRange(planeBlip, true)
        SetBlipColour(planeBlip, 0)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.Locations["main"].label)
        EndTextCommandSetBlipName(planeBlip)
    end
end



local function LoadAnimation(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do Wait(10) end
end

local function BringBackCar()
    DeleteVehicle(PlaneVehicle)
    if endBlip then
        RemoveBlip(endBlip)
    end
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end
    PlaneVehicle = nil
    hasBag = false
    currentStop = 0
    deliveryBlip = nil
    amountOfBags = 0
    luggageObject = nil
    endBlip = nil
    currentStopNum = 0
end

local function DeleteZone()
    listen = false
    PZone:destroy()
end

local function SetRouteBack()
    local hangar = Config.Locations["main"].coords -- depot to hangar
    endBlip = AddBlipForCoord(hangar.x, hangar.y, hangar.z)
    SetBlipSprite(endBlip, 1)
    SetBlipDisplay(endBlip, 2)
    SetBlipScale(endBlip, 1.0)
    SetBlipAsShortRange(endBlip, false)
    SetBlipColour(endBlip, 3)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["vehicle"].label)
    EndTextCommandSetBlipName(endBlip)
    SetBlipRoute(endBlip, true)
    DeleteZone()
    finished = true
end

local function AnimCheck()
    CreateThread(function()
        local ped = PlayerPedId()
        while hasBag and not IsEntityPlayingAnim(ped, 'missfbi4prepp1', '_bag_throw_garbage_man',3) do
            if not IsEntityPlayingAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 3) then
                ClearPedTasksImmediately(ped)
                LoadAnimation('missfbi4prepp1')
                TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
            end
            Wait(1000)
        end
    end)
end

local function DeliverAnim()
    local ped = PlayerPedId()
    LoadAnimation('missfbi4prepp1')
    TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_throw_garbage_man', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
    FreezeEntityPosition(ped, true)
    SetEntityHeading(ped, GetEntityHeading(planeVehicle))
    canTakeBag = false
    SetTimeout(1250, function()
        DetachEntity(luggageObject, 1, false)
        DeleteObject(luggageObject)
        TaskPlayAnim(ped, 'missfbi4prepp1', 'exit', 8.0, 8.0, 1100, 48, 0.0, 0, 0, 0)
        FreezeEntityPosition(ped, false)
        luggageObject = nil
        canTakeBag = true
    end)
    if Config.UseTarget and hasBag then
        local CL = Config.Locations["trashcan"][currentStop]
        hasBag = false
        local pos = GetEntityCoords(ped)
        exports['qb-target']:RemoveTargetEntity(planeVehicle)
        if (amountOfBags - 1) <= 0 then
            QBCore.Functions.TriggerCallback('pilotjob:server:NextStop', function(hasMoreStops, nextStop, newBagAmount)
                if hasMoreStops and nextStop ~= 0 then
                    -- Here he puts your next location and you are not finished working yet.
                    currentStop = nextStop
                    currentStopNum = currentStopNum + 1
                    amountOfBags = newBagAmount
                    SetPlaneRoute()
                    QBCore.Functions.Notify(Lang:t("info.all_bags"))
                else
                    if hasMoreStops and nextStop == currentStop then
                        QBCore.Functions.Notify(Lang:t("info.depot_issue"))
                        amountOfBags = 0
                    else
                        -- You are done with work here.
                        QBCore.Functions.Notify(Lang:t("info.done_working"))
                        RemoveBlip(deliveryBlip)
                        SetRouteBack()
                        amountOfBags = 0
                    end
                end
            end, currentStop, currentStopNum, pos)
        else
            -- You haven't delivered all bags here
            amountOfBags = amountOfBags - 1
            if amountOfBags > 1 then
                QBCore.Functions.Notify(Lang:t("info.luggage_left", { value = amountOfBags }))
            else
                QBCore.Functions.Notify(Lang:t("info.bags_still", { value = amountOfBags }))
            end
            exports['qb-target']:AddCircleZone('luggagecart', vector3(CL.coords.x, CL.coords.y, CL.coords.z), 2.0,{
                name = 'luggagecart', debugPoly = false, useZ=true}, {
                options = {{label = Lang:t("target.grab_luggage"),icon = 'fa-solid fa-person-walking-luggage', action = function() TakeAnim() end}},
                distance = 2.0
            })
        end
    end
end

function TakeAnim()
    local ped = PlayerPedId()
    QBCore.Functions.Progressbar("luggage_pickup", Lang:t("info.picking_luggage"), math.random(3000, 5000), false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        flags = 16,
    }, {}, {}, function()
        LoadAnimation('missfbi4prepp1')
        TaskPlayAnim(ped, 'missfbi4prepp1', '_bag_walk_garbage_man', 6.0, -6.0, -1, 49, 0, 0, 0, 0)
        luggageObject = CreateObject(`prop_luggage_05a`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(luggageObject, ped, GetPedBoneIndex(ped, 57005), 0.12, 0.0, -0.05, 220.0, 120.0, 0.0, true, true, false, true, 1, true)
        StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
        AnimCheck()
        if Config.UseTarget and not hasBag then
            hasBag = true
            exports['qb-target']:RemoveZone("luggagecart")
            exports['qb-target']:AddTargetEntity(planeVehicle, {
            options = {
                {label = Lang:t("target.dispose_garbage"),icon = 'fa-solid fa-plane',action = function() DeliverAnim() end,canInteract = function() if hasBag then return true end return false end, }
            },
            distance = 2.0
            })
        end
    end, function()
        StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
        QBCore.Functions.Notify(Lang:t("error.cancled"), "error")
    end)
end

local function RunWorkLoop()
    CreateThread(function()
        local luggageText = false
        while listen do
            local ped = PlayerPedId()
            local pos = GetEntityCoords(ped)
            local DeliveryData = Config.Locations["luggage"][currentStop]
            local Distance = #(pos - vector3(DeliveryData.coords.x, DeliveryData.coords.y, DeliveryData.coords.z))
            if Distance < 15 or hasBag then

                if not hasBag and canTakeBag then
                    if Distance < 1.5 then
                        if not luggageText then
                            luggageText = true
                            exports['qb-core']:DrawText(Lang:t("info.grab_luggage"), 'left')
                        end
                        if IsControlJustPressed(0, 51) then
                            hasBag = true
                            exports['qb-core']:HideText()
                            TakeAnim()
                        end
                    elseif Distance < 10 then
                        if luggageText then
                            luggageText = false
                            exports['qb-core']:HideText()
                        end
                    end
                else
                    if DoesEntityExist(planeVehicle) then
                        local Coords = GetOffsetFromEntityInWorldCoords(planeVehicle, Config.DropOff)
                        local PlaneDist = #(pos - Coords)
                        local PlaneText = false

                        if PlaneDist < Config.NearDropOff then
                            if not PlaneText then
                                PlaneText = true
                                exports['qb-core']:DrawText(Lang:t(Config.PropType), 'left')
                            end
                            if IsControlJustPressed(0, 51) and hasBag then
                                StopAnimTask(PlayerPedId(), 'missfbi4prepp1', '_bag_walk_garbage_man', 1.0)
                                DeliverAnim()
                                QBCore.Functions.Progressbar("deliverbag", Lang:t("info.progressbar"), 2000, false, true, {
                                        disableMovement = true,
                                        disableCarMovement = true,
                                        disableMouse = false,
                                        disableCombat = true,
                                    }, {}, {}, {}, function() -- Done
                                        hasBag = false
                                        canTakeBag = false
                                        DetachEntity(planeObject, 1, false)
                                        DeleteObject(planeObject)
                                        FreezeEntityPosition(ped, false)
                                        planeObject = nil
                                        canTakeBag = true
                                        -- Looks if you have delivered all bags
                                        if (amountOfBags - 1) <= 0 then
                                            QBCore.Functions.TriggerCallback('pilotjob:server:NextStop', function(hasMoreStops, nextStop, newBagAmount)
                                                if hasMoreStops and nextStop ~= 0 then
                                                    -- Here he puts your next location and you are not finished working yet.
                                                    currentStop = nextStop
                                                    currentStopNum = currentStopNum + 1
                                                    amountOfBags = newBagAmount
                                                    SetPlaneRoute()
                                                    QBCore.Functions.Notify(Lang:t("info.all_luggage"))
                                                    listen = false
                                                else
                                                    if hasMoreStops and nextStop == currentStop then
                                                        QBCore.Functions.Notify(Lang:t("info.hangar_issue"))
                                                        amountOfBags = 0
                                                    else
                                                        -- You are done with work here.
                                                        QBCore.Functions.Notify(Lang:t("info.done_working"))
                                                        RemoveBlip(deliveryBlip)
                                                        SetRouteBack()
                                                        amountOfBags = 0
                                                        listen = false
                                                    end
                                                end
                                            end, currentStop, currentStopNum, pos)
                                            hasBag = false
                                        else
                                            -- You haven't delivered all bags here
                                            amountOfBags = amountOfBags - 1
                                            if amountOfBags > 1 then
                                                QBCore.Functions.Notify(Lang:t("info.luggage_left", { value = amountOfBags }))
                                            else
                                                QBCore.Functions.Notify(Lang:t("info.luggage_still", { value = amountOfBags }))
                                            end
                                            hasBag = false
                                        end

                                        Wait(1500)
                                        if PlaneText then
                                            exports['qb-core']:HideText()
                                            PlaneText = false
                                        end
                                    end, function() -- Cancel
                                    QBCore.Functions.Notify(Lang:t("error.cancled"), "error")
                                end)

                            end
                        end
                    else
                        QBCore.Functions.Notify(Lang:t("error.no_plane"), "error")
                        hasBag = false
                    end
                end
            end
            Wait(1)
        end
    end)
end

local function CreateZone(x, y, z)
    CreateThread(function()
        PZone = CircleZone:Create(vector3(x, y, z), 15.0, {
            name = "NewRouteWhoDis",
            debugPoly = false,
        })

        PZone:onPlayerInOut(function(isPointInside)
            if isPointInside then
                if not Config.UseTarget then
                    listen = true
                    RunWorkLoop()
                end
            else
                if not Config.UseTarget then
                    exports['qb-core']:HideText()
                    listen = false
                end
            end
        end)
    end)
end

function SetPlaneRoute()
    local CL = Config.Locations["luggage"][currentStop]
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end
    deliveryBlip = AddBlipForCoord(CL.coords.x, CL.coords.y, CL.coords.z)
    SetBlipSprite(deliveryBlip, 1)
    SetBlipDisplay(deliveryBlip, 2)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipColour(deliveryBlip, 27)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(Config.Locations["luggage"][currentStop].name)
    EndTextCommandSetBlipName(deliveryBlip)
    SetBlipRoute(deliveryBlip, true)
    finished = false
    if Config.UseTarget and not hasBag then
        exports['qb-target']:AddCircleZone('luggagecart', vector3(CL.coords.x, CL.coords.y, CL.coords.z), 2.0,{
            name = 'luggagecart', debugPoly = false, useZ=true }, {
            options = {{label = Lang:t("target.grab_luggage"), icon = 'fa-solid fa-person-walking-luggage', action = function() TakeAnim() end }},
            distance = 2.0
        })
    end
    if PZone then
        DeleteZone()
        Wait(500)
        CreateZone(CL.coords.x, CL.coords.y, CL.coords.z)
    else
        CreateZone(CL.coords.x, CL.coords.y, CL.coords.z)
    end
end

local ControlListen = false
local function Listen4Control()
    ControlListen = true
    CreateThread(function()
        while ControlListen do
            if IsControlJustReleased(0, 38) then
                TriggerEvent("qb-pilotjob:client:MainMenu")
            end
            Wait(1)
        end
    end)
end

local pedsSpawned = false
local function spawnPeds()
    if not Config.Peds or not next(Config.Peds) or pedsSpawned then return end
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        current.model = type(current.model) == 'string' and GetHashKey(current.model) or current.model
        RequestModel(current.model)
        while not HasModelLoaded(current.model) do
            Wait(0)
        end
        local ped = CreatePed(0, current.model, current.coords, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        current.pedHandle = ped

        if Config.UseTarget then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {{type = "client", event = "qb-pilotjob:client:MainMenu", label = Lang:t("target.talk"), icon = 'fa-solid fa-recycle', job = "pilot",}},
                distance = 2.0
            })
        else
            local options = current.zoneOptions
            if options then
                local zone = BoxZone:Create(current.coords.xyz, options.length, options.width, {
                    name = "zone_cityhall_" .. ped,
                    heading = current.coords.w,
                    debugPoly = false
                })
                zone:onPlayerInOut(function(inside)
                    if LocalPlayer.state.isLoggedIn then
                        if inside then
                            exports['qb-core']:DrawText(Lang:t("info.talk"), 'left')
                            Listen4Control()
                        else
                            ControlListen = false
                            exports['qb-core']:HideText()
                        end
                    end
                end)
            end
        end
    end
    pedsSpawned = true
end

local function deletePeds()
    if not Config.Peds or not next(Config.Peds) or not pedsSpawned then return end
    for i = 1, #Config.Peds do
        local current = Config.Peds[i]
        if current.pedHandle then
            DeletePed(current.pedHandle)
        end
    end
end

-- Events

RegisterNetEvent('pilotjob:client:SetWaypointHome', function()
    SetNewWaypoint(Config.Locations["main"].coords.x, Config.Locations["main"].coords.y)
end)

RegisterNetEvent('qb-pilotjob:client:RequestRoute', function()
    if planeVehicle then continueworking = true TriggerServerEvent('pilotjob:server:PayShift', continueworking) end
    QBCore.Functions.TriggerCallback('pilotjob:server:NewShift', function(shouldContinue, firstStop, totalBags)
        if shouldContinue then
            if not planeVehicle then
                local occupied = false
                for _,v in pairs(Config.Locations["vehicle"].coords) do
                    if not IsAnyVehicleNearPoint(vector3(v.x,v.y,v.z), 2.5) then
                        QBCore.Functions.TriggerCallback('QBCore:Server:SpawnVehicle', function(netId)
                            local veh = NetToVeh(netId)
                            SetVehicleEngineOn(veh, false, true)
                            planeVehicle = veh
                            SetVehicleNumberPlateText(veh, "AP-" .. tostring(math.random(1000, 9999)))
                            SetEntityHeading(veh, v.w)
                            exports['cdn-fuel']:SetFuel(veh, 100.0)
                            SetVehicleFixed(veh)
                            SetEntityAsMissionEntity(veh, true, true)
                            SetVehicleDoorsLocked(veh, 2)
                            currentStop = firstStop
                            currentStopNum = 1
                            amountOfBags = totalBags
                            SetPlaneRoute()
                            TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                            QBCore.Functions.Notify(Lang:t("info.deposit_paid", { value = Config.PlanePrice }))
                            QBCore.Functions.Notify(Lang:t("info.started"))
                            TriggerServerEvent("qb-pilotjob:server:payDeposit")
                        end, Config.Vehicle, v, false)
                        return
                    else
                        occupied = true
                    end
                end
                if occupied then
                    QBCore.Functions.Notify(Lang:t("error.all_occupied"))
                end
            end
            currentStop = firstStop
            currentStopNum = 1
            amountOfBags = totalBags
            SetPlaneRoute()
        else
            QBCore.Functions.Notify(Lang:t("info.not_enough", { value = Config.PlanePrice }))
        end
    end, continueworking)
end)

RegisterNetEvent('qb-pilotjob:client:RequestPaycheck', function()
    if planeVehicle then
        BringBackCar()
        QBCore.Functions.Notify(Lang:t("info.plane_returned"))
    end
    TriggerServerEvent('pilotjob:server:PayShift')
end)

RegisterNetEvent('qb-pilotjob:client:MainMenu', function()
    if playerJob.name == Config.Jobname then
        local MainMenu = {}
        MainMenu[#MainMenu+1] = {isMenuHeader = true,header = Lang:t("menu.header")}
        MainMenu[#MainMenu+1] = { header = Lang:t("menu.collect"),txt = Lang:t("menu.return_collect"),params = { event = 'qb-pilotjob:client:RequestPaycheck',}}
        if not planeVehicle or finished then
            MainMenu[#MainMenu+1] = { header = Lang:t("menu.route"), txt = Lang:t("menu.request_route"), params = { event = 'qb-pilotjob:client:RequestRoute',}}
        end
        exports['qb-menu']:openMenu(MainMenu)
    else
        QBCore.Functions.Notify(Lang:t("error.job"))
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    playerJob = QBCore.Functions.GetPlayerData().job
    setupClient()
    spawnPeds()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(JobInfo)
    playerJob = JobInfo
    if planeBlip then
        RemoveBlip(planeBlip)
    end
    if endBlip then
        RemoveBlip(endBlip)
    end
    if deliveryBlip then
        RemoveBlip(deliveryBlip)
    end
    endBlip = nil
    deliveryBlip = nil
    setupClient()
    spawnPeds()
end)

AddEventHandler('onResourceStop', function(resource)
    if GetCurrentResourceName() == resource then
        if luggageObject then
            DeleteEntity(luggageObject)
            luggageObject = nil
        end
        deletePeds()
    end
end)

AddEventHandler('onResourceStart', function(resource)
    if GetCurrentResourceName() == resource then
        playerJob = QBCore.Functions.GetPlayerData().job
        setupClient()
        spawnPeds()
    end
end)