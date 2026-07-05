#!/usr/bin/env bash
#
# Desinstala e remove a configuração do Headroom (https://github.com/chopratejas/headroom)
# instalados por ./instalar.sh.
#
# Uso:
#   ./desinstalar.sh                 # desfaz os wrappers e desinstala o Headroom
#   ./desinstalar.sh --keep-package  # só desfaz os wrappers/MCP, mantém o Headroom instalado
#   ./desinstalar.sh --skip-unwrap   # só desinstala o pacote, sem desfazer wrappers
#
set -euo pipefail

KEEP_PACKAGE=0
SKIP_UNWRAP=0
for arg in "$@"; do
  case "$arg" in
    --keep-package) KEEP_PACKAGE=1 ;;
    --skip-unwrap) SKIP_UNWRAP=1 ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      echo "Argumento desconhecido: $arg" >&2
      exit 1
      ;;
  esac
done

info()  { printf '\033[1;34m[info]\033[0m %s\n' "$1"; }
ok()    { printf '\033[1;32m[ok]\033[0m %s\n' "$1"; }
warn()  { printf '\033[1;33m[aviso]\033[0m %s\n' "$1"; }
err()   { printf '\033[1;31m[erro]\033[0m %s\n' "$1" >&2; }

# Garante que o diretório de scripts do usuário está no PATH nesta sessão,
# caso o headroom tenha sido instalado em ~/.local/bin (comum com --user).
USER_BASE="$(python3 -m site --user-base 2>/dev/null || true)"
if [ -n "$USER_BASE" ] && [ -d "$USER_BASE/bin" ]; then
  case ":$PATH:" in
    *":$USER_BASE/bin:"*) ;;
    *) export PATH="$USER_BASE/bin:$PATH" ;;
  esac
fi

if ! command -v headroom >/dev/null 2>&1; then
  warn "Comando 'headroom' não encontrado no PATH. Pulando etapas que dependem dele."
  HEADROOM_AVAILABLE=0
else
  HEADROOM_AVAILABLE=1
fi

# ---------------------------------------------------------------------------
# 1. Desfazer wrappers das ferramentas (o inverso do passo 3 de instalar.sh)
# ---------------------------------------------------------------------------

if [ "$SKIP_UNWRAP" -eq 1 ]; then
  info "Flag --skip-unwrap informada: pulando remoção de wrappers."
elif [ "$HEADROOM_AVAILABLE" -eq 0 ]; then
  warn "Headroom não disponível: pulando remoção de wrappers (edite os configs manualmente se necessário)."
else
  info "Desfazendo wrappers configurados por instalar.sh..."

  if command -v claude >/dev/null 2>&1; then
    info "Desfazendo wrapper do Claude Code..."
    headroom unwrap claude || warn "Falha ao desfazer wrapper do Claude Code."
    ok "Claude Code restaurado."
  else
    warn "Claude Code (comando 'claude') não encontrado. Pulando."
  fi

  if command -v codex >/dev/null 2>&1; then
    info "Desfazendo wrapper do Codex..."
    headroom unwrap codex || warn "Falha ao desfazer wrapper do Codex."
    ok "Codex restaurado."
  else
    warn "Codex (comando 'codex') não encontrado. Pulando."
  fi

  if command -v copilot >/dev/null 2>&1 || (command -v gh >/dev/null 2>&1 && gh copilot --help >/dev/null 2>&1); then
    info "Desfazendo wrapper do GitHub Copilot CLI..."
    headroom unwrap copilot || warn "Falha ao desfazer wrapper do Copilot."
    ok "Copilot restaurado."
  else
    warn "GitHub Copilot CLI não encontrado. Pulando."
  fi

  if command -v opencode >/dev/null 2>&1; then
    info "Desfazendo wrapper do opencode..."
    headroom unwrap opencode || warn "Falha ao desfazer wrapper do opencode."
    ok "opencode restaurado."
  else
    warn "opencode não encontrado. Pulando."
  fi

  # aider, cline, continue, goose e openhands não possuem 'headroom unwrap':
  # o 'headroom wrap' desses apenas inicia um proxy/launcher e não deixa
  # configuração durável para desfazer.
  for tool in aider cline continue goose openhands; do
    if command -v "$tool" >/dev/null 2>&1; then
      warn "$tool detectado: 'headroom wrap $tool' não grava configuração durável, nada a desfazer."
    fi
  done

  info "Removendo registro do servidor MCP do Headroom (se houver)..."
  headroom mcp uninstall || warn "Falha ao remover o servidor MCP (pode já estar removido)."
fi

# ---------------------------------------------------------------------------
# 2. Desinstalar o pacote Headroom
# ---------------------------------------------------------------------------

VENV_DIR="$HOME/.local/share/headroom/venv"
SHIM_DIR="$HOME/.local/bin"
SHIM_PATH="$SHIM_DIR/headroom"

if [ "$KEEP_PACKAGE" -eq 1 ]; then
  info "Flag --keep-package informada: mantendo o pacote Headroom instalado."
else
  info "Desinstalando o pacote Headroom..."

  if [ -x "$SHIM_PATH" ] && grep -q "$VENV_DIR" "$SHIM_PATH" 2>/dev/null; then
    info "Removendo ambiente virtual dedicado em $VENV_DIR..."
    rm -rf "$VENV_DIR"
    rm -f "$SHIM_PATH"
    ok "Ambiente virtual dedicado e shim removidos."
  elif command -v pipx >/dev/null 2>&1 && pipx list 2>/dev/null | grep -qi "headroom-ai"; then
    info "Removendo instalação via pipx..."
    pipx uninstall headroom-ai || warn "Falha ao desinstalar via pipx."
    ok "Headroom removido via pipx."
  else
    info "Removendo instalação via pip (--user)..."
    if ! python3 -m pip uninstall -y "headroom-ai" 2>&1; then
      warn "Falha ao desinstalar via pip. Pode já ter sido removido ou ter sido instalado de outra forma."
    else
      ok "Headroom removido via pip."
    fi
  fi

  if command -v headroom >/dev/null 2>&1; then
    warn "O comando 'headroom' ainda está no PATH em: $(command -v headroom)"
    warn "Remova manualmente se a desinstalação acima não foi suficiente."
  fi
fi

# ---------------------------------------------------------------------------
# 3. Resumo
# ---------------------------------------------------------------------------

echo
ok "Desinstalação concluída."
echo "Observações:"
echo "  - Backups de configs originais (ex: config.toml.headroom-backup) já são"
echo "    restaurados automaticamente pelo 'headroom unwrap'."
echo "  - Se algum wrapper foi configurado manualmente fora do instalar.sh,"
echo "    revise os arquivos de configuração da ferramenta correspondente."
echo
