# The nuget.exe has to be in the folder that contains the projects that are to be built
# It also relies on Create-NuspecFromStudioProject.ps1 

param(
	[Parameter(Mandatory = $true, Position = 1)]
	[string] $projectFolder,
	
	[Parameter(Mandatory = $false, Position = 2)]
	[string] $projectRevisionVersion
)

Write-Host "projectDirectory: " $projectFolder.ToString() 

$currentFolder = (Get-Item -Path ".\").ToString() + $projectFolder.ToString()
$nuspecPath = (Get-Item -Path ".\").ToString() + "\" + $projectFolder.ToString() + ".nuspec"

Write-Host "nuspecPath: " $nuspecPath

.\Create-NuspecFromStudioProject.ps1 -projectDirectory $projectFolder.ToString() -nuspecPath $nuspecPath.ToString() -projectRevisionVersion $projectRevisionVersion

.\NuGet.exe pack $nuspecPath