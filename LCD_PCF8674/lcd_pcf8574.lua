local moduleName = ...

local M = {}
_G[moduleName] = M 

-- Constants.
local address = 0x27
local cols = 16
local rows = 2

-- Default value for i2c communication.
local id = 0
local speed = i2c.SLOW

-- Initialization values.
local backlight = 1 -- 0 - off, 1 - on

local function LcdBusy()
    --local result
    --local value = bit.lshift(backlight, 3)
    --value = value + bit.lshift(1, 2)
    --value = value + bit.lshift(1, 1)

    --i2c.start(id)
    --i2c.address(id, address, i2c.TRANSMITTER)
    --i2c.write(id, value)
    --i2c.stop(id)

    --i2c.start(id)
    --i2c.address(id, address, i2c.RECEIVER)
    --result = tonumber(string.byte(i2c.read(id,1)))
    --i2c.stop(id)

    --i2c.start(id)
    --i2c.address(id, address, i2c.TRANSMITTER)
    --i2c.write(id, value - 4, value, value - 4)
    --i2c.stop(id)

    --if bit.rshift(result, 7) == 0 then return false else return true end
    tmr.delay(800)
    return false
end

local function sendLcdToI2C(data, rs, e)
    local value = rs
    value = value + bit.lshift(e, 2)
    value = value + bit.lshift(backlight, 3)
    value = value + data
    i2c.write(id, value)
end

local function sendLcdRaw(data, rs)
    i2c.start(id)
    i2c.address(id, address, i2c.TRANSMITTER)
    sendLcdToI2C(data, rs, 1)
    sendLcdToI2C(data, rs, 0)
    i2c.stop(id)
end

local function sendLcd(data, rs)
    while LcdBusy() do end
    sendLcdRaw(bit.band(data, 0xf0), rs) -- high nibble
    sendLcdRaw(bit.lshift(bit.band(data, 0x0f), 4), rs)  -- low nibble
end

function M.begin(pinSDA, pinSCL, lcdColumns, lcdRows, addr)
    address = addr or address
    cols = lcdColumns or cols
    rows = lcdRows or rows

    i2c.setup(id, pinSDA, pinSCL, speed)

    -- reset
    sendLcdRaw(0x30, 0)
    tmr.delay(4500)
    sendLcdRaw(0x30, 0)
    tmr.delay(150)
    sendLcdRaw(0x30, 0)

    while LcdBusy() do end

    -- set to 4-bit mode
    sendLcdRaw(0x20, 0)

    -- set to 2-line mode (TODO read args)
    sendLcd(0x28, 0)

    -- turn off display
    --sendLcd(0x08, 0)

    -- turn on display
    sendLcd(0x0C, 0)

    -- turn on increments and shifting
    sendLcd(0x06, 0)

    -- clear display
    sendLcd(0x01, 0)

    -- return home
    sendLcd(0x02, 0)
end

function M.write(ch)
    sendLcd(string.byte(ch, 1), 1)
end

function M.print(s)
    for i = 1, #s do
        sendLcd(s:byte(i), 1)
    end
end

M.ROW_OFFSETS = {0, 0x40, 0x14, 0x54}

function M.setCursor(col, row)
    local val = bit.bor(0x80, col, M.ROW_OFFSETS[row + 1])
    sendLcd(val, 0)
end

function M.setBacklight(on)
    if on == 0 then
        backlight = 0
    else
        backlight = 1
    end
    sendLcdRaw(0, 0)
end

function M.clear()
    sendLcd(0x01, 0)
end

function M.define(index, bytes)
    sendLcd(0x40 + 8 * bit.band(index, 0x07), 0)
    for i = 1, #bytes do
        sendLcd(bytes[i], 1)
    end
end

function M.scroll(row, s, timer, _delay, callback)
    _delay = _delay or 40
    tmr.stop(timer)
    local i = cols
    local runner = function()
        M.setCursor(i >= 0 and i or 0, row)
        M.print(i >= 0 and s:sub(1, cols - i) or s:sub(1 - i, cols - i))
        M.print(" ")
        if i == -#s then
            if type(callback) == "function" then
                tmr.stop(timer)
                callback()
            else
                i = cols
            end
        else
            i = i - 1
        end
    end
    tmr.alarm(timer, _delay, 1, runner)
end

return M
