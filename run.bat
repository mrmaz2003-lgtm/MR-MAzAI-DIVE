@echo off
title AI DIVE Auto Launcher
cd /d "%~dp0"

echo [1/3] Starting Python FastAPI Backend...
start /min "" cmd /c ".venv\Scripts\python.exe -m backend.main"

echo [2/3] Starting Next.js Frontend...
cd frontend
start /min "" cmd /c "npm run dev"

echo [3/3] Opening application in browser...
timeout /t 4 >nul
start http://localhost:3000