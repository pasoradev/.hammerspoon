-- snip.lua
-- Port of the Raycast "Snip" extension.
-- Cmd+Shift+S freezes the main screen, then lets you crop a region to the clipboard.

local M = {}

local snipCanvas = nil
local snipTask = nil

local function cleanup()
    if snipCanvas then
        snipCanvas:delete()
        snipCanvas = nil
    end
    snipTask = nil
end

local function startSnip()
    -- Ignore the hotkey while a snip is already running.
    if snipTask then
        return
    end

    local screen = hs.screen.mainScreen()
    local image = screen and screen:snapshot()

    if not image then
        hs.notify.new({
            title = "Snip failed",
            informativeText = "Could not capture the screen. Check Screen Recording permission for Hammerspoon."
        }):send()
        return
    end

    -- Show the frozen image over the whole main screen.
    snipCanvas = hs.canvas.new(screen:fullFrame())
        :level(hs.canvas.windowLevels.screenSaver)
        :behavior({ "canJoinAllSpaces", "fullScreenAuxiliary" })

    snipCanvas[1] = {
        type = "image",
        image = image,
        imageScaling = "scaleToFit",
        frame = { x = 0, y = 0, w = "100%", h = "100%" }
    }

    snipCanvas:show()

    -- Interactive crop on top of the frozen image; result goes to the clipboard.
    snipTask = hs.task.new("/usr/sbin/screencapture", function()
        cleanup()
    end, { "-i", "-c" })

    if not snipTask:start() then
        cleanup()
        hs.notify.new({
            title = "Snip failed",
            informativeText = "Could not start screencapture."
        }):send()
    end
end

hs.hotkey.bind({ "cmd", "shift" }, "s", startSnip)

return M
