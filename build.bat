@echo off
REM ========================================
REM TubeTok Downloader Build Script - Single EXE
REM ========================================

echo Building TubeTok Downloader...
echo.

REM Activate virtual environment
if not exist ".venv\Scripts\activate.bat" (
    echo ERROR: Virtual environment not found!
    echo Please run: python -m venv .venv
    echo Then install dependencies: .venv\Scripts\pip install -r requirements.txt
    pause
    exit /b 1
)

call .venv\Scripts\activate.bat

REM Check if PyInstaller is installed
python -m pip show pyinstaller >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing PyInstaller...
    python -m pip install pyinstaller
)

REM Force kill any running TubeTok Downloader processes
taskkill /f /im TubeTokDownloader.exe >nul 2>&1

REM Clean previous builds
if exist "dist" (
    echo Cleaning previous dist folder...
    rmdir /s /q dist
)
if exist "build" (
    echo Cleaning previous build folder...
    rmdir /s /q build
)

REM Create single executable with all dependencies
echo Creating single executable...
python -m PyInstaller ^
    --onefile ^
    --windowed ^
    --name="TubeTokDownloader" ^
    --icon="assets\app.ico" ^
    --add-data="assets;assets" ^
    --add-data="ui\themes;ui\themes" ^
    --hidden-import="PySide6.QtCore" ^
    --hidden-import="PySide6.QtGui" ^
    --hidden-import="PySide6.QtWidgets" ^
    --hidden-import="yt_dlp" ^
    --hidden-import="PIL" ^
    --hidden-import="cryptography" ^
    --hidden-import="cryptography.fernet" ^
    --collect-all="yt_dlp" ^
    --collect-all="PySide6" ^
    --collect-submodules="core" ^
    --collect-submodules="ui" ^
    --distpath="dist" ^
    --workpath="build" ^
    main.py

if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo Build completed successfully!
    echo.
    echo Executable location: dist\TubeTokDownloader.exe
    echo File size:
    dir /b dist\TubeTokDownloader.exe 2>nul && for %%A in (dist\TubeTokDownloader.exe) do echo %%~zA bytes
    echo.
    echo ========================================
) else (
    echo.
    echo Build failed! Check the output above for errors.
    pause
    exit /b 1
)

pause
