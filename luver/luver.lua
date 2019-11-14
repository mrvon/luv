local UV = require "luv"
local Hub = require "luver.hub"

local Luver = {}

function Luver.start(f)
    Hub:fork_callback(f)
    UV.run()
end

function Luver.stop()
    UV.stop()
end

function Luver.fork(f, ...)
    Hub:fork_callback(f, ...)
end

function Luver.sleep(ts)
    Hub:sleep(ts)
end

function Luver.now()
    return UV.now()
end

function Luver.hrtime()
    return UV.hrtime() / (10^9)
end

function Luver.thread(f, ...)
    return UV.new_thread(f, ...)
end

return Luver
