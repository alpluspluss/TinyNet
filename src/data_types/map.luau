--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]

--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc
local string_type = require(script.Parent.smallstr)

local readu8 = buffer.readu8
local writeu8 = buffer.writeu8
local copy = buffer.copy
local len = buffer.len

local key_buffers = {}
local value_buffers = {}
local buffer_sizes = {}

return function<T>(value_types: { [string]: { 
	read: (buffer, number) -> (any, number),
	write: (T) -> buffer 
	}})
	local function read(b: buffer, offset: number): ({ [string]: any }, number)
		local map = {}
		local cursor = offset

		local map_length = readu8(b, cursor)
		cursor += 1

		for _ = 1, map_length do
			local k, k_sz = string_type.read(b, cursor)
			cursor += k_sz
			local type_handler = value_types[k]
			if type_handler then
				local v, v_sz = type_handler.read(b, cursor)
				cursor += v_sz
				map[k] = v
			end
		end
		return map, cursor - offset
	end

	local function write(map: { [string]: any }): buffer
		local count = 0
		local total_size = 1

		if #key_buffers > 0 then
			table.clear(key_buffers)
			table.clear(value_buffers)
			table.clear(buffer_sizes)
		end

		for k, v in map do
			local type_handler = value_types[k]
			if type_handler then
				count += 1
				local key_buffer = string_type.write(k)
				local value_buffer = type_handler.write(v)
				key_buffers[count] = key_buffer
				value_buffers[count] = value_buffer

				local combined_size = len(key_buffer) + len(value_buffer)
				buffer_sizes[count] = combined_size
				total_size += combined_size
			end
		end

		local b = malloc(total_size)
		local offset = 0
		writeu8(b, offset, count)
		offset += 1
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
end