# Estudo: Headroom — compressão de contexto para IA

> Pasta de estudo pessoal, fora do padrão C4/ADR/SDD do repositório (ver `AGENTS.md`), criada para reunir anotações sobre uma ferramenta de terceiros.

## Fonte

- Artigo original: [Engenheiro da Netflix cria e libera app open source para reduzir custos de IA](https://desbugados.com.br/post/2026/06/01/engenheiro-da-netflix-cria-e-libera-app-open-source-para-reduzir-custos-de-ia) (Desbugados, 01/06/2026)
- Repositório oficial: [github.com/chopratejas/headroom](https://github.com/chopratejas/headroom)
- Documentação oficial: [headroom-docs.vercel.app](https://headroom-docs.vercel.app/docs)
- Modelo de compressão (HuggingFace): [chopratejas/kompress-v2-base](https://huggingface.co/chopratejas/kompress-v2-base)
- Fontes complementares usadas na pesquisa: [Let's Data Science](https://letsdatascience.com/news/netflix-engineer-open-sources-headroom-to-cut-ai-token-costs-8f10c68d), [AI Weekly](https://aiweekly.co/alerts/netflix-headroom-proxy-cuts-llm-api-bills-by-90), [Open Source For You](https://www.opensourceforu.com/2026/06/netflix-engineer-open-sources-ai-cost-cutting-tool/)

## O que é, em uma frase

**Headroom** é um proxy open source, criado por Tejas Chopra (engenheiro sênior da Netflix), que fica entre você e o modelo de IA (Claude, GPT, etc.) e "comprime" o texto enviado — removendo redundância — antes de contar como tokens cobrados, economizando de 60% a 95% do custo sem mudar a qualidade das respostas.

## Explicação para leigos

Imagine que você paga um serviço de tradução simultânea que cobra **por palavra falada**. Se você narrar um relatório inteiro, palavra por palavra, incluindo repetições, cabeçalhos redundantes e trechos de código formatados de um jeito verboso, você paga por tudo isso — mesmo que o tradutor (o modelo de IA) só precise entender a *essência* do que está ali.

É basicamente isso que acontece hoje quando ferramentas de IA (como assistentes de código) trabalham: elas mandam para o modelo coisas como:

- Saídas de comandos de terminal (logs longos, cheios de linhas repetidas)
- Arquivos JSON inteiros, com chaves e formatação que o modelo não precisa ver por extenso
- Código-fonte completo, quando só uma parte é relevante
- Documentos grandes recuperados por busca (RAG), com muito texto de enchimento

Tudo isso vira "tokens" — a unidade que os provedores de IA (Anthropic, OpenAI, etc.) cobram. Quanto mais texto redundante você manda, mais caro fica, sem ganhar nada em qualidade de resposta.

**O que o Headroom faz:** ele se posiciona no meio do caminho, como um "compressor de mala antes do voo". Antes de o conteúdo sair da sua máquina em direção ao modelo, ele:

1. **Identifica o tipo de conteúdo** (é um JSON? um log? código Python?) e escolhe a estratégia certa de compressão para aquele tipo.
2. **Remove a redundância** — coisas repetidas, formatação desnecessária, partes do código que não mudam o significado — mantendo o que importa.
3. **Garante que, se for preciso, os dados originais possam ser recuperados** (chamam isso de compressão "reversível"): nada se perde de verdade, só se resume o que é enviado ao modelo.
4. **Devolve tokens/dinheiro para o seu bolso**: o mesmo resultado, pagando bem menos.

O ganho relatado no artigo é dramático: uma conta pessoal de US$ 287 foi o estopim para a criação da ferramenta, e a comunidade já economizou coletivamente mais de US$ 700 mil e 200 bilhões de tokens desde janeiro de 2026, com o projeto passando de 2 mil estrelas no GitHub (outras fontes já registram até ~39 mil).

## Como funciona por baixo do capô (visão técnica resumida)

| Peça | Função |
|---|---|
| **ContentRouter** | Olha o conteúdo recebido e decide qual "compressor" especializado usar (JSON, código, texto genérico) |
| **SmartCrusher** | Compressor genérico para JSON |
| **CodeCompressor** | Compressão baseada em AST (árvore sintática) para Python, JS/TS, Go, Rust, Java, C/C++, Perl — entende a estrutura do código para cortar o supérfluo sem quebrar a lógica |
| **Kompress-v2-base** | Modelo de machine learning (hospedado no HuggingFace) treinado com traces reais de agentes de IA, usado para compressão mais "inteligente" de texto livre |
| **CacheAligner** | Mantém os prefixos das mensagens estáveis para aproveitar o cache de contexto (KV cache) que provedores como Anthropic e OpenAI já oferecem — outra fonte de economia |
| **CCR (Compressão Reversível)** | Guarda os dados originais (em Redis ou SQLite) para que possam ser recuperados sob demanda via chamadas MCP, caso o modelo precise do texto completo depois |

**Modos de uso disponíveis:**
- **Biblioteca** (Python ou TypeScript) — você chama uma função `compress()` no seu próprio código.
- **Proxy HTTP** — roda como um serviço local (porta padrão `8787`) e qualquer ferramenta que aponte para ele já ganha compressão, sem mudar código.
- **MCP server** — se integra via protocolo MCP (o mesmo usado por Claude Code, Cursor, etc.) oferecendo ferramentas como `headroom_compress`, `headroom_retrieve`, `headroom_stats`.
- **Wrappers prontos** — comandos que "envolvem" ferramentas de IA já existentes (Claude Code, GitHub Copilot CLI, Codex, Aider, Cursor, Cline, Continue, Goose, OpenCode, OpenHands) para que passem a usar o Headroom automaticamente.

## Por que isso importa para quem usa Claude Code / Codex / Copilot no dia a dia

Se você já usa assistentes de IA para programar, boa parte do custo em tokens não vem do que você digita, e sim do que a ferramenta manda "nos bastidores": saída de comandos, arquivos lidos, resultados de buscas no código, etc. O Headroom ataca exatamente essa parte invisível do custo, sem exigir trocar de modelo ou mudar de fluxo de trabalho.

Ver também: [`tutorial-configuracao.md`](./tutorial-configuracao.md) para o passo a passo de instalação e uso com Claude Code, Codex e GitHub Copilot.

## Pontos de atenção / limitações a validar

- O artigo original em português **não cita a URL do repositório** nem detalhes técnicos completos — os dados de arquitetura e comandos aqui vieram do próprio README do projeto no GitHub, que deve ser tratado como fonte primária.
- Números de adoção (estrelas, economia em US$, tokens) variam entre fontes secundárias (2 mil vs. ~39 mil estrelas) — provavelmente reflexo de datas de captura diferentes; confira o número atual direto no repositório antes de citar externamente.
- É um projeto relativamente novo (lançado em janeiro de 2026) — vale checar issues abertas e o changelog antes de usar em produção ou com dados sensíveis, já que ele intercepta e armazena (mesmo que temporariamente, via Redis/SQLite) conteúdo que passaria pelo seu assistente de IA.
- Por ser um **proxy que vê todo o tráfego para o modelo**, avalie a política de segurança/privacidade da sua organização antes de rodá-lo com dados corporativos.
