--!native
--!optimize 2

local function inspect(b: buffer): string
    local length = buffer.len(b)
    local chunks = table.create(length * 3)
    
    for i = 0, length - 1 do
        local byte = buffer.readu8(b, i)
        chunks[i * 3 + 1] = string.format("%02X", byte)
        chunks[i * 3 + 2] = " "
    end
    
    local hex = table.concat(chunks)
    local rows = {}
    for i = 1, #hex, 48 do
        table.insert(rows, string.sub(hex, i, i + 47))
    end

    return string.format(
        "Buffer length: %d bytes\nHex dump:\n%s", 
        length,
        table.concat(rows, "\n")
    )
end

local function peek<T>(b: buffer, offset: number, size: number): string
    local value
    if size == 1 then
        value = string.format(
            "u8: %d\ni8: %d", 
            buffer.readu8(b, offset),
            buffer.readi8(b, offset)
        )
    elseif size == 2 then
        value = string.format(
            "u16: %d\ni16: %d", 
            buffer.readu16(b, offset),
            buffer.readi16(b, offset)
        )
    elseif size == 4 then
        value = string.format(
            "u32: %d\ni32: %d\nf32: %f", 
            buffer.readu32(b, offset),
            buffer.readi32(b, offset),
            buffer.readf32(b, offset)
        )
    elseif size == 8 then
        value = string.format("f64: %f", buffer.readf64(b, offset))
    end
    
    return string.format(
        "Offset: %d\nSize: %d bytes\n%s",
        offset,
        size,
        value
    )
end

return {
    inspect = inspect,
    peek = peek
}