# Output Formats

Two deliverables. The substance (the findings) is the same; the packaging differs by audience. Pick
deliberately — the wrong packaging is what makes a careful review read as machine-generated.

| | Reviewer letter | Audit report |
|---|---|---|
| **Audience** | The authors (or an editor) | Yourself / a triage pass / a co-author |
| **Voice** | Narrative, collegial, first-person | Structured, scannable, impersonal |
| **Structure** | Prose paragraphs | Severity-tiered finding blocks + tables |
| **Severity labels** | None | Major / Moderate / Minor |
| **Figures** | Few or none | Charts/diagrams welcome |
| **Default for** | Anything author-facing | Internal use, large papers, quick scanning |

When unsure for an author-facing review, **write the letter.**

---

## Mode A — Reviewer letter (author-facing, narrative)

This is what a real human referee sends. The goal is that an academic reading it thinks "a thoughtful
colleague reviewed my paper," not "a tool generated a report."

**Structure**
1. A brief, warm opening: thank them, name what you read, state your overall stance in one or two
   sentences. Signal that the comments are constructive.
2. **~2–3 paragraphs per paper.** Lead with the most important issue (usually a technical-lens one),
   then the next, then group the smaller points into a closing paragraph. Reference specific sections,
   tables, and figures by name so the authors can find each point.
3. A short closing: the one or two highest-leverage revisions, an offer to read a revision, a
   collegial sign-off.
4. Signature (name + one-line affiliation). Optionally a brief "About the reviewer" note when the
   review's authority benefits from it — keep it factual, never inflated.

**Voice rules — what keeps it from looking AI-generated**
- Flowing prose. **No** severity badges, **no** boxed findings, **no** "Fix:" labels, **no**
  consolidated checklist, **no** bullet-point dump of issues.
- Weave "location → issue → why → suggestion" into sentences: *"The redundancy score in §4.3 measures
  diversity, not relevance, so a drop doesn't establish better retrieval; I'd pair it with recall@k."*
- Vary sentence structure. Hedge where you're genuinely uncertain ("I suspect", "it may be worth").
  Be direct where you're confident.
- Address the authors directly ("your method", "I'd encourage you to").
- Keep it honest but kind — pre-submission help, not a verdict.

**Skeleton**
```
Dear Authors,

Thank you for the opportunity to read [these manuscripts]. [One-sentence framing of what they are
and your overall, fair-minded stance. A line promising specificity and constructiveness.]

[Paper X — Title]
[Para 1: the central concern — usually technical. State it, explain why it undermines/limits the
claim, point to the section, suggest the fix.]
[Para 2: the next concern + related literature/baseline gap. Same shape.]
[Para 3: the cluster of smaller editorial/consistency points, in prose, plus a note on what checks
out (e.g. "I recomputed Table 1 and the statistics are sound").]

[Repeat per paper. A pure appendix/algorithm doc may need only 1–2 paragraphs.]

[In closing] [The 1–2 revisions that matter most; an offer to re-read; collegial sign-off.]

[Name]
[One-line affiliation]
```

Render with `assets/review-letter.typ`.

---

## Mode B — Audit report (internal, structured)

For triage, large manuscripts, or when scannability matters more than voice.

**Structure**
1. **Executive summary** — per-paper overall assessment + a severity-count table.
2. **Cross-document findings** — shared issues across related papers.
3. **Per paper** — split into *Editorial* and *Technical* subsections, each a sequence of finding
   blocks.
4. **Consolidated action checklist** — every finding as a one-line fix, ordered by severity.
5. **Verification log** — claims checked, verdicts, sources.

**Finding block** — `[SEVERITY] ID — Title`, then *Location*, the issue + why it matters, then a
**Fix.** line. Severity: **major** breaks a core claim; **moderate** weakens rigor; **minor** is
polish/consistency.

Render with `assets/audit-report.typ`.

---

## Choosing the medium

- **Markdown** — fastest; good for an in-repo `REVIEW.md`, or as the drafting layer before Typst.
- **Typst source** — the deliverable when a PDF is wanted; hand it over so the authors can recompile.
- **PDF** — the polished artifact to send. See `typst-rendering.md`.

You can produce several at once (e.g. draft in Markdown, then render the letter to PDF). Keep the
Markdown and the Typst in sync if you ship both.
