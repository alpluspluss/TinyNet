--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]
    
--!native
--!optimize 2

local allocator = require(script.Parent.Parent.allocator)
local malloc = allocator.malloc
local string_type = require(script.Parent.string)
local unknown_type = require(script.Parent.unknown)

local readu16 = buffer.readu16
local writeu16 = buffer.writeu16
local copy = buffer.copy
local len = buffer.len

local key_buffers = {}
local value_buffers = {}
local buffer_sizes = {}

local function read(b: buffer, offset: number): ({[string]: unknown}, number)
    local map = {}
    local cursor = offset

    local map_length = readu16(b, cursor)
    cursor += 2

    for _ = 1, map_length do
        local k, k_sz = string_type.read(b)
        cursor += k_sz

        local v, v_sz = unknown_type.read(b, cursor)
        cursor += v_sz
        map[k] = v
    end
    
    return map, cursor - offset
end

local function write(map: { [string]: unknown }): buffer
    local count = 0
    local total_size = 2  -- // 2 bytes for length; im looking at you ECS mfers who keep sending the whole world

    -- // guard against growing memo
    if #key_buffers > 0 then
        table.clear(key_buffers)
        table.clear(value_buffers)
        table.clear(buffer_sizes)
    end

    for k, v in map do
        count += 1
        local key_buffer = string_type.write(k)
        local value_buffer = unknown_type.write(v)
        key_buffers[count] = key_buffer
        value_buffers[count] = value_buffer
        
        local combined_size = len(key_buffer) + len(value_buffer)
        buffer_sizes[count] = combined_size
        total_size += combined_size
    end
    
    local b, offset = malloc(total_size)
    writeu16(b, offset, count)
    offset += 2
    for i = 1, count do
        local key_buffer = key_buffers[i]
        local value_buffer = value_buffers[i]
        
        copy(b, offset, key_buffer)
        offset += len(key_buffer)
        copy(b, offset, value_buffer)
        offset += len(value_buffer)
    end
    
    return b
end

return {
    read = read,
    write = write
}