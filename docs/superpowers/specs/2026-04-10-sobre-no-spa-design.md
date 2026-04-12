# Design: Integrar "Sobre mim" ao SPA

**Data:** 2026-04-10  
**Status:** Aprovado pelo usuário  
**Escopo:** Fazer a página "Sobre mim" carregar dentro do SPA em vez de navegar para fora

---

## Contexto

O botão "Sobre mim" no header do site aponta para `sobre.html` via `<a href>` comum, causando recarregamento completo da página e perda do estado de navegação do SPA. Todos os outros conteúdos (temas, turmas) carregam dentro do app via `fetch()`. Este spec corrige essa inconsistência.

Observações técnicas sobre `sobre.html`:
- A foto do professor está embutida como data URI (base64) — sem paths externos a corrigir
- Contém um link `<a href="index.html">← Voltar para Estudos Complementares</a>` que precisa ser interceptado
- Tem `<header>` próprio que **não deve** ser ocultado (diferente das páginas de conteúdo de aula)

---

## Decisão de Design

Injetar `sobre.html` diretamente em `#app` (não dentro de `#conteudo-area`), para que a regra `#conteudo-area > header { display: none }` não afete o header de perfil da página.

---

## Mudanças

### 1. `index.html`

Trocar o link atual:
```html
<a href="sobre.html" class="btn-sobre">Sobre mim</a>
```

Por:
```html
<a href="#" class="btn-sobre" onclick="abrirSobre(); return false;">Sobre mim</a>
```

### 2. `app.js`

**Adicionar função `abrirSobre()`:**

```javascript
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

**Atualizar o handler `popstate`** para tratar `view === 'sobre'`:

```javascript
window.addEventListener('popstate', (e) => {
  const s = e.state
  if (!s || s.view === 'materias') {
    renderArvore(true)
  } else if (s.view === 'sobre') {          // ← adicionar este bloco
    abrirSobre(true)
  } else if (s.view === 'materia') {
    // ... restante inalterado
  }
})
```

**Corrigir `atualizarBreadcrumb()`** — atualmente a função usa `estado.materiaAtual` e `estado.turmaAtual` para construir o breadcrumb, e o parâmetro `tituloTema` para o item final. Para "Sobre mim", passamos `'Sobre mim'` como `tituloTema` com ambos os estados nulos, o que resulta em: `Início › Sobre mim`. Isso já funciona sem alteração na função.

---

## Arquivos Modificados

| Arquivo | Mudança |
|---|---|
| `index.html` | `href="sobre.html"` → `onclick="abrirSobre()"` |
| `app.js` | Adiciona `abrirSobre()` + trata `view === 'sobre'` no `popstate` |

---

## O que NÃO muda

- Visual da página "Sobre mim" (idêntico ao atual)
- Header do site (botão "Sobre mim" visualmente inalterado)
- Comportamento de todas as outras páginas
- `sobre.html` em si (nenhuma alteração no arquivo)

---

## Critérios de Sucesso

- Clicar "Sobre mim" carrega o conteúdo dentro do app sem recarregar a página
- Breadcrumb mostra: `Início › Sobre mim`
- Clicar "Início" no breadcrumb volta à árvore de matérias
- Clicar "← Voltar para Estudos Complementares" dentro da página também volta à árvore
- Botão voltar do navegador funciona corretamente (History API)
- A foto do professor aparece normalmente
