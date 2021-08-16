# lua-cron-nodemcu-esp32
A simple and powerful cron module for nodemcu/esp32 based and inspired on www.github.com/kedorlaomer/lua-cron <br/>
At the moment there is no esp32 nodemcu official support for cron module, as it is for esp8266. For those who want to get a cron module up and running by simply adding the lua file to your project, without the need to compiling it in the firmware... you have it! <br/>
The api is the same as in https://nodemcu.readthedocs.io/en/release/modules/cron/ <br/>

<code>cron.schedule(entry) </code> <br/>
<code>cron.reset() </code> <br/>

Cron masking is not currently supported. Instead, the cron entry format is the same as www.github.com/kedorlaomer/lua-cron, but including seconds part. <br/>

* <code>weekday</code> (1..7, Sunday is 1)
* <code>hour</code> (0..23)
* <code>minute</code> (0..59)
* <code>second</code> (0..59)
* <code>day</code> (1..31)
* <code>month</code> (1..12)

## Dependencies
* Nodemcu esp32 time module -> https://nodemcu.readthedocs.io/en/dev-esp32/modules/time/
* Nodemcu esp32 timer module -> https://nodemcu.readthedocs.io/en/dev-esp32/modules/tmr/

## Usage
In this example we first set the esp32 internal time and register 2 jobs. Job1 dynamically registers another job which will reset any registered entries,
and will reschedule another single job that will fire at a given time.

```lua
cron = require "cron"

job1 = {

    hour = "10",
    minute = "14",
    day = "1,17",
    second = "0",
    callback = function(entry, datetime)
        print "Going to work..."
        cron.schedule(job3)
    end
}

job2 = {
    hour = "10-15",
    minute = "14,16",
    second = "0,30",
    callback = function(entry, datetime)
        print("Yoga classes at " .. string.format("%02d:%02d:%02d", datetime.hour, datetime.min, datetime.sec))
    end
}

job3 = {
    hour = "10",
    minute = "15",
    second = "30",
    callback = function(entry, datetime)
        cron.reset()
        cron.schedule(job4)
    end
}

job4 = {
    hour = "10",
    minute = "17",
    second = "0",
    callback = function(entry, datetime)
        print("Build an efficient stove!")
    end
}

calendar = {}
calendar.year = 2020
calendar.mon = 10
calendar.day = 17
calendar.hour = 10
calendar.min = 13
calendar.sec = 55

timestamp = time.cal2epoch(calendar)
time.set(timestamp)

current = time.epoch2cal(time.get())
print(string.format("Current Time: %04d-%02d-%02d %02d:%02d:%02d DST:%d", current["year"], current["mon"],
    current["day"], current["hour"], current["min"], current["sec"], current["dst"]))

cron.schedule(job1)
cron.schedule(job2)

```

## Further info
You can find more info and tests of each of the internal functions on www.github.com/kedorlaomer/lua-cron. <br/>

*Deep thanks to @kerdolaomer for the nice working code =)*

