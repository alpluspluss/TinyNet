--[[
    Part of TinyNet library. Licensed under MIT.

    @author: alpluspluss
]]

--!native
--!optimize 2
--!strict

local rs = game:GetService("RunService")
local rep = game:GetService("ReplicatedStorage")

local allocator = require(script.Parent.allocator)
local malloc = allocator.malloc
local write_ref = allocator.write_ref

local ctx = rs:IsServer() and "server" or "client"
local next_channel = 0
local channels = {}

local MIN_BUFFER_SIZE = 256
local MAX_CHANNELS = 255
local BUFFER_HEADER_SIZE = 1

type Schema<T> = {
    read: (b: buffer, number) -> T,
    write: (data: T) -> buffer
}

type NetChannel<T> = {
    on: (self: NetChannel<T>, callback: (data: T, player: Player?) -> ()) -> (),
    send: (self: NetChannel<T>, data: T) -> (),
    send_to: (self: NetChannel<T>, player: Player, data: T) -> (),
    broadcast: (self: NetChannel<T>, data: T) -> (),
}

type Queue = {
    cursor: number,
    buff: buffer,
    references: { [number]: unknown }
}

local SIZES = {
    0x100,
    0x200,
    0x400,
    0x800,
    0x1000,
    0x2000,
    0x4000,
    0x8000,
    0x10000
}

