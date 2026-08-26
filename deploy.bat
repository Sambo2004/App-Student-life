@echo off
setlocal
echo Building Flutter Web App...
call flutter pub get --offline
if errorlevel 1 goto :failed

call flutter build web --release --no-pub
if errorlevel 1 goto :failed

if not exist "build\web\assets\assets\app_logo.webp" goto :missing_assets
if not exist "build\web\assets\assets\start_page.gif" goto :missing_assets
if not exist "build\web\assets\fonts\MaterialIcons-Regular.otf" goto :missing_assets

echo Uploading to Server...
scp -r build\web\* root@100.54.83.211:/usr/share/nginx/html/
if errorlevel 1 goto :failed

ssh root@100.54.83.211 chmod -R a+rX /usr/share/nginx/html
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
