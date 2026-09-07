#!/usr/bin/env bash
#
# KRoot-ADK full macOS installer — installs everything needed to use kroot with
# Claude Code, in one command:
#   Node.js, Python (latest 3.x), Git -> Claude Code -> kroot
# then makes them usable in the current shell.
#
# Node.js/Python detection (2026-09, aligned with install.ps1/install-for-kroot-adk.sh):
#   already-installed tools are detected and skipped **regardless of how they were
#   installed** — not just via Homebrew. Node.js checks nvm first (if `~/.nvm/nvm.sh`
#   exists it's sourced even in this non-interactive shell), then any `node` on PATH
#   meeting the `>=22.13.0` minimum (kroot-studio's engines.node requirement); Python
#   just needs `python3` on PATH. Homebrew is only installed/invoked as a last resort,
#   when nothing else already satisfies the requirement.
#
# Usage:
#   curl -fsSL https://kslaboratory.github.io/kroot-docs/install-mac.sh | bash
#
# Options (pass after `bash -s --`):
#   --skip-python     Skip Python
#   --skip-deps       Install only kroot (skip Node/Python/Git/Claude Code — Homebrew too, unless already needed)
#   --version X.Y.Z   Install a specific kroot version
#
set -euo pipefail

REPO="kslaboratory/kroot-docs"
RELEASES_URL="https://api.github.com/repos/${REPO}/releases"
DOWNLOAD_BASE="https://github.com/${REPO}/releases/download"
BINARY_NAME="kroot"
WT_BINARY_NAME="kroot-wt"
INSTALL_DIR="${HOME}/.local/bin"

# kroot-studio package.json 의 engines.node 와 동일한 하한(install.ps1/install-for-kroot-adk.sh
# 와 동일 기준) — 이 미만이면 임베디드 서버가 뜨지 않는다.
MIN_NODE_VERSION="22.13.0"

SKIP_PYTHON=false
SKIP_DEPS=false
TARGET_VERSION=""

# ── output helpers ───────────────────────────────────────────────────
if [ -t 1 ]; then
  CYAN=$'\033[0;36m'; GREEN=$'\033[1;32m'; YELLOW=$'\033[0;33m'; RED=$'\033[0;31m'; DIM=$'\033[2m'; NC=$'\033[0m'
else
  CYAN=''; GREEN=''; YELLOW=''; RED=''; DIM=''; NC=''
fi
info() { printf '  %s%s%s\n' "$CYAN" "$1" "$NC"; }
ok()   { printf '  %s%s%s\n' "$GREEN" "$1" "$NC"; }
warn() { printf '  %s%s%s\n' "$YELLOW" "$1" "$NC"; }
err()  { printf '  %sERROR: %s%s\n' "$RED" "$1" "$NC" >&2; }
dim()  { printf '  %s%s%s\n' "$DIM" "$1" "$NC"; }

while [ $# -gt 0 ]; do
  case "$1" in
    --skip-python) SKIP_PYTHON=true; shift ;;
    --skip-deps)   SKIP_DEPS=true; shift ;;
    --version)     TARGET_VERSION="${2:-}"; [ -z "$TARGET_VERSION" ] && { err "--version requires a value"; exit 1; }; shift 2 ;;
    --help|-h)     echo "Usage: curl -fsSL <url>/install-mac.sh | bash [-s -- --skip-python|--skip-deps|--version X.Y.Z]"; exit 0 ;;
    *) err "Unknown option: $1"; exit 1 ;;
  esac
done

banner() {
  echo ""
  echo "  ╔════════════════════════════════════════╗"
  echo "  ║  KRoot-ADK Installer (macOS)            ║"
  echo "  ║  kroot · Node · Python · Git · Claude   ║"
  echo "  ╚════════════════════════════════════════╝"
  echo ""
}

TMP_DIR=""
cleanup() { [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"; }
trap cleanup EXIT

detect_arch() {
  case "$(uname -m)" in
    x86_64|amd64)  echo "amd64" ;;
    arm64|aarch64) echo "arm64" ;;
    *) err "Unsupported architecture: $(uname -m)"; exit 1 ;;
  esac
}

