--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]
    
--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local readu8 = buffer.readu8
local writeu8 = buffer.writeu8
local copy = buffer.copy
local len = buffer.len

local function read<T>(b: buffer, value_reader: (buffer, number) -> (T, number)): (T?, number)
    local exists = readu8(b, 0) == 1
    if not exists then
        return nil, 1
    end
    
    local value, bytes_read = value_reader(b, 1)
    return value, bytes_read + 1
end

local function write<T>(v: T?, value_writer: (T) -> buffer): buffer
    local exists = v ~= nil
    
    if not exists then
        local b = malloc(1)
        writeu8(b, 0, 0)
        return b
    end
    
    local value_buffer = value_writer(v :: T)
    local b = malloc(1 + len(value_buffer))
    writeu8(b, 0, 1)
    copy(b, 1, value_buffer)
    return b
end

return {
    read = read,
    write = write
}