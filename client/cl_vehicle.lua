-- Vehicle widget made with the builder, shown while the player drives.
-- Page 1 copies the GTA 6 statistics card, page 2 shows live values updated with SetRow.

ExampleVehicle = {}

local menu = nil
local current = nil

local LIVE_PAGE = 1

local function getStats(vehicle)
    local model = GetEntityModel(vehicle)
    local maxSpeed = GetVehicleModelEstimatedMaxSpeed(model)

    local stats = {
        speed = Example.Clamp(maxSpeed / 60.0, 0.0, 1.0),
        acceleration = Example.Clamp(GetVehicleModelAcceleration(model) / 0.5, 0.0, 1.0),
        braking = Example.Clamp(GetVehicleModelMaxBraking(model) / 1.6, 0.0, 1.0),
        traction = Example.Clamp(GetVehicleModelMaxTraction(model) / 3.5, 0.0, 1.0),
        maxSpeed = maxSpeed,
    }
    stats.rating = math.floor((stats.speed + stats.acceleration + stats.braking + stats.traction) / 4 * 1000 + 0.5)

    return stats
end

local function engineTone(health)
    if health <= 0.3 then return 'danger' end
    if health <= 0.6 then return 'warning' end
    return 'safe'
end

local function build(vehicle)
    local model = GetEntityModel(vehicle)
    local brand = Example.Label(GetMakeNameFromVehicleModel(model))
    local name = Example.Label(GetDisplayNameFromVehicleModel(model))
    local stats = getStats(vehicle)
    local health = Example.Clamp(GetVehicleEngineHealth(vehicle) / 1000.0, 0.0, 1.0)

    local widget = HelpMenu.new('example_vehicle', {
        position = Example.GetPosition(Config.Vehicle.position),
    })
        :Header(brand, name, { watermark = brand })

    widget:Page('Statistics', 'gauge', 'stats')
        :Slider('Speed', stats.speed * 10, { max = 10 })
        :Slider('Acceleration', stats.acceleration * 10, { max = 10 })
        :Slider('Braking', stats.braking * 10, { max = 10 })
        :Slider('Traction', stats.traction * 10, { max = 10 })
        :Footer('Rating', {
            { value = tostring(stats.rating), icon = 'trophy' },
            { value = Example.FormatSpeed(stats.maxSpeed), icon = 'gauge' },
        })

    widget:Page('Live', 'activity', 'live')
        :Bar('Speed', 0, { id = 'speed', max = math.max(stats.maxSpeed, 1.0), display = Example.FormatSpeed(0) })
        :Bar('RPM', 0, { id = 'rpm' })
        :Text('Gear', 'N', { id = 'gear', icon = 'cog', scramble = false })
        :Bar('Engine', health, { id = 'engine', tone = engineTone(health) })

    local locked = GetVehicleDoorLockStatus(vehicle) > 1
    widget:Page('Info', 'info', 'info')
        :Text('Plate', GetVehicleNumberPlateText(vehicle))
        :Text('Class', Example.Label(('VEH_CLASS_%d'):format(GetVehicleClass(vehicle))), { icon = 'car-front' })
        :Text('Seats', GetVehicleModelNumberOfSeats(model), { icon = 'armchair' })
        :Text('Doors', locked and 'Locked' or 'Open', {
            icon = locked and 'key-round' or 'lock-open',
            tone = locked and 'danger' or 'safe',
        })

    return widget
end

local function updateLive(vehicle)
    local speed = GetEntitySpeed(vehicle)
    local gear = GetVehicleCurrentGear(vehicle)
    local health = Example.Clamp(GetVehicleEngineHealth(vehicle) / 1000.0, 0.0, 1.0)

    menu:SetRow('speed', { value = speed, display = Example.FormatSpeed(speed) })
    menu:SetRow('rpm', { value = Example.Round(GetVehicleCurrentRpm(vehicle), 2) })
    menu:SetRow('gear', { value = gear == 0 and 'R' or tostring(gear) })
    menu:SetRow('engine', { value = Example.Round(health, 2), tone = engineTone(health) })
end

function ExampleVehicle.Show(vehicle)
    current = vehicle
    menu = build(vehicle):Show()
end

function ExampleVehicle.Hide()
    if menu then menu:Hide() end
    menu = nil
    current = nil
end

function ExampleVehicle.SetPosition(position)
    if not menu then return end
    menu:Position(position):Refresh()
end

AddEventHandler('sxHelpMenu:pageChanged', function(id, page)
    if id == 'example_vehicle' and page == LIVE_PAGE and current then
        updateLive(current)
    end
end)

CreateThread(function()
    if not Config.Vehicle.enabled then return end

    local lastValues = nil

    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local driving = vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped

        if driving and vehicle ~= current then
            ExampleVehicle.Hide()
            ExampleVehicle.Show(vehicle)
            lastValues = nil
        elseif not driving and current then
            ExampleVehicle.Hide()
        end

        if menu and menu:GetPage() == LIVE_PAGE then
            local values = ('%d:%d:%d'):format(
                math.floor(GetEntitySpeed(vehicle) * 3.6),
                GetVehicleCurrentGear(vehicle),
                math.floor(GetVehicleCurrentRpm(vehicle) * 20)
            )
            if values ~= lastValues then
                lastValues = values
                updateLive(vehicle)
            end
        end

        Wait(current and Config.Vehicle.refresh or 500)
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        ExampleVehicle.Hide()
    end
end)
