param (
    [Parameter(Mandatory = $true)]
    [string]$owner,
    
    [Parameter(Mandatory = $true)]
    [string]$repo,
    
    [Parameter(Mandatory = $true)]
    [string]$token,
    
    [Parameter(Mandatory = $true)]
    [string]$branch
)

# GitHub API URL to retrieve closed pull requests
$url = "https://api.github.com/repos/$owner/$repo/pulls?state=closed"

# Set up the headers including the authorization token
$headers = @{
    "Authorization" = "Bearer $token"
    "Accept" = "application/vnd.github.v3+json"
}

# Get today's date
$today = Get-Date -Format "yyyy-MM-dd"

# Make the API request to get the closed pull requests
$response = Invoke-RestMethod -Uri $url -Headers $headers -Method Get

# Initialize an array to store pull request data
$prData = @()

# Iterate through the response to extract pull request information
foreach ($pr in $response) {
    $prNumber = $pr.number
    $prTitle = $pr.title
    $prClosedBy = $pr.user.login
    $prClosedAt = $pr.closed_at
    $prBaseBranch = $pr.base.ref

    # Check if the pull request was merged to the specified branch and closed today
    if (($prClosedAt -like "$today*") -and ($prBaseBranch -eq $branch)) {
        # Add pull request data to the array
        $prData += [PSCustomObject]@{
            'PR Number' = $prNumber
            'Title' = $prTitle
            'Closed By' = $prClosedBy
            'Closed At' = $prClosedAt
            'Base Branch' = $prBaseBranch
        }
    }
}

# Export pull request data to CSV
$csvFilePath = "Closed_PRs_$($owner)_$($repo)_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
$prData | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "Closed pull request data has been exported to $csvFilePath."
