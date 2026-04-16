# build_release.ps1
# Construye el APK de release y lo renombra con la versión del pubspec.
# Uso: .\build_release.ps1

Set-Location $PSScriptRoot

# Leer versión desde pubspec.yaml (ej: "1.0.2+3" → "1.0.2")
$versionLine = (Get-Content pubspec.yaml | Select-String '^version:').ToString()
$versionFull = $versionLine -replace 'version:\s*', '' -replace '\s.*', ''
$versionName = $versionFull.Split('+')[0].Trim()

Write-Host "[BUILD] Construyendo SIGERP V$versionName..." -ForegroundColor Cyan

# Ejecutar build de Flutter
flutter build apk --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Flutter build fallo." -ForegroundColor Red
    exit 1
}

# Renombrar APK
$apkDir   = "build\app\outputs\flutter-apk"
$srcPath  = "$apkDir\app-release.apk"
$destName = "SIGERP_V${versionName}_release.apk"
$destPath = "$apkDir\$destName"

if (Test-Path $srcPath) {
    if (Test-Path $destPath) { Remove-Item $destPath -Force }
    Rename-Item -Path $srcPath -NewName $destName
    Write-Host "[OK] APK generado: $apkDir\$destName" -ForegroundColor Green
} else {
    Write-Host "[WARN] No se encontro app-release.apk" -ForegroundColor Yellow
}
