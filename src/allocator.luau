--[[
    Part of TinyPacket library. Licensed under MIT.

    @author: alpluspluss
]]
	
--!native
--!optimize 2

local capacity: number = 8
local data: buffer = buffer.create(capacity)
local size: number = 0
local refs: { unknown } = {}
local next_ref: number = 1

local GROWTH_MULTIPLIER: number = 2

local function malloc(sz: number): (buffer, number)
	if sz > capacity then
		capacity = math.max(math.floor(capacity * GROWTH_MULTIPLIER), sz)
		data = buffer.create(capacity)
		size = 0
	end

	local wi = size
	size += sz
	return data, wi
end

local function free(b: buffer)
	if b == data then
		capacity = 4
		data = buffer.create(capacity)
		size = 0
	end
end

local function write_ref(value: unknown): number
    local id = next_ref
    refs[id] = value
    next_ref += 1
    return id
end

local function get_ref(id: number): unknown?
    return refs[id]
end

local function get_refs(): {unknown}
    return refs
end

return {
	malloc = malloc,
	free = free,
	write_ref = write_ref,
    get_ref = get_ref,
    get_refs = get_refs,
	
	get_capacity = function() return capacity end,
	get_size = function() return size end
}