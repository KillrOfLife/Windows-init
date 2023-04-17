#update config.yml from repo
Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Deej/config.yaml -o "$env:APPDATA\_custom\deej\config.yaml"