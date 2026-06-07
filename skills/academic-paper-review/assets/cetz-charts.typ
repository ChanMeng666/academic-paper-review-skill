// ============================================================================
// cetz-charts.typ — a small reusable CeTZ chart library for review documents
// ----------------------------------------------------------------------------
// Typst has NO native chart primitive; these functions hand-draw vector charts
// with the CeTZ library at compile time (no external image step). Each returns
// `canvas(...)` content you drop straight into a #figure(...).
//
// Usage:
//   #import "cetz-charts.typ": grouped-bars, diverging-bars, number-line, log-bars, stacked-bars
//   #figure(grouped-bars(data: (("BBC",0.28,0.22),("AG",0.69,0.64)),
//                         series: ("Flat","Clustered"), ymax: 0.8, ylabel: "Hit Rate"),
//           caption: [Hit Rate by dataset. _Drawn at compile time with CeTZ._])
//
// Requires (declare once in your document): #import "@preview/cetz:0.3.4": canvas, draw
// (this file imports it too, so importing this file is enough.)
// ============================================================================
#import "@preview/cetz:0.3.4": canvas, draw

// default categorical palette (accent, green, red, amber, purple, teal)
#let palette = (
  rgb("#2c5f7c"), rgb("#27ae60"), rgb("#c0392b"),
  rgb("#d68910"), rgb("#8e44ad"), rgb("#16a085"),
)

#let _grid = rgb("#dddddd")
#let _axis = rgb("#444444")

