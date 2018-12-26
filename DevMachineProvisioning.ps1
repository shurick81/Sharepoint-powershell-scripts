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
choco install -y teamviewer
choco install -y azure-cli
choco install -y greenshot
choco install -y packer
choco install -y google-backup-and-sync
choco install -y xmind
choco install -y vagrant
# close the console and run in a new one:
choco install -y vscode-powershell
code --install-extension eamodio.gitlens
code --install-extension ms-azure-devops.azure-pipelines
Enable-WindowsOptionalFeature -Online -FeatureName:Microsoft-Hyper-V -All
