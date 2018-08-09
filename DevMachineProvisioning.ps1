Install-Module SharePointPnPPowerShellOnline -Force
Set-ExecutionPolicy Bypass -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install -y microsoft-teams
choco install -y slack
choco install -y whatsapp
choco install -y telegram 
choco install -y office365proplus
choco install -y onedrive
choco install -y paint.net
choco install -y fsviewer
choco install -y obs-studio
choco install -y googlechrome
choco install -y firefox
choco install -y git
choco install -y rdcman
choco install -y nodejs.install
choco install -y visualstudiocode
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest https://github.com/PowerShell/vscode-powershell/releases/download/v1.8.2/PowerShell-1.8.2.vsix PowerShell-1.8.2.vsix
code --install-extension PowerShell-1.8.2.vsix
choco install -y teamviewer
choco install -y azure-cli
choco install -y greenshot
choco install -y packer
choco install -y google-backup-and-sync
choco install -y xmind
choco install -y vagrant
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All
