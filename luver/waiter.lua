local Class = require "luver.class"

local Waiter = Class "Waiter"

function Waiter:wait()
    assert(self.co == nil)
    self.co = coroutine.running()
    return coroutine.yield()
end

function Waiter:__call(...)
    local _, main = coroutine.running()
    assert(main, "must in main coroutine")
    if not self.co then
        return
    end
    local co = self.co
    self.co = nil
    coroutine.resume(co, ...)
end

return Waiter
