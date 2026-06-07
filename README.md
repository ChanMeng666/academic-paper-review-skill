# Academic Paper Review — a Claude Code skill

[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-skill-D97757?logo=anthropic&logoColor=white)](https://docs.claude.com/en/docs/claude-code)
[![Output: Markdown · Typst · PDF](https://img.shields.io/badge/output-Markdown%20%C2%B7%20Typst%20%C2%B7%20PDF-239DAD)](https://typst.app/)
[![Charts: CeTZ + Mermaid](https://img.shields.io/badge/figures-CeTZ%20%2B%20Mermaid-5a7d9a)](#figures-are-first-class)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A reusable [Claude Code](https://docs.claude.com/en/docs/claude-code) skill that turns manuscripts
into a credible **peer review** and ships it as Markdown, a Typst source, and/or a typeset PDF.

It encodes a workflow refined on real reviews: read each paper through **two lenses at once** —
*editorial* (consistency, statistics, citations, writing) and *technical/domain* (methods vs.
established practice; missing baselines, gameable metrics, eval bugs) — **verify** load-bearing
claims against primary sources, **recompute** the paper's statistics, and produce a deliverable in
the right register for the audience.

## What it produces

- **Reviewer letter** — author-facing, narrative prose (~2–3 paragraphs per paper), the way a human
  referee actually writes. No severity badges, boxes, or checklists (that scaffolding is what makes a
  review read as machine-generated).
- **Audit report** — internal/triage, severity-tiered findings, tables, optional data charts.

Either renders to a polished PDF via bundled Typst templates.

<a name="figures-are-first-class"></a>
**Figures are first-class.** A reusable **CeTZ chart library** (`grouped-bars`, `log-bars`,
`diverging-bars`, `number-line`, `stacked-bars`) draws publication-quality vector charts at compile
time, and **Mermaid diagram templates** (with a shared palette + batch render script) cover
structure/architecture figures — so a review can be as evidence-rich as the audience warrants.

## Repository layout

```
academic-paper-review-skill/
├── README.md                         ← you are here
└── skills/
    └── academic-paper-review/
        ├── SKILL.md                  ← the skill (entry point)
        ├── references/
        │   ├── review-dimensions.md  ← both lenses' checklists + RAG/IR domain knowledge
        │   ├── output-formats.md     ← letter vs audit: structure, voice, skeletons
        │   └── typst-rendering.md    ← md→typst→pdf pipeline, chart gallery, gotchas
        ├── scripts/
        │   └── render-mermaid.sh     ← batch-render all .mmd → high-res PNG
        └── assets/
            ├── README.md             ← figure toolkit guide
            ├── review-letter.typ     ← narrative letter template (configurable reviewer block)
            ├── audit-report.typ      ← structured report template (severity tiers)
            ├── cetz-charts.typ       ← reusable CeTZ chart library (5 chart types)
            ├── mermaid/              ← reusable diagram templates (shared palette)
            └── figures/              ← rendered diagram PNGs
```

## Install

Clone the repo, then make the inner skill folder discoverable to Claude Code, which looks for
**personal skills** in `~/.claude/skills/<name>/`. A symlink is preferred so edits stay live.

```bash
git clone https://github.com/ChanMeng666/academic-paper-review-skill.git
cd academic-paper-review-skill
```

**macOS / Linux:**
```bash
ln -s "$(pwd)/skills/academic-paper-review" ~/.claude/skills/academic-paper-review
```

**Windows (PowerShell, run as Administrator for the symlink):**
```powershell
New-Item -ItemType SymbolicLink `
  -Path  "$env:USERPROFILE\.claude\skills\academic-paper-review" `
  -Target "$(Resolve-Path .\skills\academic-paper-review)"

# …or just copy if you'd rather not symlink:
Copy-Item -Recurse ".\skills\academic-paper-review" "$env:USERPROFILE\.claude\skills\academic-paper-review"
```

To scope it to a single project instead, place (or link) the folder under that project's
`.claude/skills/` directory. Restart Claude Code (or start a new session) so it picks up the skill.

### Dependencies
- **[Typst](https://github.com/typst/typst)** CLI — for PDF output (`typst compile`). The bundled
  `typst` skill can install/help if needed.
- **[Mermaid CLI](https://github.com/mermaid-js/mermaid-cli)** (`mmdc`) — *optional*, only for flow
  diagrams in figure-rich variants.
- The Typst templates fetch **CeTZ** (`@preview/cetz`) automatically on first compile (needs network
  once).

## Use it

Just ask Claude Code in natural language — the skill triggers on review/audit/referee requests:

> "Review the three papers in `./papers/` and give me a reviewer letter as a PDF."
>
> "Audit this manuscript before I submit — check the stats and citations, flag any strawman baselines."
>
> "Critique the methodology of `draft.md` from a RAG perspective and write up the findings."

Claude will read the papers (never editing them), apply both lenses, verify the load-bearing claims,
and produce the deliverable you asked for.

### Personalize the reviewer
Open `assets/review-letter.typ` and edit the `CONFIG` block at the top (name, affiliation, the
optional "About the reviewer" note and links). Those values flow into the letterhead, signature, and
footer.

## Why two lenses

An editorial pass alone yields a proofread; a domain opinion alone yields hallway chatter. Authors
trust a review that demonstrably did both — which is why `references/review-dimensions.md` pairs a
general editorial checklist with concrete domain critique (with a deep RAG/IR/dense-retrieval section:
ANN baselines, MMR, relevance vs. diversity metrics, the bge query-prefix bug, and more).

## Contributing

Issues and pull requests are welcome — new chart types for `cetz-charts.typ`, additional Mermaid
templates, sharper domain checklists for fields beyond RAG/IR, or refinements to the review voice.

## License

[MIT](LICENSE) © Chan Meng
