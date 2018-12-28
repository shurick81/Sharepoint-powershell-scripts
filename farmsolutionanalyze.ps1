$OOBSolutions = @(
    "00000000-0000-0000-0000-000000000000",
    "7ed6cd55-b479-4eb7-a529-e99a24c10bd3",
    "a992b0f0-7b6b-4315-b687-649dcaeef726"
)
function Get-SPSolutionReport {
    param (
    )
    $report = @{
        Solutions = @();
        FeaturesActivation = @();
    };

    #Extracting all solutions and features
    Get-SPSolution | % {
        $solutionId = $_.SolutionId.Guid;
        Write-Host "Found solution $solutionId";
        $report.Solutions += @{
            Id = $solutionId;
            Name = $_.Name;
            Deployed = $_.Deployed;
            DeployedWebApplications = $_.DeployedWebApplications;
            DeploymentState = $_.DeploymentState;
            Features = @()
        }
        Get-SPFeature | ? { $_.SolutionId -eq $solutionId } | % {
            $featureId = $_.Id.Guid;
            Write-Host "Found feature $featureId";
            $selectedSolutionReport = $report.Solutions | ? { $_.Id -eq $solutionId }
            $selectedSolutionReport.Features += @{
                Id = $featureId;
                DisplayName = $_.DisplayName;
                Scope = $_.Scope;
                Activated = @{
                    Farm = $false;
                    WebApplications = @();
                    Sites = @();
                    WebSites = @();
                }
            }
        }
    }

    #Checking what features are activated on the farm
    Get-SPFeature -Farm | ? { $_.SolutionId.Guid -notin $OOBSolutions } | % {
        $featureId = $_.Id.Guid;
        $solutionId = $_.SolutionId.Guid;
        Write-Host "Found farm activated feature $featureId";
        $selectedSolutionReport = $report.Solutions | ? { $_.Id -eq $solutionId }
        $selectedFeatureReport = $selectedSolutionReport | % { $_.Features | ? { $_.Id -eq $featureId } }
        $selectedFeatureReport.Activated.Farm = $true;

        $report.FeaturesActivation += @{
            Id = $featureId;
            DisplayName = $_.DisplayName;
            SolutionId = $solutionId;
            SolutionName = $selectedSolutionReport.Name;
            Scope = $_.Scope;
        }
    }

    #Checking what features are activated on the web applications
    Get-SPWebApplication | % {
        $webAppName = $_.Name;
        Write-Host "Found web application $webAppName";
        Get-SPFeature -WebApplication $webAppName | ? { $_.SolutionId.Guid -notin $OOBSolutions } | % {
            $featureId = $_.Id.Guid;
            $solutionId = $_.SolutionId.Guid;
            Write-Host "Found activated feature $featureId";
            $selectedSolutionReport = $report.Solutions | ? { $_.Id -eq $solutionId }
            $selectedFeatureReport = $selectedSolutionReport | % { $_.Features | ? { $_.Id -eq $featureId } }
            $selectedFeatureReport.Activated.WebApplications += $webAppName

            $report.FeaturesActivation += @{
                Id = $featureId;
                DisplayName = $_.DisplayName;
                SolutionId = $solutionId;
                SolutionName = $selectedSolutionReport.Name;
                Scope = $_.Scope;
                Object = $webAppName
            }
        }

        #Checking what features are activated on the site collections
        $_.Sites | % {
            $siteUrl = $_.Url;
            Write-Host "Found site collection $siteUrl";
            Get-SPFeature -Site $siteUrl | ? { $_.SolutionId.Guid -notin $OOBSolutions } | % {
                $featureId = $_.Id.Guid;
                $solutionId = $_.SolutionId.Guid;
                if ( Get-SPFeature $featureId -ErrorAction Ignore )
                {
                    Write-Host "Found activated feature $featureId";
                    $selectedSolutionReport = $report.Solutions | ? { $_.Id -eq $solutionId }
                    $selectedFeatureReport = $selectedSolutionReport | % { $_.Features | ? { $_.Id -eq $featureId } }
                    $selectedFeatureReport.Activated.Sites += $siteUrl

                    $report.FeaturesActivation += @{
                        Id = $featureId;
                        DisplayName = $_.DisplayName;
                        SolutionId = $solutionId;
                        SolutionName = $selectedSolutionReport.Name;
                        Scope = $_.Scope;
                        Object = $siteUrl
                    }
                } else {
                    Write-Host "!!! Feature $featureId from solution $solutionId is not found in scope Local farm";
                }
            }
            #Checking what features are activated on the web sites
            $_.AllWebs | % {
                $webUrl = $_.Url;
                Write-Host "Found web site $webUrl";
                Get-SPFeature -Web $webUrl | ? { $_.SolutionId.Guid -notin $OOBSolutions } | % {
                    $featureId = $_.Id.Guid;
                    $solutionId = $_.SolutionId.Guid;
                    if ( Get-SPFeature $featureId -ErrorAction Ignore )
                    {
                        Write-Host "Found activated feature $featureId";
                        $selectedSolutionReport = $report.Solutions | ? { $_.Id -eq $solutionId }
                        $selectedFeatureReport = $selectedSolutionReport | % { $_.Features | ? { $_.Id -eq $featureId } }
                        $selectedFeatureReport.Activated.WebSites += $webUrl

                        $report.FeaturesActivation += @{
                            Id = $featureId;
                            DisplayName = $_.DisplayName;
                            SolutionId = $solutionId;
                            SolutionName = $selectedSolutionReport.Name;
                            Scope = $_.Scope;
                            Object = $webUrl
                        }
                    } else {
                        Write-Host "!!! Feature $featureId from solution $solutionId is not found in scope Local farm";
                    }
                }
            }
        }
    }
    return $report;
}
$spSolutionReport = Get-SPSolutionReport;

#Subreports
$webAppName = "Intranet";
Write-Host "Farm features:";
$spSolutionReport.Solutions | % { $solutionName = $_.Name; $_.Features | ? { $_.Activated.Farm } | % { Write-Host "$($_.DisplayName) feature from $solutionName" } }
Write-Host "Web Application features:";
$spSolutionReport.Solutions | % { $solutionName = $_.Name; $_.Features | ? { $webAppName -in $_.Activated.WebApplications } | % { Write-Host "$($_.DisplayName) feature from $solutionName" } }
$siteUrls = @();
$webUrls = @();
$wa = Get-SPWebApplication $webAppName;
$wa.Sites | % {
    $siteUrls += $_.Url;
    $_.AllWebs | % {
        $webUrls += $_.Url;
    }
};
Write-Host "Site collection features:";
$spSolutionReport.Solutions | % {
    $solutionName = $_.Name;
    $_.Features | % {
        $solutionFeatureReport = $_;
        if ( $siteUrls | ? { $_ -in $solutionFeatureReport.Activated.Sites } ) {
            Write-Host "$($_.DisplayName) feature from $solutionName"
        }
    }
}
Write-Host "Web site features:";
$spSolutionReport.Solutions | % {
    $solutionName = $_.Name;
    $_.Features | % {
        $solutionFeatureReport = $_;
        if ( $webUrls | ? { $_ -in $solutionFeatureReport.Activated.WebSites } ) {
            Write-Host "$($_.DisplayName) feature from $solutionName"
        }
    }
}