local function next_power_of_two(n: number): number
    for _, size in SIZES do
        if size >= n then
            return size
        end
    end
    return SIZES[#SIZES]
end

local function queue(): Queue
    return {
        cursor = 0,
        buff = malloc(MIN_BUFFER_SIZE),
        references = {}
    }
end

local player_reliables: { [Player]: Queue } = {}
local player_unreliables: { [Player]: Queue } = {}
local RELIABLE = queue()
local UNRELIABLE = queue()

local reliable_remote = if ctx == "server" 
    then Instance.new("RemoteEvent") 
    else rep:WaitForChild("__TINYNET__RELIABLE__")

local unreliable_remote = if ctx == "server"
    then Instance.new("UnreliableRemoteEvent")
    else rep:WaitForChild("__TINYNET__UNRELIABLE__")

if ctx == "server" then
    reliable_remote.Name = "__TINYNET__RELIABLE__"
    unreliable_remote.Name = "__TINYNET__UNRELIABLE__"
    reliable_remote.Parent = rep
    unreliable_remote.Parent = rep
end

local function push(q: Queue, channel_id: number, data: buffer)
    local data_len = buffer.len(data)
    local needed_size = q.cursor + data_len + BUFFER_HEADER_SIZE
    local curr_size = buffer.len(q.buff)
    
    if needed_size > curr_size then
        local new_size = next_power_of_two(needed_size)
        local new_buff = malloc(new_size)
        buffer.copy(new_buff, 0, q.buff, 0, q.cursor)
        q.buff = new_buff
    end

    local refs = allocator.get_refs()
    if next(refs) then
        for id, ref in refs do
            q.references[id] = ref
        end
    end

    buffer.writeu8(q.buff, q.cursor, channel_id)
    buffer.copy(q.buff, q.cursor + BUFFER_HEADER_SIZE, data, 0, data_len)
    q.cursor += data_len + BUFFER_HEADER_SIZE
end

local function flush_queue(q: Queue, remote: RemoteEvent, player: Player?)
	if q.cursor > 0 then
		local send_buff = malloc(q.cursor)
		buffer.copy(send_buff, 0, q.buff, 0, q.cursor)

		local refs = next(q.references) and q.references
		if ctx == "server" then
			if player then
				remote:FireClient(player, send_buff, refs)
			else
				remote:FireAllClients(send_buff, refs)
			end
		else
			remote:FireServer(send_buff, refs)
		end

		q.cursor = 0
		if refs then
			table.clear(q.references)
		end
	end
end

local net = {}
net.__index = net

function net:on<T>(callback: (data: T, player: Player?) -> ())
    local remote = self.reliable and reliable_remote or unreliable_remote
    local channel_id = self.channel_id
    
    if ctx == "server" then
        remote.OnServerEvent:Connect(function(player, b: buffer, refs: { unknown })
            if refs and next(refs) then
                for _, ref in refs do
                    write_ref(ref)
                end
            end
            
            local len = buffer.len(b)
            local cursor = 0
            
            while cursor < len do
                local curr_channel = buffer.readu8(b, cursor)
                cursor += BUFFER_HEADER_SIZE
                
                -- // fast path ig
                if curr_channel == channel_id then
                    local decoded, bytes_read = self.schema.read(b, cursor)
                    callback(decoded, player)
                    cursor += bytes_read
                    continue
                end
                
                local channel = channels[curr_channel]
                if not channel then break end
                
                local _, bytes_read = channel.schema.read(b, cursor)
                cursor += bytes_read
            end
        end)
    else
        remote.OnClientEvent:Connect(function(b: buffer, refs: { unknown })
            if refs and next(refs) then
                for _, ref in refs do
                    write_ref(ref)
                end
            end
            
            local len = buffer.len(b)
            local cursor = 0
            
            while cursor < len do
                local curr_channel = buffer.readu8(b, cursor)
                cursor += BUFFER_HEADER_SIZE
                
                if curr_channel == channel_id then
                    local decoded, bytes_read = self.schema.read(b, cursor)
                    callback(decoded)
                    cursor += bytes_read
                    continue
                end
                
                local channel = channels[curr_channel]
                if not channel then break end
                
                local _, bytes_read = channel.schema.read(b, cursor)
                cursor += bytes_read
            end
        end)
    end
end

function net:send<T>(data: T)
    if ctx == "client" then
        local encoded = self.schema.write(data)
        push(self.reliable and RELIABLE or UNRELIABLE, self.channel_id, encoded)
    end
end

function net:send_to<T>(player: Player, data: T)
    if ctx == "server" then
        local queues = self.reliable and player_reliables or player_unreliables
        local q = queues[player]
        if q then
            local encoded = self.schema.write(data)
            push(q, self.channel_id, encoded)
        end
    end
end

function net:broadcast<T>(data: T)
    if ctx == "server" then
        local encoded = self.schema.write(data)
        push(self.reliable and RELIABLE or UNRELIABLE, self.channel_id, encoded)
    end
end

if ctx == "server" then
    game:GetService("Players").PlayerAdded:Connect(function(player)
        player_reliables[player] = queue()
        player_unreliables[player] = queue()
    end)

    game:GetService("Players").PlayerRemoving:Connect(function(player)
        player_reliables[player] = nil
        player_unreliables[player] = nil
    end)
    
    rs.Heartbeat:Connect(function()
        if RELIABLE.cursor > 0 or UNRELIABLE.cursor > 0 then
            flush_queue(RELIABLE, reliable_remote)
            flush_queue(UNRELIABLE, unreliable_remote)
        end

        if next(player_reliables) then
            for player, reliable in player_reliables do
                local unreliable = player_unreliables[player]
                if reliable.cursor > 0 or unreliable.cursor > 0 then
                    flush_queue(reliable, reliable_remote, player)
                    flush_queue(unreliable, unreliable_remote, player)
                end
            end
        end
    end)
else
    rs.Heartbeat:Connect(function()
        if RELIABLE.cursor > 0 or UNRELIABLE.cursor > 0 then
            flush_queue(RELIABLE, reliable_remote)
            flush_queue(UNRELIABLE, unreliable_remote)
        end
    end)
end

local function create<T>(schema: Schema<T>, reliable: boolean): NetChannel<T>
    assert(next_channel <= MAX_CHANNELS, "Maximum channel limit reached (256)")
    
    local self = setmetatable({
        schema = schema,
        channel_id = next_channel,
        reliable = reliable
    }, net)

    channels[next_channel] = self
    next_channel += 1
    
    return self :: any
end

return {
    reliable = function<T>(schema: Schema<T>) 
        return create(schema, true) 
    end,
    
    unreliable = function<T>(schema: Schema<T>) 
        return create(schema, false) 
    end
}