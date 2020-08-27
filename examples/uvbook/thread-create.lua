local uv = require "luv"

local init_step = 10

local hare_id = uv.new_thread(function(step)
    local uv2 = require "luv"
    -- Uncaught Error in thread: thread:1: unexpected symbol near '<\160>'
    print("debug -------------")
    while step > 0 do
        step = step - 1
        uv2.sleep(math.random(1000))
        print("Hare ran another step")
    end
    print("Hare done running!")
end, init_step, true, "abcd", "false")

local tortoise_id = uv.new_thread(function(step)
    local uv2 = require "luv"
    print("debug -------------")
    while step > 0 do
        step = step - 1
        uv2.sleep(math.random(100))
        print("Tortoise ran another step")
    end
    print("Tortoise done running!")
end, init_step, "abcd", "false")

print(hare_id == hare_id, uv.thread_equal(hare_id, hare_id))
print(tortoise_id == hare_id, uv.thread_equal(tortoise_id, hare_id))

uv.thread_join(hare_id)
uv.thread_join(tortoise_id)
