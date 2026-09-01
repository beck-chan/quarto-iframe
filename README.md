# Quarto Iframe Embed Extension

Embeds an iframe with a fenced div with options to include a caption under the iframe, as well as adjust zoom, sizing, and loading configurations.

## Prerequisites

Requires Quarto `>= 1.4.0`.

## Install

```bash
quarto add beck-chan/quarto-iframe
```

## Usage

Add the filter to the YAML frontmatter on a `.qmd` file or your top-level `_quarto.yml`:

```yaml
filters:
  - iframe
```

### Examples

Only `url` is required. `title` becomes the caption under the iframe:

```markdown
::: {.iframe url="https://example.com" title="Example site"}
:::
```

Styled with a custom CSS class:

```markdown
::: {.iframe url="https://example.com" title="Example site" .border}
:::
```

Override defaults when you need a different size, zoom, or alignment:

```markdown
::: {.iframe url="https://example.com" title="Example site" zoom="80%" width="90%" height=720 align="left" valign="top"}
:::
```

## Reference

| Attribute | Default | Notes |
|---|---|---|
| `url` / `src` | Rrequired Input | Iframe source URL |
| `title` | — | Caption under the frame and used as the iframe `title` |
| `zoom` | `100%` | Also accepts `75` or `0.75` |
| `width` | `100%` | Visible viewport width |
| `height` | `560` | Unitless numbers become `px` |
| `align` | `center` | `left`, `center`, or `right` on the page |
| `valign` | `center` | `top`, `center` or `middle` (valign), or `bottom` in a flex/grid parent |
| `loading` | `lazy` | Iframe `loading` attribute |
| `class` | — | Add style classes with `class="..."` or `.custom-class` |
