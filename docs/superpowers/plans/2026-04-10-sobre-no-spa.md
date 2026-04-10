# Sobre mim — SPA Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the "Sobre mim" button load `sobre.html` inside the SPA without a full page reload.

**Architecture:** Two small changes — `index.html` gets an `onclick` handler instead of a bare `href`, and `app.js` gains an `abrirSobre()` function plus a `popstate` branch. The content is fetched and injected directly into `#app` (not `#conteudo-area`) so the profile header inside `sobre.html` is never hidden by the `#conteudo-area > header { display: none }` rule.

**Tech Stack:** Vanilla JavaScript, History API (`pushState` / `popstate`), `fetch()`, static HTML files.

---

## File Map

| File | Change |
|---|---|
| `index.html` | Line 13: swap `href="sobre.html"` for `onclick="abrirSobre()"` |
| `app.js` | Add `abrirSobre()` function; add `view === 'sobre'` branch in `popstate` handler |

---

### Task 1: Update the "Sobre mim" button in `index.html`

**Files:**
- Modify: `index.html:13`

**Context:** The current line 13 is:
```html
<a href="sobre.html" class="btn-sobre">Sobre mim</a>
```
It must become an in-SPA navigation trigger.

- [ ] **Step 1: Open `index.html` and replace line 13**

Replace:
```html
<a href="sobre.html" class="btn-sobre">Sobre mim</a>
```
With:
```html
<a href="#" class="btn-sobre" onclick="abrirSobre(); return false;">Sobre mim</a>
```

- [ ] **Step 2: Verify the file looks correct**

`index.html` lines 10-16 should now read:
```html
  <header>
    <div class="header-top">
      <div class="site-titulo">Estudos Complementares</div>
      <a href="#" class="btn-sobre" onclick="abrirSobre(); return false;">Sobre mim</a>
    </div>
    <nav id="breadcrumb"></nav>
  </header>
```

- [ ] **Step 3: Commit**

```bash
cd C:/Users/artur/Documents/estudos-direito
git add index.html
git commit -m "feat: wire btn-sobre to abrirSobre() instead of hard link"
```

---

### Task 2: Add `abrirSobre()` to `app.js` and update `popstate`

**Files:**
- Modify: `app.js:13-28` (popstate handler)
- Modify: `app.js:218` (insert new function after `abrirTema`)

**Context:**
- The `popstate` handler is at lines 13-28 of `app.js`. It currently has four branches (`materias`, `materia`, `turma`, `tema`). A fifth branch for `sobre` must be added.
- `abrirSobre()` fetches `sobre.html`, injects it into `app` (the `<main id="app">` element), intercepts the "← Voltar" link inside it, and pushes a history entry.
- `executarScripts()` already exists at line 149 — call it after injection.
- `atualizarBreadcrumb('Sobre mim')` with both state fields null produces: `Início › Sobre mim`.

- [ ] **Step 1: Add `abrirSobre()` function at the end of `app.js`**

Append the following block after the closing brace of `atualizarBreadcrumb` (currently the last function, ending at line 251):

```javascript
// ── Sobre mim ────────────────────────────────────────────

function abrirSobre(fromPop = false) {
  estado.materiaAtual = null
  estado.turmaAtual   = null
  atualizarBreadcrumb('Sobre mim')
  if (!fromPop) history.pushState({ view: 'sobre' }, '')

  app.innerHTML = '<p style="color:#888;font-size:13px;padding:2rem">Carregando...</p>'

  fetch('sobre.html')
    .then(r => { if (!r.ok) throw new Error(); return r.text() })
    .then(html => {
      app.innerHTML = html
      // intercepta o link "Voltar" para não sair do SPA
      app.querySelectorAll('a[href="index.html"]').forEach(a => {
        a.href = '#'
        a.onclick = (e) => { e.preventDefault(); renderArvore() }
      })
      executarScripts(app)
    })
    .catch(() => {
      app.innerHTML = '<p style="color:#c00;padding:2rem">Não foi possível carregar a página.</p>'
    })
}
```

- [ ] **Step 2: Add `view === 'sobre'` branch in the `popstate` handler**

The `popstate` handler currently reads (lines 13-28):
```javascript
window.addEventListener('popstate', (e) => {
  const s = e.state
  if (!s || s.view === 'materias') {
    renderArvore(true)
  } else if (s.view === 'materia') {
    selecionarMateria(s.materiaId, true)
  } else if (s.view === 'turma') {
    selecionarTurma(s.materiaId, s.turmaId, true)
  } else if (s.view === 'tema') {
    const materia = materias.find(m => m.id === s.materiaId)
    const turma   = materia.turmas.find(t => t.id === s.turmaId)
    estado.materiaAtual = materia
    estado.turmaAtual   = turma
    abrirTema(s.temaIndex, true)
  }
})
```

Insert the `sobre` branch after the `materias` branch (after line 16):
```javascript
window.addEventListener('popstate', (e) => {
  const s = e.state
  if (!s || s.view === 'materias') {
    renderArvore(true)
  } else if (s.view === 'sobre') {
    abrirSobre(true)
  } else if (s.view === 'materia') {
    selecionarMateria(s.materiaId, true)
  } else if (s.view === 'turma') {
    selecionarTurma(s.materiaId, s.turmaId, true)
  } else if (s.view === 'tema') {
    const materia = materias.find(m => m.id === s.materiaId)
    const turma   = materia.turmas.find(t => t.id === s.turmaId)
    estado.materiaAtual = materia
    estado.turmaAtual   = turma
    abrirTema(s.temaIndex, true)
  }
})
```

- [ ] **Step 3: Verify `app.js` manually**

Open `app.js` and confirm:
- `abrirSobre` is defined at the bottom of the file
- The `popstate` handler contains `else if (s.view === 'sobre') { abrirSobre(true) }` immediately after the `materias` branch

- [ ] **Step 4: Commit**

```bash
cd C:/Users/artur/Documents/estudos-direito
git add app.js
git commit -m "feat: add abrirSobre() and popstate support for sobre view"
```

---

### Task 3: Manual verification and push

**Files:** (none modified — verification only)

This site has no automated test suite. Manual browser verification is the test.

- [ ] **Step 1: Open the site locally**

Open `index.html` directly in a browser (double-click file, or use a local server).

> **Note:** `fetch()` requires a server origin to work — file:// URLs will produce CORS errors. Use VS Code Live Server, Python's `python -m http.server 8080` in the project folder, or any static server. Navigate to `http://localhost:8080`.

- [ ] **Step 2: Verify success criteria**

Check each item:

| # | Action | Expected result |
|---|---|---|
| 1 | Click "Sobre mim" button | Content loads inside the app — no full page reload |
| 2 | Check breadcrumb | Shows: `Início › Sobre mim` |
| 3 | Click "Início" in breadcrumb | Returns to the subject tree |
| 4 | Click "Sobre mim" again, then click "← Voltar para Estudos Complementares" inside the page | Returns to the subject tree without reload |
| 5 | Click "Sobre mim", then press browser Back button | Returns to previous view |
| 6 | Click "Sobre mim", then press browser Back, then Forward | Returns to "Sobre mim" without reload |
| 7 | Scroll to professor photo | Photo renders normally (it is base64 — no path issues) |

- [ ] **Step 3: Push to GitHub Pages**

```bash
cd C:/Users/artur/Documents/estudos-direito
git push
```

Expected: push succeeds, site updates at GitHub Pages within ~60 seconds.
