 #import UiPath cmdlets
New-Item -ItemType Directory -Force -Path ".\Temp"

    Write-Output "downloading Orchestrator PowerShell extension library..."
    $psArchiveName = 
    [Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
    $cl = New-Object System.Net.WebClient
    $url = "http://github.com/UiPath/orchestrator-powershell/files/2017288/UiPath.PowerShell.18.1.3.31520.zip"
    $filepath = "Temp\UiPath.PowerShell.18.1.3.31520.zip"
    $cl.DownloadFile($url,$filepath)

    Write-Output "Extracting Orchestrator PowerShell extension library..."
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($filepath, ".\Temp")

    Write-Output "Importing Orchestrator PowerShell extension library..."
    Import-Module ".\Temp\UiPath.PowerShell.dll"
