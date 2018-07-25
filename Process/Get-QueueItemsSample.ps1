# Gets queue items filtered by reference

function GetQueueItemsSample
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
		$Reference
	)

    Write-Host "Get token"
    $token = Get-UiPathAuthToken -URL $OrchestratorURL -Username $UserName -Password $Password -TenantName $TenantName 
   
    Write-Host "Make the request for queue items"
    $URI = $OrchestratorURL + "/odata/QueueItems"
    $Headers = @{
			Authorization = 'Bearer ' + $token.Token
		}
    
    $boundary = [Guid]::NewGuid().ToString()
    $contentType = 'multipart/form-data; boundary={0}' -f $boundary

    $getQueueItemsResponse = (Microsoft.PowerShell.Utility\Invoke-RestMethod -Uri $URI -Method GET -ContentType $contentType -Headers $Headers -ErrorAction Stop -WarningAction SilentlyContinue)
    $getQueueItemsResponse

    Write-Host "Found " $getQueueItemsResponse.$odata.count " transactions"
    $queueItemsExportFileName = "queue items with reference " + $Reference + ".json" # change the naming as you wish
    $getQueueItemsResponse | ConvertTo-Json > $queueItemsExportFileName
}

#GetQueueItemsSample


GetQueueItemsSample -OrchestratorURL "https://demo.uipath.com" -UserName "user" -Password "pwd" -TenantName "tenant" -Reference "Type A"