# deploy-gcp.ps1 — Deploy Python AI + Voice Translation to GCP Cloud Run
# Usage: .\deploy-gcp.ps1 [all|python|voice]

param(
    [string]$Service = "all"
)

$PROJECT = "orbit-classroom"
$REGION = "asia-south1"
$REPO = "asia-south1-docker.pkg.dev/$PROJECT/orbit-repo"

Write-Host "`n======================================" -ForegroundColor Cyan
Write-Host "  ORBIT — GCP Cloud Run Deployer" -ForegroundColor Cyan
Write-Host "  (Python AI + Voice Translation)" -ForegroundColor Cyan
Write-Host "======================================`n" -ForegroundColor Cyan

function Deploy-Python {
    Write-Host "📦 Building & Deploying Python AI Service..." -ForegroundColor Yellow
    Push-Location c:\ORBIT\backend\python
    gcloud builds submit --tag "$REPO/orbit-python:latest" --project $PROJECT
    if ($LASTEXITCODE -ne 0) { Write-Host "❌ Python build failed!" -ForegroundColor Red; Pop-Location; return }
    
    gcloud run deploy orbit-python `
        --image "$REPO/orbit-python:latest" `
        --region $REGION `
        --project $PROJECT `
        --platform managed `
        --allow-unauthenticated `
        --port 8000 `
        --memory 2Gi `
        --cpu 1 `
        --min-instances 0 `
        --max-instances 2 `
        --timeout 300 `
        --set-env-vars "GEMINI_API_KEY=AIzaSyDoV90Lt8FaCPuQBqv6hX-aaEkV7t8AocE"
    Pop-Location
    
    $url = gcloud run services describe orbit-python --region $REGION --project $PROJECT --format="value(status.url)" 2>$null
    Write-Host "✅ Python AI deployed at: $url" -ForegroundColor Green
}

function Deploy-Voice {
    Write-Host "📦 Building & Deploying Voice Translation (takes ~5-10 min)..." -ForegroundColor Yellow
    Push-Location c:\ORBIT\backend\voice_translation
    gcloud builds submit --tag "$REPO/orbit-voice:latest" --project $PROJECT --timeout=1200
    if ($LASTEXITCODE -ne 0) { Write-Host "❌ Voice build failed!" -ForegroundColor Red; Pop-Location; return }
    
    gcloud run deploy orbit-voice `
        --image "$REPO/orbit-voice:latest" `
        --region $REGION `
        --project $PROJECT `
        --platform managed `
        --allow-unauthenticated `
        --port 8001 `
        --memory 2Gi `
        --cpu 2 `
        --min-instances 0 `
        --max-instances 2 `
        --timeout 600 `
        --concurrency 1
    Pop-Location
    
    $url = gcloud run services describe orbit-voice --region $REGION --project $PROJECT --format="value(status.url)" 2>$null
    Write-Host "✅ Voice Translation deployed at: $url" -ForegroundColor Green
}

switch ($Service.ToLower()) {
    "python" { Deploy-Python }
    "voice"  { Deploy-Voice }
    "all" {
        Deploy-Python
        Deploy-Voice
        Write-Host "`n🎉 Both services deployed!" -ForegroundColor Green
        Write-Host "👉 Now go to Render Dashboard and set VOICE_API_URL env var" -ForegroundColor Yellow
    }
    default {
        Write-Host "Usage: .\deploy-gcp.ps1 [all|python|voice]" -ForegroundColor Yellow
    }
}

Write-Host "`n📋 Deployed Services:" -ForegroundColor Cyan
gcloud run services list --region $REGION --project $PROJECT
