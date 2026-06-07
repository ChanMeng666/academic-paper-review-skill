// ============================================================================
// TEMPLATE — Structured audit report (internal / triage)
// Severity-tiered findings, tables, optional CeTZ data charts.
// Fill CONFIG + body. Compile: typst compile <thisfile>.typ
// NOTE: imports cetz-charts.typ — keep that file alongside this one (copy the
// whole assets/ folder), or delete the import + chart usage if you want no charts.
// ============================================================================
#import "cetz-charts.typ": grouped-bars, diverging-bars, number-line, log-bars, stacked-bars

// ---- CONFIG (edit me) ------------------------------------------------------
#let report-title  = "Review Report — [Subject]"
#let reviewer-name = "[Reviewer Name]"
#let report-date   = "[DD Month YYYY]"

// ---- palette & fonts -------------------------------------------------------
#let ink      = rgb("#1a2733")
#let accent   = rgb("#2c5f7c")
#let muted    = rgb("#5b6b78")
#let serif    = ("Libertinus Serif", "Georgia", "Times New Roman")
#let sans     = ("Segoe UI", "Arial")
#let mono     = ("Consolas", "Courier New")
#let sevcolor = (major: rgb("#c0392b"), moderate: rgb("#d68910"), minor: rgb("#1e8449"))
#let sevlabel = (major: "MAJOR", moderate: "MODERATE", minor: "MINOR")

// ---- document & page -------------------------------------------------------
#set document(title: report-title, author: reviewer-name)
#set page(paper: "a4", margin: (x: 2.7cm, top: 2.6cm, bottom: 2.4cm), numbering: "1",
  footer: context [
    #set text(size: 8pt, fill: muted)
    #line(length: 100%, stroke: 0.3pt + rgb("#cfd8dc"))
    #v(2pt)
    #grid(columns: (1fr, auto, 1fr),
      align(left)[Review Report],
      align(center)[Reviewer: #reviewer-name],
      align(right)[#counter(page).display("1 / 1", both: true)])
  ])

// ---- type ------------------------------------------------------------------
#set text(font: serif, size: 10.5pt, lang: "en", fill: ink)
#set par(justify: true, leading: 0.9em, spacing: 1.5em)
#show raw: set text(font: mono, size: 8.7pt)
#show link: set text(fill: rgb("#1f6feb"))
#set list(spacing: 1.1em, indent: 0.6em)
#set enum(spacing: 1.1em, indent: 0.6em)
#set heading(numbering: "1.1")
#show heading: set text(font: sans, fill: ink)
#show heading.where(level: 1): it => block(above: 1.8em, below: 1.0em, width: 100%)[
  #set text(size: 15pt, weight: "bold")
  #block(spacing: 0.45em)[#it]
  #line(length: 100%, stroke: 0.7pt + accent.lighten(35%))]
#show heading.where(level: 2): set text(size: 12pt, fill: accent)
#show heading.where(level: 2): set block(above: 1.5em, below: 0.8em)
#set figure(gap: 1.1em)
#show figure.caption: set text(size: 8.8pt, fill: muted)
#set table(stroke: 0.4pt + rgb("#cfd8dc"), inset: (x: 8pt, y: 6.5pt))
#show table.cell.where(y: 0): set text(weight: "bold", size: 9.2pt, font: sans)

// ---- helpers ---------------------------------------------------------------
#let badge(c, t) = box(fill: c, inset: (x: 5pt, y: 2pt), radius: 2.5pt, baseline: 2pt,
  text(fill: white, weight: "bold", size: 7pt, font: sans, tracking: 0.3pt, t))
