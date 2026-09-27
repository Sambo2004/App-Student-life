@echo off
setlocal
if "%DEPLOY_HOST%"=="" (
  echo ERROR: Set DEPLOY_HOST before deploying, for example set DEPLOY_HOST=your-server
  exit /b 1
)
if "%DEPLOY_USER%"=="" set "DEPLOY_USER=deploy"
if "%DEPLOY_PATH%"=="" set "DEPLOY_PATH=/usr/share/nginx/html"

echo Building Flutter Web App...
call flutter pub get --offline
if errorlevel 1 goto :failed

call flutter build web --release --no-pub
if errorlevel 1 goto :failed

if not exist "build\web\assets\assets\app_logo.webp" goto :missing_assets
if not exist "build\web\assets\assets\start_page.gif" goto :missing_assets
if not exist "build\web\assets\fonts\MaterialIcons-Regular.otf" goto :missing_assets

echo Uploading to Server...
scp -r build\web\* %DEPLOY_USER%@%DEPLOY_HOST%:%DEPLOY_PATH%/
if errorlevel 1 goto :failed

ssh %DEPLOY_USER%@%DEPLOY_HOST% chmod -R a+rX %DEPLOY_PATH%
if errorlevel 1 goto :failed

echo Deployment Complete!
echo Clear browser cache (Ctrl+Shift+R) to see changes
goto :end

:missing_assets
echo ERROR: The web build did not contain the required image or icon-font assets.
goto :failed

:failed
echo Deployment failed. The server was not updated.
exit /b 1

:end
endlocal
pause
