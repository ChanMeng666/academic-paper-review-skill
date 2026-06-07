// ============================================================================
// TEMPLATE — Narrative reviewer letter (author-facing)
// Fill the CONFIG block and the body. Compile: typst compile <thisfile>.typ
// Voice: flowing prose, ~2-3 paragraphs per paper. No badges/boxes/checklists.
// ============================================================================

// ---- CONFIG (edit me) ------------------------------------------------------
#let review-title  = "A review of [N] manuscripts on [TOPIC]"
#let review-date   = "[DD Month YYYY]"
#let reviewer-name = "[Reviewer Name]"
#let reviewer-line = "[Title / affiliation, City, Country]"
// Optional short authority note shown at the foot. Set to `none` to omit.
#let reviewer-bio  = [
  [One short, factual paragraph establishing relevant expertise — role, notable
  work, credentials. Keep it honest; never inflate.]
]
#let reviewer-links = [
  #link("https://example.com/")[example.com] #h(8pt)·#h(8pt)
  #link("mailto:name@example.com")[name\@example.com]
]

// ---- palette & fonts -------------------------------------------------------
#let ink    = rgb("#1a2733")
#let accent = rgb("#2c5f7c")
#let muted  = rgb("#5b6b78")
#let serif  = ("Libertinus Serif", "Georgia", "Times New Roman")
#let sans   = ("Segoe UI", "Arial")
#let mono   = ("Consolas", "Courier New")

// ---- document & page -------------------------------------------------------
#set document(title: review-title, author: reviewer-name)
#set page(
  paper: "a4",
  margin: (x: 3.1cm, top: 2.7cm, bottom: 2.5cm),
  numbering: "1",
  footer: context [
    #set text(size: 8pt, fill: muted)
    #line(length: 100%, stroke: 0.3pt + rgb("#cfd8dc"))
    #v(2pt)
    #grid(columns: (1fr, auto, 1fr),
      align(left)[Peer Review],
      align(center)[Reviewer: #reviewer-name],
      align(right)[#counter(page).display("1 / 1", both: true)],
    )
  ],
)

// ---- type ------------------------------------------------------------------
#set text(font: serif, size: 11pt, lang: "en", fill: ink)
#set par(justify: true, leading: 0.98em, spacing: 1.5em)
#show raw: set text(font: mono, size: 9.2pt)
#show link: set text(fill: rgb("#1f6feb"))

// headings — manuscript names, unnumbered
#show heading: set text(font: sans, fill: ink)
#show heading.where(level: 1): it => block(above: 2.0em, below: 1.0em, width: 100%)[
  #set text(size: 13pt, weight: "bold", fill: accent)
  #block(spacing: 0.5em)[#it]
  #line(length: 100%, stroke: 0.6pt + accent.lighten(45%))
]
#show heading.where(level: 2): set text(size: 11pt, fill: ink)

// ---- letterhead ------------------------------------------------------------
#place(top + left, dx: -3.1cm, dy: -2.7cm, rect(width: 21cm, height: 0.5cm, fill: accent))
#v(0.5cm)
#text(size: 9pt, fill: accent, weight: "bold", tracking: 3pt, font: sans)[PEER REVIEW]
#v(0.25cm)
#text(size: 21pt, weight: "bold", font: sans, fill: ink)[#review-title]
#v(0.35cm)
#line(length: 100%, stroke: 0.6pt + rgb("#cfd8dc"))
#v(0.25cm)
#grid(columns: (1fr, auto),
  align(left)[#text(size: 10pt, fill: muted)[Reviewer: #text(fill: ink, weight: "bold")[#reviewer-name] — #reviewer-line]],
  align(right)[#text(size: 10pt, fill: muted)[#review-date]],
)
#v(1.4em)

// ============================================================================
// BODY — replace everything below with your review
// ============================================================================

Dear Authors,

Thank you for the opportunity to read [what you read]. [One or two sentences of
fair-minded overall framing, signalling that the comments below are specific and
constructive.]

= Paper 1 — [Title]

[Paragraph 1 — the central concern, usually a technical-lens one. State it, explain
why it limits or undermines the claim, point to the exact section/table, and suggest
a concrete fix. Weave "location → issue → why → fix" into prose.]

[Paragraph 2 — the next concern, e.g. a missing baseline or a related-work gap, in
the same shape.]

[Paragraph 3 — the cluster of smaller editorial/consistency points in flowing prose,
plus a note on what checks out, e.g. "I recomputed Table 1 and the statistics are sound."]

= Paper 2 — [Title]

[2–3 paragraphs, same approach. A short appendix/algorithm document may need only 1–2.]

= In closing

[The one or two highest-leverage revisions. An offer to read a revised version. A
collegial sign-off.]

#v(0.4em)
With respect and every good wish for the work,

#v(1.4em)
#text(size: 13pt, weight: "bold", font: sans, fill: ink)[#reviewer-name]
#v(0.1em)
#text(size: 9.5pt, fill: muted)[#reviewer-line]

// ---- optional reviewer-authority note --------------------------------------
#if reviewer-bio != none {
  v(2.2em)
  line(length: 100%, stroke: 0.4pt + rgb("#cfd8dc"))
  v(0.8em)
  block[
    #text(size: 8.5pt, fill: muted, tracking: 2pt, font: sans)[ABOUT THE REVIEWER]
    #v(0.5em)
    #set text(size: 9.3pt, fill: muted)
    #set par(leading: 0.8em, spacing: 1.0em)
    #reviewer-bio
    #v(0.5em)
    #text(size: 9pt)[#reviewer-links]
  ]
}