// ----------------------------------------------------------------------------
// grouped-bars — N categories × M series, linear y-axis.
//   data:   ((label, v1, v2, ...), ...)   one entry per category
//   series: (name1, name2, ...)           legend names (length = M)
//   ymax:   number or auto                top of axis (auto = 1.1×max)
//   ylabel: axis title  ·  colors: per-series fills  ·  steps: y gridline count
// ----------------------------------------------------------------------------
#let grouped-bars(
  data: (), series: (), ymax: auto, ylabel: "",
  colors: palette, width: 11.5, height: 4.6, steps: 4, legend: true, digits: 2,
) = canvas(length: 1cm, {
  import draw: *
  let allv = data.map(r => r.slice(1)).flatten()
  let ym = if ymax == auto { calc.max(..allv) * 1.1 } else { ymax }
  let n = data.len()
  let k = series.len()
  let groupw = width / n
  let usable = groupw * 0.7
  let barw = usable / k
  let pad = (groupw - usable) / 2
  let yv(v) = v / ym * height
  for i in range(0, steps + 1) {
    let v = ym * i / steps
    let y = yv(v)
    line((0, y), (width, y), stroke: 0.3pt + _grid)
    content((-0.15, y), anchor: "east", text(size: 8pt)[#calc.round(v, digits: digits)])
  }
  line((0, 0), (0, height), stroke: 0.6pt + _axis)
  line((0, 0), (width, 0), stroke: 0.6pt + _axis)
  if ylabel != "" {
    content((-1.2, height / 2), angle: 90deg, anchor: "south", text(size: 9pt)[#ylabel])
  }
  for (idx, row) in data.enumerate() {
    let gx = idx * groupw + pad
    for (si, v) in row.slice(1).enumerate() {
      let x = gx + si * barw
      rect((x, 0), (x + barw, yv(v)), fill: colors.at(si), stroke: none)
    }
    content((idx * groupw + groupw / 2, -0.18), anchor: "north", text(size: 8pt)[#row.at(0)])
  }
  if legend {
    for (si, name) in series.enumerate() {
      let lx = si * 2.6
      let ly = height + 0.35
      rect((lx, ly), (lx + 0.3, ly + 0.3), fill: colors.at(si), stroke: none)
      content((lx + 0.4, ly + 0.15), anchor: "west", text(size: 8pt)[#name])
    }
  }
})

// ----------------------------------------------------------------------------
// log-bars — like grouped-bars but logarithmic y-axis (for wide-ratio data,
// e.g. search-space operations). Honest about the visual compression.
//   ticks: explicit decade ticks (values); lo/hi: axis bounds.
// ----------------------------------------------------------------------------
#let log-bars(
  data: (), series: (), lo: 10, hi: 10000, ylabel: "",
  colors: palette, width: 11.5, height: 4.6,
  ticks: (10, 100, 1000, 10000), legend: true,
) = canvas(length: 1cm, {
  import draw: *
  let l10(v) = calc.log(v, base: 10)
  let yv(v) = (l10(v) - l10(lo)) / (l10(hi) - l10(lo)) * height
  let n = data.len()
  let k = series.len()
  let groupw = width / n
  let usable = groupw * 0.7
  let barw = usable / k
  let pad = (groupw - usable) / 2
  for tv in ticks {
    let y = yv(tv)
    line((0, y), (width, y), stroke: 0.3pt + _grid)
    content((-0.15, y), anchor: "east", text(size: 8pt)[#tv])
  }
  line((0, 0), (0, height), stroke: 0.6pt + _axis)
  line((0, 0), (width, 0), stroke: 0.6pt + _axis)
  if ylabel != "" {
    content((-1.45, height / 2), angle: 90deg, anchor: "south", text(size: 9pt)[#ylabel])
  }
  for (idx, row) in data.enumerate() {
    let gx = idx * groupw + pad
    for (si, v) in row.slice(1).enumerate() {
      let x = gx + si * barw
      rect((x, 0), (x + barw, yv(v)), fill: colors.at(si), stroke: none)
    }
    content((idx * groupw + groupw / 2, -0.18), anchor: "north", text(size: 8pt)[#row.at(0)])
  }
  if legend {
    for (si, name) in series.enumerate() {
      let lx = si * 2.6
      let ly = height + 0.35
      rect((lx, ly), (lx + 0.3, ly + 0.3), fill: colors.at(si), stroke: none)
      content((lx + 0.4, ly + 0.15), anchor: "west", text(size: 8pt)[#name])
    }
  }
})

// ----------------------------------------------------------------------------
// diverging-bars — horizontal bars from a zero baseline (e.g. per-query
// improvement: positive = better, negative = regression). Pass values already
// sorted if you want a clean ramp.
//   values: (num, ...)   ·   pos/neg/zero: fills
//   annotations: ((index, side, "text", color), ...)  side = "west"|"east"
// ----------------------------------------------------------------------------
#let diverging-bars(
  values: (), xmin: auto, xmax: auto,
  pos: rgb("#27ae60"), neg: rgb("#c0392b"), zero: rgb("#c4ccd2"),
  width: 10.0, annotations: (), digits: 2,
) = canvas(length: 1cm, {
  import draw: *
  let mx = if xmax == auto { calc.max(..values, 0) } else { xmax }
  let mn = if xmin == auto { calc.min(..values, 0) } else { xmin }
  let span = mx - mn
  let pad = span * 0.04
  let lo = mn - pad
  let hi = mx + pad
  let xv(v) = (v - lo) / (hi - lo) * width
  let barh = 0.2
  let gap = 0.08
  let n = values.len()
  let ph = n * (barh + gap)
  let yc(i) = ph - (i + 1) * (barh + gap) + gap / 2
  // gridlines at min, 0, max
  for t in (mn, 0, mx) {
    let x = xv(t)
    let st = if t == 0 { 0.7pt + rgb("#888888") } else { 0.3pt + _grid }
    line((x, 0), (x, ph), stroke: st)
    content((x, -0.12), anchor: "north", text(size: 7.5pt)[#calc.round(t, digits: digits)])
  }
  for (i, v) in values.enumerate() {
    let y = yc(i)
    let col = if v > 0 { pos } else if v < 0 { neg } else { zero }
    let xz = xv(0)
    if v >= 0 { rect((xz, y), (xv(v), y + barh), fill: col, stroke: none) }
    else { rect((xv(v), y), (xz, y + barh), fill: col, stroke: none) }
  }
  for a in annotations {
    let (i, side, txt, col) = a
    let v = values.at(i)
    let x = if side == "east" { xv(v) + 0.12 } else { xv(v) - 0.12 }
    content((x, yc(i) + barh / 2), anchor: side, text(size: 7pt, fill: col)[#txt])
  }
})

// ----------------------------------------------------------------------------
// number-line — annotate a 1-D scale with shaded ranges and dashed markers.
// Great for showing two value bands that should be compared (e.g. a penalty
// band sitting above the typical score band).
//   ranges:  ((start, end, "label", color), ...)
//   markers: ((value, "label", color), ...)
// ----------------------------------------------------------------------------
#let number-line(
  ranges: (), markers: (), xmin: 0, xmax: 1.5, tick: 0.25, width: 11.0, digits: 2,
) = canvas(length: 1cm, {
  import draw: *
  let xv(v) = (v - xmin) / (xmax - xmin) * width
  line((0, 0), (width, 0), stroke: 0.6pt + _axis)
  let nt = int(calc.round((xmax - xmin) / tick))
  for i in range(0, nt + 1) {
    let v = xmin + i * tick
    let x = xv(v)
    line((x, -0.08), (x, 0), stroke: 0.5pt)
    content((x, -0.13), anchor: "north", text(size: 8pt)[#calc.round(v, digits: digits)])
  }
  for r in ranges {
    let (s, e, lab, col) = r
    rect((xv(s), 0.45), (xv(e), 0.85), fill: col, stroke: none)
    content((xv((s + e) / 2), 0.98), anchor: "south", text(size: 8pt, fill: col)[#lab])
  }
  for m in markers {
    let (v, lab, col) = m
    line((xv(v), 0.15), (xv(v), 1.5), stroke: (paint: col, thickness: 0.6pt, dash: "dashed"))
    content((xv(v), 1.52), anchor: "south", text(size: 7.5pt, fill: col)[#lab])
  }
})

// ----------------------------------------------------------------------------
// stacked-bars — horizontal stacked bars (e.g. findings by section × severity).
//   rows:     ((label, s1, s2, s3), ...)
//   segments: (name1, name2, name3)   ·   colors: per-segment fills
//   total:    if true, print the row total at the bar end
// ----------------------------------------------------------------------------
#let stacked-bars(
  rows: (), segments: (), colors: palette, xmax: auto,
  width: 8.5, total: true, legend: true, steps: 5,
) = canvas(length: 1cm, {
  import draw: *
  let sums = rows.map(r => r.slice(1).sum())
  let xm = if xmax == auto { calc.max(..sums) } else { xmax }
  let xv(v) = v / xm * width
  let rowh = 0.5
  let gap = 0.34
  let n = rows.len()
  let ph = n * (rowh + gap)
  for i in range(0, steps + 1) {
    let v = xm * i / steps
    let x = xv(v)
    line((x, 0), (x, ph), stroke: 0.3pt + rgb("#e0e0e0"))
    content((x, -0.12), anchor: "north", text(size: 8pt)[#calc.round(v, digits: 0)])
  }
  line((0, 0), (0, ph), stroke: 0.6pt + _axis)
  line((0, 0), (width, 0), stroke: 0.6pt + _axis)
  for (ri, row) in rows.enumerate() {
    let y = ph - (ri + 1) * (rowh + gap) + gap / 2
    let acc = 0.0
    for (si, seg) in row.slice(1).enumerate() {
      rect((xv(acc), y), (xv(acc + seg), y + rowh), fill: colors.at(si), stroke: none)
      acc = acc + seg
    }
    content((-0.18, y + rowh / 2), anchor: "east", text(size: 8.5pt)[#row.at(0)])
    if total {
      content((xv(acc) + 0.12, y + rowh / 2), anchor: "west", text(size: 8pt, fill: rgb("#5b6b78"))[#acc])
    }
  }
  if legend {
    let ly = -0.85
    for (si, name) in segments.enumerate() {
      let lx = si * 2.2
      rect((lx, ly), (lx + 0.3, ly + 0.3), fill: colors.at(si), stroke: none)
      content((lx + 0.4, ly + 0.15), anchor: "west", text(size: 8pt)[#name])
    }
  }
})
