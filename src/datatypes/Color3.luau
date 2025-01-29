--[[
    Part of TinyPacket library. Licensed under MIT.

    Optimized color serialization with efficient bit packing.

    @author: alpluspluss
    @note
        standard Color3 representation: 3 * 4 = 12 bytes
        optimized representation: 3 bytes
        75% memory reduction.

        most color representations in games/graphics don't require 
        floating-point precision for every pixel. the implementation 
        takes advantage of the fact that the 8-bit color channels 
        are naturally 0-255 integers and floating-point is unnecessary

        conversion happens in a packed single integer with bit32.extract():
         * red in bits 16-23 (MSB)
         * green in bits 8-15 (MB)
         * blue in bits 0-7 (LB)

        this provides us constant-time conversion with minimal computational
        overhead.
]]

--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local function read(buf: buffer): Color3
	local packed = bit32.bor(
		bit32.lshift(buffer.readu8(buf, 0), 16),
		bit32.lshift(buffer.readu8(buf, 1), 8),
		buffer.readu8(buf, 2)
	)
	return Color3.fromRGB(
		bit32.extract(packed, 16, 8),
		bit32.extract(packed, 8, 8),
		bit32.extract(packed, 0, 8)
	)
end

local function write(v: Color3): buffer
	local packed = bit32.bor(
		bit32.lshift(math.round(v.R * 255), 16),
		bit32.lshift(math.round(v.G * 255), 8),
		math.round(v.B * 255)
	)
	local b = malloc(3)
	buffer.writeu8(b, 0, bit32.extract(packed, 16, 8))
	buffer.writeu8(b, 1, bit32.extract(packed, 8, 8))
	buffer.writeu8(b, 2, bit32.extract(packed, 0, 8))
	return b
end

return {
    read = read,
    write = write
}