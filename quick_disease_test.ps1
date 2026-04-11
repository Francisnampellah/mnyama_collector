# Quick test to see the exact response from /api/disease-labels
# Usage: .\quick_disease_test.ps1 -Email "email@example.com" -Password "password"

param(
    [string]$Email = "trainer@example.com",
    [string]$Password = "password123"
)

$BackendUrl = "http://192.168.1.122:4000/api"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Disease Labels API Response Test" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Step 1: Login to get token
Write-Host "Step 1: Getting JWT token..." -ForegroundColor Yellow
try {
    $loginResponse = Invoke-WebRequest -Uri "$BackendUrl/auth/login" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body @{
            email    = $Email
            password = $Password
        } | ConvertFrom-Json

    if ($loginResponse.data.token) {
        $token = $loginResponse.data.token
        Write-Host "✓ Login successful!" -ForegroundColor Green
        Write-Host "  Token: $($token.Substring(0, 30))..." -ForegroundColor Gray
    }
    else {
        Write-Host "✗ No token in response!" -ForegroundColor Red
        Write-Host "Response: $($loginResponse | ConvertTo-Json -Depth 5)"
        exit 1
    }
}
catch {
    Write-Host "✗ Login failed!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Step 2: Fetching diseases from $BackendUrl/disease-labels" -ForegroundColor Yellow

# Step 2: Fetch diseases
try {
    $response = Invoke-WebRequest -Uri "$BackendUrl/disease-labels" `
        -Method GET `
        -Headers @{
            "Authorization" = "Bearer $token"
            "Content-Type"  = "application/json"
        }

    $statusCode = $response.StatusCode
    $contentLength = $response.Content.Length
    
    Write-Host "✓ Request successful!" -ForegroundColor Green
    Write-Host "  Status Code: $statusCode" -ForegroundColor Gray
    Write-Host "  Response Size: $contentLength bytes" -ForegroundColor Gray
    Write-Host ""

    # Parse response
    $data = $response.Content | ConvertFrom-Json

    Write-Host "Response Structure:" -ForegroundColor Yellow
    Write-Host "  Type: $($data.GetType().Name)" -ForegroundColor Gray
    
    if ($data -is [Array]) {
        Write-Host "  Format: Direct Array" -ForegroundColor Green
        Write-Host "  Count: $($data.Count)" -ForegroundColor Gray
    }
    elseif ($data -is [PSObject]) {
        Write-Host "  Format: Object" -ForegroundColor Green
        Write-Host "  Keys: $($data.PSObject.Properties.Name -join ', ')" -ForegroundColor Gray
        
        # Check common keys
        if ($data.data) {
            Write-Host "  ✓ Has 'data' property" -ForegroundColor Green
            Write-Host "    data type: $($data.data.GetType().Name)" -ForegroundColor Gray
            if ($data.data -is [Array]) {
                Write-Host "    data count: $($data.data.Count)" -ForegroundColor Gray
            }
        }
        if ($data.diseases) {
            Write-Host "  ✓ Has 'diseases' property" -ForegroundColor Green
            Write-Host "    diseases type: $($data.diseases.GetType().Name)" -ForegroundColor Gray
        }
    }

    Write-Host ""
    Write-Host "First Disease Object:" -ForegroundColor Yellow
    
    # Get first disease
    if ($data -is [Array] -and $data.Count -gt 0) {
        $first = $data[0]
    }
    elseif ($data.data -and $data.data.Count -gt 0) {
        $first = $data.data[0]
    }
    elseif ($data.diseases -and $data.diseases.Count -gt 0) {
        $first = $data.diseases[0]
    }
    else {
        $first = $null
    }

    if ($first) {
        Write-Host ($first | ConvertTo-Json -Depth 3) -ForegroundColor Gray
    }
    else {
        Write-Host "No disease objects found in response!" -ForegroundColor Red
        Write-Host "Full response:" -ForegroundColor Gray
        Write-Host ($data | ConvertTo-Json -Depth 5) -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "Total Diseases Count: $(
        if ($data -is [Array]) { $data.Count }
        elseif ($data.data) { $data.data.Count }
        elseif ($data.diseases) { $data.diseases.Count }
        else { 'Unknown' }
    )" -ForegroundColor Cyan

}
catch {
    Write-Host "✗ Request failed!" -ForegroundColor Red
    Write-Host "Status: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Red
    
    try {
        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
        $errorBody = $reader.ReadToEnd()
        Write-Host "Error Response: $errorBody" -ForegroundColor Red
    }
    catch { }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
