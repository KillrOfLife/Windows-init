#region Functions

Function Test-CommandExists {
    Param ($command)
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {if(Get-Command $command){RETURN $true}}
    Catch {Write-Host “$command does not exist”; RETURN $false}
    Finally {$ErrorActionPreference=$oldPreference}
}

Function Install-Programs{
$programList=   "oh-my-posh",
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
                "powertoys",
                "modernflyouts",
                "chromium",
                "putty.install",
                "vlc",
                "qbittorrent",
                "intel-arc-graphics-driver",
                "obs-studio",
                "lavfilters",
                "file-converter",
                "mobaxterm",
                "portmaster",
                "rufus",
                "zerotier-one",
                "wingetui",
                "vscode",
                "windirstat",
                "tailscale",
                "firefox",
                "logioptionsplus",
                "epicgameslauncher",
                "icue",
#fonts
                "nerd-fonts-meslo",
                "firacode"

# PlayStation.DualSenseFWUpdater
# Synology.DriveClient

# winget install vscode
#winget install PuTTY.PuTTY
# winget install docker.dockerdesktop

Clear-Host
Write-Host "Which programs do you want to install?"
$programs = Show-Menu $ProgramList -MultiSelect


Write-host "Installing all neccesary programs"
ForEach ($program in $programs){
    choco install $program -y
}
}

Function Install-Sliders{
    choco install eartrumpet -y
    Clear-Host

    Write-host "Installing deej in $env:APPDATA\_custom\deej"
    New-Item -ItemType Directory -Force -Path "$env:APPDATA\_custom\deej" | out-null
    Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Deej/config.yaml -o "$env:APPDATA\_custom\deej\config.yaml"
    Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Deej/deej.exe -o "$env:APPDATA\_custom\deej\deej.exe"

    Write-host "Do you want a script that updates the current slider configuration on every startup"
    $answer = Show-Menu @("Y", "N")

    if($answer -contains "Y"){
        Write-host "Creating a bootscript to automatically update sliderconfiguration on startup"
        Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Deej/bootscript.ps1 -o "$env:APPDATA\_custom\deej\bootscript.ps1"
        Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/Deej/deej_bootscript.cmd -o "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\deej_bootscript.cmd"
    }

    
    #create shortcut for deej.exe
    Write-host "Creating a shortcut so deej boots up"
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\deej.lnk")
    $Shortcut.TargetPath = "$env:APPDATA\_custom\deej\deej.exe"
    $Shortcut.Save()
}

Function Install-PowershellConfig{
    Write-host "Installing Terminal-icons"
    Install-Module -Name Terminal-Icons -Repository PSGallery

    Write-host "Install OMP theme"
    New-Item -ItemType Directory -Force -Path "$env:APPDATA\_custom\oh-my-posh"
    Invoke-RestMethod https://gitlab.com/maxim.claeys/windows-init/-/raw/main/PowershellTheme/theme.omp.json -o "$env:APPDATA\_custom\oh-my-posh\theme.omp.json"

    #region Profile
    Write-host "Configuring Profile"
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
}

Function remove-telemetry{
    Write-host "Disabling Telemetry"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0
}


#region Prescript
Clear-Host
Install-PackageProvider NuGet -Force | out-null
Set-PSRepository PSGallery -InstallationPolicy Trusted | out-null
Install-Module PSMenu -Force| out-null

# Install chocolatey
Write-host "Installing chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
#endregion

Clear-Host
Write-Host "Which parts of the script would you like to Run?"
$result = Show-Menu @("Install Programs", "Install Deej Audiosliders", "Install Powershell Theme and configuration", "Remove Telemetry") -MultiSelect

if($result -contains "Install Programs"){
    Install-Programs
    Clear-Host
    Write-Host "Successfully installed the programs"
    Start-Sleep -Seconds 4
}
if($result -contains "Install Deej Audiosliders"){
    Install-Sliders
    Write-Host "Successfully installed the sliders"
    Start-Sleep -Seconds 4
}
if($result -contains "Install Powershell Theme and configuration"){
    Install-PowershellConfig
    Write-Host "Successfully installed the Profile"
    Start-Sleep -Seconds 4
}
if($result -contains "Remove Telemetry"){
    remove-telemetry
}