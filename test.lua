local luver = require "luver.luver"

local function main()
    print("hello world")
    luver:prepare_push(function()
        print("hello world")
    end)
end

luver:start(main)
