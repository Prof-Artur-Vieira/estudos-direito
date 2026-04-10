# Design: Responsividade Mobile — Abordagem C (Híbrida)

**Data:** 2026-04-10  
**Status:** Aprovado pelo usuário  
**Escopo:** Melhorar a experiência mobile sem alterar o desktop

---

## Contexto

O site "Estudos Complementares" é usado por alunos em computador, tablet e celular. Três problemas identificados no mobile:

1. **Home:** árvore horizontal força scroll lateral — matérias fora da tela não são descobertas
2. **Abas internas:** grade 2 colunas com 9+ abas consome metade da tela antes do conteúdo
3. **Cabeçalho duplo:** header do site + header interno do conteúdo carregado via fetch desperdiçam espaço

---

## Decisão de Design

**Abordagem C — Híbrida:** só CSS para a home, só CSS para as abas, mínimo de JS para o header.  
Desktop permanece 100% inalterado.

---

## Parte 1 — Home no mobile (`style.css`)

**Breakpoint:** `@media (max-width: 768px)`

Mudanças:
- `.arvore`: `flex-direction: column; overflow-x: visible`
- `.ramo`: `width: 100%; max-width: 100%; min-width: unset`
- `.ramo + .ramo::before`: `display: none` (remove separador vertical)
- `.no-materia`: mantém visual atual (azul escuro, fonte bold)
- `.turmas-lista`: `padding: 0 0 0 12px` (indentação leve)
- `.no-tema`: `padding-left: 14px` (mantém arrow e espaçamento)

Resultado: cada matéria empilha verticalmente em full-width; temas ficam listados abaixo de cada turma, roláveis normalmente.

---

## Parte 2 — Abas internas no mobile (arquivos de conteúdo)

**Breakpoint:** `@media (max-width: 768px)`  
**Bloco adicionado no `<style>` de cada arquivo:**

```css
@media (max-width: 768px) {
  nav {
    display: flex;
    overflow-x: auto;
    -webkit-overflow-scrolling: touch;
    grid-template-columns: unset;
  }
  nav button {
    white-space: nowrap;
    flex-shrink: 0;
  }
}
```

Resultado: botões ficam em faixa horizontal deslizável (padrão Gmail/YouTube mobile).

**Arquivos a editar (8 no total):**
- `conteudo/processual-penal-ii/03-prisoes.html`
- `conteudo/processual-penal-ii/01-teoria-geral-provas.html`
- `conteudo/processual-penal-ii/02-provas-em-especie.html`
- `conteudo/processual-penal-ii/guia-pratico-prisoes.html`
- `conteudo/penal/penal-iv/01-fe-publica.html`
- `conteudo/penal/penal-iv/02-adm-publica.html`
- `conteudo/penal/penal-iv/index.html`
- `conteudo/tributario/tributario-financeiro-i/01-atividade-avaliativa.html`

---

## Parte 3 — Cabeçalho duplo (`app.js` + arquivos de conteúdo)

### Mudança no `app.js`

Após injetar o HTML do tema em `#conteudo-area`, adicionar classe `embedded` no primeiro elemento filho:

```javascript
const primeiro = area.firstElementChild
if (primeiro) primeiro.classList.add('embedded')
```

### Mudança em cada arquivo de conteúdo

Adicionar ao `<style>`:

```css
body.embedded header,
.embedded ~ * header,
header.embedded-hide {
  display: none;
}
```

Como o fetch injeta o HTML como fragmento (não tem `<body>`), a classe `embedded` vai no elemento raiz do conteúdo (normalmente o `<header>` ou wrapper). A abordagem mais confiável: o `app.js` adiciona `embedded` ao `#conteudo-area` (o container), e o CSS usa:

```css
#conteudo-area.embedded-ctx > header { display: none; }
```

Implementação definitiva (mais simples e confiável):
- `app.js`: após injetar, `area.classList.add('com-conteudo')` 
- `style.css`: `#conteudo-area header { display: none; }` — já é suficiente pois o header interno nunca deve aparecer dentro do SPA

Resultado: aluno vê apenas o breadcrumb do site indicando onde está; o header interno (com badge, título, subtítulo) fica oculto.

---

## Arquivos Modificados

| Arquivo | Tipo de mudança |
|---|---|
| `style.css` | Media query home mobile |
| `app.js` | Ocultar header interno |
| `conteudo/processual-penal-ii/03-prisoes.html` | Media query abas |
| `conteudo/processual-penal-ii/01-teoria-geral-provas.html` | Media query abas |
| `conteudo/processual-penal-ii/02-provas-em-especie.html` | Media query abas |
| `conteudo/processual-penal-ii/guia-pratico-prisoes.html` | Media query abas |
| `conteudo/penal/penal-iv/01-fe-publica.html` | Media query abas |
| `conteudo/penal/penal-iv/02-adm-publica.html` | Media query abas |
| `conteudo/penal/penal-iv/index.html` | Media query abas |
| `conteudo/tributario/tributario-financeiro-i/01-atividade-avaliativa.html` | Media query abas |

---

## O que NÃO muda

- Visual no desktop (todas as mudanças são dentro de `@media (max-width: 768px)` ou impactam apenas o contexto SPA)
- Lógica de navegação do `app.js`
- Estrutura dos dados em `data.js`
- Conteúdo de nenhuma página

---

## Critérios de Sucesso

- No mobile (≤ 768px): home mostra todas as matérias sem scroll lateral
- No mobile: abas de conteúdo deslizam horizontalmente com o polegar
- No mobile e desktop: sem cabeçalho duplicado ao abrir um tema
- No desktop: visual 100% idêntico ao atual