# ── prerequisites (Homebrew + brew formulae + Claude Code) ───────────
# ensure_brew 는 지연 호출된다 — brew_install() 이 "brew 로도 없다"고 확정한 뒤에만 부른다.
# 예전엔 install_prereqs() 맨 앞에서 무조건 요구해서, nvm 으로 Node 가 이미 있어도 Homebrew가
# 없으면 전체가 실패했다.
ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return 0
  fi
  info "Installing Homebrew (it may ask for your Mac password)..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi
  command -v brew >/dev/null 2>&1
}

brew_install() { # formula name step total
  local pkg="$1" name="$2" step="$3" total="$4"
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    ok "[$step/$total] $name is already installed."; return
  fi
  if ! ensure_brew; then
    err "[$step/$total] Homebrew is not available — cannot install $name automatically."
    dim "Install Homebrew from https://brew.sh and re-run, or install $name manually."
    return 1
  fi
  info "[$step/$total] Installing $name (brew install $pkg) — this may take a few minutes..."
  if brew install "$pkg"; then ok "[$step/$total] $name installed."
  else warn "[$step/$total] $name install failed — you may need to install it manually."; fi
}

install_claude() { # step total
  local step="$1" total="$2"
  if command -v claude >/dev/null 2>&1; then ok "[$step/$total] Claude Code is already installed."; return; fi
  info "[$step/$total] Installing Claude Code — this may take a minute..."
  curl -fsSL https://claude.ai/install.sh | bash || warn "native Claude Code installer reported an error."
  export PATH="${HOME}/.local/bin:$PATH"
  if ! command -v claude >/dev/null 2>&1; then
    warn "Falling back to: npm install -g @anthropic-ai/claude-code"
    npm install -g @anthropic-ai/claude-code || warn "Claude Code install failed — install it manually."
  fi
  ok "[$step/$total] Claude Code step done."
}

