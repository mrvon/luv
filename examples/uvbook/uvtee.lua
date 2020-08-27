local uv = require "luv"

if not arg[1] then
    print(string.format("please run %s filename", arg[0]))
    return
end

local stdin = uv.new_tty(0, true)
local stdout = uv.new_tty(1, true)

-- local stdin_pipe = uv.new_pipe(false)
-- uv.pipe_open(stdin_pipe,0)

local filename = arg[1]

local FLAGS = "w+"
local MODE = tonumber("644", 8)

uv.fs_open(filename, FLAGS, MODE, function(err, fd)
    if err then
        print("error opening file:" .. err)
    else
        local fpipe = uv.new_pipe(false)
        uv.pipe_open(fpipe, fd)
        uv.read_start(stdin, function(err2, chunk)
            if err2 then
                print("Read error: " .. err2)
            else
                uv.write(stdout, chunk)
                uv.write(fpipe, chunk)
            end
        end)
    end
end)

uv.run("default")
