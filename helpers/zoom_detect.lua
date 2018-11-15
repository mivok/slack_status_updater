-- Hammerspoon script to automatically update your slack status when in zoom
--
-- To use:
--
-- * Install and set up the slack_status.sh script (make sure it's in your
--   path)
-- * Ensure there is a 'zoom' preset (one is created by default during setup)
-- * Install hammerspoon (brew cask install hammerspoon) if you don't have it
--   already.
-- * Copy this file to ~/.hammerspoon
-- * Add the following line to ~/.hammerspoon/init.lua
--      local zoom_detect = require("zoom_detect")

-- Configuration
check_interval=20 -- How often to check if you're in zoom, in seconds

-- Initialization
inzoom = nil
local lightbox = require("lightbox")
local logger = hs.logger.new("zoomdetect")

function update_status(status)
    task = hs.execute("slack_status.sh " .. status, true)
end

function on_air()
    inzoom = true
    hs.notify.show("Started zoom meeting", "Updating slack status", "")
    update_status("zoom")
    lightbox.on()
end

function off_air()
    inzoom = false
    hs.notify.show("Left zoom meeting", "Updating slack status", "")
    update_status("none")
    lightbox.off()
end

function isInMeeting()
    local zoom_app = hs.application.find("zoom.us")
    if zoom_app == nil then return false end
    return meeting_menu_is_present(zoom_app)
end

function meeting_menu_is_present(app)
    menu_items = app:getMenuItems()
    if menu_items == nil then return false end
    return menu_items[2]["AXTitle"] == "Meeting"
end

function meetingCheck()
    logger.d("check for meeting")
    if isInMeeting() then
        if inzoom == false or inzoom == nil then
            logger.i("going on air")
            on_air()
        end
    else
        if inzoom == true or inzoom == nil then
            logger.i("going off air")
            off_air()
        end
    end
end

meetingCheck()

zoomTimer = hs.timer.new(check_interval, meetingCheck)

function zoomWatcherCallback(appName, eventType, appObject)
    if (appName == "zoom.us") then
        logger.d("zoom called back with " .. eventType .. " event")
        if (eventType == hs.application.watcher.activated or
            eventType == hs.application.watcher.deactivated) then

            meetingCheck()
            if not zoomTimer:running() then
                logger.i("restarting timer to monitor in/out of meetings")
                zoomTimer:start()
            end
        elseif eventType == hs.application.watcher.launched then
            logger.i("starting timer to monitor in/out of meetings")
            zoomTimer:start()
        elseif eventType == hs.application.watcher.terminated then
            logger.i("stopping timer to monitor in/out of meetings")
            zoomTimer:stop()
            meetingCheck()
        end
    end
end

zoomWatcher = hs.application.watcher.new(zoomWatcherCallback)
zoomWatcher:start()
