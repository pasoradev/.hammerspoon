-- Water reminder
local waterInterval = 10 * 60  -- minutes * 60 = seconds; change 45 to whatever you want

local waterMessages = {
  "Drink some water 💧",
  "Hydration check — grab that glass",
  "Sip time. Your brain will thank you",
  "Water break. Stand up, stretch, drink",
}

-- Tracks whether the screen is currently locked/asleep (e.g. lid closed),
-- so we don't fire reminders while you're away.
local screenUnavailable = false

local caffeineWatcher = hs.caffeinate.watcher.new(function(eventType)
  local caff = hs.caffeinate.watcher
  if eventType == caff.screensDidLock
    or eventType == caff.screensDidSleep
    or eventType == caff.sessionDidResignActive
  then
    screenUnavailable = true
  elseif eventType == caff.screensDidUnlock
    or eventType == caff.screensDidWake
    or eventType == caff.sessionDidBecomeActive
  then
    screenUnavailable = false
  end
end)
caffeineWatcher:start()

local waterTimer = hs.timer.new(waterInterval, function()
  if screenUnavailable then return end

  local msg = waterMessages[math.random(#waterMessages)]
  hs.notify.new({
    title = "💧 Hydrate",
    informativeText = msg,
    withdrawAfter = 0,  -- stay until dismissed
  }):send()
end)

waterTimer:start()

-- Menu bar toggle so you can pause it (e.g. during meetings)
local waterMenu = hs.menubar.new()
waterMenu:setTitle("💧")

local function updateWaterMenu()
  waterMenu:setMenu({
    { title = waterTimer:running() and "Pause reminders" or "Resume reminders",
      fn = function()
        if waterTimer:running() then waterTimer:stop() else waterTimer:start() end
        updateWaterMenu()
      end },
    { title = "Drink now", fn = function()
        hs.notify.new({ title = "💧 Hydrate", informativeText = "Manual reminder" }):send()
      end },
  })
end
updateWaterMenu()
