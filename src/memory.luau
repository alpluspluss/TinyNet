--!native
--!optimize 2

local RESIZE_MULTIPLER = 1.25

local function resize(b: buffer, sz: number): (buffer, number)
    local nsz = math.round(sz * RESIZE_MULTIPLER)
    local nb = buffer.create(nsz)
    buffer.copy(nb, 0, b)
    return nb, nsz
end

local function memcpy(dest: buffer, src: buffer, sz: number, dest_offset: number?, src_offset: number?): ()
    buffer.copy(dest, dest_offset or 0, src, src_offset or 0, sz)
end

return {
    resize = resize,
    memcpy = memcpy
}