# ── 버전 비교 ──────────────────────────────────────────────────────────
# a >= b 이면 참(exit 0). 점(.) 구분 숫자를 수치 비교한다("9" < "10" 문자열 정렬 오류 방지).
version_ge() {
  local a="$1" b="$2"
  local IFS=.
  local -a A=($a) B=($b)
  local i ai bi
  for i in 0 1 2; do
    ai="${A[i]:-0}"; bi="${B[i]:-0}"
    if ((10#$ai > 10#$bi)); then return 0; fi
    if ((10#$ai < 10#$bi)); then return 1; fi
  done
  return 0
}

# ══════════════════════════════════════════════════════════════════════
# Node.js — install.ps1/install-for-kroot-adk.sh 와 동일한 판정:
#   1) nvm 있음 + 관리 버전 중 MIN_NODE_VERSION 이상 존재 → 그 최신을 nvm use 로 활성화
#   2) nvm 있음 + 기준 이상 없음 → nvm install --lts 후 nvm use
#   3) nvm 없음 + 전역(PATH)에 기준 이상 존재 → 그대로 사용(brew 미실행)
#   4) nvm 없음 + 전역에도 없음 → brew install node(최후 수단, Homebrew 는 이때만 지연 설치)
# ══════════════════════════════════════════════════════════════════════

# macOS 의 nvm 은 바이너리가 아니라 **셸 함수**라(`~/.nvm/nvm.sh` 를 로그인 셸 rc 가 source)
# `curl | bash` 같은 비대화형 셸에는 로드돼 있지 않다 — 표준 설치 위치에서 직접 source 한다.
# 서드파티 스크립트(nvm.sh)를 우리 set -e 아래서 그대로 source 하면 깨지기 쉬워 일시적으로 끈다.
load_nvm() {
  local nvm_dir="${NVM_DIR:-$HOME/.nvm}"
  [ -s "$nvm_dir/nvm.sh" ] || return 1
  set +e
  # shellcheck disable=SC1090
  . "$nvm_dir/nvm.sh" >/dev/null 2>&1
  set -e
  command -v nvm >/dev/null 2>&1
}

# nvm 관리 버전 중 MIN_NODE_VERSION 이상인 것들 중 최신을 고른다(없으면 빈 문자열, 항상 exit 0).
nvm_latest_meeting_min() {
  local best="" v
  while IFS= read -r v; do
    [ -z "$v" ] && continue
    if version_ge "$v" "$MIN_NODE_VERSION"; then
      if [ -z "$best" ] || version_ge "$v" "$best"; then best="$v"; fi
    fi
  done < <(nvm ls --no-colors 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)
  printf '%s\n' "$best"
}

# 케이스 1)/2). 성공 시 stdout 으로 사용할 버전 문자열을 출력.
setup_node_via_nvm() {
  local latest
  latest="$(nvm_latest_meeting_min)"
  if [ -z "$latest" ]; then
    info "nvm: no installed Node >= ${MIN_NODE_VERSION} — installing the latest LTS via nvm..."
    if ! nvm install --lts >/dev/null 2>&1; then
      warn "nvm install --lts failed."
      return 1
    fi
    latest="$(nvm_latest_meeting_min)"
    if [ -z "$latest" ]; then
      warn "nvm install --lts did not produce a version >= ${MIN_NODE_VERSION}."
      return 1
    fi
  fi
  nvm use "$latest" >/dev/null 2>&1 || warn "nvm use ${latest} failed — Node may still work if it was already the active version."
  printf '%s\n' "$latest"
}

# 케이스 3): 전역 설치(brew 여부 무관, PATH 상의 아무 node) 중 기준 이상인지 확인.
find_global_node() {
  local v
  command -v node >/dev/null 2>&1 || return 1
  v="$(node --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)"
  if [ -n "$v" ] && version_ge "$v" "$MIN_NODE_VERSION"; then
    printf '%s\n' "$v"
    return 0
  fi
  return 1
}

ensure_node() { # step total
  local step="$1" total="$2" chosen
  if load_nvm; then
    info "[$step/$total] nvm detected — resolving Node.js through nvm..."
    if chosen="$(setup_node_via_nvm)" && [ -n "$chosen" ]; then
      ok "[$step/$total] Node.js ${chosen} is ready (via nvm)."
      return 0
    fi
    warn "[$step/$total] nvm-based Node setup failed — falling back to Homebrew."
  fi
  if chosen="$(find_global_node)"; then
    ok "[$step/$total] Node.js ${chosen} is already installed (>= ${MIN_NODE_VERSION}) — using it."
    return 0
  fi
  brew_install node "Node.js" "$step" "$total"
}

# Python — macOS/Linux 는 python3 커맨드 하나로 충분하다(Windows 같은 앱 실행 별칭 스텁 문제
# 없음). brew 로 설치됐는지 여부와 무관하게, python3 가 PATH 어디서든 발견되면 그걸 쓴다.
ensure_python() { # step total
  local step="$1" total="$2"
  if command -v python3 >/dev/null 2>&1; then
    local v
    v="$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' || true)"
    ok "[$step/$total] Python is already installed. (python3 ${v:-unknown})"
    return 0
  fi
  brew_install python "Python (latest 3.x)" "$step" "$total"
}

install_prereqs() {
  local total=3  # node + git + claude
  $SKIP_PYTHON || total=$((total + 1))

  local step=0
  step=$((step + 1)); ensure_node "$step" "$total"
  if ! $SKIP_PYTHON; then step=$((step + 1)); ensure_python "$step" "$total"; fi
  # git usually ships with the Xcode CLT — count it as a step either way.
  step=$((step + 1))
  if command -v git >/dev/null 2>&1; then
    ok "[$step/$total] Git is already installed ($(command -v git))."
  else
    brew_install git "Git" "$step" "$total"
  fi
  step=$((step + 1)); install_claude "$step" "$total"
}

# ── kroot binary ─────────────────────────────────────────────────────
get_latest_version() {
  local resp
  resp=$(curl -fsSL -H "Accept: application/vnd.github.v3+json" "${RELEASES_URL}/latest" 2>/dev/null) || { err "Failed to reach GitHub for the latest version."; exit 1; }
  echo "$resp" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/' | sed 's/^v//'
}

sha256_of() {
  if command -v shasum >/dev/null 2>&1; then shasum -a 256 "$1" | awk '{print $1}'
  else sha256sum "$1" | awk '{print $1}'; fi
}

install_kroot() { # arch version
  local arch="$1" version="$2"
  TMP_DIR="$(mktemp -d)"
  mkdir -p "$INSTALL_DIR"
  # Fetch checksums once (best-effort).
  local checks="${TMP_DIR}/checksums.txt"
  curl -fsSL -o "$checks" "${DOWNLOAD_BASE}/v${version}/checksums.txt" 2>/dev/null || true
  for b in "$BINARY_NAME" "$WT_BINARY_NAME"; do
    local asset="${b}-darwin-${arch}"
    info "Downloading ${asset} (kroot v${version})..."
    curl -fsSL -o "${TMP_DIR}/${asset}" "${DOWNLOAD_BASE}/v${version}/${asset}" || { err "Download failed: ${asset}"; exit 1; }
    if [ -f "$checks" ]; then
      local expected; expected=$(awk -v n="$asset" '$2 == n {print $1; exit}' "$checks")
      if [ -n "$expected" ]; then
        local actual; actual=$(sha256_of "${TMP_DIR}/${asset}")
        [ "$expected" = "$actual" ] || { err "Checksum mismatch for ${asset}"; exit 1; }
      fi
    fi
    install -m 0755 "${TMP_DIR}/${asset}" "${INSTALL_DIR}/${b}"
  done
  ok "kroot installed to ${INSTALL_DIR}"
}

# add_to_shell_rc: idempotently persist INSTALL_DIR on PATH (zsh is macOS default).
# Sets the global RC_FILE to the rc it wrote (no stdout capture needed).
RC_FILE=""
add_to_shell_rc() {
  local rc marker="# added by kroot-adk installer"
  case "$(basename "${SHELL:-/bin/zsh}")" in
    zsh)  rc="${ZDOTDIR:-$HOME}/.zshrc" ;;
    bash) rc="${HOME}/.bash_profile" ;;
    *)    rc="${HOME}/.profile" ;;
  esac
  [ -f "$rc" ] || : > "$rc"
  if ! grep -qF "$marker" "$rc" 2>/dev/null; then
    printf '\n%s\nexport PATH="%s:$PATH"\n' "$marker" "$INSTALL_DIR" >> "$rc"
    ok "Added ${INSTALL_DIR} to PATH in ${rc}"
  else
    dim "${rc} already has the kroot PATH entry."
  fi
  case ":$PATH:" in *":${INSTALL_DIR}:"*) : ;; *) export PATH="${INSTALL_DIR}:$PATH" ;; esac
  RC_FILE="$rc"
}

