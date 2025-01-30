--!native
--!optimize 2

local function inspect(b: buffer): string
    local length = buffer.len(b)
    local chunks = {}
    local used_bytes = 0
    for i = 0, length - 1 do
        local byte = buffer.readu8(b, i)
        if byte ~= 0 then
            used_bytes = i + 1
        end
        if i < used_bytes then
            table.insert(chunks, string.format("%02X", byte))
        else
            table.insert(chunks, "··")
        end
        table.insert(chunks, " ")
    end

    local hex = table.concat(chunks)
    local rows = {}
    for i = 1, #hex, 48 do
        table.insert(rows, string.sub(hex, i, i + 47))
    end

    return string.format(
        "Buffer length: %d bytes\nUsed bytes: %d\nWasted bytes: %d\nHex dump:\n%s", 
        length,
        used_bytes,
        length - used_bytes,
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