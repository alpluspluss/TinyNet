--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]
    
--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local readu8 = buffer.readu8
local writeu8 = buffer.writeu8

local function read(b: buffer, offset: number): (string, number)
    local len = readu8(b, offset)
    local str = buffer.readstring(b, offset + 1, len)
    return str, len + 1
end

local function write(str: string): buffer
    local len = #str
    local b = malloc(1 + len)
    writeu8(b, 0, len)
    buffer.writestring(b, 1, str)
    return b
end

return {
    read = read,
    write = write
}