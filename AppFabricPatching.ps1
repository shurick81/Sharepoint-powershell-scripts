Function AppfabricPatching
{
    Use-CacheCluster; Get-CacheHost;
    Write-Host "Press any key when you are ready to apply App Fabric CU AppFabric-KB3092423-x64-ENU.exe";
    $host.UI.RawUI.ReadKey( "NoEcho,IncludeKeyDown" ) | Out-Null;
        #inspired by http://softlanding.ca/blog/Scripted-Patching-of-AppFabric-for-SharePoint
	$patchFileUrl = "https://download.microsoft.com/download/F/1/0/F1093AF6-E797-4CA8-A9F6-FC50024B385C/AppFabric-KB3092423-x64-ENU.exe"
	$patchFileName = "$env:temp\AppFabric-KB3092423-x64-ENU.exe"
	Invoke-RestMethod -Uri $patchFileUrl -OutFile $patchFileName	
	$patchfile = Get-ChildItem $patchFileName;
	if( $patchfile -eq $null ) { 
		Write-Host "Unable to retrieve the file.  Exiting Script" -ForegroundColor Red;
		Return;
	}
	$instanceName ="SPDistributedCacheService Name=AppFabricCachingService" 
    $serviceInstance = Get-SPServiceInstance | ? {($_.service.tostring()) -eq $instanceName -and ($_.server.name) -eq $env:computername} 
    if ( $serviceInstance )
	{
		Write-Host "Stopping AppFabric" -ForegroundColor Magenta;
		Stop-SPDistributedCacheServiceInstance -Graceful
		Sleep -Seconds 60;
		Write-Host "Stopping AppFabric complete" -ForegroundColor Green;
		$stopped = $true;
	} else {
		$stopped = $false;
	}
	Write-Host "Patching now keep this PowerShell window open" -ForegroundColor Magenta;
	Start-Process -FilePath $patchFileName -ArgumentList "/passive" -Wait;
	Write-Host "Patch installation complete" -foregroundcolor Green;
	Write-Host "Updating AppFabric config" -ForegroundColor Magenta;
	$location = "C:\Program Files\AppFabric 1.1 for Windows Server\DistributedCacheService.exe.config"
	$xml = [xml]( get-content $location );
	if ($xml.configuration.appSettings.add -eq $null) {
		$appsettings = $xml.CreateElement( "appSettings" );
		$add = $xml.CreateElement( "add" );
		$key = $xml.CreateAttribute( "key" );
		$key.InnerText = "backgroundGC";
		$add.Attributes.Append( $key ) | out-null;
		$value = $xml.CreateAttribute( "value" );
		$value.InnerText = "true";
		$add.Attributes.Append( $value ) | out-null;
		$appsettings.AppendChild( $add ) | out-null;
		$configsections = $xml.configuration.configSections;
		$xml.configuration.InsertAfter( $appsettings,$configsections ) | out-null;
		$xml.save($location);
	}
	Write-Host "Updating AppFabric config complete" -ForegroundColor Green;
	if ( $stopped )
	{
		Write-Host "Starting AppFabric" -ForegroundColor Magenta;
		$instance = Get-SPServiceInstance | ? { $_.TypeName -eq "Distributed Cache" -and $_.Server.Name -eq $env:computername };
		$instance.Provision();
		Write-Host "Starting AppFabric complete" -ForegroundColor Green;
	}
    Use-CacheCluster; Get-CacheHost;
}

AppfabricPatching;
