# Check if the required modules are installed, and install them if not
if (!(Get-Module -Name MicrosoftPowerBIMgmt -ListAvailable)) {
  Install-Module -Name MicrosoftPowerBIMgmt
}

# A function to get the cluster URI for the tenant
function get-powerbiAPIclusterURI () {
  $reply = Invoke-RestMethod -uri "https://api.powerbi.com/v1.0/myorg/datasets" -Headers @{ "Authorization" = $token } -Method GET
  $unaltered = $reply.'@odata.context'
  $stripped = $unaltered.split('/')[2]
  $clusterURI = "https://$stripped/beta/myorg/groups"
  return $clusterURI
}

# A function to get the workspace usage metrics dataset ID
function getWorkspaceUsageMetrics($workspaceId) {
  $token =(Get-PowerBIAccessToken)["Authorization"]
  $url = get-powerbiAPIclusterURI
  $data = Invoke-WebRequest -Uri "$url/$workspaceId/usageMetricsReportV2?experience=power-bi" -Headers @{ "Authorization" = $token } -ErrorAction SilentlyContinue
  $response = $data.Content.ToString().Replace("nextRefreshTime", "NextRefreshTime").Replace("lastRefreshTime", "LastRefreshTime") | ConvertFrom-Json
  return $response.models[0].dbName
}

# Define the root path as the parent folder of the script
#$rootPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Get a list of tenants, one txt file pr tenant in the tenants folder
# The file should be named after tenant of the type Tenant.txt and contain username in the first line and password in the second
$tenants = Get-ChildItem -Path ".\tenants\" -file