show_tool() { # cmd label
  local p
  if p="$(command -v "$1" 2>/dev/null)"; then printf '  %s%-8s %s%s\n' "$GREEN" "$2" "$p" "$NC"
  else printf '  %s%-8s not found yet — open a new terminal to use it.%s\n' "$DIM" "$2" "$NC"; fi
}

# ── main ─────────────────────────────────────────────────────────────
banner
arch="$(detect_arch)"
info "Platform: darwin/${arch}"

if ! $SKIP_DEPS; then
  install_prereqs || warn "Continuing to install kroot despite a prerequisite error."
else
  dim "Skipping Homebrew/Node/Python/Git/Claude Code (--skip-deps)."
fi

version="${TARGET_VERSION}"
[ -z "$version" ] && { info "Resolving latest kroot version..."; version="$(get_latest_version)"; }
install_kroot "$arch" "$version"
add_to_shell_rc

echo ""
ok "Installation complete!"
echo ""
dim "Installed:"
show_tool kroot  "kroot"
if ! $SKIP_DEPS; then
  show_tool node    "node"
  $SKIP_PYTHON || show_tool python3 "python"
  show_tool git     "git"
  show_tool claude  "claude"
fi
echo ""
dim "Try it now:  kroot --version"
dim "(If anything shows \"not found yet\", run:  source ${RC_FILE}   — or open a new terminal.)"
echo ""
