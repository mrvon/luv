local uv = require "luv"

local ctx = uv.new_work(function(n)
    -- work in threadpool
    local uv2 = require "luv"
    -- local t = uv2.thread_self()
    uv2.sleep(100)
    local r = n * n
    return n, r
end, function(n, r)
    -- after work, in loop thread
    print(string.format('%d => %d', n, r))
end)

uv.queue_work(ctx, 2)
uv.queue_work(ctx, 4)
uv.queue_work(ctx, 6)
uv.queue_work(ctx, 8)
uv.queue_work(ctx, 10)

uv.run("default")
