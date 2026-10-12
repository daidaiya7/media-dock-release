# Load the official release image without requiring a registry login.
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
$version = (Get-Content VERSION -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') { throw 'Invalid VERSION' }
docker compose version
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose v2 is required' }
$arch = (docker info --format '{{.Architecture}}').Trim()
if ($LASTEXITCODE -ne 0) { throw 'Please start Docker Desktop in Linux container mode' }
switch ($arch) {
    'x86_64' { $arch = 'amd64' }
    'amd64' { $arch = 'amd64' }
    'aarch64' { $arch = 'arm64' }
    'arm64' { $arch = 'arm64' }
    default { throw "Unsupported Docker architecture: $arch" }
}
$file = "mediadock-$version-linux-$arch.tar.gz"
$base = "https://github.com/daidaiya7/media-dock-release/releases/download/v$version"
New-Item -ItemType Directory -Force .downloads | Out-Null
Invoke-WebRequest -Uri "$base/$file" -OutFile ".downloads/$file"
Invoke-WebRequest -Uri "$base/SHA256SUMS.txt" -OutFile .downloads/SHA256SUMS.txt
$expected = $null
foreach ($line in Get-Content .downloads/SHA256SUMS.txt) {
    $parts = $line.Trim() -split '\s+'
    if ($parts.Length -eq 2 -and $parts[1] -eq $file) { $expected = $parts[0] }
}
$actual = (Get-FileHash ".downloads/$file" -Algorithm SHA256).Hash
if (-not $expected -or $expected -ne $actual) { throw 'Image checksum mismatch' }
docker load -i ".downloads/$file"
if ($LASTEXITCODE -ne 0) { throw 'Docker image import failed' }
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
docker compose up -d --pull never
if ($LASTEXITCODE -ne 0) { throw 'Docker Compose startup failed' }
docker compose ps
Write-Host 'MediaDock started. Open http://127.0.0.1:59189/admin to initialize.'
Write-Host 'Existing .env and data volumes were preserved.'
