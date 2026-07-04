# Transcrição (pt-BR) — Engenharia de Prompt na prática, com Claude (Anthropic)

**Fonte:** https://x.com/twetsfyp/status/2068004091695919574/video/1
**Duração:** ~24,7 minutos
**Palestrantes:** Hannah e Christian, time de Applied AI da Anthropic
**Contexto do evento:** aparenta ser um evento/conferência da Anthropic (há menções a uma "sessão de prompting para agentes" em seguida e a uma demo de "Claude jogando Pokémon" depois desta talk — condizente com o evento *Code with Claude*).

> **Nota sobre a fonte:** a X (Twitter) não expõe uma transcrição oficial em áudio; o que foi extraído foi a legenda automática em **espanhol** gerada pela plataforma (via `yt-dlp`), que por sua vez é uma transcrição/tradução automática da fala original (em inglês). O texto abaixo foi limpo, reorganizado em parágrafos por assunto e **traduzido para pt-BR**, corrigindo erros evidentes de reconhecimento de fala (ex.: "Clau/Cloud/Claudio/Clauide" → **Claude**; "Consuela Antropica" → **console da Anthropic**; "insurrección/insurrecional" → **seguro/seguradora**; "ingeniería promptiva/promptual" → **engenharia de prompt**). Onde a fala original alternava entre os dois palestrantes de forma clara, isso foi marcado; nos demais trechos a atribuição exata de fala não é confiável a partir da legenda automática, então o texto segue como narrativa contínua.

---

## Introdução

**Hannah:** Meu nome é Hannah, sou parte do time de AI Aplicada aqui na Anthropic, e comigo está o Christian, também do time de AI Aplicada. O que vamos fazer hoje é passar por algumas boas práticas usando um cenário do mundo real para construir um prompt juntos.

Um pouco sobre o que é engenharia de prompt: provavelmente todo mundo já está se familiarizando com isso. É o modo como nos comunicamos com os modelos de linguagem, tentando fazer com que eles façam tudo o que queremos — a prática de escrever instruções claras para o modelo, dando a ele o contexto necessário para completar as tarefas, e pensando em como estruturar essa informação para obter os melhores resultados.

Há muito detalhe aqui, muitas formas diferentes de pensar sobre a construção de um prompt, e como sempre, a melhor forma de aprender isso é simplesmente praticando. Hoje vamos passar por um cenário manual, usando um exemplo inspirado em um cliente real com quem trabalhamos — modificamos o que o cliente nos pediu, mas o caso é bem interessante: analisar imagens, obter informação factual sobre elas e deixar o Claude tomar uma decisão sobre o que encontra ali.

**Christian:** Vou passar o cenário e o conteúdo. Imagine que você trabalha em uma companhia de seguros e lida com sinistros diariamente. Você tem duas peças de informação: de um lado, um formulário de relato do acidente — simples e direto, o que aconteceu antes do acidente; do outro, um desenho feito por um humano mostrando qual foi a situação. Essas são as duas peças que vamos passar para o Claude.

## V1 — o prompt mais simples possível (e por que ele falha)

Para começar, podemos pegar essas duas peças e colocá-las no console, para ver o que acontece de forma real. Aqui vemos o console da Anthropic — estamos usando o novo Claude 4 / Claude Sonnet 4, com temperatura zero e um número alto de tokens máximos, para garantir que não há limitação no que o Claude pode fazer.

O prompt nesta primeira versão é muito simples: só menciona que a tarefa é revisar um formulário de relato de acidente e determinar o que aconteceu e de quem foi a culpa. Ao executar isso, o Claude entende que o acidente aconteceu em uma rua chamada "Chapmangatan" — um nome de rua comum na Suécia — e, sem mais contexto, interpreta erroneamente que se trata de um **acidente de esqui**. É um erro inocente e compreensível: como primeiro palpite, não é tão mau, mas ainda exige muita intuição humana para preencher as lacunas.

Isso ilustra bem que a engenharia de prompt é, em boa parte, uma ciência empírica: podemos quase tratar isso como um caso de teste, em que o Claude precisa entender que está lidando com um veículo/carro, nada relacionado a esqui — e então, iterativamente, construir o prompt para garantir que ele realmente entenda o problema que está tentando resolver.

## A estrutura recomendada de um bom prompt

Antes de continuar o exemplo, vale falar sobre a estrutura que recomendamos para um prompt "grande" (system prompt bem construído). Ao interagir com um chatbot como o Claude, a interação costuma ser conversacional, indo e voltando; mas quando estamos construindo algo via API, o ideal é conseguir enviar **uma única mensagem** e fazer com que o modelo acerte de primeira, sem precisar voltar atrás.

