PowerShell -Command "Set-ExecutionPolicy Unrestricted" >> "%TEMP%\StartupLog.txt" 2>&1
PowerShell %appdata%\_custom\deej\bootscript.ps1 >> "%TEMP%\StartupLog.txt" 2>&1

