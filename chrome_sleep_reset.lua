-- chrome_sleep_reset.lua
-- Quit Chrome after waking if the Mac was asleep for 2+ hours.

local sleepStartedAt = nil
local sleepThresholdSeconds = 2 * 60 * 60 -- 2 hours

local function quitChrome()
    local chrome = hs.application.get("Google Chrome")

    if chrome then
        chrome:kill()

        hs.notify.new({
            title = "Chrome reset",
            informativeText = "Closed Chrome after 2+ hours of sleep."
        }):send()
    end
end

chromeSleepResetWatcher = hs.caffeinate.watcher.new(function(eventType)
    if eventType == hs.caffeinate.watcher.systemWillSleep then
        sleepStartedAt = os.time()

    elseif eventType == hs.caffeinate.watcher.systemDidWake then
        if sleepStartedAt then
            local sleptFor = os.time() - sleepStartedAt

            if sleptFor >= sleepThresholdSeconds then
                quitChrome()
            end

            sleepStartedAt = nil
        end
    end
end)

chromeSleepResetWatcher:start()