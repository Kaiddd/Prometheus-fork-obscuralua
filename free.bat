@echo off
set /p times="Enter the number of times to run script.obfuscated.lua: "
for /L %%i in (1,1,%times%) do (
    echo Running iteration %%i
    bin\luajit ./cli.lua --preset Basic --LuaU ./script.lua
    bin\luajit.exe script.obfuscated.lua
    echo Pausing for a moment to reduce lag...
    timeout /t 1 /nobreak >nul
)
echo Done.
pause