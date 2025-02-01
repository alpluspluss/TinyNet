--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]

--!native
--!optimize 2

local allocator = require(script.Parent.Parent.allocator)
local malloc = allocator.malloc

local readu8 = buffer.readu8
local writeu8 = buffer.writeu8
local copy = buffer.copy
local len = buffer.len
local create = table.create

local value_buffers = create(32)
local buffer_sizes = create(32)

local function read<T>(b: buffer, value_reader: (buffer, number) -> (T, number)): { T }
	local arr_length = readu8(b, 0)
	local cursor = 1
	local arr = create(arr_length)

	for i = 1, arr_length do
		local value, value_size = value_reader(b, cursor)
		arr[i] = value
		cursor += value_size
	end
	return arr
end 

local function write<T>(arr: { T }, value_writer: (T) -> buffer): buffer
	local length = #arr
	if length > 255 then
		error("Array too large (>255 elements)")
	end

	if #value_buffers > 0 then
		table.clear(value_buffers)
		table.clear(buffer_sizes)
	end

	local total_size = 1
	for i = 1, length do
		local value_buffer = value_writer(arr[i])
		value_buffers[i] = value_buffer
		local buf_size = len(value_buffer)
		buffer_sizes[i] = buf_size
		total_size += buf_size
	end

	local b = malloc(total_size)
	writeu8(b, 0, length)
	local offset = 1
	for i = 1, length do
		local value_buffer = value_buffers[i]
		copy(b, offset, value_buffer)
		offset += buffer_sizes[i]
	end

	return b
end

return function<T>(value_type: { 
	read: (buffer, number) -> (T, number),
	write: (T) -> buffer 
	})
	return {
		read = function(b: buffer)
			return read(b, value_type.read)
		end,
		write = function(arr: { T })
			return write(arr, value_type.write)
		end
	}
end