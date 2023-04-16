Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine

irm "https://gitlab.com/maxim.claeys/windows-init/-/raw/main/setup.ps1" | iex