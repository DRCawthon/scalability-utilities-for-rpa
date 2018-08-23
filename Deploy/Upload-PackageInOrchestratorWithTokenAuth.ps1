function UploadPackageInOrchestratorWithTokenAuth
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
		HelpMessage = 'Package file')]
		[string]
		$PackageFile
	)

    #acquire token
    $token = Get-UiPathAuthToken -URL $OrchestratorURL -Username $UserName -Password $Password -TenantName $TenantName 
   
    #upload package
    Add-UiPathPackage -PackageFile $PackageFile -AuthToken $token
}