A estrutura recomendada, em ordem, é:

1. **Contexto da tarefa** — diga ao Claude quem ele é, qual é seu papel, qual tarefa está tentando realizar hoje.
2. **Contexto de tom** — como ele deve se comportar (por exemplo, ser factual e confiável).
3. **Dados de fundo / documentos / imagens** — o conteúdo dinâmico (no nosso caso, as imagens do formulário e do desenho).
4. **Instruções detalhadas da tarefa e regras** — uma lista passo a passo de como o Claude deve realizar a tarefa.
5. **Exemplos** — mostrando, para um determinado tipo de conteúdo, como a resposta deveria ser.
6. **Histórico de conversa**, quando aplicável.
7. **Tarefa imediata** — o pedido específico deste turno.
8. **Pensar passo a passo / deixar o Claude "mostrar o trabalho"** antes de responder.
9. **Formatação do output**.
10. **Resposta pré-preenchida (prefill)**, quando útil.

No final, vale reforçar o que é mais crítico para aquela tarefa e então dizer ao Claude: "ok, agora faça seu trabalho".

## V2 — contexto da tarefa e tom

Nas versões seguintes do prompt, os dois primeiros blocos (contexto da tarefa e tom) entram em cena. Na primeira demonstração praticamente não havia elaboração sobre qual era o cenário em que o Claude estava trabalhando — e, por causa disso, o Claude também não tinha motivo para pensar mais profundamente sobre o que realmente queríamos.

Com mais instruções claras sobre o cenário (é um formulário de sinistro de seguro de automóvel) e sobre as tarefas pedidas, o entendimento melhora. Também é importante adicionar um pouco de **tom**: queremos que o Claude seja **factual e confiável**. Se ele não conseguir entender o que está vendo, queremos que ele **não invente** — nosso objetivo é conseguir aconselhamento tão claro e confiável quanto possível; caso contrário, perdemos o propósito de todo o processo.

Ao executar a V2 no console: o formulário tem 17 linhas diferentes descrevendo o que ocorreu, com um veículo A e um veículo B, colunas à esquerda e à direita. O objetivo é garantir que o Claude entenda esses dados gerados manualmente. Ao explicitar que esse sistema de IA deve ajudar um **avaliador de sinistros humano** a revisar formulários de acidentes reportados, e que o desenho é uma obra humana que talvez não deva ser avaliada se não houver confiança suficiente, o resultado muda bastante: agora o Claude entende corretamente que se trata de um **acidente de carro**, identifica que o veículo A estava marcado na caixa 1 e o veículo B na caixa 12 — mas ainda reconhece que **falta informação** para fazer uma determinação totalmente confiante sobre quem cometeu o erro. Isso é bom: o que não queremos é que o Claude faça afirmações que não são factuais, e que ele só afirme algo quando estiver de fato confiante.

## Dados de fundo: a estrutura do formulário e o cache de prompt

Existe muita informação "fora" do formulário sobre como ele deve ser lido — e essa informação também deve entrar no sistema. Um exemplo bom: o **formato do formulário nunca muda** (títulos, colunas, linhas), apenas os **valores preenchidos** mudam de caso para caso. Essa é uma informação muito valiosa para dar ao Claude no *system prompt*, porque:

- ela sempre será igual entre diferentes casos, então o Claude não precisa "redescobrir" a estrutura do formulário a cada chamada — ele já sabe o que esperar e pode se concentrar em interpretar os valores;
- é um ótimo candidato para **cache de prompt**, já que esse bloco de contexto é sempre o mesmo.

## Uso de delimitadores (tags XML e Markdown)

Ao Claude "adora estrutura" — ele aprecia organização, então recomendamos usar algum tipo de estrutura nos prompts. Markdown é bastante útil, mas **tags XML** são especialmente boas porque permitem especificar exatamente o que está contido dentro delas (por exemplo, `<user_preferences>` deixa claro que tudo o que está dentro daquela tag se refere às preferências do usuário). Tudo isso, com muitos exemplos, está documentado publicamente na documentação da Anthropic.

## V3 — metadados do formulário e a ordem das instruções

Na V3, mantém-se tudo igual em relação ao contexto e ao tom, mas adiciona-se uma descrição detalhada do formulário dentro do *system prompt*: é um formulário de acidente de carro, em espanhol, com um determinado título, com duas colunas representando veículos diferentes, e uma explicação do significado de cada uma das 17 linhas. Sem isso, o Claude precisava "ler" e inferir o significado de cada linha individualmente a cada execução; com isso explicitado, essa informação já vem pronta.

