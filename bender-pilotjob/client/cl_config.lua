Config = {}

Config.UseTarget = GetConvar('UseTarget', 'false') == 'true'
Config.Jobname = 'pilot'
-- Price taken and given back when delivered a truck
Config.PlanePrice = 3200

-- How many stops minimum should the job roll?
Config.MinStops = 2

-- Upper worth per bag
Config.BagUpperWorth = 350

-- Lower worth per bag
Config.BagLowerWorth = 220

-- Minimum bags per stop
Config.MinBagsPerStop = 3

-- Maximum bags per stop
Config.MaxBagsPerStop = 6

-- Location on plane (entity) to where you load the luggage (different on each plane)
Config.DropOff = 0.0, 2.5, 0.0

-- How close do you have to be to the plane to load the luggage
Config.NearDropOff = 4

-- What Prop of luggage do you want to use?
Config.PropType = "info.load_luggage"

Config.Peds = {
    {
        model = 's_m_y_garbage',
        coords = vector4(-941.52, -2955.23, 13.0, 153.1),
        zoneOptions = { -- Used for when UseTarget is false
            length = 3.0,
            width = 3.0
        }
    }
}

Config.Locations = {
    ["main"] = {
        label = "Airline Hangar",
        coords = vector3(-962.7, -2996.86, 13.95),
    },
    ["vehicle"] = {
        label = "Plane Parking",
        coords = { -- parking spot locations to spawn plane
            [1] = vector4(-987.74, -3002.0, 13.95, 60.54),
            [2] = vector4(-974.12, -2978.34, 13.95, 60.54),
        },
    },
    ["paycheck"] = {
        label = "Payslip Collection",
        coords = vector3(-930.73, -2957.48, 13.95),
    },
    ["luggage"] ={
        [1] = {
            name = "LSIA",
            coords = vector4(-1271.58, -2851.47, 13.95, 189.76),
        },
        [2] = {
            name = "Sandy Airfield",
            coords = vector4(1711.97, 3274.76, 41.15, 280.93),
        },
        [3] = {
            name = "Military Base",
            coords = vector4(-2116.09, 3126.93, 32.81, 242.52),
        },
    },
}

Config.Vehicle = 'miljet' -- vehicle name used to spawn