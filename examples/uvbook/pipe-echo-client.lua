local uv = require "luv"

local SOCK = "/tmp/echo.sock"

local client = uv.new_pipe(false)

client:connect(SOCK, function (err)
    assert(not err, err)
    client:read_start(function (err2, chunk)
        assert(not err2, err2)
        if chunk then
            print(chunk)
        else
            client:close()
        end
    end)

    client:write("Hello ")
    client:write("world!")
end)

print("CTRL-C to break")

uv.run("default")
