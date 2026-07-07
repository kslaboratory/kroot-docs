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
    -SkipDeps        Install only kroot — skip Node.js / Python / Claude Code / Git
    -SkipPython      Install everything except Python
    -SkipGitBash     Install everything except Git for Windows
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
    [switch]$SkipPython,
    [switch]$NoModifyPath
)

# StrictMode 1.0 catches uninitialized variables without the property-access
# strictness of Latest (which would throw on optional JSON fields).
Set-StrictMode -Version 1.0
$ErrorActionPreference = 'Stop'

# Windows PowerShell 5.1 may default to TLS 1.0/1.1; GitHub requires TLS 1.2+.
try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch {}

# Invoke-WebRequest's progress bar makes downloads pathologically slow on Windows
# PowerShell 5.1, so silence it (the kroot binary is small; we print our own
# "Downloading…" line). winget is a separate process, so its own live progress
# bar for the Node/Claude/Git installs is unaffected by this.
$ProgressPreference = 'SilentlyContinue'

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

# Update-SessionPath rebuilds THIS session's $env:Path from the registry
# (Machine + User) plus $extraDir. winget installers (Node, Claude Code, Git)
# update the registry PATH but NOT the already-running shell, so without this the
# new commands aren't found until you reopen the terminal. Order-preserving dedup.
function Update-SessionPath($extraDir) {
    $machine = [System.Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user    = [System.Environment]::GetEnvironmentVariable('Path', 'User')
    $paths = @()
    if ($extraDir) { $paths += $extraDir }
    foreach ($p in @($machine, $user)) {
        if ($p) { $paths += @($p -split ';' | Where-Object { $_ -ne '' }) }
    }
    $seen = @{}
    $env:Path = (($paths | Where-Object { if ($seen.ContainsKey($_)) { $false } else { $seen[$_] = $true; $true } }) -join ';')
}

# Show-Tool prints where a command resolved (or a hint if not yet on PATH).
function Show-Tool($cmd, $label) {
    $c = Get-Command $cmd -ErrorAction SilentlyContinue
    if ($c) {
        Write-Ok ("{0,-8} {1}" -f $label, $c.Source)
    } else {
        Write-Dim ("{0,-8} not found yet — open a NEW terminal to use it." -f $label)
    }
}

# ── prerequisites via winget ─────────────────────────────────────────
function Test-Winget { [bool](Get-Command winget -ErrorAction SilentlyContinue) }

function Install-WingetPackage($id, $name, $step, $total) {
    $prefix = if ($step) { "[$step/$total] " } else { '' }
    $listed = winget list --id $id -e --accept-source-agreements 2>$null | Out-String
    if ($listed -match [regex]::Escape($id)) { Write-Ok "${prefix}$name is already installed."; return }
    Write-Info "${prefix}Installing $name ($id) — this may take a few minutes..."
    # NOTE: no `| Out-Null` here on purpose — winget prints its own live progress
    # bar (download %, install spinner), so the user sees the install advancing.
    # --silent keeps the underlying app installer quiet (no extra GUI windows).
    winget install --id $id -e --source winget --silent `
        --accept-package-agreements --accept-source-agreements
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "${prefix}$name installed."
    } else {
        Write-Warn "${prefix}$name install returned exit code $LASTEXITCODE — you may need to install it manually."
    }
}

# Get-LatestPythonId returns the newest available Python.Python.3.x winget id
# (so "latest Python" tracks new minor releases), falling back to a known-good
# version if the search can't be parsed.
function Get-LatestPythonId {
    try {
        $out = winget search --id 'Python.Python.3.' --source winget --accept-source-agreements 2>$null | Out-String
        $found = [regex]::Matches($out, 'Python\.Python\.3\.(\d+)')
        if ($found.Count -gt 0) {
            $best = $found | Sort-Object { [int]$_.Groups[1].Value } -Descending | Select-Object -First 1
            return $best.Value
        }
    } catch {}
    return 'Python.Python.3.13'
}

function Install-Dependencies {
    if (-not (Test-Winget)) {
        Write-Warn 'winget not found — skipping Node.js / Python / Claude Code / Git for Windows.'
        Write-Dim 'Install winget (App Installer) from the Microsoft Store, or install those tools manually.'
        return
    }
    # Build the list first so we can show "[i/N]" step progress.
    $pkgs = @(
        @{ id = 'OpenJS.NodeJS.LTS';    name = 'Node.js (LTS)' }   # for the kroot chat executor
    )
    # Python (latest 3.x) — optional (--SkipPython).
    if (-not $SkipPython) { $pkgs += @{ id = (Get-LatestPythonId); name = 'Python (latest 3.x)' } }
    $pkgs += @{ id = 'Anthropic.ClaudeCode'; name = 'Claude Code' }   # native install, no npm
    # Git for Windows is OPTIONAL — it gives Claude Code a real bash for its Bash tool.
    if (-not $SkipGitBash) { $pkgs += @{ id = 'Git.Git'; name = 'Git for Windows (Git Bash)' } }

    Write-Info "Installing $($pkgs.Count) prerequisite(s) via winget..."
    for ($i = 0; $i -lt $pkgs.Count; $i++) {
        Install-WingetPackage $pkgs[$i].id $pkgs[$i].name ($i + 1) $pkgs.Count
    }
    if ($SkipPython)  { Write-Dim 'Skipped Python (--SkipPython).' }
    if ($SkipGitBash) { Write-Dim 'Skipped Git for Windows (--SkipGitBash); Claude Code will use PowerShell as its shell tool.' }
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

    # winget updated the registry PATH but not THIS shell — reload it so kroot,
    # node, claude and git are usable right now, without reopening the terminal.
    if (-not $NoModifyPath) { Update-SessionPath $InstallDir }

    Write-Host ''
    Write-Ok 'Installation complete!'
    Write-Host ''
    Write-Dim 'Installed (usable in THIS terminal now):'
    Show-Tool 'kroot' 'kroot'
    if (-not $SkipDeps) {
        Show-Tool 'node'   'node'
        if (-not $SkipPython) { Show-Tool 'python' 'python' }
        Show-Tool 'claude' 'claude'
        if (-not $SkipGitBash) { Show-Tool 'git' 'git' }
    }
    Write-Host ''
    Write-Dim 'Try it now:  kroot --version'
    Write-Dim '(If anything shows "not found yet", just open a new terminal.)'
    Write-Host ''
} finally {
    Remove-Item $tmp -Recurse -Force -ErrorAction SilentlyContinue
}
