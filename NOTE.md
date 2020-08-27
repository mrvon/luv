# Compiler

Run examples

```sh
WITH_LUA_ENGINE=Lua make
lua examples/uvbook/helloworld.lua
```

# Issue

Check with ASAN
```sh
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libasan.so.2 ./build/lua \
    examples/uvbook/thread-create.lua
```

You should use ./build/lua instead of official lua
Otherwise you will got errors

    AddressSanitizer: heap-use-after-free
    Uncaught Error in thread: thread:1: unexpected symbol near '<\160>'


More materials about ASAN

    https://github.com/google/sanitizers/wiki/AddressSanitizer

Check with Valgrind
```sh
valgrind ./build/lua examples/uvbook/thread-create.lua
```

How to Read valgrind report

    https://www.valgrind.org/docs/manual/quick-start.html#quick-start.interpret
