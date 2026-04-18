# Download PDF por Tema — Plano de Implementação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adicionar um botão "⬇ Salvar como PDF" no rodapé de cada tema, que aciona `window.print()` com CSS de impressão que oculta a navegação e exibe um cabeçalho de identidade (site + título + turma).

**Architecture:** Duas mudanças independentes: (1) `style.css` recebe estilos do botão, do `#print-header` e extensão do bloco `@media print` existente; (2) `app.js` injeta o `#print-header` e o botão ao final do carregamento de cada tema em `abrirTema`.

**Tech Stack:** HTML/CSS/JS vanilla, GitHub Pages — sem dependências externas.

---

## Arquivos alterados

| Arquivo | Mudança |
|---|---|
| `style.css` | Adicionar `.btn-download-wrap`, `.btn-download-pdf`, `#print-header` e estender o `@media print` existente (linha 1303) |
| `app.js` | Injetar `#print-header` e `.btn-download-wrap` no final do callback `.then()` de `abrirTema`, antes de `executarScripts(area)` |

---

## Task 1 — CSS: estilo do botão e print

**Files:**
- Modify: `style.css` (perto da linha 1303 — bloco `@media print` existente; e antes dele para os estilos normais)

- [ ] **Step 1: Adicionar estilos normais do botão**

Localizar o bloco `@media print` em `style.css` (linha ~1303). Imediatamente **antes** dele, adicionar:

```css
/* ── Botão de download PDF ── */
.btn-download-wrap {
  border-top: 1px solid var(--border);
  padding-top: 14px;
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

.btn-download-pdf {
  background: var(--gold);
  color: white;
  border: none;
  border-radius: 8px;
  padding: 10px 20px;
  font-size: 13px;
  font-weight: 600;
  font-family: var(--sans);
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 7px;
  transition: background .2s;
}

.btn-download-pdf:hover { background: #b8943f; }

/* Cabeçalho de identidade — visível só no PDF */
#print-header { display: none; }
```

- [ ] **Step 2: Estender o bloco `@media print` existente**

O bloco existente (linha ~1303) começa com:
```css
@media print {
  header, #btn-topo, nav#breadcrumb { display: none !important; }
```

Substituir esse bloco inteiro por:
```css
@media print {
  header, #btn-topo, nav#breadcrumb,
  .rodape-site, #busca-painel, .skip-link,
  .btn-download-wrap { display: none !important; }
  body { background: white; }
  body::before { display: none; }
  main { max-width: 100%; padding: 0; }
  #conteudo-area {
    box-shadow: none;
    border-radius: 0;
    padding: 0;
    max-width: 100%;
    border: none;
  }
  .arvore, .cards-turmas, .cards-temas { display: none; }
  a { color: inherit; text-decoration: none; }

  /* Cabeçalho de identidade */
  #print-header {
    display: block !important;
    border-bottom: 2px solid #1F497D;
    padding-bottom: 10px;
    margin-bottom: 20px;
  }
  #print-header-site {
    font-size: 9pt;
    color: #888;
    text-transform: uppercase;
    letter-spacing: .05em;
    margin-bottom: 4px;
  }
  #print-header-titulo {
    font-size: 16pt;
    font-weight: bold;
    color: #1F497D;
    font-family: 'Playfair Display', Georgia, serif;
    margin-bottom: 2px;
  }
  #print-header-turma {
    font-size: 9pt;
    color: #555;
  }
}
```

- [ ] **Step 3: Verificar manualmente**

Abrir o site localmente (ou via GitHub Pages após push). Navegar até qualquer tema. Confirmar:
- O botão dourado "⬇ Salvar como PDF" aparece no rodapé do conteúdo (ainda não — o JS não foi feito)
- Não há erros no console relacionados ao CSS

- [ ] **Step 4: Commit**
```bash
git add style.css
git commit -m "feat(pdf): adiciona estilos do botão de download e CSS de impressão"
```

---

## Task 2 — JS: injetar botão e cabeçalho em `abrirTema`

**Files:**
- Modify: `app.js` (dentro do `.then(html => {...})` de `abrirTema`, antes da linha `executarScripts(area)`)

- [ ] **Step 1: Localizar o ponto de injeção**

Em `app.js`, dentro de `abrirTema`, o callback `.then()` termina assim (linha ~634):
```js
      executarScripts(area)
      rolarParaAncora()
    })
    .catch(() => {
```

A injeção vai **antes** de `executarScripts(area)`.

- [ ] **Step 2: Adicionar a injeção**

Substituir:
```js
      executarScripts(area)
      rolarParaAncora()
```

Por:
```js
      // Cabeçalho de identidade para impressão (oculto na tela)
      const printHeader = document.createElement('div')
      printHeader.id = 'print-header'
      printHeader.innerHTML = `
        <div id="print-header-site">Estudos Complementares — Prof. Artur Vieira</div>
        <div id="print-header-titulo">${esc(tema.titulo)}</div>
        <div id="print-header-turma">${esc(estado.turmaAtual.titulo)}</div>
      `
      area.insertBefore(printHeader, area.firstChild)

      // Botão de download
      const downloadWrap = document.createElement('div')
      downloadWrap.className = 'btn-download-wrap'
      downloadWrap.innerHTML = `
        <button class="btn-download-pdf" onclick="window.print()">
          ⬇ Salvar como PDF
        </button>
      `
      area.appendChild(downloadWrap)

      executarScripts(area)
      rolarParaAncora()
```

- [ ] **Step 3: Verificar manualmente**

Abrir o site. Navegar até qualquer tema e confirmar:
- Botão dourado "⬇ Salvar como PDF" aparece no rodapé
- Ao clicar, o diálogo de impressão abre
- Na prévia de impressão: cabeçalho com site/título/turma aparece no topo, navegação e botão estão ocultos
- Ao voltar para outra tela (ex: tela inicial) e retornar a um tema, o botão aparece corretamente (sem duplicação)
- Em telas que não são tema (turmas, matérias, sobre), o botão **não** aparece

- [ ] **Step 4: Commit**
```bash
git add app.js
git commit -m "feat(pdf): injeta botão de download e cabeçalho de impressão em abrirTema"
```

---

## Self-Review

### Cobertura da spec
- [x] Botão no rodapé da área de conteúdo, alinhado à direita → Task 1 + Task 2
- [x] PDF com cabeçalho de identidade (site + título + turma) → Task 1 Step 2 + Task 2 Step 2
- [x] Botão somente na view de tema → injetado apenas em `abrirTema`
- [x] Ocultar navegação no PDF → Task 1 Step 2 (`@media print`)
- [x] Sem dependências externas → `window.print()` nativo
- [x] `prefers-reduced-motion` não necessário → botão tem só `transition: background` (cor)

### Placeholder scan
Nenhum TBD, TODO ou passo sem código.

### Consistência de nomes
- `#print-header`, `#print-header-site`, `#print-header-titulo`, `#print-header-turma` — consistentes entre Task 1 e Task 2
- `.btn-download-wrap`, `.btn-download-pdf` — consistentes entre Task 1 e Task 2
