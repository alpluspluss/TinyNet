--[[
    Part of TinyPacket library. Licensed under MIT.

    @author: alpluspluss
]]
    
--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local readu8 = buffer.readu8
local writeu8 = buffer.writeu8

local function read(b: buffer): (string, number)
    local len = readu8(b, 0)
    local chrs = table.create(len)
    for i = 1, len do
        chrs[i] = string.char(readu8(b, i))
    end
    return table.concat(chrs), len
end

local function write(str: string): buffer
    local len = #str -- // you shouldn't send a longass string whe networking anyway
    local b = malloc(1 + len) -- // 1 byte for length and rest for content
    writeu8(b, 0, len)
    for i = 1, len do
        writeu8(b, i, string.byte(str, i))
    end
    return b
end

return {
    read = read,
    write = write
}
