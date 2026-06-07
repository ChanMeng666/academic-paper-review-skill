# Rendering to PDF with Typst

The pipeline is **draft → Typst source → PDF**. Typst is a modern typesetting system (think LaTeX,
but faster and with a saner language). For installation and general Typst help, use the separate
**`typst` skill**; this file covers only what's specific to review documents.

## Quick start

1. Copy the template you want into the working directory:
   - `assets/review-letter.typ` → for a narrative letter
   - `assets/audit-report.typ` → for a structured audit
2. Fill in the content (the templates have clearly-marked placeholder sections and a reviewer block).
3. Compile:
   ```bash
   typst compile REVIEW.typ            # → REVIEW.pdf
   ```
4. Verify visually — render pages to PNG and look at them (don't trust "it compiled"):
   ```bash
   typst compile REVIEW.typ --format png --ppi 110 preview/page-{p}.png
   ```

If `typst` isn't installed, the `typst` skill explains setup; on this machine the CLI is already on
PATH.

## Typst gotchas that bite in review documents

These were all hit while building real review PDFs — internalize them to avoid the same loops:

- **`@` triggers a reference.** Writing `recall@k` makes Typst look for a label `<k>` and fail.
  Escape it: `recall\@k`. Same for any literal `@` in prose (emails, handles).
- **`#let` must precede use.** Define every helper/chart *above* the first place it's used. A chart
  referenced in the body must be `#let`-defined earlier in the file.
- **CeTZ needs `#set page`, not `#page`.** A bare `#page(...)` call expects a body; for page setup use
  `#set page(...)`. (Charts use the CeTZ library — see below.)
- **Boxes splitting across pages.** A block you want kept whole (a credentials box) needs
  `breakable: false`; add a `#pagebreak()` before it if it lands awkwardly.
- **Math vs. code.** Use `$...$` for math (`$alpha = 0.55$`, `$p < 0.05$`) and raw backticks for code
  identifiers (`` `nprobe` ``, `` `IndexFlatIP` ``). Underscores inside raw spans are literal; inside
  math they subscript.

## Figures — two engines, both bundled

Default to **few or no figures in an author-facing letter** (prose is the point). Figures belong in
audit reports and figure-rich variants. **Mermaid for structure (boxes & arrows); CeTZ for data
(bars & scales).** Don't hand-roll figure code — use the bundled toolkit. Caption CeTZ figures as
*"drawn at compile time with CeTZ"* and Mermaid ones as *"rendered with the Mermaid CLI"* so the two
kinds are distinguishable.

### CeTZ data charts — `assets/cetz-charts.typ`

Typst has **no native chart primitive**; this library hand-draws vector charts with CeTZ at compile
time (no external image step). Import once, then call a function with your data:

```typst
#import "cetz-charts.typ": grouped-bars, diverging-bars, number-line, log-bars, stacked-bars
```

| Function | Best for | Key args |
|----------|----------|----------|
| `grouped-bars` | N categories × M series, linear axis (method vs. baseline per dataset) | `data`, `series`, `ymax`, `ylabel`, `colors` |
| `log-bars`     | same but logarithmic axis (wide-ratio data, e.g. ops/query) | `data`, `series`, `lo`, `hi`, `ticks`, `ylabel` |
| `diverging-bars` | per-item gains/regressions from zero (sort the values first) | `values`, `annotations`, `pos`/`neg`/`zero` |
| `number-line`  | compare value bands on one scale (penalty band vs. score band) | `ranges`, `markers`, `xmin`/`xmax`, `tick` |
| `stacked-bars` | composition, e.g. findings by section × severity | `rows`, `segments`, `colors`, `xmax` |

```typst
// grouped bars: method vs. baseline
#figure(grouped-bars(
  data: (("BBC", 0.28, 0.22), ("AG News", 0.69, 0.64)),
  series: ("Flat RAG", "Clustered RAG"), ymax: 0.8, ylabel: "Hit Rate",
  colors: (rgb("#c0392b"), rgb("#27ae60")),
), caption: [Hit Rate by dataset. _Drawn at compile time with CeTZ._])

// number line: a penalty band sitting above the typical score band
#figure(number-line(
  ranges: ((0.3, 0.6, "typical score", rgb("#5a7d9a")), (0.825, 1.5, "penalty", rgb("#c0392b"))),
  markers: ((0.55, "α = 0.55", rgb("#555")),), xmax: 1.5,
), caption: [Why the penalty acts as a hard switch. _Drawn at compile time with CeTZ._])
```

Defaults are sensible; pass `ymax`/`xmax` for clean axes. Each function's full signature is documented
in the library header and `assets/README.md`. `audit-report.typ` already imports and uses it — keep
`cetz-charts.typ` beside any template that imports it.

### Mermaid diagrams — `assets/mermaid/` → `assets/figures/`

Author `.mmd` source, render to PNG, embed. Three reusable templates ship with a **shared palette
frontmatter** (paste it atop new diagrams so everything matches): `review-methodology.mmd` (the
dual-lens process — usable as-is), `method-pipeline.mmd` (summarize a paper's offline/online method),
`baseline-comparison.mmd` (expose a strawman baseline).

```bash
bash scripts/render-mermaid.sh assets/mermaid assets/figures   # render all .mmd, 3× scale, white bg
# one at a time:
mmdc -i assets/mermaid/review-methodology.mmd -o assets/figures/review-methodology.png -b white -s 3
```
```typst
#figure(image("assets/figures/review-methodology.png", width: 70%), caption: [...])
```
Avoid `xychart-beta` for grouped bars — it overlays series rather than placing them side by side; use
CeTZ `grouped-bars` for that.

## Asset conventions

Keep generated artifacts tidy — never loose in the repo root:
```
assets/
├── mermaid/   # .mmd sources (edit these)
└── figures/   # rendered .png (embedded by the .typ)
```
Add a one-line note in the review repo's README mapping each figure to its source and the regenerate
command, so the figures stay reproducible.

## Scratch hygiene

Render PNG previews and other throwaway artifacts to a scratch directory, not next to the deliverable;
clean them up when done. The final PDF, its `.typ` source, and any embedded `assets/` are the only
things that should remain.
