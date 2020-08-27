local uv = require "luv"

local HOST = "127.0.0.1"
local PORT = 1337

local client = uv.new_tcp()

uv.tcp_connect(client, HOST, PORT, function(err)
    assert(not err, err)
    uv.read_start(client, function(err2, chunk)
        assert(not err2, err2)
        if chunk then
            print(chunk)
        else
            uv.close(client)
        end
    end)
    uv.write(client, "Hello")
    uv.write(client, "World")
end)

print("CTRL-C to break")

uv.run("default")
