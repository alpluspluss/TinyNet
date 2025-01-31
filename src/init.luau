--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]

return {
    array = require(script.data_types.array),
    bool = require(script.data_types.bool),
    cframe = require(script.data_types.cframe),
    color3 = require(script.data_types.color3),
    instance = require(script.data_types.instance),
    u8 = require(script.data_types.number).u8,
    i8 = require(script.data_types.number).i8,
    u16 = require(script.data_types.number).u16,
    i16 = require(script.data_types.number).i16,
    u32 = require(script.data_types.number).u32,
    i32 = require(script.data_types.number).i32,
    f32 = require(script.data_types.number).f32,
    f64 = require(script.data_types.number).f64,
    optional = require(script.data_types.optional),
    string = require(script.data_types.string),
    map = require(script.data_types.map),
    unknown = require(script.data_types.unknown),
    vec2 = require(script.data_types.vector2),
    vec3 = require(script.data_types.vector3),
    inspector = require(script.inspector),

    reliable = require(script.net).reliable,
    unreliable = require(script.net).unreliable
}