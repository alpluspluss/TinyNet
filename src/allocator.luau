--!native
--!optimize 2

local capacity: number = 8
local data: buffer = buffer.create(capacity)
local size: number = 0

local GROWTH_MULTIPLIER: number = 2

local function malloc(sz: number): (buffer, number)
	if sz > capacity then
		capacity = math.max(math.floor(capacity * GROWTH_MULTIPLIER), sz)
		data = buffer.create(capacity)
		size = 0
	end

	local writeIndex = size
	size += sz
	return data, writeIndex
end

local function free(b: buffer)
	if b == data then
		capacity = 4
		data = buffer.create(capacity)
		size = 0
	end
end

return {
	malloc = malloc,
	free = free,
	get_capacity = function() return capacity end,
	get_size = function() return size end
}