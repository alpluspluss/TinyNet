--[[
    Part of TinyNet library. Licensed under MIT.

    Optimized CFrame serialization with compact rotation representation.

    @author: alpluspluss
    @note
        standard CFrame representation: 28 bytes
        optimized representation: 15 bytes
        .. memory reduction.

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

		MAYBE-TODO: Use partial bytes to store pitch, yaw, roll to reduce the memory from 
			15B to 12-13B
]]

--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local writef32 = buffer.writef32
local writeu8 = buffer.writeu8
local readf32 = buffer.readf32
local readu8 = buffer.readu8

local PI = math.pi
local TWO_PI = 2 * PI
local ANGLE_TO_BYTE = 255 / TWO_PI
local BYTE_TO_ANGLE = TWO_PI / 255
local floor = math.floor

local function write(v: CFrame): buffer
    local pos = v.Position
    local pitch, yaw, roll = v:ToEulerAnglesXYZ()

    local pitch_byte = floor((pitch + PI) * ANGLE_TO_BYTE)
    local yaw_byte = floor((yaw + PI) * ANGLE_TO_BYTE)
    local roll_byte = floor((roll + PI) * ANGLE_TO_BYTE)

    local b = malloc(15)
    writef32(b, 0, pos.X)
    writef32(b, 4, pos.Y)
    writef32(b, 8, pos.Z)
    writeu8(b, 12, pitch_byte)
    writeu8(b, 13, yaw_byte)
    writeu8(b, 14, roll_byte)
    return b
end

local function read(b: buffer, offset: number): (CFrame, number)
    local x = readf32(b, offset)
    local y = readf32(b, offset + 4)
    local z = readf32(b, offset + 8)

    local pitch_byte = readu8(b, offset + 12)
    local yaw_byte = readu8(b, offset + 13)
    local roll_byte = readu8(b, offset + 14)

    local pitch = pitch_byte * BYTE_TO_ANGLE - PI
    local yaw = yaw_byte * BYTE_TO_ANGLE - PI
    local roll = roll_byte * BYTE_TO_ANGLE - PI
    return CFrame.new(x, y, z) * CFrame.Angles(pitch, yaw, roll), 15
end

return {
    read = read,
    write = write
}