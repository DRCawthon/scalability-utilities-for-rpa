function UploadPackage
{
	[CmdletBinding()]
	param 
	(
		[Parameter(Mandatory = $true,
				ValueFromPipeline = $true,
		HelpMessage = 'Nuget package to upload, full path needed')]
		[ValidateNotNullOrEmpty()]
		[string]
		$FilePath
	)

	process
	{
		# Build the URI for our request
		$URI = 'https://platform.uipath.com/odata/Processes/UiPath.Server.Configuration.OData.UploadPackage'

		# Create our authentication header
		$Headers = @{
			Authorization = 'UiRobot c9b9129a-127a-4a7e-8d22-d876a947901a'
		}

		# The boundary is essential - Trust me, very essential
		$boundary = [Guid]::NewGuid().ToString()

		<#
				This is the crappy part: Build a body for a multipart request with PowerShell

				This is something that should be changed in PowerShell ASAP (I mean it is really crappy and really bad).

				It is an absolute no brainer with Curl.
		#>
		$bodyStart = @"
--$boundary
Content-Disposition: form-data; name="token"

--$boundary
Content-Disposition: form-data; name="files"; filename="$(Split-Path -Leaf -Path $FilePath)"
Content-Type: application/octet-stream


"@

		# Generate the end of the request body to finish it.
		$bodyEnd = @"

--$boundary--
"@

		# Now we create a temp file (Another crappy/bad thing)
		$requestInFile = (Join-Path -Path $env:TEMP -ChildPath ([IO.Path]::GetRandomFileName()))

		try
		{
			# Create a new object for the brand new temporary file
			$fileStream = (New-Object -TypeName 'System.IO.FileStream' -ArgumentList ($requestInFile, [IO.FileMode]'Create', [IO.FileAccess]'Write'))

			try
			{
				# The Body start
				$bytes = [Text.Encoding]::UTF8.GetBytes($bodyStart)
				$fileStream.Write($bytes, 0, $bytes.Length)

				# The original File
				$bytes = [IO.File]::ReadAllBytes($FilePath)
				$fileStream.Write($bytes, 0, $bytes.Length)

				# Append the end of the body part
				$bytes = [Text.Encoding]::UTF8.GetBytes($bodyEnd)
				$fileStream.Write($bytes, 0, $bytes.Length)
			}
			finally
			{
				# End the Stream to close the file
				$fileStream.Close()

				# Cleanup
				$fileStream = $null

				# PowerShell garbage collector
				[GC]::Collect()
			}

			# Make it multipart, this is the magic part...
			$contentType = 'multipart/form-data; boundary={0}' -f $boundary

			<#
					The request itself is simple and easy, also works fine with Invoke-WebRequest instead of Invoke-RestMethod

					I use Microsoft.PowerShell.Utility\Invoke-RestMethod to make sure the build in (Windows PowerShell native) function is used.
					If PowerShell Core is installed or any Module provides a tweaked version... Just in case!
			#>
			try
			{
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
				$null = (Microsoft.PowerShell.Utility\Invoke-RestMethod -Uri $URI -Method Post -InFile $requestInFile -ContentType $contentType -Headers $Headers -ErrorAction Stop -WarningAction SilentlyContinue)
			}
			catch
			{
				# PowerShell garbage collector
				[GC]::Collect()

				# For the Build logs (will not break the build)
				Write-Warning -Message 'StatusCode:' $_.Exception.Response.StatusCode.value__
				Write-Warning -Message 'StatusDescription:' $_.Exception.Response.StatusDescription

				# Saved in the verbose logs for this build
				Write-Verbose -Message $_

				# Inform the build and terminate (Will break the build)
				Write-Error -Message 'We were unable to upload your file to the BitBucket downloads section, please check the build logs for further information.' -ErrorAction Stop
			}
		}
		finally
		{
			# Remove the temp file
			$null = (Remove-Item -Path $requestInFile -Force -Confirm:$false)

			# Cleanup
			$contentType = $null

			# PowerShell garbage collector
			[GC]::Collect()
		}
	}
}

UploadPackage