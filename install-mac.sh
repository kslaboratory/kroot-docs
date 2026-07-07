#!/usr/bin/env bash
#
# KRoot-ADK full macOS installer — installs everything needed to use kroot with
# Claude Code, in one command:
#   Homebrew (if missing) -> Node.js, Python (latest 3.x), Git -> Claude Code -> kroot
# then makes them usable in the current shell.
#
# Usage:
#   curl -fsSL https://kslaboratory.github.io/kroot-docs/install-mac.sh | bash
#
# Options (pass after `bash -s --`):
#   --skip-python     Skip Python
#   --skip-deps       Install only kroot (skip Homebrew/Node/Python/Git/Claude Code)
#   --version X.Y.Z   Install a specific kroot version
#
set -euo pipefail

REPO="kslaboratory/kroot-docs"
RELEASES_URL="https://api.github.com/repos/${REPO}/releases"
DOWNLOAD_BASE="https://github.com/${REPO}/releases/download"
BINARY_NAME="kroot"
WT_BINARY_NAME="kroot-wt"
INSTALL_DIR="${HOME}/.local/bin"

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
ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    ok "Homebrew already installed."
  else
    info "Installing Homebrew (it may ask for your Mac password)..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  if [ -x /opt/homebrew/bin/brew ]; then eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then eval "$(/usr/local/bin/brew shellenv)"; fi
  command -v brew >/dev/null 2>&1
}

brew_install() { # formula name step total
  local pkg="$1" name="$2" step="$3" total="$4"
  if brew list --formula "$pkg" >/dev/null 2>&1; then
    ok "[$step/$total] $name is already installed."; return
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

install_prereqs() {
  if ! ensure_brew; then
    err "Homebrew is not available — cannot install prerequisites."
    dim "Install Homebrew from https://brew.sh and re-run, or pass --skip-deps."
    return 1
  fi
  local total=2  # node + claude
  $SKIP_PYTHON || total=$((total + 1))
  command -v git >/dev/null 2>&1 || total=$((total + 1))

  local step=0
  step=$((step + 1)); brew_install node   "Node.js"             "$step" "$total"
  if ! $SKIP_PYTHON; then step=$((step + 1)); brew_install python "Python (latest 3.x)" "$step" "$total"; fi
  # git usually ships with the Xcode CLT — confirm it (no brew step) or install it.
  if command -v git >/dev/null 2>&1; then
    ok "Git is already installed ($(command -v git))."
  else
    step=$((step + 1)); brew_install git "Git" "$step" "$total"
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