Também vale explicar como o formulário costuma ser **preenchido na prática por humanos**: as marcações não serão perfeitas — pode haver círculos, texto escrito à mão, X's fora da caixa, e vários tipos diferentes de marcação que é preciso saber reconhecer. Dar ao Claude contexto sobre como interpretar essas marcações e qual é o propósito/significado do formulário ajuda bastante na análise.

Um ponto muito importante descoberto durante a construção desta demo (e também no trabalho real com o cliente): **a ordem em que o Claude analisa a informação importa muito**. Isso é análogo a como um humano pensaria sobre o problema — provavelmente você não olharia primeiro para o desenho (um monte de caixas e linhas, sem significado óbvio sem contexto); você leria primeiro o formulário, entenderia que se trata de um acidente e quais veículos estavam envolvidos em quais pontos, e só então usaria essa base para interpretar o desenho.

Por isso, as instruções passam a dizer explicitamente: "primeiro veja o formulário, olhe com cuidado, certifique-se de identificar quais caixas estão marcadas, não perca nada, faça uma lista para você mesmo — e só então siga para o desenho". Assim, ao chegar no desenho, o Claude já tem uma base factual do formulário e pode usar essa compreensão para interpretar o desenho, chegando a um veredito final mais fundamentado.

Ao executar essa versão, aparece um comportamento interessante: como foi pedido para examinar cuidadosamente cada caixinha individualmente, o Claude relata, caixa por caixa, se ela está marcada ou não — o que é mais detalhado do que talvez seja necessário no output final (isso seria algo a ajustar depois). Mas o resultado também traz, dentro de tags XML, um bom resumo do formulário e a conclusão de que o veículo B está claramente com a culpa. Este é um exemplo simples; com desenhos mais complicados e formulários menos claros, esse tipo de raciocínio passo a passo, na ordem certa, tem impacto ainda maior na capacidade do Claude de fazer a avaliação correta.

## Exemplos (multishot)

**Christian:** Uma coisa que realmente valorizamos são os **exemplos**. Um exemplo, ou "poucos exemplos" (few-shot/multishot), é um mecanismo muito poderoso para direcionar o Claude, especialmente em cenários não triviais — como acidentes concretos difíceis para o Claude, mas em que a intuição humana e os dados de treinamento humano conseguem chegar à conclusão correta. Você pode "baixar" esse conhecimento para o sistema por meio de exemplos claros do que deveria ser observado.

Você pode ter exemplos visuais (usando *base64* para codificar uma imagem, por exemplo) como parte do prompt, e, junto com cada exemplo, uma descrição da estratégia/raciocínio esperado. Isso é algo que ensinamos e enfatizamos bastante: uma forma de empurrar os limites da sua aplicação com LLM é justamente baixando esses exemplos no *system prompt*. De novo, é a ciência empírica da engenharia de prompt: você quer constantemente testar os limites da sua aplicação, capturar o feedback loop de onde está errando, e adicionar esses casos como exemplos no *system prompt* — assim, na próxima vez que um caso parecido aparecer, o Claude consegue se referir ao seu conjunto de exemplos.

No exemplo mostrado no console, usa-se novamente a mesma estrutura em XML (que o Claude responde muito bem), mas essa parte não foi de fato executada na demo, por ser um exemplo simples. Em um cenário real — digamos, para uma companhia de seguros — você poderia ter centenas de exemplos difíceis, "na zona cinzenta", justamente para garantir que o Claude tenha uma base real para tomar a decisão da próxima vez.

## Histórico de conversa

Outro ponto que vale destacar: **não** estamos usando histórico de conversa nesta demo, no mesmo sentido dos exemplos. Isso porque, no nosso caso, não é uma aplicação voltada para o usuário final em tempo real — é algo rodando "no fundo" (um sistema automatizado que gera dados, com um humano revisando no final). Se você estivesse construindo algo mais voltado ao usuário, com um histórico de conversa relevante, esse seria o lugar certo no *system prompt* para incluí-lo, pois isso desenvolve o contexto com o qual o Claude trabalha.

## Tarefa imediata e prevenção de alucinação

O próximo passo é desenvolver a parte final da tarefa imediata e dar ao Claude um lembrete sobre qualquer orientação importante a seguir. Algumas razões para isso: prevenir **alucinações** — não queremos que o Claude invente detalhes que não encontra no prompt ou nos dados. Se o Claude não conseguir determinar com certeza o que está marcado em um formulário, não queremos que ele "dê seu melhor palpite" ou invente o conteúdo de uma caixa e faça um trabalho ruim interpretando o desenho, mesmo que um humano também não conseguisse entendê-lo — queremos que o Claude seja capaz de dizer isso abertamente.

