# assets/ — figure & template toolkit

Everything needed to add professional figures to a review document. Two complementary engines:

## Typst templates
- `review-letter.typ` — narrative reviewer letter (configurable reviewer block).
- `audit-report.typ` — structured severity-tiered report. **Imports `cetz-charts.typ`**, so copy that
  file alongside it (or copy the whole `assets/` folder).

## CeTZ data charts — `cetz-charts.typ`
A small reusable library of vector charts drawn at compile time (no image step). Import and call:

```typst
#import "cetz-charts.typ": grouped-bars, diverging-bars, number-line, log-bars, stacked-bars
#figure(grouped-bars(
  data: (("BBC", 0.28, 0.22), ("AG News", 0.69, 0.64)),
  series: ("Flat RAG", "Clustered RAG"), ymax: 0.8, ylabel: "Hit Rate",
  colors: (rgb("#c0392b"), rgb("#27ae60")),
), caption: [Hit Rate by dataset. _Drawn at compile time with CeTZ._])
```

| Function | Use it for |
|----------|-----------|
| `grouped-bars` | N categories × M series, linear axis (method vs. baseline per dataset) |
| `log-bars`     | same, logarithmic axis (wide-ratio data like search-space ops) |
| `diverging-bars` | per-item gains/regressions from a zero baseline (sort first for a clean ramp) |
| `number-line`  | compare value bands on one scale (e.g. penalty band vs. score band) |
| `stacked-bars` | horizontal composition (e.g. findings by section × severity) |

Each takes named args with sensible defaults; see the header comments in `cetz-charts.typ`.

## Mermaid diagrams — `mermaid/` → `figures/`
Flow diagrams / architectures / pipelines. Sources carry a shared palette frontmatter so all diagrams
match. Render to PNG (then embed with `#image("figures/<name>.png")`):

```bash
bash ../scripts/render-mermaid.sh assets/mermaid assets/figures   # renders all .mmd
# or one at a time:
mmdc -i assets/mermaid/review-methodology.mmd -o assets/figures/review-methodology.png -b white -s 3
```

| Source (`mermaid/`) | What it shows |
|---------------------|---------------|
| `review-methodology.mmd` | the dual-lens review process (reusable as-is in any review) |
| `method-pipeline.mmd`    | template for summarizing a paper's offline/online method |
| `baseline-comparison.mmd`| strawman vs. expected baseline (adapt labels per domain) |

`figures/` holds rendered PNGs — regenerate them from the `.mmd` sources; don't hand-edit.

> **Tip — which engine?** Mermaid for *structure* (boxes & arrows); CeTZ for *data* (bars & scales).
> Caption CeTZ figures *"drawn at compile time with CeTZ"* and Mermaid ones *"rendered with the
> Mermaid CLI"* so the two kinds are distinguishable. Keep figures out of author-facing letters unless
> they earn their place — see `../references/output-formats.md`.
