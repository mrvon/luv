local UV = require "luv"
local Class = require "luver.class"

local Luver = Class "Luver"

function Luver:initialize()
    self.prepare_callbacks = {}
    self.prepare = UV.new_prepare()
    self.prepare:start(function()
        xpcall(self.prepare_run, debug.traceback, self)
    end)
end

function Luver:prepare_run()
    for _, f in ipairs(self.prepare_callbacks) do
        f()
    end
end

function Luver:prepare_push(f)
    table.insert(self.prepare_callbacks, f)
end

function Luver:start(main)
    self:prepare_push(main)
    UV.run()
end

function Luver:run()
end

function Luver:stop()
    UV.stop()
end

return Luver:new()
