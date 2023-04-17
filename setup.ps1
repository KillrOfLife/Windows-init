#region Functions

Function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {if(Get-Command $command){RETURN $true}}
    Catch {Write-Host “$command does not exist”; RETURN $false}
    Finally {$ErrorActionPreference=$oldPreference}
}


#endregion

#region ProgramList
$ProgramList=   "oh-my-posh",
                "brave",
                "steam",
                "discord",
                "git",
                "plex",
                "autohotkey",
                "rpi-imager",
                "spotify",
                "superf4",
                "totalcommander",
                "gsudo",
                "telegram",
                "microsoft-windows-terminal",
                "everything",
                "notepadplusplus",
                "7zip",
                "winrar",
                # "powertoys",
                # "modernflyouts",
                # "chromium",
                # "putty.install",
                "vlc",
                "eartrumpet",
                "qbittorrent",
#fonts
                "nerd-fonts-meslo",
                "firacode"

# winget install vscode
#winget install PuTTY.PuTTY
# winget install docker.dockerdesktop

#endregion

# Install chocolatey
Write-host "Installing chocolatey" -ForegroundColor red -BackgroundColor white
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Write-host "Installing all neccesary programs" -ForegroundColor red -BackgroundColor white
ForEach ($program in $ProgramList){
    choco install $Program -y
}

Write-host "Installing Terminal-icons" -ForegroundColor red -BackgroundColor white
Install-PackageProvider NuGet -Force;
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module -Name Terminal-Icons -Repository PSGallery

Write-host "Install OMP theme" -ForegroundColor red -BackgroundColor white
New-Item -ItemType Directory -Force -Path "$env:APPDATA\_custom\oh-my-posh"
Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/PowershellTheme/theme.omp.json -o "$env:APPDATA\_custom\oh-my-posh\theme.omp.json"

Write-host "Installing deej and configuration" -ForegroundColor red -BackgroundColor white
New-Item -ItemType Directory -Force -Path "$env:APPDATA\_custom\deej"
Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Deej/config.yaml -o "$env:APPDATA\_custom\deej\config.yml"
Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Deej/deej.exe -o "$env:APPDATA\_custom\deej\deej.exe"
Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Deej/bootscript.ps1 -o "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\bootscript.ps1"
#create shortcut for deej.exe
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\deej.lnk")
$Shortcut.TargetPath = "$env:APPDATA\_custom\deej\deej.exe"
$Shortcut.Save()

#region Profile
Write-host "Configuring Profile" -ForegroundColor red -BackgroundColor white
#If the file does not exist, create it.
if (!(Test-Path -Path $PROFILE -PathType Leaf)) {
    try {
        # Detect Version of Powershell & Create Profile directories if they do not exist.
        if ($PSVersionTable.PSEdition -eq "Core" ) { 
            if (!(Test-Path -Path ($env:userprofile + "\Documents\Powershell"))) {
                New-Item -Path ($env:userprofile + "\Documents\Powershell") -ItemType "directory"
            }
        }
        elseif ($PSVersionTable.PSEdition -eq "Desktop") {
            if (!(Test-Path -Path ($env:userprofile + "\Documents\WindowsPowerShell"))) {
                New-Item -Path ($env:userprofile + "\Documents\WindowsPowerShell") -ItemType "directory"
            }
        }

        Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
        Write-Host "The profile @ [$PROFILE] has been created."
    }
    catch {
        throw $_.Exception.Message
    }
}
# If the file already exists, show the message and do nothing.
 else {
		 Get-Item -Path $PROFILE | Move-Item -Destination oldprofile.ps1
         Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Microsoft.PowerShell_profile.ps1 -o $PROFILE
		 Write-Host "The profile @ [$PROFILE] has been created and old profile removed."
 }
& $profile

#endregion

# Disable Telemetry
Write-host "Disabling Telemetry" -ForegroundColor red -BackgroundColor white
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0

pause