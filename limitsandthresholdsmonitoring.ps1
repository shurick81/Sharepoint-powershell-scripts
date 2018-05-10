# Tested on SharePoint 2013 and SharePoint 2010
# Limits: https://technet.microsoft.com/en-us/library/cc262787.aspx

$webApplicationsLimit = @( 20, 15 )
$alternativeUrlsLimit = @( 5, 4 )
$HNSCMPLimit = @( 20, 15 )
$PBSCMPLimit = @( 20, 15 )
$appPoolsLimit = @( 10, 7 )
$contentDatabasesLimit = @( 500, 450 )
$contentDatabaseSizeLimit = @( 200, 150 ) #Gigs
$dbItemsLimit = @( 60000000, 45000000 )
$dbSCLimit = @( 10000, 7500 )
$SCLimit = @( 750000, 500000 )
$SCWebsLimit = @( 250000, 200000 )
$deviceChannelsLimit = @( 10, 7 )
$listItemsLimit = @( 30000000, 25000000 )
$viewItemsLimit = @( 5000, 4000 )
$viewLookupFieldsLimit = @( 18, 16 )
$subSitesLimit = @( 2000, 1500 )


$emailAddress = "alexander.sapozhkov@telecomputing.no"
$from = "limits-checker@telecomputing.no"
$SMTPServer = "smtp-relay.telecomputing.se"
$maxObjectsNumber = 500

$lookupFieldTypes = @( "Lookup", "User", "WorkflowStatus" )

