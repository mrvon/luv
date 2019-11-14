local Luver = require "luver.luver"
local Pipe = require "luver.pipe"
local Codec = require "luver.codec"

local function main()
    local sock = "/tmp/__luver.sock"
    local server, err = Pipe.listen(sock)
    assert(not err, err)
    while true do
        local client = server:accept()
        Luver.fork(function()
            local codec = Codec:new()
            while true do
                local chunk = client:read()
                if not chunk then
                    print("connection close", client)
                    client:shutdown()
                    client:close()
                    break
                end
                local packs = codec:decode(chunk)
                for _, pack in ipairs(packs) do
                    client:write(codec:encode(pack))
                end
            end
        end)
    end
end

Luver.start(main)
