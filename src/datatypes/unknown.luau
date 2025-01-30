--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]
    
--!native
--!optimize 2

local allocator = require(script.Parent.Parent.allocator)
local malloc = allocator.malloc
local write_ref = allocator.write_ref
local get_ref = allocator.get_ref

local function read(b: buffer, offset: number): (any, number)
   local ref_id = buffer.readu8(b, offset)
   return get_ref(ref_id), 1
end

local function write(value: unknown): buffer
   local ref_id = write_ref(value)
   local b, offset = malloc(1)
   buffer.writeu8(b, offset, ref_id)
   return b
end

return {
   read = read,
   write = write
}