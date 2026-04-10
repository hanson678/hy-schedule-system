@echo off
chcp 65001 >nul
cd /d "%~dp0"
title ZURU 河源排期入单系统
echo ================================================
echo   ZURU 河源排期入单系统
echo   http://localhost:5006
echo ================================================
echo.
"C:\Users\Administrator\AppData\Local\Programs\Python\Python312\python.exe" app.py
pause
