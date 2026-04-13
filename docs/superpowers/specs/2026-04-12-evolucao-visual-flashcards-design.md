# Design: Evolução Visual + Flashcards

**Data:** 2026-04-12
**Status:** Aprovado

---

## Contexto

Site SPA de estudos complementares de Direito (GitHub Pages, HTML/CSS/JS puro, sem framework).
Público-alvo: alunos de graduação revisando matérias **antes de provas** (múltipla escolha + dissertativa).
O site ainda não foi lançado.

---

## Escopo

Duas etapas independentes e sequenciais:

1. **Etapa 1 — Fundação**: Redesign visual (direção Moderno Profissional) + layout mobile-first
2. **Etapa 2 — Flashcards**: Nova aba de flashcards dentro de cada matéria

A Etapa 1 deve ser concluída antes da Etapa 2, pois os flashcards nascerão já no visual correto.

---

## Etapa 1 — Visual e Mobile

### Direção visual: Moderno Profissional

Abandona o estilo clássico-acadêmico (dourado + azul escuro) por um visual contemporâneo que transmite seriedade sem parecer antiquado — adequado para um professor jovem.

**Tokens alterados:**
- `--gold` e `--gold-light` saem como acentos primários
- Novo acento: `--blue-accent: #4C9BE8`
- Tags/badges: pílulas arredondadas (`border-radius: 20px`) em vez de retangulares
- Cards: `border-left: 4px solid var(--blue-accent)` em vez de `border-top: 3px solid var(--gold)`
- Header: `border-bottom: 3px solid var(--blue-accent)` em vez do dourado
- Sombras: mantidas (`--shadow-sm`, `--shadow-md`)
- Tipografia: mantida (Playfair Display + Source Sans 3)
- Paleta base: mantida (`--blue: #1F497D`, `--bg: #f0f4f8`, etc.)

### Layout mobile-first

O CSS passa a ser escrito pensando primeiro em telas pequenas, expandindo para desktop via `@media (min-width: 640px)`.

**Tela inicial (lista de matérias):**
- Mobile: cards em coluna única, cada matéria ocupa 100% da largura, com ícone + título + tags + barra de progresso + seta `›`
- Desktop: grid de 3 colunas (comportamento atual)
- Sem scroll horizontal na tela inicial

**Header:**
- Mobile: título curto ("Estudos Complementares") + avatar/ícone de perfil no canto
- O "Sobre mim" migra para dentro do perfil ou fica acessível via avatar
- Desktop: layout atual mantido

**Tela interna de matéria (abas):**
- Abas em scroll horizontal (`overflow-x: auto`, sem scrollbar visível) — padrão de apps mobile
- Touch targets mínimos de 44px de altura
- Conteúdo das abas (mapas mentais, roteiros) revisado para não extravazar a tela em mobile

---

## Etapa 2 — Flashcards

### Localização

Nova aba "Flashcards" dentro de cada matéria, ao lado das abas existentes (Mapa Mental, Roteiro, Estudo de Caso). Não aparece na tela inicial.

Cada matéria tem sua própria aba independente — alunos de períodos diferentes só veem os cards da matéria que abrirem.

### Dois decks por matéria

**Deck do Professor** (somente leitura):
- Definido em `data.js`, no objeto da matéria, como array `flashcards`:
  ```js
  flashcards: [
    { frente: "Pergunta", verso: "Resposta" },
    ...
  ]
  ```
- Professor edita diretamente o `data.js` para adicionar/remover cards
- Sem painel de admin, sem backend

**Meu Deck** (aluno cria e gerencia):
- Salvo em `localStorage`, chave: `flashcards_<slug-da-materia>` (ex: `flashcards_penal-iv`)
- Estrutura de cada card: `{ id, frente, verso, criadoEm }`
- Aluno pode criar, editar e deletar os próprios cards
- Cards do professor são somente leitura

### Mecânica da sessão de revisão

- Cards exibidos em sequência: Deck do Professor primeiro, depois Meu Deck
- Aluno toca o card para revelar a resposta (frente → verso)
- Marca cada card como "Sabia ✓" ou "Não sabia ✗"
- Progresso da sessão: barra + contador "X de Y"
- Ao terminar: tela de resumo com total de acertos
- Marcações **não persistem** entre sessões — simples e adequado para revisão pré-prova

### O que está fora do escopo (YAGNI)

- Spaced repetition / algoritmo de repetição espaçada
- Embaralhamento configurável
- Sincronização entre dispositivos (localStorage = apenas no dispositivo)
- Estatísticas históricas persistidas
- Painel de admin para professor

---

## Arquitetura técnica

- Nenhum framework ou build tool introduzido — HTML/CSS/JS puro
- `data.js`: adicionar campo `flashcards` nos objetos de matéria
- `app.js`: adicionar renderização da aba Flashcards e lógica de localStorage
- `style.css`: atualizar tokens visuais e adicionar regras mobile-first
- Compatível com GitHub Pages (site estático)

---

## Critérios de sucesso

- [ ] Visual moderno aplicado em todas as telas sem regressões
- [ ] Tela inicial legível no mobile sem scroll horizontal
- [ ] Abas navegáveis por toque no mobile
- [ ] Aluno consegue percorrer todos os cards de um deck e ver o resumo
- [ ] Aluno consegue criar, ver e deletar cards no Meu Deck
- [ ] Cards do professor definidos em `data.js` aparecem corretamente
- [ ] localStorage persiste entre recarregamentos da página
