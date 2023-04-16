#update config.yml from repo
Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/deej/config.yml -o "$env:APPDATA\_custom\deej\config.yml"