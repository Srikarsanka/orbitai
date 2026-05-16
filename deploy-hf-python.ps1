# deploy-hf-python.ps1 - Deploy Python AI to Hugging Face Spaces

$REPO_URL = "https://huggingface.co/spaces/srikar048/orbit-python-ai"
$CLONE_DIR = "c:\ORBIT\orbit-python-ai"
$SOURCE_DIR = "c:\ORBIT\backend\python"

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Deploying Python AI to Hugging Face" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Clone the repo if it doesn't exist
if (-not (Test-Path $CLONE_DIR)) {
    Write-Host "Cloning repository..." -ForegroundColor Yellow
    git clone $REPO_URL $CLONE_DIR
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Failed to clone repository. Make sure you entered the right URL." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "Repository already cloned at $CLONE_DIR" -ForegroundColor Green
    Push-Location $CLONE_DIR
    git pull
    Pop-Location
}

# 2. Copy all files from backend/python to the HF repo folder
Write-Host "Copying files to the Hugging Face repo..." -ForegroundColor Yellow
Copy-Item -Path "$SOURCE_DIR\*" -Destination $CLONE_DIR -Recurse -Force
Copy-Item -Path "$SOURCE_DIR\.dockerignore" -Destination $CLONE_DIR -Force

# 3. Commit and push the changes
Push-Location $CLONE_DIR

Write-Host "Adding changes to git..." -ForegroundColor Yellow
git add .
git commit -m "Deploy Python AI to Hugging Face Spaces"

Write-Host ""
Write-Host "Pushing to Hugging Face!" -ForegroundColor Cyan
Write-Host "NOTE: You will be prompted for your Hugging Face credentials." -ForegroundColor Yellow
Write-Host "For the password, you MUST use a Hugging Face Access Token (Role: Write)." -ForegroundColor Yellow
Write-Host "Get one here: https://huggingface.co/settings/tokens" -ForegroundColor Yellow
Write-Host ""

git push origin main --force

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Successfully pushed! Check your space at: $REPO_URL" -ForegroundColor Green
    Write-Host "Don't forget to add your GEMINI_API_KEY in the Hugging Face Space Settings -> Variables and secrets" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Push failed. Did you use your Access Token as the password?" -ForegroundColor Red
}

Pop-Location