# Loop through each tenant
foreach ($tenant in $tenants) {
  # Get the path to the credential file for the tenant
  $credentialPath = $tenant.fullname

  # Read the username and password from the credential file
  $credentials = Get-Content -Path $credentialPath
  $username = $credentials[0]
  $password = $credentials[1]

  # Convert the password to a secure string
  $securePassword = ConvertTo-SecureString $password -AsPlainText -Force

  # Create a PSCredential object from the username and secure password
  $credential = New-Object System.Management.Automation.PSCredential ($username, $securePassword)
  #reset token to empty string
  $token = ""
  $workspaces = ""
  # Connect to the Power BI service using the tenants credentials. 
  $con = Connect-PowerBIserviceaccount -Credential $credential
  #if the connection is successful, get the token and the workspaces
  if ($con -ne $null) {
    
    $token = (Get-PowerBIAccessToken)["Authorization"]
    
    # Get a list of all the workspaces in the tenant.
    $workspaces = Get-PowerBIWorkspace 
  }
  # Loop through each workspace
  foreach ($group in $workspaces) { 
    $groupId = $group.Id
    $workspacename = $group.Name

    # Write which workspaces have been processed into a file
    "$tenant, $workspacename, $groupId" | out-file -filePath ".\um_workspaces.csv" -Append

    # Write the name of the workspace to the console
    Write-host "Tenant: " $tenant
    Write-Host "Workspace: $workspacename"

    # Make a usage metrics report for the workspace
    $result = getWorkspaceUsageMetrics -workspaceId $groupId

    # Execute Queries
    # Get the data from Reports
    $reportbody = '{
    "queries": [
      {
        "query": "EVALUATE VALUES(Reports)"
      }
    ],
    "serializerSettings": {
      "includeNulls": true
    },
    "impersonatedUserName": "'+ $username + '"
  }'
    $headers = @{ 
      "Authorization" = $token
      "Content-Type"  = "application/json"

    }

    #Wait 10 sec
    Start-Sleep -s 10
    $reports = Invoke-RestMethod -uri "https://api.powerbi.com/v1.0/myorg/groups/$groupId/datasets/$result/executeQueries" -Headers $headers -Body $reportbody -Method Post
    $reports.results[0].tables[0].rows | export-csv -Path ".\um_reports.csv" -Append

    # Get the data from Users
    $usersbody = '{
    "queries": [
      {
        "query": "EVALUATE VALUES(Users)"
      }
    ],
    "serializerSettings": {
      "includeNulls": true
    },
    "impersonatedUserName": "'+ $username + '"
  }'
    $headers = @{ 
      "Authorization" = $token
      "Content-Type"  = "application/json"

    }
    $users = Invoke-RestMethod -uri "https://api.powerbi.com/v1.0/myorg/groups/$groupId/datasets/$result/executeQueries" -Headers $headers -Body $usersbody -Method Post
    $users.results[0].tables[0].rows | export-csv -Path ".\um_users.csv" -Append
 
    # Get the data from Report Pages
    $reportpagesbody = '{
  "queries": [
    {
      "query": "EVALUATE VALUES(''Report pages'')"
    }
  ],
  "serializerSettings": {
    "includeNulls": true
  },
  "impersonatedUserName": "'+ $username + '"
}'
    $headers = @{ 
      "Authorization" = $token
      "Content-Type"  = "application/json"

    }
    $reportpages = Invoke-RestMethod -uri "https://api.powerbi.com/v1.0/myorg/groups/$groupId/datasets/$result/executeQueries" -Headers $headers -Body $reportpagesbody -Method Post
    $reportpages.results[0].tables[0].rows | export-csv -Path ".\um_reportpages.csv" -Append

    # Get the data from Workspace Views
    $workspaceviewsbody = '{
  "queries": [
    {
      "query": "EVALUATE VALUES(''Workspace views'')"
    }
  ],
  "serializerSettings": {
    "includeNulls": true
  },
  "impersonatedUserName": "'+ $username + '"
}'
    $headers = @{ 
      "Authorization" = $token
      "Content-Type"  = "application/json"

    }
    $workspaceviews = Invoke-RestMethod -uri "https://api.powerbi.com/v1.0/myorg/groups/$groupId/datasets/$result/executeQueries" -Headers $headers -Body $workspaceviewsbody -Method Post
    $workspaceviews.results[0].tables[0].rows | export-csv -Path ".\um_workspaceviews.csv" -Append

    # Get the data from Report Views
    $reportviewsbody = '{
  "queries": [
    {
      "query": "EVALUATE VALUES(''Report views'')"
    }
  ],
  "serializerSettings": {
    "includeNulls": true
  },
  "impersonatedUserName": "'+ $username + '"
}'
    $headers = @{ 
      "Authorization" = $token
      "Content-Type"  = "application/json"

    }
    $reportviews = Invoke-RestMethod -uri "https://api.powerbi.com/v1.0/myorg/groups/$groupId/datasets/$result/executeQueries" -Headers $headers -Body $reportviewsbody -Method Post
    $reportviews.results[0].tables[0].rows | export-csv -Path ".\um_reportviews.csv" -Append

    # Get the data from Report Page Views
    $reportpageviewsbody = '{
  "queries": [
    {
      "query": "EVALUATE VALUES(''Report page views'')"
    }
  ],
  "serializerSettings": {
    "includeNulls": true
  },
  "impersonatedUserName": "'+ $username + '"
}'
    $headers = @{ 
      "Authorization" = $token
      "Content-Type"  = "application/json"

    }
    $reportpageviews = Invoke-RestMethod -uri "https://api.powerbi.com/v1.0/myorg/groups/$groupId/datasets/$result/executeQueries" -Headers $headers -Body $reportpageviewsbody -Method Post
    $reportpageviews.results[0].tables[0].rows | export-csv -Path ".\um_reportpageviews.csv" -Append

    # Get the data from Report Load Times
    $reportloadtimesbody = '{
  "queries": [
    {
      "query": "EVALUATE VALUES(''Report load times'')"
    }
  ],
  "serializerSettings": {
    "includeNulls": true
  },
  "impersonatedUserName": "'+ $username + '"
}'
    $headers = @{ 
      "Authorization" = $token
      "Content-Type"  = "application/json"

    }
    $reportloadtimes = Invoke-RestMethod -uri "https://api.powerbi.com/v1.0/myorg/groups/$groupId/datasets/$result/executeQueries" -Headers $headers -Body $reportloadtimesbody -Method Post
    $reportloadtimes.results[0].tables[0].rows | export-csv -Path ".\um_reportloadtimes.csv" -Append

    if ($result -eq $null) { "$tenant, $workspacename, $groupId" | out-file -filePath ".\um_errors.csv" -Append }

    #Wait 10 sec
    Start-Sleep -s 10  
  }

  #-------------------------------------------------------------------------
