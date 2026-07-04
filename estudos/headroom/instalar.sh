#!/usr/bin/env bash
#
# Instala e configura o Headroom (https://github.com/chopratejas/headroom)
# seguindo o passo a passo descrito em tutorial-configuracao.md.
#
# Uso:
#   ./instalar.sh                 # instala + detecta e envolve ferramentas presentes
#   ./instalar.sh --skip-wrap     # só instala o Headroom, sem envolver nenhuma ferramenta
#   ./instalar.sh --with-mcp      # também registra o Headroom como servidor MCP
#
set -euo pipefail

SKIP_WRAP=0
WITH_MCP=0
for arg in "$@"; do
  case "$arg" in
    --skip-wrap) SKIP_WRAP=1 ;;
    --with-mcp) WITH_MCP=1 ;;
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

# ---------------------------------------------------------------------------
# 0. Pré-requisitos
# ---------------------------------------------------------------------------

info "Verificando Python..."
if ! command -v python3 >/dev/null 2>&1; then
  err "python3 não encontrado no PATH. Instale Python 3.10+ antes de continuar."
  exit 1
fi

PY_VERSION="$(python3 -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
PY_MAJOR="$(echo "$PY_VERSION" | cut -d. -f1)"
PY_MINOR="$(echo "$PY_VERSION" | cut -d. -f2)"
if [ "$PY_MAJOR" -lt 3 ] || { [ "$PY_MAJOR" -eq 3 ] && [ "$PY_MINOR" -lt 10 ]; }; then
  err "Python $PY_VERSION detectado. O Headroom requer Python 3.10+."
  exit 1
fi
ok "Python $PY_VERSION"

if ! command -v pip3 >/dev/null 2>&1 && ! python3 -m pip --version >/dev/null 2>&1; then
  err "pip não encontrado. Instale pip para o seu Python 3 antes de continuar."
  exit 1
fi

# ---------------------------------------------------------------------------
# 1. Instalar o Headroom
# ---------------------------------------------------------------------------

VENV_DIR="$HOME/.local/share/headroom/venv"
SHIM_DIR="$HOME/.local/bin"
SHIM_PATH="$SHIM_DIR/headroom"

install_via_dedicated_venv() {
  info "Criando ambiente virtual dedicado em $VENV_DIR (não mexe no Python do sistema)..."
  python3 -m venv "$VENV_DIR"
  "$VENV_DIR/bin/python" -m pip install --upgrade pip >/dev/null
  if ! "$VENV_DIR/bin/python" -m pip install "headroom-ai[all]"; then
    return 1
  fi
  mkdir -p "$SHIM_DIR"
  cat > "$SHIM_PATH" <<EOF
#!/usr/bin/env bash
exec "$VENV_DIR/bin/headroom" "\$@"
EOF
  chmod +x "$SHIM_PATH"
  return 0
}

if command -v headroom >/dev/null 2>&1; then
  ok "Headroom já instalado ($(headroom --version 2>/dev/null || echo 'versão desconhecida')). Pulando instalação."
else
  info "Instalando headroom-ai[all] via pip (--user)..."
  PIP_OUTPUT="$(python3 -m pip install --user "headroom-ai[all]" 2>&1)" && PIP_STATUS=0 || PIP_STATUS=$?

  if [ "$PIP_STATUS" -ne 0 ] && echo "$PIP_OUTPUT" | grep -qi "externally-managed-environment"; then
    warn "Este sistema usa Python 'externally managed' (PEP 668): pip --user recusou instalar globalmente."
    if command -v pipx >/dev/null 2>&1; then
      info "pipx encontrado. Instalando headroom-ai[all] via pipx..."
      if pipx install "headroom-ai[all]"; then
        PIP_STATUS=0
      else
        warn "Falha ao instalar via pipx. Tentando ambiente virtual dedicado..."
        install_via_dedicated_venv && PIP_STATUS=0 || PIP_STATUS=1
      fi
    else
      info "pipx não encontrado. Criando ambiente virtual dedicado só para o Headroom..."
      install_via_dedicated_venv && PIP_STATUS=0 || PIP_STATUS=1
    fi
  elif [ "$PIP_STATUS" -ne 0 ]; then
    echo "$PIP_OUTPUT" >&2
  fi

  if [ "$PIP_STATUS" -ne 0 ]; then
    err "Falha ao instalar o Headroom."
    warn "Se você está em uma rede corporativa com SSL inspection, veja a seção"
    warn "'Problemas comuns de instalação' em tutorial-configuracao.md (instalar Rust"
    warn "manualmente e exportar REQUESTS_CA_BUNDLE / SSL_CERT_FILE)."
    exit 1
  fi
  ok "Headroom instalado."
