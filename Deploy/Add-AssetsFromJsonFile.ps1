# Reads the assets from a json file and pushes them into Orchestrator. 

function AddAssetsFromJsonFile
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
		HelpMessage = 'File that contains the assets in a json format.')]
		[string]
		$File
    )

    $assets = Get-Content -Raw -Path $File | ConvertFrom-Json

    Write-Host "Found " $assets.Count " assets."

    Write-Host "Get token"
    $token = Get-UiPathAuthToken -URL $OrchestratorURL -Username $UserName -Password $Password -TenantName $TenantName 
    
    Write-Host "Push the assets to Orchestrator" 
    
    $assets | ForEach-Object {

        $assetName = $_.Name
        $assetValue = $_.Value
        $assetCredential = $_.Credential

        switch ($_.ValueType) {
            2 { 
                Write-Host "Add text asset " $assetName " with value: " $assetValue
                $addAssetResponse = Add-UiPathAsset -AuthToken $token -Name $assetName -TextValue $assetValue
            }
            3 {
                Write-Host "Add bool asset " $assetName " with value: " $assetValue
                $addAssetResponse = Add-UiPathAsset -AuthToken $token -Name $assetName -BoolValue $assetValue
            }
            4 {
                Write-Host "Add int asset " $assetName " with value: " $assetValue
                $addAssetResponse = Add-UiPathAsset -AuthToken $token -Name $assetName -IntValue $assetValue
            }
            5 {
                $secpasswd = ConvertTo-SecureString "nopassword" -AsPlainText -Force
                $credential = New-Object System.Management.Automation.PSCredential ($assetCredential.UserName, $secpasswd)
                #todo: add also password if you wish

                Write-Host "Add credential asset " $assetName " with value: " $assetValue
                $addAssetResponse = Add-UiPathAsset -AuthToken $token -Name $assetName -Credential $credential
            }
        }
    }

}

AddAssetsFromJsonFile

#AddAssetsFromJsonFile -OrchestratorURL "https://demo.uipath.com" -UserName "user" -Password "pwd" -TenantName "tenant" -File "1234 assets.json"