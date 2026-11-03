-- capslock_delay_fix.lua
-- Reset CapsLockDelayOverride whenever Hammerspoon starts and whenever the screen is unlocked.

local function resetCapsLockDelay()
    hs.task.new("/usr/bin/hidutil", nil, {
        "property", "--set", '{"CapsLockDelayOverride":0}'
    }):start()
end

capsLockDelayWatcher = hs.caffeinate.watcher.new(function(eventType)
    if eventType == hs.caffeinate.watcher.screensDidUnlock
        or eventType == hs.caffeinate.watcher.sessionDidBecomeActive then
        resetCapsLockDelay()
    end
end)

capsLockDelayWatcher:start()

resetCapsLockDelay()
