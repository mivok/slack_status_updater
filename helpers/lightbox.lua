local logger = hs.logger.new("lightbox")
local lightmenu = hs.menubar.new()

-- these two variables are currently hardcoded to my
-- Apple Keyboard's USB id to manage its left USB port
local vendor_product_id = "1452:591"
local usb_command = "uhubctl --vendor 05ac --ports 1 "

function lightboxSet(lit)
    if lit then
        local output, status, type, rc = hs.execute(usb_command .. "--action on", true)
        logger.d(output)
        lightmenu:setTitle("💡")
        lightmenu:setTooltip("The light is lit.")
        logger.i("turn on the light")
    else
        local output, status, type, rc = hs.execute(usb_command .. "--action off", true)
        logger.d(output)
        lightmenu:setTitle("⚫️")
        lightmenu:setTooltip("The light is off.")
        logger.i("turn off the light")
    end
end

function lightboxGet()
    local output, status, type, rc = hs.execute(usb_command .. ' | grep Port | grep power', true)
    return rc == 0
end

function lightboxToggle()
    local current = lightboxGet()
    if (current == nil) then
        return nil
    end
    lightboxSet(not current)
    return lightboxGet()
end

function isLightboxUSB(vendorID, productID)
    return vendorID .. ':' .. productID == vendor_product_id
end

function pluggedIn()
    for _, dev in ipairs(hs.usb.attachedDevices()) do
        if isLightboxUSB(dev["vendorID"], dev["productID"]) then
            return true
        end
    end

    return false
end

function usbDeviceCallback(data)
    if isLightboxUSB(data["vendorID"], data["productID"]) then
        if data["eventType"] == "added" then
            logger.i("Apple Keyboard hub just plugged in. Turning off the light.")
            lightmenu:returnToMenuBar()
            lightboxSet(false)
        elseif data["eventType"] == "removed" then
            logger.i("Apply Keyboard hub unplugged. Removing menubar icon.")
            lightmenu:removeFromMenuBar()
        end
    end
end

lightmenu:setTitle("❓")
lightmenu:setClickCallback(lightboxToggle)

if pluggedIn() then
    lightmenu:returnToMenuBar()
else
    lightmenu:removeFromMenuBar()
end

usbWatcher = hs.usb.watcher.new(usbDeviceCallback)
usbWatcher:start()

local M = {}

function M.on()
  lightboxSet(true)
end

function M.off()
  lightboxSet(false)
end

function M.toggle()
  lightboxToggle()
end

return M
