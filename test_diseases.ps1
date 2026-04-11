# Test Disease Labels API Endpoint
# Usage: .\test_diseases.ps1 -Token "YOUR_JWT_TOKEN"
# Or: .\test_diseases.ps1  (will prompt for token)

param(
    [string]$Token = ""
)

$BackendUrl = "http://192.168.1.122:4000/api"

Write-Host "=== Testing Disease Labels Endpoint ===" -ForegroundColor Cyan
Write-Host "Backend URL: $BackendUrl"
Write-Host ""

if ([string]::IsNullOrEmpty($Token)) {
    Write-Host "ERROR: No JWT token provided" -ForegroundColor Red
    Write-Host "Usage: .\test_diseases.ps1 -Token <JWT_TOKEN>" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Get token by running:" -ForegroundColor Yellow
    Write-Host @"
`$response = Invoke-WebRequest -Uri "http://192.168.1.122:4000/api/auth/login" `
  -Method POST `
  -Headers @{"Content-Type"="application/json"} `
  -Body '{"email":"test@example.com","password":"password123"}'

`$data = $response.Content | ConvertFrom-Json
`$token = `$data.data.token

.\test_diseases.ps1 -Token `$token
"@ -ForegroundColor Gray
    exit 1
}

Write-Host "Making request to: $BackendUrl/disease-labels" -ForegroundColor Green
Write-Host "Authorization: Bearer $($Token.Substring(0, [Math]::Min(20, $Token.Length)))..." -ForegroundColor Gray
Write-Host ""

try {
    $response = Invoke-WebRequest -Uri "$BackendUrl/disease-labels" `
        -Method GET `
        -Headers @{
            "Authorization" = "Bearer $Token"
            "Content-Type"  = "application/json"
        } `
        -ErrorAction Stop

    $HttpCode = $response.StatusCode
    $body = $response.Content | ConvertFrom-Json

    Write-Host "HTTP Status Code: $HttpCode" -ForegroundColor Green
    Write-Host ""
    Write-Host "Response Body:" -ForegroundColor Green
    Write-Host ($body | ConvertTo-Json -Depth 10)
    Write-Host ""

    # Count diseases
    $count = if ($body.data) { $body.data.Count } elseif ($body -is [array]) { $body.Count } else { 0 }
    
    if ($count -gt 0) {
        Write-Host "✓ SUCCESS: Found $count disease label(s)!" -ForegroundColor Green
    } else {
        Write-Host "⚠ WARNING: Endpoint returned 200 but no diseases found" -ForegroundColor Yellow
    }
}
catch {
    $statusCode = $_.Exception.Response.StatusCode.Value__
    Write-Host "HTTP Status Code: $statusCode" -ForegroundColor Red
    Write-Host ""
    
    if ($_.Exception.Response) {
        try {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $body = $reader.ReadToEnd() | ConvertFrom-Json
            Write-Host "Error Response:" -ForegroundColor Red
            Write-Host ($body | ConvertTo-Json -Depth 10)
        }
        catch {
            Write-Host "Response: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Host ""
    Write-Host "✗ FAILED: Could not fetch diseases" -ForegroundColor Red
    Write-Host ""
    Write-Host "Common Issues:" -ForegroundColor Yellow
    Write-Host "  • Status 401: Invalid or expired token"
    Write-Host "  • Status 404: Endpoint not implemented"
    Write-Host "  • Status 500: Backend error (check server logs)"
    Write-Host "  • Connection refused: Backend not running"
}
