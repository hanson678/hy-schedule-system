@echo off
chcp 65001 >nul 2>&1
title 河源排期入单系统
setlocal enabledelayedexpansion

echo ══════════════════════════════════════════
echo   河源排期入单系统 - 智能启动
echo ══════════════════════════════════════════
echo.

:: ========== 1. 检测 Python ==========
set "PY="
where python >nul 2>&1
if %ERRORLEVEL%==0 (
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do set "PY_VER=%%i"
    set "PY=python"
)
if not defined PY (
    where python3 >nul 2>&1
    if !ERRORLEVEL!==0 (
        for /f "tokens=*" %%i in ('python3 --version 2^>^&1') do set "PY_VER=%%i"
        set "PY=python3"
    )
)
if not defined PY (
    echo [错误] 未检测到 Python，请先安装 Python 3.8 以上版本
    echo.
    echo 下载地址：https://www.python.org/downloads/
    echo 安装时务必勾选 "Add Python to PATH"
    echo.
    pause
    exit /b 1
)
echo [√] 已检测到 %PY_VER%

:: ========== 2. 检查 Python 版本 ==========
for /f "tokens=2 delims= " %%v in ("%PY_VER%") do set "VER_FULL=%%v"
for /f "tokens=1,2 delims=." %%a in ("%VER_FULL%") do (
    set "VER_MAJOR=%%a"
    set "VER_MINOR=%%b"
)
if %VER_MAJOR% LSS 3 (
    echo [错误] Python 版本太低（%VER_FULL%），需要 3.8 以上
    pause
    exit /b 1
)
if %VER_MAJOR%==3 if %VER_MINOR% LSS 8 (
    echo [错误] Python 版本太低（%VER_FULL%），需要 3.8 以上
    pause
    exit /b 1
)
:: Win7 兼容性警告
if %VER_MAJOR%==3 if %VER_MINOR% GEQ 9 (
    ver | findstr /i "6.1" >nul 2>&1
    if !ERRORLEVEL!==0 (
        echo [警告] 您的系统是 Windows 7，但 Python %VER_FULL% 不支持 Win7
        echo [警告] 请改用 Python 3.8.x：https://www.python.org/downloads/release/python-3819/
        echo.
        pause
        exit /b 1
    )
)
echo [√] 版本检查通过

:: ========== 3. 虚拟环境 ==========
set "VENV_DIR=%~dp0.venv"
set "VENV_PY=%VENV_DIR%\Scripts\python.exe"
set "REQ_FILE=%~dp0requirements.txt"
set "REQ_HASH=%VENV_DIR%\.req_hash"

if not exist "%VENV_PY%" (
    echo.
    echo [安装] 首次运行，正在创建虚拟环境...
    %PY% -m venv "%VENV_DIR%"
    if !ERRORLEVEL! NEQ 0 (
        echo [错误] 创建虚拟环境失败
        pause
        exit /b 1
    )
    echo [√] 虚拟环境创建成功
)

:: ========== 4. 检查依赖是否需要安装/更新 ==========
set "NEED_INSTALL=0"

:: 计算 requirements.txt 的哈希（用 certutil）
set "NEW_HASH="
for /f "skip=1 tokens=*" %%h in ('certutil -hashfile "%REQ_FILE%" MD5 2^>nul') do (
    if not defined NEW_HASH set "NEW_HASH=%%h"
)

:: 对比上次安装时的哈希
if not exist "%REQ_HASH%" (
    set "NEED_INSTALL=1"
) else (
    set /p OLD_HASH=<"%REQ_HASH%"
    if not "!OLD_HASH!"=="!NEW_HASH!" set "NEED_INSTALL=1"
)

if %NEED_INSTALL%==1 (
    echo.
    echo [安装] 正在安装/更新依赖...
    "%VENV_PY%" -m pip install --upgrade pip -q 2>nul
    "%VENV_PY%" -m pip install -r "%REQ_FILE%" -q
    if !ERRORLEVEL! NEQ 0 (
        echo [错误] 依赖安装失败，请检查网络连接
        echo 如果在国内，可尝试使用清华源：
        echo   %VENV_PY% -m pip install -r "%REQ_FILE%" -i https://pypi.tuna.tsinghua.edu.cn/simple
        pause
        exit /b 1
    )
    echo !NEW_HASH!>"%REQ_HASH%"
    echo [√] 依赖安装完成
) else (
    echo [√] 依赖已是最新
)

:: ========== 5. 确保目录存在 ==========
if not exist "%~dp0uploads" mkdir "%~dp0uploads"
if not exist "%~dp0exports" mkdir "%~dp0exports"
if not exist "%~dp0data" mkdir "%~dp0data"

:: ========== 6. 启动系统 ==========
echo.
echo ══════════════════════════════════════════
echo   启动中...
echo   本机访问：http://localhost:5006
echo   关闭此窗口即可停止系统
echo ══════════════════════════════════════════
echo.

:: 2秒后打开浏览器
start "" cmd /c "timeout /t 2 /nobreak >nul & start http://localhost:5006"

"%VENV_PY%" "%~dp0app.py"

pause
