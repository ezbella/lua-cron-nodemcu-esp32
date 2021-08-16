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

-- we set a random time and register 2 jobs. 
-- Job1 dynamically registers another job which will reset any registered entries,
-- and reschedules another single job that will fire at a given time.

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

