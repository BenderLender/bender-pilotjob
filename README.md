  Pilot Job :airplane:
-
I made this script based on the qb-garbagejob. It has been reworked into a pilot job with more configuration.
**Features**

- Fly planes around the map
- Load luggage onto plane
- Each luggage has a different value
- Must make a deposit for plane
- Only supports 1 plane model

**Configuration**
- Cost of each luggage (min/max)
- Easily adjust settings for different plane model
- Add more airport locations
- change luggage prop

**Installation**

- Go to qb-core\shared\jobs.lua
```
['pilot'] = {
		label = 'Airline Pilot',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
            ['0'] = {
                name = 'Pilot',
                payment = 100
            },
        },
	},
```
- Then, qb-cityhall\config.lua (if you dont want the job whitelisted)
```
["pilot"] = {["label"] = "Airline Pilot", ["isManaged"] = false}
```
**Requirements**

- QB-CORE
- QB-Targets
- QB-Cityhall
- Polyzones
