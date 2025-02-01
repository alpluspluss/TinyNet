--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]
    
--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local readu16 = buffer.readu16
local writeu16 = buffer.writeu16

local function read(b: buffer, offset: number): (string, number)
    local len = readu16(b, offset)
    local str = buffer.readstring(b, offset + 2, len)
    return str, len + 2
end

local function write(str: string): buffer
    local len = #str
    local b = malloc(2 + len)
    writeu16(b, 0, len)
    buffer.writestring(b, 2, str)
    return b
end

return {
    read = read,
    write = write
}