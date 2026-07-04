# Resumo — Engenharia de Prompt na prática, com Claude (Anthropic)

**Fonte:** https://x.com/twetsfyp/status/2068004091695919574/video/1 · [transcrição completa](./transcricao.md)
**Palestrantes:** Hannah e Christian (Applied AI, Anthropic)

## O que é a talk

Uma demonstração ao vivo, no console da Anthropic, de como evoluir um *system prompt* de "quase inútil" para "confiável e pronto para produção", usando um caso real de seguros: o Claude analisa (1) um formulário de sinistro de acidente de carro (grade de 17 linhas, 2 colunas/veículos, marcada à mão) e (2) um desenho manual do acidente, para ajudar um avaliador humano a apurar a culpa.

## Progressão da demo

| Versão | O que foi adicionado | Resultado |
|---|---|---|
| **V1** | Prompt mínimo, sem contexto | Claude confunde um nome de rua sueco ("Chapmangatan") e "alucina" um acidente **de esqui** |
| **V2** | Contexto da tarefa + tom ("seja factual e confiável, não invente") | Identifica corretamente que é um acidente de carro, mas reconhece que **falta informação** para determinar a culpa com confiança — comportamento desejado |
| **V3** | Estrutura do formulário explicitada (schema fixo, significado de cada linha, como humanos o marcam na prática) + **ordem obrigatória**: ler o formulário todo antes de olhar o desenho | Ganho grande de confiança e precisão; raciocínio passo a passo visível em tags XML |
| **Final** | Lembretes anti-alucinação, formatação de output (`<veredito>`), prefill de resposta | Veredito confiável, conciso e **extraível programaticamente** (ex.: para salvar em SQL) |

## Os 10 blocos de um bom prompt (ordem recomendada)

1. Contexto da tarefa (quem o Claude é, qual seu papel)
2. Contexto de tom (como se comportar)
3. Dados de fundo / documentos / imagens (conteúdo dinâmico)
4. Instruções detalhadas da tarefa e regras
5. Exemplos (multishot)
6. Histórico de conversa (quando aplicável)
7. Tarefa imediata
8. Pedir para "pensar passo a passo" / mostrar o raciocínio
9. Formatação do output
10. Resposta pré-preenchida (prefill)

## Ideias-chave

- **Engenharia de prompt é ciência empírica**: trate como um loop de teste — rode, veja onde falha, ajuste, adicione o caso como exemplo, repita.
- **Dados estáveis (schema) devem ir no prompt de forma explícita e separada dos dados variáveis** — isso melhora a leitura e viabiliza **cache de prompt**.
- **Tags XML > texto livre** para dar estrutura, porque delimitam exatamente o que está dentro de cada bloco (ex.: `<user_preferences>`).
- **A ordem em que o modelo processa a informação afeta o resultado** — estruture as instruções na mesma sequência em que um humano raciocinaria sobre o problema.
- **Exemplos (multishot) são a ferramenta mais poderosa** para casos difíceis/ambíguos — melhor do que tentar descrever a regra em prosa.
- **Instruir explicitamente contra alucinação**: peça para o modelo fundamentar cada afirmação factual em uma referência concreta do input, e para admitir incerteza em vez de "chutar".
- **Separe raciocínio de output final**: deixe o modelo "mostrar o trabalho" (chain-of-thought), mas extraia só o veredito estruturado para a aplicação consumir.
- **Prefill** (pré-preencher o início da resposta, ex. abrindo uma tag) remove preâmbulo e força um formato serializável.
- **Extended thinking** (Claude 3.7/4, raciocínio híbrido) expõe a transcrição de pensamento do modelo — útil tanto para depurar o prompt quanto para auditar/entender como o modelo pesou as evidências.
