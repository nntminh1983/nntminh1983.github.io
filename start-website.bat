@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"

rem ---------------------------------------------------------------------
rem  Khoi dong website tren mang noi bo (LAN).
rem  Nhap doi chuot vao file nay de chay. Dong cua so de tat server.
rem ---------------------------------------------------------------------

set PORT=8000

rem --- Tim dia chi IPv4 cua may (bo qua loopback 127.x) ---
set LANIP=
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set "IP=%%a"
    set "IP=!IP: =!"
    if "!IP:~0,3!" neq "127" if not defined LANIP set "LANIP=!IP!"
)
if not defined LANIP set LANIP=127.0.0.1

echo.
echo  ==========================================================
echo    WEBSITE DANG CHAY
echo  ==========================================================
echo.
echo    Tren may nay:      http://localhost:%PORT%
echo    Tren mang noi bo:  http://!LANIP!:%PORT%
echo.
echo    Chia se dia chi thu hai cho dien thoai / may khac
echo    dang dung CUNG MOT mang Wi-Fi.
echo.
echo    Nhan Ctrl+C hoac dong cua so nay de tat server.
echo  ==========================================================
echo.

rem --- Uu tien "py", neu khong co thi dung "python" ---
where py >nul 2>&1
if %errorlevel%==0 (
    py -m http.server %PORT% --bind 0.0.0.0
) else (
    python -m http.server %PORT% --bind 0.0.0.0
)

echo.
echo  Server da dung lai.
pause
