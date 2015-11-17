# 1. save this file contents to ps1 file
# 2. run this file in SharePoint Management Console with administrator permissions

$filename = "inventory.txt"
$logfilename = "inventorylog.txt"
Add-Content -Value ("Class|Type/relation|Name/URL|Size in bytes|Details1|Details2") -Path $filename
try {
    [System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
    Add-PSSnapin Microsoft.SharePoint.PowerShell
    $farm = [Microsoft.SharePoint.Administration.SPFarm]::Local
    $products = "";
    foreach ($product in $farm.Products.Guid) {
        if ($products -ne "") {$products = $products + ","};
        $products = $products + $product
    }
    Add-Content -Value ("Farm|" + $farm.BuildVersion.ToString() + "|" + $farm.Name + "||" + $farm.Products) -Path $filename
    foreach ($solution in $farm.Solutions) {
        Add-Content -Value ("Solution|" + $solution.deployed + "|" + $solution.Name) -Path $filename
    }
    foreach ($serviceapplication in Get-SPServiceApplication) {
        Add-Content -Value ("Service Application|" + $serviceapplication.TypeName + "|" + $serviceapplication.Name) -Path $filename
    }
    $ContentService = [Microsoft.SharePoint.Administration.SPWebService]::ContentService;
    foreach ($wa in $ContentService.WebApplications) {
        Add-Content -Value ("Web Application||" + $wa.alternateurls[0].IncomingUrl) -Path $filename
        try {
            foreach ($database in $wa.contentdatabases)
            {
                Add-Content -Value ("Database|" + $wa.alternateurls[0].IncomingUrl + "|" + $database.Server + "/" + $database.Name + "|" + $database.DiskSizeRequired) -Path $filename
            }
            foreach ($site in $wa.Sites) {
                Add-Content -Value ("Site Collection|" + $site.ContentDatabase.Server + "/" + $site.ContentDatabase.Name + "|" + $site.Url + "|" + $site.Usage.Storage) -Path $filename
                try {
                    foreach ($web in $site.AllWebs) {
                        $masterUrlSplit=$web.MasterUrl.Split("/");
                        $customMasterUrlSplit=$web.CustomMasterUrl.Split("/");
                        Add-Content -Value ("Web site||" + $web.Url + "||" + $masterUrlSplit[$masterUrlSplit.Length-1] + "|" + $customMasterUrlSplit[$customMasterUrlSplit.Length-1]) -Path $filename
                        try {
                            foreach($list in $web.Lists) {
                                Add-Content -Value ("List|" + $list.BaseType + "|" + $web.Url + "/" + $list.RootFolder.Url) -Path $filename
                                try {
                                    if ($list.BaseType -eq "DocumentLibrary")
                                    {
                                        try {
                                            foreach ($folder in $list.Folders) {
                                                Add-Content -Value ("Folder||" + $web.Url + "/" + $folder.Url) -Path $filename
                                            	try {
                                                    foreach ($file in $web.GetFolder($folder.Url).Files) {
                                                        Add-Content -Value ("File|" + $file.Item.ContentType.Name + "|" + $web.Url + "/" + $folder.Url + "/" + $file.Name + "|" + $file.Length + "|" + $file.TimeLastModified ) -Path $filename
                                                	}
                                            	}
                                            	catch { 
                                                	Add-Content -Value ("Folder|" + "|" + $web.Url + "/" + $folder.Url + "|" + $error[0]) -Path $logfilename
                                            	}
                                        	}
					                    }
					                    catch {
						                    Add-Content -Value ("List folders|" + $web.Url + "/" + $list.RootFolder.Url + "|" + $error[0]) -Path $logfilename
					                    }
					                    try {
                                        	foreach ($file in $web.GetFolder($list.RootFolder.Url).Files) {
                                            		Add-Content -Value ("File|" + $file.Item.ContentType.Name + "|" + $web.Url + "/" + $list.RootFolder.Url + "/" + $file.Name + "|" + $file.Length + "|" + $file.TimeLastModified ) -Path $filename
                                        	}
					                    }
					                    catch {
						                    Add-Content -Value ("Root folder|" + $web.Url + "/" + $list.RootFolder.Url + "|" + $error[0]) -Path $logfilename
					                    }
                                    }
                                }
                                catch { 
                                    Add-Content -Value ("List|" + $web.Url + "/" + $list.RootFolder.Url + "|" + $error[0]) -Path $logfilename
                                }
                            }
                        }
                        catch { 
                            Add-Content -Value ("Web site|" + $web.Url + "|" + $error[0]) -Path $logfilename
                        }
                    }
                }
                catch { 
                    Add-Content -Value ("Site Collection|" + $site.Url + "|" + $error[0]) -Path $logfilename
                }
            }
        }
        catch { 
            Add-Content -Value ("Web Application|" + $wa.alternateurls[0].IncomingUrl + "|" + $error[0]) -Path $logfilename
        }
    }
}
catch { 
    write-host ("Farm|" + $error[0])
}
