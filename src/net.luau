--[[
    Part of TinyNet library. Licensed under MIT.
    @author: alpluspluss
]]
	
--!native
--!optimize 2

local rs = game:GetService("RunService")
local rep = game:GetService("ReplicatedStorage")

local ctx = rs:IsServer() and "server" or "client"

local net = {}
net.__index = net

type Schema<T> = {
	read: (buffer, number) -> T,
	write: (T, number) -> buffer
}

type NetPacket<T> = {
	connect: (self: NetPacket<T>, callback: (data: T, player: Player?) -> ()) -> (),
	send: (self: NetPacket<T>, data: T) -> (),
	send_to: (self: NetPacket<T>, player: Player, data: T) -> (),
	broadcast: (self: NetPacket<T>, data: T) -> (),
}

function net:connect<T>(callback: (data: T, player: Player?) -> ())
	if ctx == "server" then
		self.remote.OnServerEvent:Connect(function(player, encoded)
			local decoded = self.schema.read(encoded, 0)
			callback(decoded, player)
		end)
	else
		self.remote.OnClientEvent:Connect(function(encoded)
			local decoded = self.schema.read(encoded, 0)
			callback(decoded)
		end)
	end
end

function net:send<T>(data: T)
	if ctx == "client" then
		local encoded = self.schema.write(data)
		self.remote:FireServer(encoded)
	end
end

function net:send_to<T>(player: Player, data: T)
	if ctx == "server" then
		local encoded = self.schema.write(data)
		self.remote:FireClient(player, encoded)
	end
end

function net:broadcast<T>(data: T)
	if ctx == "server" then
		local encoded = self.schema.write(data)
		self.remote:FireAllClients(encoded)
	end
end

local function reliable<T>(id: string, schema: Schema<T>): NetPacket<T>
	local self = setmetatable({
		remote = if ctx == "server" 
			then Instance.new("RemoteEvent") 
			else rep:WaitForChild(id),
		schema = schema
	}, net)

	if ctx == "server" then
		self.remote.Name = id
		self.remote.Parent = rep
	end

	return self :: any
end

local function unreliable<T>(id: string, schema: Schema<T>): NetPacket<T>
	local self = setmetatable({
		remote = if ctx == "server" 
			then Instance.new("UnreliableRemoteEvent") 
			else rep:WaitForChild(id),
		schema = schema
	}, net)

	if ctx == "server" then
		self.remote.Name = id
		self.remote.Parent = rep
	end

	return self :: any
end

return {
	reliable = reliable,
	unreliable = unreliable
}