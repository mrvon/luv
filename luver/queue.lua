local Class = require "luver.class"
local Hub = require "luver.hub"

local Queue = Class "Queue"

function Queue:initialize(volume)
    self.volume = volume or 1024
    self.items = {}
    self.get_waiters = {}
    self.put_waiters = {}
end

function Queue:get()
    if #self.items == 0 then
        local waiter = Hub:waiter()
        table.insert(self.get_waiters, waiter)
        waiter:wait()
    end
    assert(#self.items > 0)
    local item = table.remove(self.items, 1)
    self:wakeup_puter()
    return item
end

function Queue:put(item)
    if #self.items >= self.volume then
        local waiter = Hub:waiter()
        table.insert(self.put_waiters, waiter)
        waiter:wait()
    end
    table.insert(self.items, item)
    self:wakeup_geter()
end

function Queue:wakeup_geter()
    if #self.get_waiters == 0 then
        return
    end
    local waiter = table.remove(self.get_waiters, 1)
    Hub:wakeup_callback(waiter)
end

function Queue:wakeup_puter()
    if #self.put_waiters == 0 then
        return
    end
    local waiter = table.remove(self.put_waiters, 1)
    Hub:wakeup_callback(waiter)
end

return Queue
