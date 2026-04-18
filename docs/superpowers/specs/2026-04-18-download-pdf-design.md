# Download PDF — Design Spec

## Objetivo

Permitir que o aluno salve qualquer material de tema como PDF diretamente pelo browser, sem dependências externas.

## Decisões

| Questão | Decisão |
|---|---|
| Formato | PDF via `window.print()` (diálogo nativo do browser) |
| Posição do botão | Rodapé da área de conteúdo, alinhado à direita |
| Estilo do botão | Fundo dourado (`--gold`), ícone ⬇, label "Salvar como PDF" |
| Conteúdo do PDF | Material + cabeçalho de identidade (site, título, turma) |
| Quando aparece | Somente na view de tema (`abrirTema`) — não em turmas, matérias ou sobre |

## Arquitetura

Três peças, todas dentro dos arquivos existentes. Nenhum arquivo de conteúdo (`conteudo/**`) é tocado.

### 1. `app.js` — injeção após carregamento do tema

Dentro do `.then(html => {...})` em `abrirTema`, após o conteúdo ser inserido em `#conteudo-area`, injetar dois elementos:

**Cabeçalho de impressão** (no topo de `#conteudo-area`, antes do conteúdo):
```html
<div id="print-header">
  <div id="print-header-site">Estudos Complementares — Prof. Artur Vieira</div>
  <div id="print-header-titulo">{tema.titulo}</div>
  <div id="print-header-turma">{estado.turmaAtual.titulo}</div>
</div>
```
Populado com `tema.titulo` e `estado.turmaAtual.titulo`. Oculto por padrão (`display: none`), visível só no `@media print`.

**Botão de download** (após todo o conteúdo de `#conteudo-area`):
```html
<div class="btn-download-wrap">
  <button class="btn-download-pdf" onclick="window.print()">
    ⬇ Salvar como PDF
  </button>
</div>
```

Ambos são descartados automaticamente a cada navegação porque `abrirTema` limpa `#conteudo-area` antes de cada fetch.

### 2. `style.css` — estilo do botão

```css
/* Wrapper do botão de download */
.btn-download-wrap {
  border-top: 1px solid var(--border);
  padding-top: 14px;
  margin-top: 24px;
  display: flex;
  justify-content: flex-end;
}

/* Botão */
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

/* Cabeçalho de impressão — oculto na tela */
#print-header { display: none; }
```

### 3. `style.css` — CSS de impressão (`@media print`)

```css
@media print {
  /* Ocultar elementos de navegação e UI */
  header, #btn-topo, .rodape-site,
  #busca-painel, .skip-link, .btn-download-wrap { display: none !important; }

  /* Exibir cabeçalho de identidade */
  #print-header { display: block !important; }

  /* Limpar visual para impressão */
  body { background: white; }
  #conteudo-area {
    box-shadow: none;
    border-radius: 0;
    max-width: 100%;
    padding: 0;
  }
}
```

### 4. `style.css` — estilo do cabeçalho no PDF

```css
@media print {
  #print-header {
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

## Restrições

- Não adicionar bibliotecas externas
- Botão aparece **somente** na view de tema — não em turmas, matérias, sobre ou tela inicial
- O CSS `@media print` não deve afetar a experiência de impressão de outras páginas do site (já existia um bloco print em `style.css` — este é adicionado a ele)
- Respeitar `prefers-reduced-motion`: o botão tem apenas `transition: background .2s` (cor), sem movimento — não precisa de media query adicional

## Arquivos alterados

| Arquivo | Mudança |
|---|---|
| `app.js` | Injetar `#print-header` e `.btn-download-wrap` em `abrirTema` |
| `style.css` | Adicionar estilos de `.btn-download-pdf`, `#print-header` e `@media print` |
