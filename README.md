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

Only `url` is required. `title` becomes the caption under the iframe. An SVG control in the bottom-left corner opens the source URL in a new window by default:

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

Hide the open-in-new-window control:

```markdown
::: {.iframe url="https://example.com" title="Example site" new-window="false"}
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
| `loading` | `lazy` | Iframe `loading` attribute, switch to `eager` for pre-loading |
| `new-window` | `true` | SVG control in the bottom-left that opens the iframe URL in a new window. Set `false` / `off` / `no` to hide it |
| `class` | — | Add style classes with `class="..."` or `.custom-class` |

## Support

> If you liked this extension and found it useful, please consider donating via Ko-fi: [https://ko-fi.com/beckchan](https://ko-fi.com/beckchan)
