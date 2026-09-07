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

  Uninstall (completely remove kroot):
    & ([scriptblock]::Create((irm https://kslaboratory.github.io/kroot-docs/install.ps1))) -Uninstall
    -Uninstall       Remove kroot / kroot-wt, %USERPROFILE%\.kroot, and the PATH entry
    -KeepState       With -Uninstall: keep %USERPROFILE%\.kroot (login token & settings)
#>
[CmdletBinding()]
param(
    [string]$Version    = $env:KROOT_VERSION,
    [string]$InstallDir = (Join-Path $env:USERPROFILE '.local\bin'),
    [switch]$SkipDeps,
    [switch]$SkipGitBash,
    [switch]$SkipPython,
    [switch]$NoModifyPath,
    [switch]$Uninstall,
    [switch]$KeepState
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

# kroot-studio 앱의 'AI코딩' 메뉴(prereqs.ts)와 동일한 Node.js 하한 기준(2026-09 정렬).
$MinNodeVersion = '22.13.0'

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

# Remove-FromUserPath drops $dir from the user PATH registry (order-preserving).
function Remove-FromUserPath($dir) {
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (-not $userPath) { return }
    $entries = @($userPath -split ';' | Where-Object { $_ -ne '' -and $_ -ne $dir })
    $newPath = ($entries -join ';')
    if ($newPath -ne $userPath.TrimEnd(';')) {
        [Environment]::SetEnvironmentVariable('Path', $newPath, 'User')
        Write-Ok "Removed $dir from your PATH (user)."
    } else {
        Write-Dim "$dir was not on your user PATH."
    }
}

# ── uninstall ────────────────────────────────────────────────────────
function Invoke-Uninstall {
    Show-Banner
    Write-Info 'Uninstalling KRoot-ADK...'

    $stateDir = Join-Path $env:USERPROFILE '.kroot'

    if (-not $KeepState) {
        Write-Host ''
        Write-Dim 'This will remove:'
        Write-Dim "  * kroot.exe / kroot-wt.exe from known install dirs"
        Write-Dim "  * $stateDir (login token, chat-executor, logs, uploads)"
        Write-Dim "  * the PATH entry pointing at the install dir"
    }

    # 1) Stop the chat daemon while kroot.exe still exists (best-effort).
    if (Get-Command kroot -ErrorAction SilentlyContinue) {
        Write-Info 'Stopping chat daemon (if running)...'
        try { & kroot chat stop 2>$null | Out-Null } catch {}
    }

    # 2) Collect candidate install dirs: -InstallDir, the default, wherever kroot
    #    currently resolves, and GOPATH\bin (go install / make install).
    $dirs = New-Object System.Collections.Generic.List[string]
    foreach ($d in @($InstallDir, (Join-Path $env:USERPROFILE '.local\bin'))) {
        if ($d) { $dirs.Add($d) }
    }
    $onPath = Get-Command kroot -ErrorAction SilentlyContinue
    if ($onPath) { $dirs.Add((Split-Path $onPath.Source -Parent)) }
    $goCmd = Get-Command go -ErrorAction SilentlyContinue
    if ($goCmd) {
        $gobin = (& go env GOBIN) 2>$null
        if (-not $gobin) { $gp = (& go env GOPATH) 2>$null; if ($gp) { $gobin = Join-Path $gp 'bin' } }
        if ($gobin) { $dirs.Add($gobin) }
    }

    # 3) Remove binaries.
    Write-Host ''
    Write-Info 'Removing binaries...'
    $removed = $false
    $seen = @{}
    foreach ($d in $dirs) {
        if (-not $d -or $seen.ContainsKey($d)) { continue }
        $seen[$d] = $true
        foreach ($f in @("$BinaryName.exe", "$WtBinaryName.exe")) {
            $target = Join-Path $d $f
            if (Test-Path $target) {
                try {
                    Remove-Item $target -Force -ErrorAction Stop
                    Write-Ok "Removed $target"
                    $removed = $true
                } catch {
                    Write-Err "Could not remove $target — it may be running. Close all kroot processes and retry."
                }
            }
        }
    }
    if (-not $removed) { Write-Dim 'No kroot binaries found in known locations.' }

    # 4) Remove user state.
    Write-Host ''
    if ($KeepState) {
        Write-Dim "Keeping $stateDir (-KeepState)."
    } elseif (Test-Path $stateDir) {
        Write-Info "Removing $stateDir..."
        try {
            Remove-Item $stateDir -Recurse -Force -ErrorAction Stop
            Write-Ok "Removed $stateDir"
        } catch {
            Write-Err "Could not remove $stateDir — $($_.Exception.Message)"
        }
    } else {
        Write-Dim "$stateDir not found."
    }

    # 5) Clean PATH entries for every candidate dir.
    Write-Host ''
    Write-Info 'Cleaning PATH entries...'
    $seen2 = @{}
    foreach ($d in $dirs) {
        if (-not $d -or $seen2.ContainsKey($d)) { continue }
        $seen2[$d] = $true
        Remove-FromUserPath $d
    }

    Write-Host ''
    Write-Ok 'KRoot-ADK uninstalled.'
    Write-Dim 'Open a NEW terminal so the updated PATH takes effect.'
    Write-Dim 'Per-project files (.kroot\, CLAUDE.md) inside your projects are left untouched.'
    Write-Dim 'Node.js / Python / Claude Code / Git were installed separately and are NOT removed.'
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

# ── 설치 여부 감지 (install-for-kroot-adk.sh / kroot-studio 'AI코딩' prereqs.ts 와 동일 기준) ──
# kroot-studio 의 detectPrereqs() 는 winget 등록 여부가 아니라 "실제로 <cmd> --version 을
# 실행해 semver 를 파싱할 수 있는가"로 설치 여부를 판정한다. 아래 함수들은 그 판정 방식을
# PowerShell 로 그대로 이식한 것 — winget install 을 시도하기 전에 먼저 이 기준으로 확인해,
# 이미 설치돼 있으면 재설치하지 않고 다음 항목으로 넘어간다.

function Get-VersionGE($a, $b) {
    $pa = $a -split '\.' | ForEach-Object { [int]$_ }
    $pb = $b -split '\.' | ForEach-Object { [int]$_ }
    for ($i = 0; $i -lt 3; $i++) {
        $ai = if ($i -lt $pa.Count) { $pa[$i] } else { 0 }
        $bi = if ($i -lt $pb.Count) { $pb[$i] } else { 0 }
        if ($ai -gt $bi) { return $true }
        if ($ai -lt $bi) { return $false }
    }
    return $true
}

function Get-SemVer([string]$output) {
    if (-not $output) { return $null }
    $m = [regex]::Match($output, '\d+\.\d+\.\d+')
    if ($m.Success) { return $m.Value }
    return $null
}

# GUI 로 뜬 프로세스는 로그인 셸 PATH 를 못 받아 반쪽 PATH 로 보이므로, 표준 설치 경로를
# 보강한 뒤 실행한다(prereqs.ts 의 augmentedPath() 와 동일 목록).
function Get-AugmentedPath {
    $homeDir = $env:USERPROFILE
    $programFiles   = if ($env:ProgramFiles)  { $env:ProgramFiles }  else { 'C:\Program Files' }
    $localAppData   = if ($env:LOCALAPPDATA)  { $env:LOCALAPPDATA }  else { Join-Path $homeDir 'AppData\Local' }
    $roamingAppData = if ($env:APPDATA)       { $env:APPDATA }       else { Join-Path $homeDir 'AppData\Roaming' }
    $extra = @(
        (Join-Path $programFiles 'nodejs'),                        # OpenJS.NodeJS.LTS
        (Join-Path $programFiles 'Git\cmd'),                       # Git.Git
        (Join-Path $localAppData 'Microsoft\WinGet\Links'),
        (Join-Path $localAppData 'Programs\claude'),                # Claude Code 네이티브 설치기
        (Join-Path $roamingAppData 'npm'),
        (Join-Path $homeDir '.local\bin'),                          # kroot-adk INSTALL_DIR / Claude 네이티브 설치
        (Join-Path $homeDir '.claude\local')
    )
    return ($extra -join ';') + ';' + $env:Path
}

# ConvertTo-QuotedArg — 공백/따옴표가 있는 인자만 감싼다(경로에 공백이 흔함, 예: "Program Files").
function ConvertTo-QuotedArg([string]$arg) {
    if ($arg -match '[\s"]') { return '"' + ($arg -replace '"', '\"') + '"' }
    return $arg
}

# Invoke-VersionCheck — <cmd> <args> 를 실행해 stdout 을 반환한다(실패/5초 타임아웃은 $null).
# ⚠ npm/nvm 로 설치된 CLI(claude 등)는 .cmd/.bat wrapper 뿐인 경우가 흔한데, .NET Process 를
#   UseShellExecute=$false 로 직접 실행하면 배치파일은 CreateProcess 가 거부한다 — cmd.exe 를
#   경유(`/d /c`)하면 PATHEXT 해석과 배치파일 실행이 둘 다 정상 동작한다(install-for-kroot-adk.sh
#   의 runExec() 우회와 동일 이유·동일 해법).
# ⚠ 실측(Windows PowerShell 5.1/.NET Framework): `ProcessStartInfo.ArgumentList` 프로퍼티가
#   이 런타임에서 초기화되지 않은 채 $null 로 남아 `.Add()`가 예외를 던진다(.NET Core 전용 API가
#   .NET Framework 5.1에는 온전히 배선돼 있지 않음) — 그래서 모든 감지가 조용히 실패하는 갭이
#   실측으로 드러났다. 대신 `.Arguments`(단일 커맨드라인 문자열)를 직접 조립해 우회한다.
function Invoke-VersionCheck {
    param([string]$Cmd, [string[]]$CmdArgs, [string]$ExtraPath = $env:Path)
    $originalPath = $env:Path
    try {
        $resolved = $Cmd
        if ($Cmd -notmatch '[\\/]') {
            $env:Path = $ExtraPath
            $found = Get-Command $Cmd -ErrorAction SilentlyContinue | Select-Object -First 1
            if (-not $found) { return $null }
            $resolved = $found.Source
        } elseif (-not (Test-Path $Cmd)) {
            return $null
        }
        $argParts = @('/d', '/c', (ConvertTo-QuotedArg $resolved))
        foreach ($a in $CmdArgs) { $argParts += (ConvertTo-QuotedArg $a) }
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName  = 'cmd.exe'
        $psi.Arguments = ($argParts -join ' ')
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError  = $true
        $psi.UseShellExecute = $false
        $proc = [System.Diagnostics.Process]::Start($psi)
        $stdout = $proc.StandardOutput.ReadToEnd()
        $null = $proc.StandardError.ReadToEnd()
        if (-not $proc.WaitForExit(5000)) {
            try { $proc.Kill() } catch {}
            return $null
        }
        return $stdout
    } catch {
        return $null
    } finally {
        $env:Path = $originalPath
    }
}

function Test-CommandInstalled([string]$Cmd) {
    $out = Invoke-VersionCheck -Cmd $Cmd -CmdArgs @('--version') -ExtraPath (Get-AugmentedPath)
    return Get-SemVer $out
}

# ══════════════════════════════════════════════════════════════════════
# Node.js — install-for-kroot-adk.sh 의 ensure_node() 와 동일한 4단계 판정:
#   1) nvm(nvm4w) 있음 + 관리 버전 중 $MinNodeVersion 이상 존재 → 그 최신을 nvm use 로 활성화
#   2) nvm 있음 + 기준 이상 없음 → nvm install latest 후 nvm use
#   3) nvm 없음 + 전역(PATH) 에 기준 이상 존재 → 그대로 사용(winget 미실행)
#   4) nvm 없음 + 전역에도 없음 → winget 으로 최신 LTS 설치
# ══════════════════════════════════════════════════════════════════════
function Get-NvmInstalledVersions {
    if (-not (Get-Command nvm -ErrorAction SilentlyContinue)) { return @() }
    $out = & nvm list 2>$null | Out-String
    return ([regex]::Matches($out, '\d+\.\d+\.\d+') | ForEach-Object { $_.Value })
}

function Get-NvmLatestMeetingMin {
    $best = $null
    foreach ($v in (Get-NvmInstalledVersions)) {
        if ((Get-VersionGE $v $MinNodeVersion) -and ((-not $best) -or (Get-VersionGE $v $best))) { $best = $v }
    }
    return $best
}

function Install-NodeViaNvm {
    $latest = Get-NvmLatestMeetingMin
    if (-not $latest) {
        Write-Info "nvm: no installed Node >= $MinNodeVersion — installing the latest version via nvm..."
        & nvm install latest | Out-Null
        $latest = Get-NvmLatestMeetingMin
        if (-not $latest) {
            Write-Warn "nvm install latest did not produce a version >= $MinNodeVersion."
            return $null
        }
    }
    Write-Info "nvm: activating Node $latest (nvm use)..."
    try { & nvm use $latest 2>$null | Out-Null } catch {
        Write-Warn "nvm use $latest failed — Node may still work if it was already the active version."
    }
    return $latest
}

# 순수 $env:Path(증강 전) 위에서 발견되는 모든 node 실행파일 — 여러 전역 설치가 공존하는
# 드문 케이스 대비(install-for-kroot-adk.sh 의 `type -a` 와 동일 목적).
function Get-GlobalNodeCandidates {
    return (Get-Command node -All -ErrorAction SilentlyContinue) | ForEach-Object { $_.Source } | Select-Object -Unique
}

function Get-GlobalNodeVersion {
    $best = $null
    foreach ($p in (Get-GlobalNodeCandidates)) {
        $out = Invoke-VersionCheck -Cmd $p -CmdArgs @('--version') -ExtraPath $env:Path
        $v = Get-SemVer $out
        if ($v -and ((-not $best) -or (Get-VersionGE $v $best))) { $best = $v }
    }
    if ($best -and (Get-VersionGE $best $MinNodeVersion)) { return $best }
    # 순수 PATH 에 기준을 만족하는 버전이 없다 — 표준 설치 경로까지 넓혀서 재탐색.
    $v = Test-CommandInstalled 'node'
    if ($v -and (Get-VersionGE $v $MinNodeVersion)) { return $v }
    return $null
}

function Confirm-Node {
    if (Get-Command nvm -ErrorAction SilentlyContinue) {
        Write-Info 'nvm detected — resolving Node.js through nvm...'
        $chosen = Install-NodeViaNvm
        if ($chosen) { Write-Ok "Node.js $chosen is ready (via nvm)."; return }
        Write-Warn 'nvm-based Node setup failed — falling back to a global winget install.'
    }

    $chosen = Get-GlobalNodeVersion
    if ($chosen) { Write-Ok "Node.js $chosen is already installed globally (>= $MinNodeVersion) — using it."; return }

    if (-not (Test-Winget)) {
        Write-Err "No Node.js >= $MinNodeVersion found, and winget is unavailable — install Node.js manually."
        return
    }
    Write-Info "No Node.js >= $MinNodeVersion found — installing the latest LTS via winget..."
    Install-WingetPackage 'OpenJS.NodeJS.LTS' 'Node.js (LTS)' $null $null $null
}

# ══════════════════════════════════════════════════════════════════════
# Python — install-for-kroot-adk.sh 의 ensure_python() 과 동일한 3단 폴백. Windows 의
# python.org 설치기는 python.exe 만 만들고(python3 없음), 게다가 미설치 상태에서도 "앱 실행
# 별칭"(App Execution Alias) 스텁이 python.exe/python3.exe 를 PATH 에 미리 심어둔다(실행하면
# "Python" 만 출력·비정상 종료코드 — 버전 숫자 없음). 커맨드 존재만으로는 설치 여부를 구분할
# 수 없어, 신뢰도 순으로 확인한다: 1) 레지스트리(PythonCore) 2) py 런처(`py -3`) 3) `python`.
# ══════════════════════════════════════════════════════════════════════
function Get-PythonRegistryDirs {
    $roots = @(
        'HKLM:\SOFTWARE\Python\PythonCore',
        'HKCU:\SOFTWARE\Python\PythonCore',
        'HKLM:\SOFTWARE\WOW6432Node\Python\PythonCore'
    )
    $dirs = @()
    foreach ($root in $roots) {
        if (Test-Path $root) {
            Get-ChildItem $root -ErrorAction SilentlyContinue | ForEach-Object {
                $ipPath = Join-Path $_.PSPath 'InstallPath'
                if (Test-Path $ipPath) {
                    $val = Get-ItemProperty -Path $ipPath -ErrorAction SilentlyContinue
                    $prop = $val.PSObject.Properties['(default)']
                    if ($prop -and $prop.Value) { $dirs += $prop.Value }
                }
            }
        }
    }
    return $dirs
}

function Get-Python3Version {
    $best = $null
    foreach ($dir in (Get-PythonRegistryDirs)) {
        $exe = Join-Path $dir 'python.exe'
        if (Test-Path $exe) {
            $out = Invoke-VersionCheck -Cmd $exe -CmdArgs @('--version')
            $v = Get-SemVer $out
            if ($v -and $v.StartsWith('3.') -and ((-not $best) -or (Get-VersionGE $v $best))) { $best = $v }
        }
    }
    if ($best) { return $best }

    $out = Invoke-VersionCheck -Cmd 'py' -CmdArgs @('-3', '--version') -ExtraPath (Get-AugmentedPath)
    $v = Get-SemVer $out
    if ($v -and $v.StartsWith('3.')) { return $v }

    $out = Invoke-VersionCheck -Cmd 'python' -CmdArgs @('--version') -ExtraPath (Get-AugmentedPath)
    $v = Get-SemVer $out
    if ($v -and $v.StartsWith('3.')) { return $v }

    return $null
}

function Confirm-Python {
    $ver = Get-Python3Version
    if ($ver) { Write-Ok "Python 3 is already installed. ($ver)"; return }

    if (-not (Test-Winget)) {
        Write-Warn 'winget not found — cannot install Python automatically. Install Python 3 manually.'
        return
    }

    $pyid = Get-LatestPythonId
    Write-Info "Installing Python ($pyid) — this may take a few minutes..."
    # --override 는 winget 의 기본 무인 인자를 대체해 설치기(EXE)에 직접 전달된다. PrependPath=0
    # 은 python.org 설치기의 "Add python.exe to PATH" 체크박스에 대응하는 공식 커맨드라인
    # 프로퍼티 — 요청대로 이 옵션을 끈 채로 설치한다(레지스트리 등록은 이 옵션과 무관하게
    # 이뤄지므로 Get-Python3Version 의 1단계가 설치 직후에도 재탐지 가능하다).
    winget install --id $pyid -e --source winget --silent `
        --accept-package-agreements --accept-source-agreements `
        --override '/quiet PrependPath=0'
    if ($LASTEXITCODE -eq 0) {
        Write-Ok "Python ($pyid) installed. ('Add python.exe to PATH' left unchecked, as requested.)"
    } else {
        Write-Warn "Python install returned exit code $LASTEXITCODE — you may need to install it manually."
        return
    }

    $ver = Get-Python3Version
    if ($ver) {
        Write-Ok "Python $ver is detected (via registry/py launcher) even without being on PATH."
    } else {
        Write-Warn 'Could not confirm the installed Python via registry/py launcher/command — its directory may need to be added to PATH manually.'
    }
}

# ── prerequisites via winget ─────────────────────────────────────────
function Test-Winget { [bool](Get-Command winget -ErrorAction SilentlyContinue) }

function Install-WingetPackage($id, $name, $step, $total, $checkCmd) {
    $prefix = if ($step) { "[$step/$total] " } else { '' }
    if ($checkCmd) {
        $ver = Test-CommandInstalled $checkCmd
        if ($ver) { Write-Ok "${prefix}$name is already installed. ($checkCmd $ver)"; return }
    } else {
        $listed = winget list --id $id -e --accept-source-agreements 2>$null | Out-String
        if ($listed -match [regex]::Escape($id)) { Write-Ok "${prefix}$name is already installed."; return }
    }
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
    Confirm-Node

    if (Test-Winget) {
        Install-WingetPackage 'Anthropic.ClaudeCode' 'Claude Code' $null $null 'claude'
    } else {
        Write-Warn 'winget not found — skipping Claude Code / Git for Windows.'
        Write-Dim 'Install winget (App Installer) from the Microsoft Store, or install those tools manually.'
    }
    if ((-not $SkipGitBash) -and (Test-Winget)) {
        Install-WingetPackage 'Git.Git' 'Git for Windows (Git Bash)' $null $null 'git'
    } elseif ($SkipGitBash) {
        Write-Dim 'Skipped Git for Windows (--SkipGitBash); Claude Code will use PowerShell as its shell tool.'
    }

    if (-not $SkipPython) {
        Confirm-Python
    } else {
        Write-Dim 'Skipped Python (--SkipPython).'
    }
}

# ── main ─────────────────────────────────────────────────────────────
if ($Uninstall) {
    Invoke-Uninstall
    return
}

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
