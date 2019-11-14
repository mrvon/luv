local Luver = require "luver.luver"
local Socket = require "luver.socket"

local function main()
    local server, err = Socket.listen("127.0.0.1", 1337)
    assert(not err, err)
    while true do
        local client = server:accept()
        Luver.fork(function()
            while true do
                local chunk = client:read()
                if not chunk then
                    print("connection close", client)
                    client:shutdown()
                    client:close()
                    break
                end
                client:write(chunk)
            end
        end)
    end
end

Luver.start(main)
