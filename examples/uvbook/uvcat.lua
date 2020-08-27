local uv = require "luv"

local filename = arg[1] and arg[1] or arg[0]

local FLAGS = "r"
local MODE = tonumber("644", 8)
local STDOUT = 1

uv.fs_open(filename, FLAGS, MODE, function(err, fd)
    if err then
        print("error opening file:" .. err)
    else
        local off = 0
        local block = 10
        local function on_read(err2, chunk)
            if err2 then
                print("Read error: " .. err2);
            elseif #chunk == 0 then
                uv.fs_close(fd)
            else
                off = block + off
                uv.fs_write(STDOUT, chunk, -1, function(err3)
                    if err3 then
                        print("Write error: " .. err3)
                    else
                        uv.fs_read(fd, block, off, on_read)
                    end
                end)
            end
        end
        uv.fs_read(fd, block, off, on_read)
    end
end)



uv.run('default')