Então, nesse bloco final de lembretes, incluímos coisas como: responder apenas quando estiver muito confiante; pedir para o Claude referenciar o que viu no formulário sempre que fizer uma afirmação factual (por exemplo: "sei disso com base no fato de que a caixa 2 está claramente marcada"). Ou seja, damos ao Claude algumas regras sobre como fundamentar suas afirmações.

Voltando ao console, essa versão mantém tudo igual em termos de contexto (nada muda na forma como preenchemos o ambiente para o Claude); a única adição é essa lista detalhada de tarefas, dizendo como queremos que o Claude analise a informação — reforçando a ordem já explicada (primeiro o formulário, depois o desenho).

## Formatação do output e prefill de resposta

**Christian:** Um passo-chave adicional no final é dar orientações simples sobre a parte final da resposta. Uma peça importante é o **formato do output**: imagine que você é o engenheiro responsável por essa aplicação — todo esse "preâmbulo" de raciocínio é útil para você entender o processo, mas, no final, você quer salvar apenas a peça de informação relevante (por exemplo, em um banco de dados SQL), e não precisa necessariamente de todo o raciocínio intermediário na sua aplicação.

No console, ao voltar a essa versão, fica claro que se adicionou apenas essa parte de orientação final, reforçando o comportamento "mecânico" desejado do Claude: garantir que o resumo é claro, conciso e adequado, e que nada além da análise interfere na avaliação. No fim, quando se trata do formato, pede-se ao Claude para completar seu **veredito final** dentro de uma tag específica (por exemplo, `<veredito>`), e tudo o mais pode ser ignorado pela aplicação — usado apenas se quiser construir algum tipo de "trilha analítica" depois, ou simplesmente extraído para obter a determinação final.

Ao executar, o processo é o mesmo de antes, mas agora muito mais sucinto, porque foi pedido explicitamente para resumir os achados de forma direta — e, no final, o resultado aparece dentro das tags de veredito.

É possível notar, ao longo da demonstração, uma evolução: de um "acidente de esqui" (V1) para um output inseguro e pouco confiante (V2), até um output bem formatado e confiante (versões seguintes) — pronto para ser usado por uma aplicação real, ajudando de fato a seguradora no mundo real.

Outra forma-chave de moldar o output do Claude é **colocar palavras na boca dele** — o que chamamos de **resposta pré-preenchida (prefill)**. Fazer parsing de tags XML já funciona bem, mas você também pode querer garantir uma estrutura de output "serializável", pronta para ser usada em uma chamada subsequente. É bem simples: você pode fazer o Claude "abrir" uma tag específica no início da resposta (por exemplo, a tag de veredito em XML) — uma ótima forma de remodelar como o Claude deve responder, sem todo o preâmbulo, caso você não o queira. Isso também é importante para garantir que o Claude está de fato raciocinando pelos passos desejados antes de chegar ao formato final.

## Extended thinking / raciocínio estendido

Por fim, um ponto que vale revisar: o **Claude 3.7**, e especialmente a geração **4**, tem um modelo de raciocínio **híbrido** — ou seja, existe um "pensamento" disponível, exposto em tags específicas de pensamento (*thinking*). O interessante é que você pode analisar essa transcrição de pensamento para entender como o Claude está de fato "conversando" com aqueles dados — por exemplo, ele vai passando, passo a passo, pelo cenário do acidente, exatamente como orientado.

Tentar ajudar o Claude a construir esse raciocínio sobre si mesmo não é apenas mais eficiente: é também uma boa forma de entender como esses modelos, que não têm nossa intuição humana, de fato lidam com os dados que oferecemos a eles. Por isso, isso é bastante importante quando você está tentando descobrir onde o seu *system prompt* pode ser melhorado.

## Encerramento

Com isso, agradecemos a todos por terem vindo hoje. Estaremos por aqui o resto do dia — se tiverem alguma pergunta sobre prompting, fiquem à vontade para nos procurar. Em uma hora tem uma sessão sobre prompting para **agentes**, e logo depois teremos uma demo incrível: **Claude jogando Pokémon** — então não vão a lugar nenhum. Infelizmente não sobrou tempo para Q&A ao vivo nesta sessão, mas estaremos por aqui o dia todo para conversar. Muito obrigado.
