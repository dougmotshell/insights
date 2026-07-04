# Sugestões de aplicação no dia a dia de desenvolvimento de software

**Fonte:** [resumo](./resumo.md) · [transcrição completa](./transcricao.md)

Ideias práticas para levar da talk para o trabalho com Claude/LLMs no dia a dia — tanto ao **construir features com IA** quanto ao **usar o próprio Claude Code** como ferramenta de desenvolvimento.

## 1. Trate prompts de produção como código, não como texto solto

Adote a estrutura de 10 blocos (contexto → tom → dados → instruções → exemplos → histórico → tarefa → raciocínio → formato → prefill) como um **template reutilizável** para qualquer *system prompt* novo, em vez de escrever prosa livre a cada vez. Isso facilita revisão em PR e detecta rapidamente "o que está faltando" quando um prompt não performa bem.

## 2. Separe o que é fixo do que é variável — e cacheie o que é fixo

Se você tem um *schema* estável (formato de um documento, estrutura de uma API, convenções de um formulário interno) que se repete em toda chamada, coloque-o explicitamente no *system prompt*, separado dos dados que mudam a cada request. Além de melhorar a interpretação do modelo, isso é exatamente o gatilho para usar **prompt caching**, reduzindo custo e latência em chamadas repetidas com o mesmo contexto de fundo.

## 3. Prefira tags XML a texto livre para estruturar prompts complexos

Em prompts com múltiplas seções (contexto, exemplos, dados, instruções), delimite cada bloco com tags XML nomeadas (`<contexto_da_tarefa>`, `<exemplos>`, `<dados_de_entrada>`). Isso reduz ambiguidade tanto para o modelo quanto para quem revisa o prompt depois — e facilita fazer parsing programático da resposta.

## 4. Ordene as instruções na mesma sequência do raciocínio humano

Ao pedir para o modelo analisar múltiplas fontes de informação (ex.: um log + um stack trace, um contrato de API + um payload de exemplo, um requisito + um diagrama), **force explicitamente a ordem**: "primeiro leia X e liste o que encontrar, só depois analise Y usando essa base". A demo mostra que isso muda o resultado de forma mensurável — não é só estética.

## 5. Trate exemplos difíceis como uma base de conhecimento viva

Sempre que um prompt (seu ou de uma feature em produção) errar em um caso real, **não corrija só aquele caso na mão** — adicione-o como exemplo (multishot) no prompt/sistema, junto com o raciocínio esperado. Isso vale tanto para prompts de produto quanto para instruções que você mesmo escreve para o Claude Code (ex.: `CLAUDE.md`/`AGENTS.md`): se o agente repetir um erro, documente o caso certo ali.

## 6. Escreva guarda-corpos explícitos contra alucinação

Em qualquer feature que use LLM para extrair fatos ou tomar decisões sobre dados de entrada (não geração criativa), inclua instruções explícitas: "só afirme algo se conseguir apontar de onde no input isso vem" e "diga que não sabe em vez de chutar". Isso é especialmente relevante em pipelines de dados/observabilidade — onde uma alucinação silenciosa é mais perigosa do que uma resposta "não tenho certeza".

## 7. Separe raciocínio (debug) de output (contrato da aplicação)

Ao integrar um LLM em um pipeline (ex.: gravar um veredito em banco de dados, disparar um evento, alimentar um dashboard), peça o raciocínio completo em uma tag e o resultado final estruturado em outra (`<veredito>`, `<resultado_json>`), e faça sua aplicação consumir **só a segunda**. Isso dá observabilidade sem acoplar sua lógica de negócio ao "texto solto" do modelo.

## 8. Use prefill para forçar formato de saída sem preâmbulo

Quando precisar de uma resposta estritamente estruturada (JSON, XML, um enum), pré-preencha o início da resposta do modelo com a abertura do formato esperado. É mais barato e mais confiável do que só instruir "responda em JSON" e depois tentar limpar texto extra na integração.

## 9. Use extended thinking como ferramenta de debug de prompt, não só de qualidade de resposta

Quando um prompt (seu ou do Claude Code) produzir um resultado inesperado, ative/inspecione o *thinking* do modelo para entender **onde** o raciocínio divergiu do esperado, antes de reescrever o prompt inteiro por tentativa e erro. É o mesmo princípio de olhar um stack trace antes de reescrever a função.

## 10. Aplique o mesmo princípio às instruções que você escreve para agentes de código

O padrão "contexto → dados → regras → exemplos → formato" desta talk é diretamente transferível para `AGENTS.md`/`CLAUDE.md` e para specs de feature (SDD): descreva o papel/contexto do projeto, dê a estrutura estável do repositório, liste regras explícitas (como as de documentação C4/ADR/SDD já definidas neste repo), e — quando um agente errar repetidamente algo — registre o caso certo como exemplo, em vez de reescrever a regra em prosa cada vez mais longa.
