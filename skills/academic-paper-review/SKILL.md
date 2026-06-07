---
name: academic-paper-review
description: >-
  Conduct a rigorous, two-lens peer review (editorial + technical-domain) of academic papers and
  produce a polished deliverable as Markdown, a Typst source, and/or a compiled PDF. Use this skill
  whenever the user asks to review, audit, critique, referee, proofread for rigor, or give
  peer-review feedback on a paper, manuscript, preprint, thesis chapter, or technical report — or to
  check a draft before submission, write a reviewer report or reviewer letter, or assess a paper's
  claims, statistics, citations, baselines, figures, or methodology — even if they never say the word
  "review". Especially relevant for ML / AI / RAG / IR / NLP / data-systems papers, where
  domain-specific methodological critique (missing baselines, gameable metrics, evaluation bugs)
  matters as much as editorial polish.
---

# Academic Paper Review

## What this skill does

It turns a pile of manuscripts into a credible peer review. The output is a deliverable you can
actually send: either a **narrative reviewer letter** addressed to the authors, or a **structured
audit report** with severity-tiered findings — rendered as Markdown, a Typst source file, and/or a
typeset PDF.

The whole approach rests on one conviction learned the hard way: **a good review needs two lenses at
once.** An editorial lens alone produces a proofread; a domain lens alone produces a hallway opinion.
Together they produce a review the authors trust. Read `references/review-dimensions.md` for the full
checklist behind both lenses — it is the substance of this skill.

## The two lenses (the core principle)

Apply **both** to every manuscript, and keep them distinct so the authors can see you have done each:

1. **Editorial / academic lens** — internal consistency, claims-versus-evidence, statistics,
   citations and attributions, figure/text agreement, structure, reproducibility, writing.
2. **Technical / domain lens** — the methods judged against established practice *in the paper's own
   field*. Is the baseline a strawman? Is the headline metric gameable or measuring the wrong thing?
   Are standard baselines or ablations missing? Do the numbers hint at an implementation/eval bug
   rather than a real result? This is where a review earns its authority — see the domain knowledge
   in `references/review-dimensions.md` (it includes a deep RAG/IR section).

A finding from either lens follows the same shape: **location → issue → why it matters → concrete
fix.** "Why it matters" is what separates a review from nitpicking; never skip it.

## Workflow

Work through these phases. They are a sensible default, not a straitjacket — adapt to the request.

### 1. Intake & scoping
- Locate the manuscript(s). **Treat source papers as read-only — never edit them.** The review is a
  *new* artifact.
- Note relationships between documents (companion papers, shared datasets/code, a paper + its
  algorithm appendix). Related papers should be cross-checked for parameter/claim parity and
  reviewed as one submission where appropriate.
- Settle the deliverable up front, because it changes how you write (see
  `references/output-formats.md`): **reviewer letter** (author-facing, narrative) vs **audit report**
  (internal/triage, structured); and the medium(s): Markdown, Typst, PDF. If the user hasn't said and
  it isn't obvious, ask once — an author-facing review almost always wants the letter.

### 2. Dual-lens reading
- Read each paper fully and run **both** lenses, using `references/review-dimensions.md` as the
  checklist. Record candidate findings as you go with exact locations (section numbers, table/figure
  names, the offending sentence).

### 3. Verification — don't assert from memory
- Identify the **load-bearing external claims**: cited statistics, attributions ("X reports 55%"),
  named prior methods, dataset provenance. Verify these against primary sources with web search.
  Citing the wrong reference for a real number is one of the most common — and most credibility-
  damaging — defects, so this pass pays for itself.
- **Recompute the paper's own statistics** where the data is in the manuscript (means, t-tests,
  percentages). Use a quick Python script. Confirm internal consistency; flag what doesn't reconcile.
- Keep a short verification log (what you checked, the verdict, the source) — it is evidence the
  review is grounded, and belongs in the audit report (and as a private appendix for a letter).

### 4. Synthesis
- Turn candidates into findings (location → issue → why → fix). Merge duplicates; drop anything you
  could not stand behind.
- For an **audit report**, assign severity (major = breaks a core claim; moderate = weakens rigor;
  minor = polish) and tally them.
- For a **letter**, do *not* tier or label — weave the points into argument, leading with the ones
  that matter most.

### 5. Output & rendering
- Write the deliverable in the chosen mode following `references/output-formats.md`.
- To produce a PDF, render via Typst — see `references/typst-rendering.md`. Two ready templates live
  in `assets/` (`review-letter.typ`, `audit-report.typ`); copy one into the working directory, fill
  it, and compile. For PDF setup/troubleshooting, also lean on the separate **`typst` skill**.
