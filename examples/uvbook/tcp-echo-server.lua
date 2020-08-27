local uv = require "luv"

local HOST = "127.0.0.1"
local PORT = 1337
local BACKLOG = 128

local server = uv.new_tcp()

server:bind(HOST, PORT)
server:listen(BACKLOG, function(err)
    assert(not err, err)
    local client = uv.new_tcp()
    server:accept(client)
    client:read_start(function(err2, chunk)
        assert(not err2, err2)
        if chunk then
            client:write(chunk)
        else
            client:shutdown()
            client:close()
        end
    end)
end)

uv.run("default")