#let dot(c) = box(baseline: 0.5pt, circle(radius: 3pt, fill: c, stroke: none))
#let finding(level, id, title, body) = block(width: 100%, breakable: true, above: 1.7em, below: 0.4em,
  inset: (left: 14pt, top: 1pt, bottom: 4pt), stroke: (left: 2.5pt + sevcolor.at(level)))[
  #block(spacing: 0.9em)[#badge(sevcolor.at(level), sevlabel.at(level)) #h(0.5em)
    #text(weight: "bold", size: 10.6pt, fill: ink)[#id — #title]]
  #body]
#let loc(t) = text(size: 9pt, fill: muted, style: "italic")[Location: #t]
#let fix(body) = block(spacing: 1.0em, above: 1.0em)[#text(weight: "bold", fill: sevcolor.minor)[Fix.] #body]
#let callout(c, title, body) = block(fill: c.lighten(90%), inset: 11pt, radius: 4pt, width: 100%,
  stroke: (left: 2.5pt + c), above: 1.5em, below: 1.5em)[
  #text(weight: "bold", fill: c.darken(8%))[#title] #h(4pt) #body]

// Data charts come from the cetz-charts.typ library (imported above):
//   grouped-bars · log-bars · diverging-bars · number-line · stacked-bars
// See its header comments for the full argument list of each.

// ============================================================================
// COVER
// ============================================================================
#place(top + left, dx: -2.7cm, dy: -2.6cm, rect(width: 21cm, height: 0.55cm, fill: accent))
#v(3.6cm)
#align(center)[
  #text(size: 10pt, fill: accent, weight: "bold", tracking: 3pt, font: sans)[REVIEW REPORT]
  #v(0.7cm)
  #text(size: 26pt, weight: "bold", font: sans, fill: ink)[#report-title]
  #v(1.2cm)
  #line(length: 28%, stroke: 1pt + accent.lighten(20%))
  #v(1.6cm)
  #text(size: 11pt, fill: muted)[Reviewer: #reviewer-name]
  #v(0.2cm)
  #text(size: 9.5pt, fill: muted)[#report-date]
]
#pagebreak()

// ============================================================================
// BODY — replace below
// ============================================================================
= Executive Summary

[One short paragraph of overall assessment.]

== Findings by severity
#align(center)[#table(columns: (auto, auto, auto, auto),
  table.header([Section], [#dot(sevcolor.major) Major], [#dot(sevcolor.moderate) Moderate], [#dot(sevcolor.minor) Minor]),
  [Editorial], [0], [0], [0],
  [Technical], [0], [0], [0],
  [*Total*], [*0*], [*0*], [*0*])]

// Optional: visualize the same counts (replace the rows with your tallies).
// #figure(stacked-bars(
//   rows: (("Editorial", 1, 2, 1), ("Technical", 2, 1, 0)),
//   segments: ("Major", "Moderate", "Minor"),
//   colors: (sevcolor.major, sevcolor.moderate, sevcolor.minor), xmax: 6,
// ), caption: [Findings by section × severity. _Drawn at compile time with CeTZ._])

= [Paper / Subject] — Editorial Review

#finding("major", "E1", "[Short title of the issue]")[
  #loc[§X / Table Y.] [State the issue and why it matters for a core claim.]
  #fix[[The concrete change.]]
]

#finding("moderate", "E2", "[Title]")[
  #loc[§X.] [Issue + why.]
  #fix[[Fix.]]
]

= [Paper / Subject] — Technical Review

#finding("major", "T1", "[Title]")[
  #loc[§X.] [Domain-grounded critique — strawman baseline, gameable metric, eval bug, etc.]
  #fix[[Fix.]]
]

// Example data chart — replace the data with the paper's numbers (or delete).
#figure(
  grouped-bars(
    data: (("Set A", 0.28, 0.22), ("Set B", 0.69, 0.64), ("Set C", 0.25, 0.25)),
    series: ("Baseline", "Proposed method"), ymax: 0.8, ylabel: "Metric",
    colors: (sevcolor.major, sevcolor.minor),
  ),
  caption: [Example chart — replace with the paper's data. _Drawn at compile time with the CeTZ library._],
)

= Consolidated Action Checklist
- *E1:* [one-line fix]
- *T1:* [one-line fix]

= Verification Log
#table(columns: (2.4fr, auto, 1.5fr),
  table.header([Claim], [Verdict], [Source]),
  [[claim checked]], [#text(fill: sevcolor.minor, weight: "bold")[Confirmed]], [[primary source]])
