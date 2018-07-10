# Scalability Utilities

Current repository contains scripts that will help you put in place a continuous integration and deployment mechanism for UiPath RPA projects.

It covers the following areas:

1. Build - takes an UiPath project folder and turns it into a nuget package ready to be shiped onto  robot machines (directly or via Orchestrator). 
Make sure you have project.json file containing the right dependencies. It can be updated automatically with a single Publish click in Studio.

2. Deploy 

Upload-Package.ps1: Takes a nuget package and ships it into an Orchestrator instance. It uses Robot Authentication.  
In order to aquire Robot Key to make the calls to Orchestrator please follow these steps:  
 a) Go to the target Orchestrator instance and add a dummy robot, with a fictional Name, Machine, and Username.  
 b) Then go to Users and check to view Robot users, you'll find the one that's associated with the newly created dummy robot.  
 c) Add 'Administrator' rights to that user.  
 d) Make this HTTP request: https://orchestratorURL/api/RobotsService/GetRobotMappings?licenseKey='key'&machineName='machine' . 
 It can be done in a browser easily. Its response will contain the license key that we're looking for. 
 The license key argument in this call is the Key you take from the Edit Robot view.
 
 Import-OrchestratorCmdlets.ps1: Gets the UiPath.PowerShell.dll and imports the cmdlets stored within for interacting with the Orchestrator API.
 
 Get-AssetsFromOrchestrator.ps1: Gets the assets from an Orchestrator tenant and saves them in a file using json format.  
 A filter can be passed so if tenant has assets ABCD_1, ABCD_2 and XXAA_3 and the filter is ABCD then the result will contain ABCD_1 and ABCD_2.
 Requires: Import-OrchestratorCmdlets
 
 Upload-AssetsInOrchestrator.ps1: Reads a file that contains the assets in json format exactly how Get-AssetsFromOrchestrator.ps1 exports. 
 The assets are being pushed to the specified Orchestrator's tenant. Supported types: Text, Bool, Integer, Credential. 
 Passwords are set to "nopassword" so that an admin can change them manually.
 TBD: Per robot Assets
 Requires: Import-OrchestratorCmdlets
 
 3. Examples - scripts in which you'll see the main utilities in action
 