local UV = require "luv"
local Class = require "luver.class"
local Hub = require "luver.hub"

local PipeClient = Class "PipeClient"

function PipeClient:initialize(handle)
    self.handle = handle
    self.waiter = Hub:waiter()
end

function PipeClient:read()
    local _, chunk = self.waiter:wait()
    return chunk
end

function PipeClient:write(chunk)
    return self.handle:write(chunk)
end

function PipeClient:shutdown()
    return self.handle:shutdown()
end

function PipeClient:close()
    return self.handle:close()
end

function PipeClient:__tostring()
    return string.format("pipe_client:<%s>", self.handle)
end

local PipeServer = Class "PipeServer"

function PipeServer:initialize(ipc)
    self.handle = UV.new_pipe(ipc)
    self.waiter = Hub:waiter()
end

function PipeServer:bind(path)
    local ret, err, code = self.handle:bind(path)
    if not ret and code == "EADDRINUSE" then
        Hub:fs_unlink(path)
        ret, err = self.handle:bind(path)
    end
    return ret, err
end

function PipeServer:listen(backlog)
    return self.handle:listen(backlog, self.waiter)
end

function PipeServer:accept()
    self.waiter:wait()
    local client = PipeClient:new(UV.new_pipe())
    self.handle:accept(client.handle)
    client.handle:read_start(client.waiter)
    return client
end

function PipeServer:__tostring()
    return string.format("pipe_server:<%s>", self.handle)
end

local function listen(path)
    local pipe = PipeServer:new()
    pipe:bind(path)
    local _, err = pipe:listen(128)
    return pipe, err
end

local function connect(path)
    local handle = UV.new_pipe()
    local waiter = Hub:waiter()
    handle:connect(path, waiter)
    waiter:wait()
    local pipe = PipeClient:new(handle)
    pipe.handle:read_start(pipe.waiter)
    return pipe, nil
end

return {
    listen = listen,
    connect = connect,
}
