local UV = require "luv"
local Class = require "luver.class"
local Waiter = require "luver.waiter"

local Hub = Class "Hub"

function Hub:initialize()
    self.fork_callbacks = {}
    self.fork_handle = UV.new_idle()
    self.fork_handle:start(function()
        self:_run_fork()
    end)
    self.wakeup_callbacks = {}
    self.wakeup_handle = UV.new_idle()
    self.wakeup_handle:start(function()
        self:_run_wakeup()
    end)
end

function Hub:waiter()
    return Waiter:new()
end

function Hub:_run_fork()
    local callbacks = self.fork_callbacks
    self.fork_callbacks = {}
    for _, f in ipairs(callbacks) do
        local c = coroutine.wrap(function()
            local ok, msg = xpcall(f, debug.traceback)
            if not ok then
                print(msg)
            end
            return ok, msg
        end)
        c()
    end
end

function Hub:_run_wakeup()
    local callbacks = self.wakeup_callbacks
    self.wakeup_callbacks = {}
    for _, f in ipairs(callbacks) do
        local ok, msg = xpcall(f, debug.traceback)
        if not ok then
            print(msg)
        end
    end
end

function Hub:fork_callback(f, ...)
    local args = table.pack(...)
    table.insert(self.fork_callbacks, function()
        f(table.unpack(args))
    end)
end

function Hub:wakeup_callback(f, ...)
    local args = table.pack(...)
    table.insert(self.wakeup_callbacks, function()
        f(table.unpack(args))
    end)
end

function Hub:sleep(ts)
    local waiter = self:waiter()
    local timer_handle = UV.new_timer()
    timer_handle:start(ts, 0, waiter)
    waiter:wait()
end

function Hub:thread(f)
    local id = UV.new_thread(f)
    return id
end

function Hub:fs_unlink(file)
    local waiter = self:waiter()
    UV.fs_unlink(file, waiter)
    waiter:wait()
end

return Hub:new()
