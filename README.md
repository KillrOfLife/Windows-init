Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

irm "https://gitlab.com/maxim.claeys/windows-init/-/raw/main/setup.ps1" | iex

create a shortcut for deej.exe into your startup folder 

hint: to open your startup folder press win+r and type
```
    shell:startup
```