- Add figures with the bundled toolkit (see "Figures & charts" next) — don't hand-roll chart code.

### Figures & charts

Figures make a review more persuasive and authoritative — *when they earn their place*. Use the two
bundled engines instead of writing diagram/chart code from scratch; both are already styled to match
the templates. **Rule of thumb: Mermaid for structure (boxes & arrows), CeTZ for data (bars & scales).**

- **CeTZ data charts — `assets/cetz-charts.typ`.** A reusable library of vector charts drawn at
  compile time (no image step). Import it and call a function with your data:
  ```typst
  #import "cetz-charts.typ": grouped-bars, diverging-bars, number-line, log-bars, stacked-bars
  #figure(grouped-bars(data: (("BBC", 0.28, 0.22),), series: ("Flat", "Clustered"),
                        ymax: 0.8, ylabel: "Hit Rate"), caption: [... _Drawn with CeTZ._])
  ```
  `grouped-bars` (method vs. baseline), `log-bars` (wide-ratio data), `diverging-bars` (per-item
  gains/regressions), `number-line` (compare value bands), `stacked-bars` (composition, e.g. findings
  by severity). The `audit-report.typ` template already imports and uses it. Full arg lists are in the
  library header and `assets/README.md`.
- **Mermaid diagrams — `assets/mermaid/` → `assets/figures/`.** Flow diagrams, architectures,
  pipelines. Three reusable templates ship with a shared palette: `review-methodology.mmd` (the
  dual-lens process, usable as-is), `method-pipeline.mmd` (summarize a paper's method),
  `baseline-comparison.mmd` (expose a strawman baseline). Render with the bundled script, then embed:
  ```bash
  bash scripts/render-mermaid.sh assets/mermaid assets/figures   # all .mmd → high-res PNG
  ```
  ```typst
  #figure(image("assets/figures/review-methodology.png", width: 70%), caption: [...])
  ```
- **Audience matters.** Default to **few or no figures in an author-facing letter** (prose is the
  point); figures belong in audit reports and figure-rich variants. Keep `.mmd` sources and rendered
  images under `assets/`, never loose in the repo root. See `references/typst-rendering.md` for the
  gallery, captions convention, and gotchas.

## Critical practices (learned from real reviews)

- **Never edit the source papers.** Output is always a separate file.
- **Verify, don't trust your memory** for any external number, citation, or method attribution.
- **Recompute reported statistics** instead of taking them on faith.
- **Avoid the AI-generated feel — match the artifact to the audience.** A review meant to be *sent to
  authors* should read like a human referee wrote it: flowing prose, ~2–3 paragraphs per paper,
  direct address, specific section references, *no* severity badges, no boxed "findings", no "Fix:"
  labels, no consolidated checklist, and few or no figures. That scaffolding is exactly what makes a
  review look machine-generated. Reserve the heavily-structured, chart-rich format for *internal*
  audit/triage, where scannability beats voice. When in doubt for an author-facing review, default to
  the narrative letter. See `references/output-formats.md`.
- **Be constructive and concrete.** Pre-submission tone: point to what to strengthen and why, with an
  achievable fix. Even hard findings ("this baseline is a strawman") should land as help, not a verdict.
- **Calibrate scope to the ask.** "Quick sanity check" ≠ "full referee report". Don't manufacture a
  20-finding audit when the user wanted a paragraph of honest reactions.

## Reference files

- `references/review-dimensions.md` — the editorial + technical checklists, including the RAG/IR/ML
  domain knowledge (baselines, metrics, common eval bugs). **Read this for every review.**
- `references/output-formats.md` — how to write each deliverable (letter vs audit), with skeletons,
  voice guidance, and the "don't look AI-generated" rules.
- `references/typst-rendering.md` — the Markdown→Typst→PDF pipeline, the bundled templates, Typst
  gotchas, and figure/asset conventions.

## Bundled templates & toolkit

- `assets/review-letter.typ` — parameterized narrative reviewer letter (elegant letterhead,
  signature, optional reviewer-credentials block).
- `assets/audit-report.typ` — structured severity-tiered report (badges, finding blocks, tables);
  imports the chart library for data figures.
- `assets/cetz-charts.typ` — reusable CeTZ chart library (`grouped-bars`, `log-bars`,
  `diverging-bars`, `number-line`, `stacked-bars`). Keep it beside `audit-report.typ`.
- `assets/mermaid/*.mmd` — reusable diagram templates (shared palette); `assets/figures/` holds their
  rendered PNGs.
- `scripts/render-mermaid.sh` — batch-render all `.mmd` to high-res PNG with the standard settings.
