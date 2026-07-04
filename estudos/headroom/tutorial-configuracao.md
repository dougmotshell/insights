# Tutorial: configurando o Headroom com Claude Code, Codex e GitHub Copilot

> Passo a passo para instalar o Headroom localmente e ligá-lo às ferramentas de IA que você já usa. Baseado no README oficial de [github.com/chopratejas/headroom](https://github.com/chopratejas/headroom) e na [documentação oficial](https://headroom-docs.vercel.app/docs). Confirme sempre a versão mais recente no repositório, pois o projeto está em desenvolvimento ativo.

> **Atalho:** os passos 1 a 3 abaixo estão automatizados em [`instalar.sh`](./instalar.sh). Rode `./instalar.sh` para instalar o Headroom e configurar automaticamente o wrapper das ferramentas que já estiverem no seu PATH (Claude Code, Codex, Aider, etc). O passo a passo manual abaixo continua útil para entender o que o script faz, ou para configurar ferramentas sem detecção automática (Cursor, Copilot).

## 0. Pré-requisitos

- **Python 3.10+** (recomendado 3.13, necessário se você quiser que o dashboard mostre economia em dólares via LiteLLM)
- **CPU com AVX2** se for x86/x86_64 (para os recursos que usam ONNX). Em Apple Silicon (arm64) isso não é necessário.
- Opcional: **Redis** rodando localmente, se quiser usar armazenamento de CCR (compressão reversível) em Redis em vez de SQLite (SQLite é o padrão e não exige nada extra).
- Já ter instalados os CLIs que você quer "envelopar": Claude Code, GitHub Copilot CLI, Codex CLI, etc.

Verifique sua versão de Python:

```bash
python3 --version
```

## 1. Instalar o Headroom

Recomendado — via `pip`, com todos os extras:

```bash
pip install "headroom-ai[all]"
```

Alternativas:

```bash
# Apenas o SDK TypeScript (sem CLI)
npm install headroom-ai

# Via pipx, isolado do seu Python global (recomendado se quiser evitar conflitos)
pipx install --python python3.13 "headroom-ai[all]"

# Via Docker, se preferir rodar em container
docker pull ghcr.io/chopratejas/headroom:latest
```

Se você não precisa de todos os recursos, dá para instalar só os extras relevantes, por exemplo:

```bash
pip install "headroom-ai[proxy,mcp,code]"
```

### Problema comum: `externally-managed-environment` (Debian/Ubuntu com Python 3.12+)

Distribuições recentes bloqueiam `pip install` fora de um ambiente virtual (PEP 668). O `instalar.sh` já trata isso automaticamente: tenta `pip install --user`, se falhar por esse motivo tenta `pipx`, e se `pipx` não existir cria um ambiente virtual dedicado em `~/.local/share/headroom/venv` com um atalho em `~/.local/bin/headroom`. Se estiver instalando manualmente, faça o mesmo:

```bash
python3 -m venv ~/.local/share/headroom/venv
~/.local/share/headroom/venv/bin/pip install "headroom-ai[all]"
ln -s ~/.local/share/headroom/venv/bin/headroom ~/.local/bin/headroom
```

Evite usar `--break-system-packages` — ele contorna a proteção instalando direto no Python do sistema, com risco de quebrar pacotes geridos pelo `apt`.

### Problemas comuns de instalação (ambientes corporativos com SSL inspection)

Se o `pip install` falhar por erro de certificado:

```bash
# 1. Instale o Rust manualmente (necessário para compilar dependências nativas)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup default stable

# 2. Aponte para o certificado da sua empresa
export REQUESTS_CA_BUNDLE=/caminho/para/ca-corporativo.crt
# ou, alternativamente:
export SSL_CERT_FILE=/caminho/para/ca-corporativo.crt
```

## 2. Verificar a instalação

```bash
headroom doctor
```

Esse comando faz uma checagem de saúde: confirma se o Python, dependências nativas (ONNX) e configuração estão OK.

## 3. Duas formas de usar: proxy manual ou wrapper automático

Você tem duas estratégias. Recomendo começar pela opção B (wrapper), que é mais simples para uso diário com Claude Code / Codex / Copilot.

### Opção A — Proxy manual (mais controle, serve várias ferramentas ao mesmo tempo)

```bash
headroom proxy --port 8787
```

Isso sobe um proxy HTTP local na porta `8787`. Qualquer ferramenta que permita configurar uma "base URL" customizada para chamadas de API de IA pode ser apontada para esse proxy em vez de ir direto para a Anthropic/OpenAI. É a opção certa se você quer compartilhar uma única instância do Headroom entre múltiplas ferramentas (ex: Cursor + um script próprio).

### Opção B — Wrapper por ferramenta (mais simples, um comando por CLI)

O Headroom oferece comandos prontos que "envolvem" a ferramenta original, aplicando a compressão de forma transparente.

**Claude Code:**

```bash
headroom wrap claude
```

Flags úteis:
- `--memory` — habilita memória entre sessões
- `--code-graph` — usa grafo de dependências do código para compressão mais inteligente
- `--1m` — otimizado para janelas de contexto de 1M tokens
- `--tool-search` — melhora a busca por ferramentas/tools disponíveis

Exemplo combinando flags:

```bash
headroom wrap claude --memory --code-graph
```

Depois de rodar isso, use o Claude Code normalmente (dentro do wrapper) — a compressão acontece nos bastidores.

**Codex (OpenAI):**

```bash
headroom wrap codex
```

**GitHub Copilot CLI (modo subscription, sem precisar de chave de API separada):**

```bash
headroom copilot-auth login
headroom wrap copilot --subscription -- --model gpt-4o
```

> Se sua organização usa GitHub Copilot Enterprise, configure antes:
> ```bash
> export GITHUB_COPILOT_ENTERPRISE_DOMAIN=ghe.example.com
> ```

**Outras ferramentas suportadas** (mesmo padrão `headroom wrap <ferramenta>`):

```bash
headroom wrap aider
headroom wrap opencode
headroom wrap cline
headroom wrap continue
headroom wrap goose
headroom wrap openhands
```

**Cursor** não tem wrapper automático — nesse caso, suba o proxy manualmente (Opção A) e aponte a configuração de "Base URL" do Cursor para o endereço impresso pelo Headroom.

### Desfazendo (voltar ao normal)

```bash
headroom unwrap claude
headroom unwrap codex
headroom unwrap copilot
```

## 4. Medir o ganho real (antes de confiar cegamente)

Depois de usar por um tempo com o wrapper ativo, confira as métricas:

```bash
headroom perf          # métricas de desempenho da compressão
headroom dashboard      # dashboard ao vivo com economia estimada
headroom output-savings # estimativa de economia também nos tokens de saída (resposta do modelo)
```

Dica prática: rode uma tarefa típica sua (ex: pedir para o Claude Code investigar um bug) **sem** o wrapper, anote os tokens consumidos (a maioria das CLIs mostra isso no fim da sessão ou via `/cost` no Claude Code), depois repita uma tarefa parecida **com** `headroom wrap claude` e compare. Isso valida o ganho no seu uso real, não só no benchmark do projeto.

## 5. (Opcional) Reduzir também os tokens de saída

Por padrão, o Headroom foca em comprimir o que é **enviado** ao modelo. Para também aparar os tokens de **resposta**:

```bash
export HEADROOM_OUTPUT_SHAPER=1
```

## 6. (Opcional) Instalar como servidor MCP

Se você quer que o Headroom exponha suas ferramentas de compressão via protocolo MCP (útil se você já usa MCP servers com Claude Code, por exemplo):

```bash
headroom mcp install
```

Isso registra o servidor e disponibiliza as ferramentas `headroom_compress`, `headroom_retrieve` e `headroom_stats` para qualquer cliente MCP.

## 7. Variáveis de ambiente úteis (referência rápida)

| Variável | Para que serve |
|---|---|
| `HEADROOM_OUTPUT_SHAPER=1` | Também comprime tokens de saída (resposta do modelo) |
| `HEADROOM_UPDATE_CHECK=off` | Desliga checagem automática de atualização |
| `GITHUB_COPILOT_ENTERPRISE_DOMAIN=...` | Aponta para domínio do GitHub Copilot Enterprise |
| `HEADROOM_TLS_STRICT=0` | Relaxa validação TLS (redes corporativas com SSL inspection) |
| `HF_HUB_OFFLINE=1` | Usa o modelo Kompress-v2-base já baixado, sem tentar acessar o HuggingFace |
| `ORT_STRATEGY=system` / `ORT_LIB_LOCATION=/caminho` | Usa uma instalação própria do ONNX Runtime |
| `HEADROOM_EMBEDDER_RUNTIME=pytorch_mps` | Usa GPU via Metal em Macs Apple Silicon para o embedder |

## 8. Manter atualizado

```bash
headroom update --check   # só verifica se há versão nova
headroom update           # atualiza para a última versão estável
headroom update --pre     # inclui pre-releases (use com cautela)
```

## Checklist rápido para o seu setup

- [ ] Python 3.10+ instalado (idealmente 3.13)
- [ ] `pip install "headroom-ai[all]"` executado com sucesso
- [ ] `headroom doctor` sem erros
- [ ] Testado `headroom wrap claude` numa tarefa real e comparado tokens antes/depois
- [ ] Testado `headroom wrap codex` (se usar Codex)
- [ ] Testado `headroom copilot-auth login` + `headroom wrap copilot --subscription` (se usar Copilot CLI)
- [ ] Revisado a política de segurança/dados da sua empresa antes de rodar com projetos que tenham dados sensíveis (o proxy vê todo o tráfego enviado ao modelo)

## Se algo der errado

- Rode `headroom doctor` primeiro — cobre a maioria dos problemas de ambiente.
- Consulte o [Quickstart oficial](https://headroom-docs.vercel.app/docs/quickstart) e a [documentação de arquitetura](https://headroom-docs.vercel.app/docs/architecture).
- Comunidade no [Discord do projeto](https://discord.gg/yRmaUNpsPJ).
- Para uso em nível organizacional com suporte, o próprio criador disponibiliza contato: `hello@headroomlabs.ai`.
