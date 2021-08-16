local M, module = {}, ...

local function freeModule()
    package.loaded[module] = nil
    module = nil
end

local entries, cronTimer = {}, tmr.create()

-- returns a list of all elements matching the entry
local function enumerate_entry(entry)
    local parts = {}

    -- split into parts separated by comma
    while string.match(entry, ",") do
        head, entry = string.match(entry, "^(.-),(.*)$")
        table.insert(parts, head)
    end

    table.insert(parts, entry)

    local rv = {}

    -- deal with ranges
    for _, part in pairs(parts) do
        from, to = string.match(part, "^(%d-)%-(%d*)$")
        if from and to then
            for i = from, to do
                table.insert(rv, i)
            end
        else
            table.insert(rv, part)
        end
    end

    -- convert everything into numbers
    for i in pairs(rv) do
        rv[i] = 0 + rv[i]
    end

    return rv
end

local function expand_list(list)
    rv = {}
    for _, v in pairs(list) do
        rv[v] = true
    end

    return rv
end

-- `entry` is a table representing a cron entry using keys
--
-- * weekday (1..7, Sunday is 1)
-- * hour (0..23)
-- * minute (0..59)
-- * second (0..59)
-- * day (1..31)
-- * month (1..12)
-- callback(entry, datetime)
--
-- `parse_cronentry` returns a version more easily used
local function parse_cronentry(entry)
    local rv = {}
    rv.weekday = expand_list(enumerate_entry(entry.weekday or "1-7"))
    rv.hour = expand_list(enumerate_entry(entry.hour or "0-23"))
    rv.minute = expand_list(enumerate_entry(entry.minute or "0-59"))
    rv.second = expand_list(enumerate_entry(entry.second or "0-59"))
    rv.day = expand_list(enumerate_entry(entry.day or "1-31"))
    rv.month = expand_list(enumerate_entry(entry.month or "1-12"))
    rv.callback = entry.callback

    return rv
end

-- `cronentry` is a cronentry as constructed by
-- `parse_cronentry`; `date` is a date as constructed by
local function match_cronentry_with_date(cronentry, calDate)
    local rv = cronentry.weekday[calDate.wday] and cronentry.hour[calDate.hour] and cronentry.minute[calDate.min] and
                   cronentry.second[calDate.sec] and cronentry.day[calDate.day] and cronentry.month[calDate.mon]
    return not not rv
end


local function checkCronEntries()
    local datetime = time.epoch2cal(time.get())
    -- print(string.format("Current Time: %04d-%02d-%02d %02d:%02d:%02d DST:%d Weekday: %d", datetime["year"],
    --     datetime["mon"], datetime["day"], datetime["hour"], datetime["min"], datetime["sec"], datetime["dst"],
    --     datetime["wday"]))
    for i, v in pairs(entries) do
        if (match_cronentry_with_date(v, datetime)) then
            -- print("cron entry matched! -> " .. i)
            v.callback(v, datetime)
        end
    end
end

function M.schedule(entry, callback)
    if (#entries == 0) then
        -- print("Starting timer!")
        cronTimer:unregister()
        -- check cron entries every second
        cronTimer:register(1000, tmr.ALARM_AUTO, checkCronEntries)
        cronTimer:start()
    end
    entry.callback = callback
    local parsedEntry = parse_cronentry(entry)
    table.insert(entries, parsedEntry)
end

function M.reset()
    cronTimer:unregister()
    entries = {}
end

local function cron(entries, verbose)
    local extra = {}
    for i, v in pairs(entries) do
        extra[i] = {}
        extra[i].cronentry = parse_cronentry(v)
    end

end

return M
