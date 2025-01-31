--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]

--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local function read(b: buffer, offset: number): (boolean, number)
    return buffer.readu8(b, offset) == 1, 1
end

local function write(v: boolean): buffer
    local b = malloc(1)
    buffer.writeu8(b, 0, v and 1 or 0)
    return b
end

return {
	read = read,
	write = write
}