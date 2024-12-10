@echo off
set /p times="Enter the number of times to run script.obfuscated.lua: "
for /L %%i in (1,1,%times%) do (
    echo Running iteration %%i
bin\luajit ./cli.lua --preset Strong --LuaU ./script.lua
lua script.obfuscated.lua
)
echo Done.
pause