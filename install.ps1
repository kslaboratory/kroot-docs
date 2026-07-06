#Requires -Version 5.1
<#
  KRoot-ADK installer for Windows (native PowerShell — no Git Bash needed).

  Quick install (kroot + Node.js + Claude Code via winget):
    irm https://kslaboratory.github.io/kroot-docs/install.ps1 | iex

  With options (download the script, then invoke it as a scriptblock):
    & ([scriptblock]::Create((irm https://kslaboratory.github.io/kroot-docs/install.ps1))) -SkipDeps
    & ([scriptblock]::Create((irm https://kslaboratory.github.io/kroot-docs/install.ps1))) -Version 2.3.2

  Options:
    -Version X.Y.Z   Install a specific kroot version (default: latest)
    -InstallDir P    Install directory (default: %USERPROFILE%\.local\bin)
    -SkipDeps        Install only kroot — skip Node.js / Claude Code / Git for Windows
    -SkipGitBash     Install kroot + Node + Claude Code, but NOT Git for Windows
                     (Git Bash is optional: without it Claude Code uses PowerShell
                     as its shell tool)
    -NoModifyPath    Do not add the install dir to your PATH
#>
[CmdletBinding()]
param(
    [string]$Version    = $env:KROOT_VERSION,
    [string]$InstallDir = (Join-Path $env:USERPROFILE '.local\bin'),
    [switch]$SkipDeps,
    [switch]$SkipGitBash,
    [switch]$NoModifyPath
)

# StrictMode 1.0 catches uninitialized variables without the property-access
# strictness of Latest (which would throw on optional JSON fields).
Set-StrictMode -Version 1.0
$ErrorActionPreference = 'Stop'

# Windows PowerShell 5.1 may default to TLS 1.0/1.1; GitHub requires TLS 1.2+.
try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}

$Repo         = 'kslaboratory/kroot-docs'
$ReleasesApi  = "https://api.github.com/repos/$Repo/releases"
$DownloadBase = "https://github.com/$Repo/releases/download"
$BinaryName   = 'kroot'
$WtBinaryName = 'kroot-wt'

# ── output helpers ────────────────────────────────────────────────────
function Write-Info($m) { Write-Host "  $m" -ForegroundColor Cyan }
function Write-Ok($m)   { Write-Host "  $m" -ForegroundColor Green }
function Write-Warn($m) { Write-Host "  $m" -ForegroundColor Yellow }
function Write-Err($m)  { Write-Host "  ERROR: $m" -ForegroundColor Red }
function Write-Dim($m)  { Write-Host "  $m" -ForegroundColor DarkGray }

function Show-Banner {
    Write-Host ''
    Write-Host '  ╔════════════════════════════════════════╗' -ForegroundColor Magenta
    Write-Host '  ║  KRoot-ADK Installer (Windows)          ║' -ForegroundColor Magenta
    Write-Host '  ╚════════════════════════════════════════╝' -ForegroundColor Magenta
    Write-Host ''
}

# ── platform ─────────────────────────────────────────────────────────
function Get-Arch {
    $a = $env:PROCESSOR_ARCHITECTURE
    if ($a -eq 'x86' -and $env:PROCESSOR_ARCHITEW6432) { $a = $env:PROCESSOR_ARCHITEW6432 }
    switch ($a) {
        'AMD64' { 'amd64' }
        'ARM64' { 'arm64' }
        default { throw "Unsupported architecture: $a (supported: AMD64, ARM64)" }
    }
}

function Get-LatestVersion {
    $headers = @{ 'Accept' = 'application/vnd.github.v3+json'; 'User-Agent' = 'kroot-installer' }
    $token = if ($env:GITHUB_TOKEN) { $env:GITHUB_TOKEN } elseif ($env:GH_TOKEN) { $env:GH_TOKEN } else { $null }
    if ($token) { $headers['Authorization'] = "Bearer $token" }
    $rel = Invoke-RestMethod -Uri "$ReleasesApi/latest" -Headers $headers
    if (-not $rel.tag_name) { throw 'Could not determine the latest version from GitHub.' }
    return ($rel.tag_name -replace '^v', '')
}

# ── download + checksum ──────────────────────────────────────────────
function Get-ReleaseFile($version, $assetName, $dest) {
    $url = "$DownloadBase/v$version/$assetName"
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
}

function Test-Checksum($version, $assetName, $filePath) {
    $checksums = Join-Path ([System.IO.Path]::GetTempPath()) "kroot-checksums-$PID.txt"
    try {
        Get-ReleaseFile $version 'checksums.txt' $checksums
    } catch {
        Write-Warn 'Could not download checksums.txt — skipping verification.'
        return
    }
    $expected = $null
    foreach ($line in Get-Content $checksums) {
        $parts = @($line -split '\s+' | Where-Object { $_ -ne '' })
        if ($parts.Count -ge 2 -and $parts[1] -eq $assetName) { $expected = $parts[0].ToLower(); break }
    }
    Remove-Item $checksums -ErrorAction SilentlyContinue
    if (-not $expected) { Write-Warn "Checksum not found for $assetName — skipping verification."; return }
    $actual = (Get-FileHash -Algorithm SHA256 -Path $filePath).Hash.ToLower()
    if ($actual -ne $expected) { throw "Checksum mismatch for $assetName (expected $expected, got $actual)" }
}

# ── PATH (Windows user registry) ─────────────────────────────────────
function Add-ToUserPath($dir) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not $userPath) { $userPath = '' }
    $entries = $userPath -split ';' | Where-Object { $_ -ne '' }
    if ($entries -contains $dir) {
        Write-Dim "$dir is already on your PATH."
    } else {
        $newPath = if ($userPath.TrimEnd(';')) { $userPath.TrimEnd(';') + ';' + $dir } else { $dir }
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Ok "Added $dir to your PATH (user)."
    }
    # Make it usable in THIS session too.
    if (($env:Path -split ';') -notcontains $dir) { $env:Path = "$dir;$env:Path" }
}

# ── prerequisites via winget ─────────────────────────────────────────
function Test-Winget { [bool](Get-Command winget -ErrorAction SilentlyContinue) }

function Install-WingetPackage($id, $name) {
    $listed = winget list --id $id -e --accept-source-agreements 2>$null | Out-String
    if ($listed -match [regex]::Escape($id)) { Write-Ok "$name is already installed."; return }
    Write-Info "Installing $name ($id)..."
    winget install --id $id -e --source winget --silent `
        --accept-package-agreements --accept-source-agreements | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "$name installed."
    } else {
        Write-Warn "$name install returned exit code $LASTEXITCODE — you may need to install it manually."
    }
}

function Install-Dependencies {
    if (-not (Test-Winget)) {
        Write-Warn 'winget not found — skipping Node.js / Claude Code / Git for Windows.'
        Write-Dim 'Install winget (App Installer) from the Microsoft Store, or install those tools manually.'
        return
    }
    Write-Info 'Installing prerequisites via winget...'
    # Node.js — required by `kroot chat start` (the node chat executor).
    Install-WingetPackage 'OpenJS.NodeJS.LTS' 'Node.js (LTS)'
    # Claude Code — native Windows install (no npm needed).
    Install-WingetPackage 'Anthropic.ClaudeCode' 'Claude Code'
    # Git for Windows — OPTIONAL: gives Claude Code a real bash for its Bash tool.
    if (-not $SkipGitBash) {
        Install-WingetPackage 'Git.Git' 'Git for Windows (Git Bash)'
    } else {
        Write-Dim 'Skipping Git for Windows (--SkipGitBash); Claude Code will use PowerShell as its shell tool.'
    }
}

# ── main ─────────────────────────────────────────────────────────────
Show-Banner

$arch = Get-Arch
Write-Info "Platform: windows/$arch"

if (-not $Version) {
    Write-Info 'Resolving latest version...'
    $Version = Get-LatestVersion
}
Write-Info "Installing kroot v$Version"

$tmp = Join-Path ([System.IO.Path]::GetTempPath()) "kroot-install-$PID"
New-Item -ItemType Directory -Force -Path $tmp | Out-Null
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

try {
    foreach ($b in @($BinaryName, $WtBinaryName)) {
        $asset = "$b-windows-$arch.exe"
        $dest  = Join-Path $tmp $asset
        Write-Info "Downloading $asset..."
        Get-ReleaseFile $Version $asset $dest
        Test-Checksum $Version $asset $dest
        Copy-Item $dest (Join-Path $InstallDir "$b.exe") -Force
    }
    Write-Ok "Binaries installed to $InstallDir"

    if (-not $NoModifyPath) { Add-ToUserPath $InstallDir }
    else { Write-Dim "Skipped PATH update (--NoModifyPath). Add $InstallDir to PATH yourself." }

    if (-not $SkipDeps) { Install-Dependencies }
    else { Write-Dim 'Skipped Node.js / Claude Code / Git for Windows (--SkipDeps).' }

    Write-Host ''
    Write-Ok 'Installation complete!'
    Write-Dim "Installed: $(Join-Path $InstallDir "$BinaryName.exe")"
    Write-Host ''
    Write-Dim "Open a NEW terminal (so the updated PATH loads), then run:  kroot --help"
    Write-Host ''
} finally {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
