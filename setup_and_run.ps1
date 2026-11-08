$ErrorActionPreference = "Stop"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  SiliCord - 100% Native Rust Discord Client Setup & Run  " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$cargoBin = Join-Path $env:USERPROFILE ".cargo\bin"
if (Test-Path $cargoBin) {
    $env:PATH = "$cargoBin;$env:PATH"
}

# Add WinGet Links and WinLibs MinGW paths if installed
$wingetLinks = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Links"
if (Test-Path $wingetLinks) {
    $env:PATH = "$wingetLinks;$env:PATH"
}
$mingwPackages = Get-ChildItem (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages") -Directory -Filter "*WinLibs*" -ErrorAction SilentlyContinue
foreach ($pkg in $mingwPackages) {
    $mingwBin = Join-Path $pkg.FullName "mingw64\bin"
    if (Test-Path $mingwBin) {
        $env:PATH = "$mingwBin;$env:PATH"
    }
}

$hasVs = Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"

if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
    Write-Host "[1/3] Rust toolchain not found. Downloading rustup-init.exe..." -ForegroundColor Yellow
    $rustupUrl = "https://win.rustup.rs/x86_64"
    $rustupInstaller = Join-Path $env:TEMP "rustup-init.exe"
    Invoke-WebRequest -Uri $rustupUrl -OutFile $rustupInstaller -UseBasicParsing

    if ($hasVs) {
        & $rustupInstaller -y --default-toolchain stable-x86_64-pc-windows-msvc
    } else {
        Write-Host "[1b/3] Installing lightweight MinGW-w64 linker via winget..." -ForegroundColor Yellow
        if (-not (Get-Command gcc -ErrorAction SilentlyContinue)) {
            winget install --id=BrechtSanders.WinLibs.POSIX.UCRT -e --accept-source-agreements --accept-package-agreements
            $mingwPackages = Get-ChildItem (Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages") -Directory -Filter "*WinLibs*" -ErrorAction SilentlyContinue
            foreach ($pkg in $mingwPackages) {
                $mingwBin = Join-Path $pkg.FullName "mingw64\bin"
                if (Test-Path $mingwBin) {
                    $env:PATH = "$mingwBin;$env:PATH"
                }
            }
        }
        & $rustupInstaller -y --default-toolchain stable-x86_64-pc-windows-gnu
    }

    $env:PATH = "$cargoBin;$env:PATH"
}

Write-Host "[2/3] Building and launching SiliCord..." -ForegroundColor Green
cargo run --release
