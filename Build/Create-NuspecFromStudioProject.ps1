param(
    [Parameter(Mandatory = $true, Position = 1)]
    [string] $projectDirectory,

    [Parameter(Mandatory = $true, Position = 2)]
    [string] $nuspecPath,
	
	[Parameter(Mandatory = $false, Position = 3)]
	[string] $projectRevisionVersion
)

$ErrorActionPreference = "Stop"

$projectPath = Join-Path $projectDirectory "project.json"

if (!(Test-Path -Path $projectDirectory -PathType Container)) {
    Write-Error "The project directory '$projectDirectory' was not found"
    Exit 1
}

if (!(Test-Path -Path $projectPath -PathType Leaf)) {
    Write-Error "The project file '$projectPath' was not found"
    Exit 1
}

$projectMetadata = Get-Content $projectPath | ConvertFrom-Json

$filesToInclude = Get-ChildItem (Join-Path $projectDirectory "**\*.*") -Recurse | Resolve-Path -Relative | ForEach-Object {
    $_ -replace "^\.\\",""
}

$nuspec = New-Object System.Xml.XmlDocument

$xmlDeclarationNode = $nuspec.CreateXmlDeclaration("1.0", $null, $null)
$packageNode = $nuspec.CreateElement("package")
$metadataNode = $nuspec.CreateElement("metadata")

$idNode = $nuspec.CreateElement("id")
$versionNode = $nuspec.CreateElement("version")
$authorsNode = $nuspec.CreateElement("authors")
$ownersNode = $nuspec.CreateElement("owners")
$licenseNode = $nuspec.CreateElement("requireLicenseAcceptance")
$descriptionNode = $nuspec.CreateElement("description")
$dependenciesNode = $nuspec.CreateElement("dependencies")
$filesNode = $nuspec.CreateElement("files")

$projectName = $projectMetadata.name
$projectDescription = $projectMetadata.description

$projectVersion = $projectMetadata.projectVersion

# override project version if specified
if ($projectRevisionVersion) {
	$projectVersionTokens = $projectVersion.split(".")
	$projectVersionLastTwoParts = ""
	
	if ($projectRevisionVersion.length -gt 5) {
		$projectVersionLastTwoParts = $projectRevisionVersion.substring(0, $projectRevisionVersion.length - 5) + 
										"." + 
										$projectRevisionVersion.substring($projectRevisionVersion.length - 5, 5)
	}
	else {
		$projectVersionLastTwoParts = "0." + $projectRevisionVersion
	}
	
	$projectVersion = $projectVersionTokens[0] + "." + $projectVersionTokens[1] + "." + $projectVersionLastTwoParts;
}

$currentUserWithoutDomain = $ENV:USERNAME -replace "^.+\\",""

$projectDependencies = if ($projectMetadata.dependencies) {
    $projectMetadata.dependencies | Get-Member -MemberType *Property | ForEach-Object {

        $property = $_.Name
        $value = $projectMetadata.dependencies."$property"

        return @{
            id = $property;
            version = $value;
        }
    }
} else {
    @()
}

$idNode.InnerText = $projectName
$versionNode.InnerText = $projectVersion
$authorsNode.InnerText = $currentUserWithoutDomain
$ownersNode.InnerText = $currentUserWithoutDomain
$licenseNode.InnerText = "false"
$descriptionNode.InnerText = $projectDescription

$projectDependencies | ForEach-Object {

    $dependencyNode = $nuspec.CreateElement("dependency")

    $dependencyNode.SetAttribute("id", $_.id)
    $dependencyNode.SetAttribute("version", $_.version)

    $dependenciesNode.AppendChild($dependencyNode) | Out-Null
}

$filesToInclude | ForEach-Object {

    $fileNode = $nuspec.CreateElement("file")

    $fileNode.SetAttribute("src", $_)
	$targetFile = $_
	$targetFile = if ($_.StartsWith($projectDirectory)) { $_.Remove(0, $projectDirectory.Length + 1) }
		
    $fileNode.SetAttribute("target", "lib\net45\" + (Split-Path -Path $targetFile))

    $filesNode.AppendChild($fileNode) | Out-Null
}

$metadataNode.AppendChild($idNode) | Out-Null
$metadataNode.AppendChild($versionNode) | Out-Null
$metadataNode.AppendChild($authorsNode) | Out-Null
$metadataNode.AppendChild($ownersNode) | Out-Null
$metadataNode.AppendChild($licenseNode) | Out-Null
$metadataNode.AppendChild($descriptionNode) | Out-Null
$metadataNode.AppendChild($dependenciesNode) | Out-Null

$packageNode.SetAttribute("xmlns", "http://schemas.microsoft.com/packaging/2010/07/nuspec.xsd")

$packageNode.AppendChild($metadataNode) | Out-Null
$packageNode.AppendChild($filesNode) | Out-Null

$nuspec.AppendChild($xmlDeclarationNode) | Out-Null
$nuspec.AppendChild($packageNode) | Out-Null

$nuspec.Save($nuspecPath)
