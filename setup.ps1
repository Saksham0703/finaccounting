# FinAI Accounting — One-Click Setup Script
# Run this script after installing Node.js (https://nodejs.org)
# Usage: Right-click → "Run with PowerShell"

Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║      🧮 FinAI Accounting — Setup          ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Check Node.js
try {
    $nodeVersion = node --version 2>&1
    Write-Host "✅ Node.js found: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Node.js not found!" -ForegroundColor Red
    Write-Host "   Please install from: https://nodejs.org/en/download" -ForegroundColor Yellow
    Write-Host "   Then re-run this script." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check PostgreSQL
Write-Host ""
Write-Host "⚠️  Make sure PostgreSQL is running on localhost:5432" -ForegroundColor Yellow
Write-Host "   Default DB: finai_accounting" -ForegroundColor Yellow
Write-Host "   Create it with: CREATE DATABASE finai_accounting;" -ForegroundColor Yellow
Write-Host ""
$answer = Read-Host "Is PostgreSQL running and database created? (y/n)"
if ($answer -ne 'y' -and $answer -ne 'Y') {
    Write-Host "Please setup PostgreSQL first, then re-run this script." -ForegroundColor Red
    exit 1
}

# Get DB password
$dbPassword = Read-Host "Enter your PostgreSQL password (for user 'postgres')"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ── Backend Setup ─────────────────────────────────────────────
Write-Host ""
Write-Host "📦 Installing backend dependencies..." -ForegroundColor Cyan
Set-Location "$scriptDir\backend"

# Update .env with actual password
(Get-Content .env) -replace 'DB_PASSWORD=yourpassword', "DB_PASSWORD=$dbPassword" | Set-Content .env
Write-Host "✅ .env updated with DB password" -ForegroundColor Green

npm install
if ($LASTEXITCODE -ne 0) { Write-Host "❌ npm install failed" -ForegroundColor Red; exit 1 }
Write-Host "✅ Backend dependencies installed" -ForegroundColor Green

# Run migrations
Write-Host ""
Write-Host "🔄 Running database migrations..." -ForegroundColor Cyan
node src/database/migrate.js
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Migrations failed. Check your PostgreSQL connection." -ForegroundColor Red
    exit 1
}
Write-Host "✅ Database schema created" -ForegroundColor Green

# ── Frontend Setup ────────────────────────────────────────────
Write-Host ""
Write-Host "📦 Installing frontend dependencies..." -ForegroundColor Cyan
Set-Location "$scriptDir\frontend"
npm install
if ($LASTEXITCODE -ne 0) { Write-Host "❌ npm install failed" -ForegroundColor Red; exit 1 }
Write-Host "✅ Frontend dependencies installed" -ForegroundColor Green

# ── Done! ─────────────────────────────────────────────────────
Write-Host ""
Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         ✅ Setup Complete!                 ║" -ForegroundColor Green
Write-Host "╠════════════════════════════════════════════╣" -ForegroundColor Green
Write-Host "║                                            ║" -ForegroundColor Green
Write-Host "║  To start the app, open 2 terminals:      ║" -ForegroundColor Green
Write-Host "║                                            ║" -ForegroundColor Green
Write-Host "║  Terminal 1 (Backend):                    ║" -ForegroundColor Green
Write-Host "║    cd backend                              ║" -ForegroundColor Green
Write-Host "║    npm run dev                             ║" -ForegroundColor Green
Write-Host "║                                            ║" -ForegroundColor Green
Write-Host "║  Terminal 2 (Frontend):                   ║" -ForegroundColor Green
Write-Host "║    cd frontend                             ║" -ForegroundColor Green
Write-Host "║    npm run dev                             ║" -ForegroundColor Green
Write-Host "║                                            ║" -ForegroundColor Green
Write-Host "║  Then open: http://localhost:3000          ║" -ForegroundColor Green
Write-Host "║                                            ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Read-Host "Press Enter to exit"
