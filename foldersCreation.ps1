$web = Get-SPWeb http://unisp2016sp01.westeurope.cloudapp.azure.com
$list = $web.Lists["LargeList"]
for($i=11; $i -le 4999; $i++)
{
    $folder = $list.AddItem("", [Microsoft.SharePoint.SPFileSystemObjectType]::Folder, "folder$i")
    $folder["Title"] = "folder$i"
    $folder.Update();
}