$body = ""
$objectsNumber = 0
$alarm = $false
[System.Reflection.Assembly]::LoadWithPartialName( "Microsoft.SharePoint" )
Add-PSSnapin Microsoft.SharePoint.PowerShell
$was = Get-SPWebApplication
$webApplicationsCount = $was.Count
$logEntry = 'Number of web applications is ' + $webApplicationsCount
if ( $webApplicationsCount -ge $webApplicationsLimit[1] )
{
	if ( $was.count -ge $webApplicationsLimit[0] )
	{
		$body = $body + 'ALARM:<br>'
		$alarm = $true
	}
	$body = $logEntry + '<br>'
	$logEntry
}
ForEach ( $wa in $was )
{
	$alternativeUrlsCount = $wa.AlternateUrls.Count
	$logEntry = 'Web application ' + $wa.Name + ' has ' + $urls.count + ' alternative mappings'
	if ( $urls.count -ge $alternativeUrlsLimit[1] )
	{
		if ( $urls.count -ge $alternativeUrlsLimit[0] )
		{
			$body = $body + 'ALARM:<br>'
			$alarm = $true
		}
		$body = $body + $logEntry + '<br>'
		$logEntry
	}
	$PBSCMP = $wa | Get-SPManagedPath
	$PBSCMPCount = $PBSCMP.Count
	$logEntry = 'Web application ' + $wa.Name + ' has ' + $PBSCMP.count + ' managed paths'
	if ( $PBSCMPCount -ge $PBSCMPLimit[1] )
	{
		if ( $PBSCMPCount -ge $PBSCMPLimit[0] )
		{
			$body = $body + 'ALARM:<br>'
			$alarm = $true
		}
		$body = $body + $logEntry + '<br>'
		$logEntry
	}
}
$HNSCMP = Get-SPManagedPath -HostHeader
$logEntry = 'Number of HNSC managed paths is ' + $HNSCMP.count
if ( $HNSCMP.count -ge $HNSCMPLimit[1] )
{
	if ( $HNSCMP.count -ge $HNSCMPLimit[0] )
	{
		$body = $body + 'ALARM:<br>'
		$alarm = $true
	}
	$body = $body + $logEntry + '<br>'
	$logEntry
}
$appPoolsCount = ( [Microsoft.SharePoint.Administration.SPWebService]::ContentService.ApplicationPools ).count + ( Get-SPServiceApplicationPool ).count
$logEntry = 'Number of application pools is ' + $appPoolsCount
if ( $appPoolsCount -ge $appPoolsLimit[1] )
{
	if ( $appPoolsCount -ge $appPoolsLimit[0] )
	{
		$body = $body + 'ALARM:<br>'
		$alarm = $true
	}
	$body = $body + $logEntry + '<br>'
	$logEntry
}
$contentDatabases = Get-SPDatabase | ? { $_.Type -eq "Content Database" }
$logEntry = 'Number of content databases is ' + $contentDatabases.count
if ( $contentDatabases.count -ge $contentDatabasesLimit[1] )
{
	if ( $contentDatabases.count -ge $contentDatabasesLimit[0] )
	{
		$body = $body + 'ALARM:<br>'
		$alarm = $true
	}
	$body = $body + $logEntry + '<br>'
	$logEntry
}
ForEach ( $contentDatabase in $contentDatabases )
{
	$contentDatabaseSize = $contentDatabase.DiskSizeRequired/1024/1024/1024
	$logEntry = 'Database ' + $contentDatabase.Name + ' size is ' + $contentDatabaseSize + ' gigabytes'
	if ( $contentDatabaseSize -ge $contentDatabaseSizeLimit[1] )
	{
		if ( $contentDatabaseSize -ge $contentDatabaseSizeLimit[0] )
		{
			$body = $body + 'ALARM:<br>'
			$alarm = $true
		}
		$body = $body + $logEntry + '<br>'
		$logEntry
	}
	$dbItemsCount = 0
	$sites = $contentDatabase.Sites
	ForEach( $site in $sites )
	{
		$webs = $site.AllWebs
		ForEach( $web in $webs )
		{
			$lists = $web.Lists
			ForEach( $list in $lists )
			{
				Write-Host ( 'List ' + $list.ParentWeb.Url + '/' + $list.RootFolder.Url );
				$listItemsCount = $list.ItemCount
				$dbItemsCount = $dbItemsCount + $listItemsCount
				$logEntry = 'List ' + $list.ParentWeb.Url + '/' + $list.RootFolder.Url + ' has ' + $listItemsCount + ' items'
				if ( $listItemsCount -ge $listItemsLimit[1] )
				{
					if ( $listItemsCount -ge $listItemsLimit[0] )
					{
						$body = $body + 'ALARM:<br>'
						$alarm = $true
					}
					$body = $body + $logEntry + '<br>'
					$logEntry
				}
				$objectsNumber++
				ForEach( $view in $list.Views )
				{
					$query = New-Object Microsoft.SharePoint.SPQuery
					$query.Query = $view.Query
					$query.RowLimit = $view.RowLimit
					$items = $list.GetItems( $query )
					$viewItemsCount = $items.Count
					$logEntry = 'List ' + $list.ParentWeb.Url + '/' + $list.RootFolder.Url + ' view ' + $view.ID + ' has ' + $viewItemsCount + ' items'
					if ( $viewItemsCount -ge $viewItemsLimit[1] )
					{
						if ( $viewItemsCount -ge $viewItemsLimit[0] )
						{
							$body = $body + 'ALARM:<br>'
							$alarm = $true
						}
						$body = $body + $logEntry + '<br>'
						$logEntry
					}
					$objectsNumber++
					$viewLookupFields = $view.ViewFields | % {
						$fieldName = $_
						$list.Fields | ? { ( $_.InternalName -eq $fieldname ) -and ( $lookupFieldTypes -Contains $_.Type.ToString() ) }
					}
					$viewLookupFieldsCount = $viewLookupFields.Count
					$logEntry = 'List ' + $list.ParentWeb.Url + '/' + $list.RootFolder.Url + ' view ' + $view.ID + ' has ' + $viewLookupFieldsCount + ' lookup fields'
					if ( $viewLookupFieldsCount -ge $viewLookupFieldsLimit[1] )
					{
						if ( $viewLookupFieldsCount -ge $viewLookupFieldsLimit[0] )
						{
							$body = $body + 'ALARM:<br>'
							$alarm = $true
							$logEntry
							$viewLookupFields | Select InternalName, Type;
						}
						$body = $body + $logEntry + '<br>'
					}
					$objectsNumber++
				}
				$query = New-Object Microsoft.SharePoint.SPQuery;
				$items = $list.GetItems( $query );
				$uniquePermissionsItems = $items | ? { $_.HasUniqueRoleAssignments -eq $true };
				$uniquePermissionsItemsCount = $uniquePermissionsItems.Count;
				$uniquePermissionsItemsLimit = @( $contentDatabase.WebApplication.MaxUniquePermScopesPerList, ( $contentDatabase.WebApplication.MaxUniquePermScopesPerList * 0.66 ) );
				$logEntry = 'List ' + $list.ParentWeb.Url + '/' + $list.RootFolder.Url + ' has ' + $uniquePermissionsItemsCount + ' unique permissions items'
				if ( $uniquePermissionsItemsCount -ge $uniquePermissionsItemsLimit[1] )
				{
					if ( $uniquePermissionsItemsCount -ge $uniquePermissionsItemsLimit[0] )
					{
						$body = $body + 'ALARM:<br>'
						$alarm = $true
					}
					$body = $body + $logEntry + '<br>'
					$logEntry
				}
				if ( $objectsNumber -ge $maxObjectsNumber )
				{
					$objectsNumber = 0;
					[gc]::collect()
					[gc]::WaitForPendingFinalizers()			
				}
			}
		}
	}
	$logEntry = 'Database ' + $contentDatabase.Name + ' has ' + $dbItemsCount + ' items'
	if ( $dbItemsCount -ge $dbItemsLimit[1] )
	{
		if ( $dbItemsCount -ge $dbItemsLimit[0] )
		{
			$body = $body + 'ALARM:<br>'
			$alarm = $true
		}		
		$body = $body + $logEntry + '<br>'
		$logEntry
	}

}

  
if ( $body -ne "" )
{
	$body = 'Server: ' + $env:computername + '<br>' + $body
	"Sending Email"
	$subject = "Some limits are about to be crossed"
	if ( $alarm ) { $subject = "ALARM! Some limits are crossed" }
	Send-MailMessage -From $from -to $emailAddress -Subject $Subject -Body $Body -SmtpServer $SMTPServer -UseSsl -BodyAsHTML
}
