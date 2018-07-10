# Will go to Orchestrator and get he assets that match the given filter. 
# No filter specified will return all the assets from the tenant.

function GetAssetsFromOrchestrator
{
	[CmdletBinding()]
	param 
	(
		[Parameter(Mandatory = $true,
				ValueFromPipeline = $true,
		HelpMessage = 'Orchestrator URL')]
		[ValidateNotNullOrEmpty()]
		[string]
		$OrchestratorURL,
        [Parameter(Mandatory = $true,
				ValueFromPipeline = $true,
		HelpMessage = 'User Name')]
		[ValidateNotNullOrEmpty()]
		[string]
		$UserName,
        [Parameter(Mandatory = $true,
				ValueFromPipeline = $true,
		HelpMessage = 'Password')]
		[ValidateNotNullOrEmpty()]
		[string]
		$Password,
        [Parameter(Mandatory = $false,
				ValueFromPipeline = $true,
		HelpMessage = 'TenantName')]
		[string]
		$TenantName,
        [Parameter(Mandatory = $false,
				ValueFromPipeline = $true,
		HelpMessage = 'Filter for the get assets querry.')]
		[string]
		$Filter
	)

    Write-Host "Get token"
    $token = Get-UiPathAuthToken -URL $OrchestratorURL -Username $UserName -Password $Password -TenantName $TenantName 
   
    Write-Host "Make the request for assets" 
    $getAssetResponse = Get-UiPathAsset -AuthToken $token -Name $Filter
    Write-Host "Found " $getAssetResponse.count " assets"

    $assetsExportFileName = "assets" + [System.DateTime]::Now.Millisecond.ToString() + ".json" # change the naming as you wish

    $getAssetResponse | ConvertTo-Json > $assetsExportFileName
}

GetAssetsFromOrchestrator

#GetAssetsFromOrchestrator -OrchestratorURL "https://demo.uipath.com" -UserName "user" -Password "pwd" -TenantName "tenant" -Filter "ABCD"