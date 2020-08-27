local uv = require "luv"

local SOCK = "/tmp/echo.sock"
local BACKLOG = 128

local server = uv.new_pipe(false)

local function bind()
    local ret, err, code = server:bind(SOCK)
    -- if file already exists, remove it first and try again
    if not ret and code == "EADDRINUSE" then
        uv.fs_unlink(SOCK)
        local _
        _, err, _ = server:bind(SOCK)
        assert(not err, err)
    else
        assert(not err, err)
    end
end

bind()

server:listen(BACKLOG, function(err)
    assert(not err, err)
    local client = uv.new_pipe(false)
    server:accept(client)
    client:read_start(function(err2, chunk)
        assert(not err2, err2)
        if chunk then
            print("Got: " .. chunk)
            client:write(chunk)
        else
            client:shutdown()
            client:close()
        end
    end)
end)

uv.run("default")
