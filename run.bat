@echo off
setlocal

:: MCP Server Runner Script
:: Usage: run.bat [mode] [environment]
:: Modes: http, stdio
:: Environment: dev, prod

:: Get the directory where this script is located
set SCRIPT_DIR=%~dp0

:: Change to the project directory
cd /d "%SCRIPT_DIR%"

:: Set default values
set MODE=%1
if "%MODE%"=="" set MODE=http

set ENV=%2
if "%ENV%"=="" set ENV=dev

:: Process mode
if "%MODE%"=="build" goto build
if "%MODE%"=="binary" goto binary
if "%MODE%"=="http" goto http
if "%MODE%"=="stdio" goto stdio
if "%MODE%"=="help" goto help
if "%MODE%"=="-h" goto help
if "%MODE%"=="--help" goto help

:: If we get here, invalid mode
echo ❌ Invalid mode. Use 'build', 'binary', 'http', or 'stdio'
echo Run 'run.bat help' for usage information
exit /b 1

:build
echo 🏗️  Building standalone distribution...
call build.bat
echo ✅ Build complete! Files available in dist/
goto :eof

:binary
echo 🔧 Building standalone binary executables...
echo Checking for pkg...
npx pkg --help >nul 2>&1 || npm install -g pkg
echo Compiling binary for Windows (x64) using Node.js 20 runtime...
npx pkg dist/server.js -t node20-win-x64 -o dist-binary/mcp-server.exe
echo ✅ Binary build complete! Executable available in dist-binary/mcp-server.exe
goto :eof

:http
if "%ENV%"=="dev" goto http-dev
if "%ENV%"=="prod" goto http-prod

echo ❌ Invalid environment. Use 'dev' or 'prod'
exit /b 1

:http-dev
echo 🚀 Starting HTTP server in development mode...
echo 📡 Server will be available at: http://localhost:8603
call npm run dev
goto :eof

:http-prod
echo 🏗️  Building and starting HTTP server in production mode...
call npm run build
echo 🚀 Starting production HTTP server...
call npm run start
goto :eof

:stdio
if "%ENV%"=="dev" goto stdio-dev
if "%ENV%"=="prod" goto stdio-prod

echo ❌ Invalid environment. Use 'dev' or 'prod'
exit /b 1

:stdio-dev
echo 🚀 Starting STDIO server in development mode...
call npm run dev-stdio
goto :eof

:stdio-prod
echo 🏗️  Building and starting STDIO server in production mode...
call npm run build
echo 🚀 Starting production STDIO server...
call npm run start-stdio
goto :eof

:help
echo MCP Server Runner
echo.
echo Usage: run.bat [mode] [environment]
echo.
echo Modes:
echo   build   - Build standalone distribution
echo   binary  - Build standalone binary executables
echo   http    - Run HTTP server (default)
echo   stdio   - Run STDIO server
echo.
echo Environments:
echo   dev     - Development mode with hot reload (default)
echo   prod    - Production mode (requires build)
echo.
echo Examples:
echo   run.bat                   # HTTP dev (default)
echo   run.bat build             # Build standalone files
echo   run.bat binary            # Build binary executables
echo   run.bat http dev          # HTTP dev
echo   run.bat http prod         # HTTP prod
echo   run.bat stdio dev         # STDIO dev
echo   run.bat stdio prod        # STDIO prod
echo.
echo HTTP endpoints when running in http mode:
echo   - HTTP Streaming: http://localhost:8603/mcp
echo   - SSE: http://localhost:8603/sse
goto :eof

:eof
endlocal
