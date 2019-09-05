$xml = [xml](Get-Content $env:USERPROFILE\.VirtualBox\VirtualBox.xml);
$xml.VirtualBox.Global.SystemProperties.defaultMachineFolder = "D:\VirtualboxVMs";
$xml.Save("$env:USERPROFILE\.VirtualBox\VirtualBox.xml");
