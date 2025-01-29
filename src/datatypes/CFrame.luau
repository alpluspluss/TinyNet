--[[
    Part of TinyPacket library. Licensed under MIT.

    Optimized CFrame serialization with compact rotation representation.

    @author: alpluspluss
    @note
        standard CFrame representation: potentially 12 * 4 = 48 bytes
        optimized representation: 15 bytes
        68.75% memory reduction.

        rotation compression strategy:
         * stores all three rotation components (pitch, yaw, and roll)
         * uses one byte per component (0-255) to represent full 2π radian rotation
         * maps byte value to a full 2π radian rotation

        compression techniques:
         * position stored as standard 32-bit floats (x, y, z)
         * rotation extracted using ToEulerAnglesXYZ
         * single-byte encoding for each rotation angle (pitch, yaw, roll)

        trade-offs:
         * 2π/256 ≈ 0.0245 rad = 1.4 degree precision per rotation step
         * ideal for scenarios where sub-degree precision isn't critical

        FYI: 1.4 degree precision is basically unnoticeable in most games.

		MAYBE-TODO: Use partial bytes to store pitch, yaw, roll to reduce the memory from 15B to 12-13B
]]

--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local function write(v: CFrame): buffer
	local pos = v.Position
	local pitch, yaw, roll = v:ToEulerAnglesXYZ()

	local pitch_byte = math.floor(((pitch + math.pi) / (2 * math.pi)) * 255)
	local yaw_byte = math.floor(((yaw + math.pi) / (2 * math.pi)) * 255)
	local roll_byte = math.floor(((roll + math.pi) / (2 * math.pi)) * 255)

	local b = malloc(15)
	buffer.writef32(b, 0, pos.X)
	buffer.writef32(b, 4, pos.Y)
	buffer.writef32(b, 8, pos.Z)
	buffer.writeu8(b, 12, pitch_byte)
	buffer.writeu8(b, 13, yaw_byte)
	buffer.writeu8(b, 14, roll_byte)
	return b
end

local function read(b: buffer): CFrame
	local x = buffer.readf32(b, 0)
	local y = buffer.readf32(b, 4)
	local z = buffer.readf32(b, 8)

	local pitch_byte = buffer.readu8(b, 12)
	local yaw_byte = buffer.readu8(b, 13)
	local roll_byte = buffer.readu8(b, 14)

	local pitch = (pitch_byte / 255) * (2 * math.pi) - math.pi
	local yaw = (yaw_byte / 255) * (2 * math.pi) - math.pi
	local roll = (roll_byte / 255) * (2 * math.pi) - math.pi

	return CFrame.new(x, y, z) * CFrame.Angles(pitch, yaw, roll)
end

return {
	read = read,
	write = write
}