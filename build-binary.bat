@echo on
chcp 65001 >nul

REM Binary build script for grep_app_mcp
REM Creates standalone executable binaries using TypeScript + NCC

setlocal EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

echo 🏗️  Building binary distribution...

REM Clean previous builds
echo 🧹 Cleaning previous builds...
rmdir /s /q dist-binary 2>nul
mkdir dist-binary

REM Install dependencies if needed
if not exist "node_modules" (
    echo 📦 Installing dependencies...
    npm install
)

REM Build TypeScript first
echo 🔨 Building TypeScript...
call npm run build

REM Use NCC to create truly standalone binaries
echo 📦 Creating standalone binaries with NCC...

REM Build HTTP server binary
echo   Building HTTP server binary...
call npx ncc build dist/server.js -o dist-binary/server-bundle --minify

REM Build STDIO server binary  
echo   Building STDIO server binary...
call npx ncc build dist/server-stdio.js -o dist-binary/stdio-bundle --minify

REM Create executable wrapper scripts
echo 🚀 Creating executable wrappers...

REM HTTP server wrapper (Windows .cmd equivalent)
(
echo @node "%~dp0dist-binary/server-bundle\index.js"
) > dist-binary\grep-app-server.bat

REM STDIO server wrapper (Windows .cmd equivalent)
(
echo @node "%~dp0dist-binary/stdio-bundle\index.js"
) > dist-binary\grep-app-stdio.bat

REM Create package.json for binary distribution
(
echo {
echo   "name": "grep_app_mcp_binary",
echo   "version": "1.0.0",
echo   "description": "Standalone binary distribution of grep_app_mcp",
echo   "type": "module",
echo   "main": "server-bundle/index.js",
echo   "bin": {
echo     "grep-app-server": "./grep-app-server",
echo     "grep-app-stdio": "./grep-app-stdio"
echo   }
echo }
) > dist-binary\package.json

REM Create usage instructions
(
echo # Grep App MCP Server - Binary Distribution
echo.
echo This directory contains standalone executable binaries for the MCP server.
echo.
echo ## Files:
echo - `grep-app-server` - HTTP server executable (no dependencies needed)
echo - `grep-app-stdio` - STDIO server executable (no dependencies needed)
echo - `server-bundle/` - HTTP server bundle
echo - `stdio-bundle/` - STDIO server bundle
echo.
echo ## Usage:
echo.
echo ```bash
echo # HTTP mode (standalone executable)
echo ./grep-app-server
echo.
echo # STDIO mode (standalone executable)
echo ./grep-app-stdio
echo.
echo # Or with node directly
echo node server-bundle/index.js
echo node stdio-bundle/index.js
echo ```
echo.
echo ## Installation:
echo No installation required! Just run the executables directly.
echo.
echo ## Notes:
echo - These binaries include all dependencies bundled
echo - No need to run `npm install`
echo - Node.js runtime still required on the system
) > dist-binary\README.md

REM Clean up intermediate files (none needed for NCC approach)

echo ✅ Binary build complete!
echo.
echo 📁 Built binaries in dist-binary/:
dir dist-binary
echo.
echo 🚀 To run the standalone binaries:
echo    .\dist-binary\grep-app-server.cmd     # HTTP server
echo    .\dist-binary\grep-app-stdio.cmd      # STDIO server
echo.
echo 📦 Or install globally:
echo    npm install -g .\dist-binary
echo    grep-app-server                       # Available system-wide
