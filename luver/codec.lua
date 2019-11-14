local Class = require "luver.class"

local Codec = Class "Codec"

local HEADER_SIZE = 4
local MAX_PACKET_LEN = 2^(HEADER_SIZE*8) - 1
local RECV_PACK_FMT = ">I4"
local SEND_PACK_FMT = ">s4"

function Codec:initialize()
    self.remain = ""
end

function Codec:encode(chunk)
    assert(#chunk <= MAX_PACKET_LEN, "too large chunk")
    return string.pack(SEND_PACK_FMT, chunk)
end

function Codec:decode(chunk)
    local packs = {}
    local data = chunk
    if not data or #data == 0 then
        return nil
    end
    self.remain = self.remain .. data
    while true do
        if #self.remain < HEADER_SIZE then
            break
        end
        local len = self.remain:sub(1, HEADER_SIZE)
        len = string.unpack(RECV_PACK_FMT, len)
        if len + HEADER_SIZE > #self.remain then
            break
        end
        data = self.remain:sub(HEADER_SIZE + 1, HEADER_SIZE + len)
        self.remain = self.remain:sub(HEADER_SIZE + len + 1)
        table.insert(packs, data)
    end
    return packs
end

return Codec
