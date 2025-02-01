--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]
    
--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local readi16 = buffer.readi16
local writei16 = buffer.writei16

local SCALE = 10

local function read(b: buffer, offset: number): (Vector2, number)
    local x = readi16(b, offset) / SCALE
    local y = readi16(b, offset + 2) / SCALE
    return Vector2.new(x, y), 4
end

local function write(v: Vector2): buffer
    local x = math.clamp(math.floor(v.X * SCALE), -32768, 32767)
    local y = math.clamp(math.floor(v.Y * SCALE), -32768, 32767)

    local b = malloc(4)
    writei16(b, 0, x)
    writei16(b, 2, y)
    return b
end

return {
    read = read,
    write = write
}