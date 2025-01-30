--[[
    Part of TinyPacket library. Licensed under MIT.

    Optimized for efficient storage of position deltas with
    minimal precision loss.

    @author: alpluspluss
    @note
        a typical vector3 costs 3 * 4 = 12 bytes
        optimized: 6 bytes | actual 5 & 1 from rtt
        50% memory reduction.

        most game updates usually involves small position changes rather
        than a big changes. the idea stems from taking advantages of spatial locality
        by storing relative movements rather than absolute positions i.e. 
         * absolute position: (1234.5678, 987.6543, 456.7890)
         * delta: (0.2, -0.1, 0.3) 
         * compressed delta: (2, -1, 3) when scaled by 10
        the code covers most fine-grained movement scenarios and provides
        0.1 unit precision with the range of ±3,276.8 units at scaled 
        precision.

        FYI: 0.1 is literally almost impossible to notice.
]]

--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local readi16 = buffer.readi16
local writei16 = buffer.writei16

-- // scaling factor to preserve decimal precision
-- // this allows fractional movements with keeping the memory compact
local SCALE = 10

local function read(b: buffer): Vector3
    local x = readi16(b, 0) / SCALE
	local y = readi16(b, 2) / SCALE
	local z = readi16(b, 4) / SCALE
	return Vector3.new(x, y, z)
end

local function write(v: Vector3)
    local x = math.clamp(math.floor(v.X * SCALE), -32768, 32767)
    local y = math.clamp(math.floor(v.Y * SCALE), -32768, 32767)
    local z = math.clamp(math.floor(v.Z * SCALE), -32768, 32767)

    local b = malloc(6)
    writei16(b, 0, x)
	writei16(b, 2, y)
	writei16(b, 4, z)
	return b
end

return {
    read = read,
    write = write
}