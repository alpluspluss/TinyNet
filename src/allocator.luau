--[[
    Part of TinyNet library. Licensed under MIT.
    @author: alpluspluss
]]

--!native
--!optimize 2

local capacity: number = 1
local data: buffer = buffer.create(capacity)
local size: number = 0
local refs: { unknown } = {}
local next_ref: number = 1

-- // MAYBE-TODO: buffer reuse
-- // was actually planning to be awesome but breh
-- // too much of a hassle; Roblox GC should handle 
-- // this fine
local function malloc(sz: number): (buffer, number)
	return buffer.create(sz), 0
end

local function free(b: buffer)
	if b == data then
		capacity = 1
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