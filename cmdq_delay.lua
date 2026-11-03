-- ~/.hammerspoon/cmdq_delay.lua

local M = {}

------------------------------------------------------------
-- CONFIG
------------------------------------------------------------

local CMD_Q_DELAY = 0.5
local CMD_Q_STEPS = 30

local ACCENT = { red = 0.35, green = 0.68, blue = 1.00, alpha = 1.0 }

------------------------------------------------------------
-- STATE
------------------------------------------------------------

local cmdQTimer = nil
local cmdQCanvas = nil

------------------------------------------------------------
-- HELPERS
------------------------------------------------------------

local function stopCmdQ()
    if cmdQTimer then
        cmdQTimer:stop()
        cmdQTimer = nil
    end

    if cmdQCanvas then
        cmdQCanvas:delete()
        cmdQCanvas = nil
    end
end

local function centerFrameOnScreen(screenFrame, w, h)
    return {
        x = screenFrame.x + (screenFrame.w - w) / 2,
        y = screenFrame.y + (screenFrame.h - h) / 2,
        w = w,
        h = h
    }
end

------------------------------------------------------------
-- HOTKEY
------------------------------------------------------------

hs.hotkey.bind({"cmd"}, "q", function()
    stopCmdQ()

    local app = hs.application.frontmostApplication()
    if not app then
        return
    end

    local appName = app:name() or "Application"

    local startTime = hs.timer.absoluteTime()
    local durationNanos = CMD_Q_DELAY * 1e9

    local screen = hs.screen.mainScreen():frame()
    local canvasFrame = centerFrameOnScreen(screen, 320, 250)

    cmdQCanvas = hs.canvas.new(canvasFrame)
        :level(hs.canvas.windowLevels.floating)
        :behavior(hs.canvas.windowBehaviors.canJoinAllSpaces)
        :show()

    -- Background
    cmdQCanvas[1] = {
        type = "rectangle",
        action = "fill",
        fillColor = { white = 0.08, alpha = 0.92 }
    }

    -- Subtle border
    cmdQCanvas[2] = {
        type = "rectangle",
        action = "stroke",
        strokeWidth = 2,
        strokeColor = { white = 1, alpha = 0.10 }
    }

    -- Inner glow circle
    cmdQCanvas[3] = {
        type = "circle",
        action = "fill",
        fillColor = { white = 1, alpha = 0.05 },
        radius = 52,
        center = { x = 160, y = 78 }
    }

    cmdQCanvas[4] = {
        type = "circle",
        action = "stroke",
        strokeWidth = 8,
        strokeColor = { white = 1, alpha = 0.12 },
        radius = 58,
        center = { x = 160, y = 78 },
        strokeCapStyle = "round"
    }

    cmdQCanvas[5] = {
        type = "arc",
        action = "stroke",
        strokeWidth = 8,
        strokeColor = ACCENT,
        radius = 58,
        center = { x = 160, y = 78 },
        startAngle = -90,
        endAngle = -90,
        strokeCapStyle = "round"
    }

    -- Q symbol instead of app icon
    cmdQCanvas[6] = {
        type = "text",
        text = "",
        textSize = 34,
        textColor = { white = 1, alpha = 0.95 },
        textAlignment = "center",
        frame = { x = 100, y = 57, w = 120, h = 42 }
    }

    -- Title
    cmdQCanvas[7] = {
        type = "text",
        text = "Hold to Quit",
        textSize = 24,
        textColor = { white = 1, alpha = 0.95 },
        textAlignment = "center",
        frame = { x = 20, y = 135, w = 280, h = 30 }
    }

    -- App name
    cmdQCanvas[8] = {
        type = "text",
        text = appName,
        textSize = 18,
        textColor = { white = 1, alpha = 0.75 },
        textAlignment = "center",
        frame = { x = 20, y = 166, w = 280, h = 24 }
    }

    -- Countdown text
    cmdQCanvas[9] = {
        type = "text",
        text = string.format("Quitting in %.1fs", CMD_Q_DELAY),
        textSize = 17,
        textColor = { white = 1, alpha = 0.95 },
        textAlignment = "center",
        frame = { x = 20, y = 195, w = 280, h = 24 }
    }

    -- Hint text
    cmdQCanvas[10] = {
        type = "text",
        text = "Release to cancel",
        textSize = 14,
        textColor = { white = 1, alpha = 0.45 },
        textAlignment = "center",
        frame = { x = 20, y = 220, w = 280, h = 20 }
    }

    cmdQTimer = hs.timer.doEvery(CMD_Q_DELAY / CMD_Q_STEPS, function()
        if not cmdQCanvas then
            stopCmdQ()
            return
        end

        local elapsedNanos = hs.timer.absoluteTime() - startTime
        local progress = math.min(1, elapsedNanos / durationNanos)
        local remaining = math.max(0, CMD_Q_DELAY - (elapsedNanos / 1e9))

        if progress >= 1 then
            if app then
                app:kill()
            end

            stopCmdQ()
        else
            cmdQCanvas[5].endAngle = -90 + (360 * progress)
            cmdQCanvas[9].text = string.format("Quitting in %.1fs", remaining)
        end
    end)
end, function()
    stopCmdQ()
end)

return M