fi

# Garante que o diretório de scripts do usuário está no PATH nesta sessão,
# caso o pip tenha instalado em ~/.local/bin (comum com --user).
USER_BASE="$(python3 -m site --user-base 2>/dev/null || true)"
if [ -n "$USER_BASE" ] && [ -d "$USER_BASE/bin" ]; then
  case ":$PATH:" in
    *":$USER_BASE/bin:"*) ;;
    *) export PATH="$USER_BASE/bin:$PATH" ;;
  esac
fi

if ! command -v headroom >/dev/null 2>&1; then
  err "O comando 'headroom' não foi encontrado no PATH após a instalação."
  err "Adicione '$USER_BASE/bin' ao seu PATH (ex: no ~/.bashrc ou ~/.zshrc) e rode este script novamente."
  exit 1
fi

# ---------------------------------------------------------------------------
# 2. Verificação de saúde
# ---------------------------------------------------------------------------

info "Rodando 'headroom doctor'..."
if ! headroom doctor; then
  warn "'headroom doctor' reportou problemas. Revise a saída acima antes de prosseguir."
fi

# ---------------------------------------------------------------------------
# 3. Detectar ferramentas instaladas e envolvê-las (wrap)
# ---------------------------------------------------------------------------

if [ "$SKIP_WRAP" -eq 1 ]; then
  info "Flag --skip-wrap informada: pulando configuração de wrappers."
else
  info "Detectando ferramentas de IA instaladas para configurar automaticamente..."

  if command -v claude >/dev/null 2>&1; then
    info "Claude Code detectado -> configurando 'headroom wrap claude'..."
    headroom wrap claude --memory --code-graph || warn "Falha ao configurar wrapper do Claude Code."
    ok "Claude Code configurado. Use normalmente; a compressão passa a ser aplicada nos bastidores."
  else
    warn "Claude Code (comando 'claude') não encontrado. Pulando."
  fi

  if command -v codex >/dev/null 2>&1; then
    info "Codex detectado -> configurando 'headroom wrap codex'..."
    headroom wrap codex || warn "Falha ao configurar wrapper do Codex."
    ok "Codex configurado."
  else
    warn "Codex (comando 'codex') não encontrado. Pulando."
  fi

  if command -v copilot >/dev/null 2>&1 || (command -v gh >/dev/null 2>&1 && gh copilot --help >/dev/null 2>&1); then
    info "GitHub Copilot CLI detectado."
    warn "O login do Copilot é interativo ('headroom copilot-auth login')."
    warn "Rode manualmente, depois:  headroom wrap copilot --subscription -- --model gpt-4o"
  else
    warn "GitHub Copilot CLI não encontrado. Pulando."
  fi

  for tool in aider opencode cline continue goose openhands; do
    if command -v "$tool" >/dev/null 2>&1; then
      info "$tool detectado -> configurando 'headroom wrap $tool'..."
      headroom wrap "$tool" || warn "Falha ao configurar wrapper de $tool."
      ok "$tool configurado."
    fi
  done

  if command -v cursor >/dev/null 2>&1; then
    warn "Cursor detectado, mas não tem wrapper automático."
    warn "Suba o proxy manualmente com: headroom proxy --port 8787"
    warn "e aponte a 'Base URL' do Cursor para o endereço impresso pelo comando."
  fi
fi

# ---------------------------------------------------------------------------
# 4. (Opcional) Servidor MCP
# ---------------------------------------------------------------------------

if [ "$WITH_MCP" -eq 1 ]; then
  info "Registrando Headroom como servidor MCP ('headroom mcp install')..."
  headroom mcp install || warn "Falha ao registrar o servidor MCP."
fi

# ---------------------------------------------------------------------------
# 5. Resumo
# ---------------------------------------------------------------------------

echo
ok "Instalação concluída."
echo "Próximos passos sugeridos:"
echo "  headroom dashboard        # ver economia estimada em tempo real"
echo "  headroom perf             # métricas de desempenho da compressão"
echo "  headroom output-savings   # estimativa de economia também na resposta do modelo"
echo
echo "Para medir o ganho real: rode uma tarefa típica sem o wrapper, anote os tokens,"
echo "depois repita uma tarefa parecida com o wrapper ativo e compare."
echo
echo "Detalhes completos em: $(dirname "$0")/tutorial-configuracao.md"
