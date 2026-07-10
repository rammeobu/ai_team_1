<#
.SYNOPSIS
  OpenRouter API 키가 유효한지 로컬에서 바로 확인합니다(앱 재빌드 불필요).
  키는 이 스크립트를 실행하는 사람의 화면에만 표시되고 어디로도 전송되지 않습니다
  (OpenRouter API 서버로 보내는 것 외에는).

.USAGE
  .\scripts\test_openrouter_key.ps1 -ApiKey "sk-or-v1-..."

  또는 키를 매번 입력하기 번거로우면 환경변수로 등록해두고 실행:
  $env:OPENROUTER_API_KEY = "sk-or-v1-..."
  .\scripts\test_openrouter_key.ps1
#>

param(
    [string]$ApiKey = $env:OPENROUTER_API_KEY
)

if ([string]::IsNullOrWhiteSpace($ApiKey)) {
    Write-Host 'API 키를 입력해주세요.' 
    exit 1
}

# 앱(openrouter_service.dart)이 실제로 보내는 것과 동일한 모델/요청 형태.
$model = "openai/gpt-4o-mini"
$body = @{
    model    = $model
    messages = @(
        @{ role = "user"; content = "say hi in one word" }
    )
} | ConvertTo-Json -Depth 5

Write-Host "OpenRouter에 테스트 요청을 보내는 중... (model: $model)" -ForegroundColor Cyan

try {
    $response = Invoke-RestMethod `
        -Uri "https://openrouter.ai/api/v1" `
        -Method Post `
        -Headers @{
            "Authorization" = "Bearer $ApiKey"
            "Content-Type"  = "application/json"
        } `
        -Body $body

    Write-Host "`n키가 정상 동작합니다." -ForegroundColor Green
    Write-Host ($response.choices[0].message.content)
}
catch {
    Write-Host "`n요청이 실패했습니다." -ForegroundColor Red
    $webResponse = $_.Exception.Response
    if ($webResponse) {
        $status = [int]$webResponse.StatusCode
        $stream = $webResponse.GetResponseStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $errorBody = $reader.ReadToEnd()
        Write-Host "HTTP $status" -ForegroundColor Red
        Write-Host $errorBody
    }
    else {
        Write-Host $_.Exception.Message
    }
}

