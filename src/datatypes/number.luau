--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]
    
--!native
--!optimize 2

local malloc = require(script.Parent.Parent.allocator).malloc

local readi8 = buffer.readi8
local writei8 = buffer.writei8
local readi16 = buffer.readi16
local writei16 = buffer.writei16
local readi32 = buffer.readi32
local writei32 = buffer.writei32
local readu8 = buffer.readu8
local writeu8 = buffer.writeu8
local readu16 = buffer.readu16
local writeu16 = buffer.writeu16 
local readu32 = buffer.readu32 
local writeu32 = buffer.writeu32 
local readf32 = buffer.readf32
local writef32 = buffer.writef32
local readf64 = buffer.readf64
local writef64 = buffer.writef64

-- i8
local function read_i8(b: buffer): number
    return readi8(b, 0)
end

local function write_i8(v: number): buffer
    local b = malloc(1)
    writei8(b, 0, v)
    return b
end

local function read_u8(b: buffer): number
    return readu8(b, 0)
end

local function write_u8(v: number): buffer
    local b = malloc(1)
    writeu8(b, 0, v)
    return b
end

local function read_i16(b: buffer): number
    return readi16(b, 0)
end

local function write_i16(v: number): buffer
    local b = malloc(2)
    writei16(b, 0, v)
    return b
end

local function read_u16(b: buffer): number
    return readu16(b, 0)
end

local function write_u16(v: number): buffer
    local b = malloc(2)
    writeu16(b, 0, v)
    return b
end

local function read_i32(b: buffer): number
    return readi32(b, 0)
end

local function write_i32(v: number): buffer
    local b = malloc(4)
    writei32(b, 0, v)
    return b
end

local function read_u32(b: buffer): number
    return readu32(b, 0)
end

local function write_u32(v: number): buffer
    local b = malloc(4)
    writeu32(b, 0, v)
    return b
end

local function read_f32(b: buffer): number
    return readf32(b, 0)
end

local function write_f32(v: number): buffer
    local b = malloc(4)
    writef32(b, 0, v)
    return b
end

local function read_f64(b: buffer): number
    return readf64(b, 0)
end

local function write_f64(v: number): buffer
    local b = malloc(8)
    writef64(b, 0, v)
    return b
end

return {
    read_i8 = read_i8,
    write_i8 = write_i8,
    read_u8 = read_u8,
    write_u8 = write_u8,
    read_i16 = read_i16,
    write_i16 = write_i16,
    read_u16 = read_u16,
    write_u16 = write_u16,
    read_i32 = read_i32,
    write_i32 = write_i32,
    read_u32 = read_u32,
    write_u32 = write_u32,
    read_f32 = read_f32,
    write_f32 = write_f32,
    read_f64 = read_f64,
    write_f64 = write_f64,
}