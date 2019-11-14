local Luver = require "luver.luver"
local Queue = require "luver.queue"

local queue = Queue:new(30)

local function producer()
    for i = 1, 100 do
        local item = "hello " .. i
        print("PUT:", item)
        queue:put(item)
        Luver.sleep(0)
    end
end

local function consumer()
    while true do
        local item = queue:get()
        print("GET:", item)
        Luver.sleep(100)
    end
end

Luver.start(function()
    Luver.fork(producer)
    consumer()
end)
