# This script is intended to be a Jenkins build step
#
# It has the following functionality: 
# 1. Takes the sources from source control (SVN)
# 2. Creates the nuget package of the project
# 3. Publishes the package in Orchestrator
#
# It requires the following: 
# 1. Environment variables: ORCH_USERNAME, ORCH_PASSWORD, SVN_REVISION 
# 2. Binaries: nuget.exe
# 3. Scripts: Create-NuspecAndPack.ps1 and Create-NuspecFromStudioProject.ps1 (located in the Build folder of current repository)
#
try {
    $username = "$($env:ORCH_USERNAME)"
    $pwd = "$($env:ORCH_PASSWORD)"

    #########make params in build############
    $orchURL = "https://demo-orch.deskover.local"
    $tenantName = "default"

    $svnCheckoutFolder = "svn_contents" #folder that was setup as "Local module directory" in SVN step
    $projectFolderName = "WeatherReporter"

    ########################################

    Set-Location "$($env:WORKSPACE)\$($svnCheckoutFolder)"

    #copy scripts and nuget.exe stored in SVN repository to new folder
    Copy-Item -Path "$($env:WORKSPACE)\$($svnCheckoutFolder)\binaries\*" -Destination "$($env:WORKSPACE)\$($svnCheckoutFolder)"

    Write-Output "creating .nupkg file..."
    Write-Output "svn revision number is: " $env:SVN_REVISION

    ## $latestrevnum should be per project/process/folder

    $latestrevnum = $env:SVN_REVISION

    ## check if orchestrator already has this version, if so - stop
    #run script to create package from specific folder
    .\Create-NuspecAndPack.ps1 -projectFolder $projectFolderName -projectRevisionVersion $latestrevnum

    #import UiPath cmdlets
    Write-Output "downloading Orchestrator PowerShell extension library..."
    $psArchiveName = 
    [Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $cl = New-Object System.Net.WebClient
    $url = "http://github.com/UiPath/orchestrator-powershell/files/2017288/UiPath.PowerShell.18.1.3.31520.zip"
    $filepath = "$($env:WORKSPACE)\$($svnCheckoutFolder)\UiPath.PowerShell.18.1.3.31520.zip"
    $cl.DownloadFile($url,$filepath)

    Write-Output "Extracting Orchestrator PowerShell extension library..."
    $shellApp = New-Object -Com shell.application
    $zipFile = $shellApp.namespace($filepath)
    $destination = $shellApp.namespace("$($env:WORKSPACE)\$($svnCheckoutFolder)\")
    $destination.Copyhere($zipFile.items())

    Write-Output "Importing Orchestrator PowerShell extension library..."
    Import-Module "$($env:WORKSPACE)\$($svnCheckoutFolder)\UiPath.PowerShell.dll"

    #find out the name of package
    [xml]$projectMetadata = Get-Content "$($projectFolderName).nuspec"
    $packageName = ($projectMetadata.package.metadata.id.ToString() + "." + $projectMetadata.package.metadata.version.ToString() + ".nupkg")
    Write-Output "Expected package name is $($packageName)"

    #upload package
    Write-Output "Obtain login token for $($username)"
    
    $token = Get-UiPathAuthToken -URL $orchURL -Username $username -Password $pwd -TenantName $tenantName

    Add-UiPathPackage -PackageFile "$($env:WORKSPACE)\$($svnCheckoutFolder)\$($packageName)" -AuthToken $token

    #add commands to update jobs


}
catch {
    Write-Output $_.Exception.Message
    exit 222
}
