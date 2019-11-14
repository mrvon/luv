local Luver = require "luver.luver"
local Socket = require "luver.socket"

local function main()
    local client, err = Socket.connect("127.0.0.1", 1337)
    assert(not err, err)
    Luver.fork(function()
        -- writer
        for i = 1, 10 do
            client:write("hello " .. i)
            Luver.sleep(1000)
        end
        client:close()
    end)
    while true do
        -- reader
        local chunk = client:read()
        if not chunk then
            -- connection close
            print("connection close", client)
            break
        end
        print("Receive stream", chunk)
    end
end

Luver.start(main)
