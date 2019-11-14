local Luver = require "luver.luver"
local Pipe = require "luver.pipe"
local Codec = require "luver.codec"

local function main()
    local sock = "/tmp/__luver.sock"
    local codec = Codec:new()
    local client, err = Pipe.connect(sock)
    assert(not err, err)
    Luver.fork(function()
        for i = 1, 10 do
            client:write(codec:encode("hello " .. i))
            Luver.sleep(1000)
        end
        client:close()
    end)
    while true do
        local chunk = client:read()
        if not chunk then
            print("connection close", client)
            break
        end
        local packs = codec:decode(chunk)
        for _, pack in ipairs(packs) do
            print("Receive pack", pack)
        end
    end
end

Luver.start(main)
