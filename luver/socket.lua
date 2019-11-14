local UV = require "luv"
local Class = require "luver.class"
local Hub = require "luver.hub"

local TcpClient = Class "TcpClient"

function TcpClient:initialize(handle)
    self.handle = handle
    self.waiter = Hub:waiter()
end

function TcpClient:read()
    local _, chunk = self.waiter:wait()
    return chunk
end

function TcpClient:write(chunk)
    return self.handle:write(chunk)
end

function TcpClient:shutdown()
    return self.handle:shutdown()
end

function TcpClient:close()
    return self.handle:close()
end

function TcpClient:fileno()
    return self.handle:fileno()
end

function TcpClient:__tostring()
    return string.format("tcp_client:<%s>", self.handle)
end

local TcpServer = Class "TcpServer"

function TcpServer:initialize()
    self.handle = UV.new_tcp()
    self.waiter = Hub:waiter()
end

function TcpServer:bind(address, port)
    return self.handle:bind(address, port)
end

function TcpServer:listen(backlog)
    return self.handle:listen(backlog, self.waiter)
end

function TcpServer:accept()
    self.waiter:wait()
    local client = TcpClient:new(UV.new_tcp())
    self.handle:accept(client.handle)
    client.handle:read_start(client.waiter)
    return client
end

function TcpClient:fileno()
    return self.handle:fileno()
end

function TcpServer:__tostring()
    return string.format("tcp_server:<%s>", self.handle)
end

local function listen(address, port)
    local socket = TcpServer:new()
    socket:bind(address, port)
    local _, err = socket:listen(128)
    return socket, err
end

local function connect(address, port)
    local handle = UV.new_tcp()
    local waiter = Hub:waiter()
    handle:connect(address, port, waiter)
    local err = waiter:wait()
    if err then
        return nil, err
    end
    local socket = TcpClient:new(handle)
    socket.handle:read_start(socket.waiter)
    return socket, nil
end

return {
    listen = listen,
    connect = connect,
}
