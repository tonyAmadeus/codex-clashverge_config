@echo off
setlocal
chcp 65001 >nul
set "REPAIR_NODE="
for /f "delims=" %%N in ('where node.exe 2^>nul') do if not defined REPAIR_NODE set "REPAIR_NODE=%%N"
if not defined REPAIR_NODE for /d %%D in ("%LOCALAPPDATA%\OpenAI\Codex\runtimes\cua_node\*") do if exist "%%~fD\bin\node.exe" set "REPAIR_NODE=%%~fD\bin\node.exe"
if not defined REPAIR_NODE (
  echo Node.js runtime not found. Use a supported installed Node.js or the ChatGPT bundled runtime. No runtime will be installed automatically.
  echo 未找到 Node.js 或 ChatGPT 附带的运行时。工具不会自动安装软件。
  if "%~1"=="" pause
  exit /b 1
)
if "%~1"=="" (
  "%REPAIR_NODE%" "%~dp0menu-launch.cjs"
  if errorlevel 1 pause
  exit /b
)
"%REPAIR_NODE%" "%~dp0repair.cjs" %*
exit /b %errorlevel%
