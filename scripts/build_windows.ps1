$ErrorActionPreference = "Stop"

Write-Host "Building Syncro for Windows..." -ForegroundColor Green

$projectPath = Split-Path -Parent $PSScriptRoot
$releasePath = "$projectPath\build\windows\x64\runner\Release"
$flutterPath = (Get-Command flutter -ErrorAction SilentlyContinue).Source
if ($flutterPath) {
    $flutterSdkPath = Split-Path (Split-Path $flutterPath)
} else {
    $flutterSdkPath = "E:\flutter"
}

Set-Location $projectPath

Write-Host "Step 1: Cleaning build..." -ForegroundColor Yellow
flutter clean 2>&1 | Out-Null

Write-Host "Step 2: Getting dependencies..." -ForegroundColor Yellow
flutter pub get 2>&1 | Out-Null

Write-Host "Step 3: Building Windows application..." -ForegroundColor Yellow
flutter build windows --release 2>&1 | Out-Null

Write-Host "Step 4: Copying required files..." -ForegroundColor Yellow

$dest = $releasePath
New-Item -ItemType Directory -Force -Path "$dest\data" | Out-Null

$plugins = @(
    "dynamic_color",
    "file_selector_windows", 
    "media_kit_libs_windows_video",
    "media_kit_video"
)

foreach ($plugin in $plugins) {
    $pluginPath = "$projectPath\build\windows\x64\plugins\$plugin\Release\*.dll"
    if (Test-Path $pluginPath) {
        Copy-Item $pluginPath $dest -Force
        Write-Host "  Copied $plugin DLL" -ForegroundColor Gray
    }
}

if (Test-Path "$projectPath\build\windows\x64\libmpv\libmpv-2.dll") {
    Copy-Item "$projectPath\build\windows\x64\libmpv\libmpv-2.dll" $dest -Force
    Write-Host "  Copied libmpv-2.dll" -ForegroundColor Gray
}

if (Test-Path "$projectPath\build\windows\x64\ANGLE\*.dll") {
    Copy-Item "$projectPath\build\windows\x64\ANGLE\*.dll" $dest -Force
    Write-Host "  Copied ANGLE DLLs" -ForegroundColor Gray
}

$flutterEnginePath = "$flutterSdkPath\bin\cache\artifacts\engine\windows-x64"
if (Test-Path "$flutterEnginePath\flutter_windows.dll") {
    Copy-Item "$flutterEnginePath\flutter_windows.dll" $dest -Force
    Write-Host "  Copied flutter_windows.dll" -ForegroundColor Gray
}
if (Test-Path "$flutterEnginePath\icudtl.dat") {
    Copy-Item "$flutterEnginePath\icudtl.dat" "$dest\data\icudtl.dat" -Force
    Write-Host "  Copied icudtl.dat" -ForegroundColor Gray
}

if (Test-Path "$projectPath\build\windows\app.so") {
    Copy-Item "$projectPath\build\windows\app.so" "$dest\data\app.so" -Force
    Write-Host "  Copied app.so" -ForegroundColor Gray
}

if (Test-Path "$projectPath\build\flutter_assets") {
    Copy-Item "$projectPath\build\flutter_assets" "$dest\data\flutter_assets" -Recurse -Force
    Write-Host "  Copied flutter_assets" -ForegroundColor Gray
}

$totalSize = (Get-ChildItem -Path $dest -Recurse | Measure-Object -Property Length -Sum).Sum
$totalSizeMB = [math]::Round($totalSize / 1MB, 2)

Write-Host ""
Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "Output: $dest" -ForegroundColor Cyan
Write-Host "Total size: $totalSizeMB MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "To run: $dest\syncro.exe" -ForegroundColor Yellow
