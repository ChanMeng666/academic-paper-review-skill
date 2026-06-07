# Review Dimensions

The checklist behind both review lenses. Walk it for every manuscript. Not every item applies to
every paper — use judgment — but a defect you didn't look for is a defect you'll miss.

A finding, whichever lens it comes from, always takes the form:
**location → issue → why it matters → concrete fix.**

---

## Contents
- [Lens 1 — Editorial / academic](#lens-1--editorial--academic)
- [Lens 2 — Technical / domain](#lens-2--technical--domain)
  - [Generic technical critique (any field)](#generic-technical-critique-any-field)
  - [RAG / IR / dense-retrieval deep dive](#rag--ir--dense-retrieval-deep-dive)
- [Recurring high-value defect patterns](#recurring-high-value-defect-patterns)

---

## Lens 1 — Editorial / academic

**Claims vs. evidence.** Does each claim in the abstract/intro/conclusion survive contact with the
results? The classic failure is an abstract that says "minor, mostly non-significant impact" while a
results table shows a significant drop. Check that headline language matches the data, and that
"outperforms" claims rest on significant differences, not noise.

**Statistics.** Recompute means, percentages, and tests where the data is present. Check: does the
reported test fit the design (paired vs unpaired)? Is significance claimed on a tiny sample? Is a
significance test run on something deterministic (e.g. a constant), where p-values are meaningless by
construction? Is "greater variance" mis-sold as improvement (only central tendency + a proper test
support an improvement claim)? Report effect sizes / confidence intervals, not just p-values.

**Citations & attribution.** For every load-bearing external number or named method, verify the cited
source *actually* reports it (see the verification phase). Watch for: a real statistic attributed to
the wrong reference; a famous method cited by the wrong paper; dataset provenance pointing at an
unrelated paper instead of the dataset card; duplicate references; forward-dated ("2026") refs that
should be marked "online first".

**Internal consistency.** Numbers that drift between abstract, body, and tables (e.g. "~200" vs 202);
a metric defined two different ways in two places; parameters that differ between a paper and its
algorithm appendix. Cross-document parity matters when companion papers exist.

**Figure / text agreement.** Do figure labels match the prose definitions? (A diagram node that says
"Entities + Verbs" while the text says "nouns/proper-nouns + verbs/adjectives" is a real finding.)
Are all figures referenced and readable?

**Reproducibility.** Are datasets, splits, model versions, hyperparameters, and prompts (for
LLM-generated data) specified well enough to reproduce? LLM-generated eval queries need the exact
prompt, a human-validation pass, and a note on the bias of same-family models retrieving them easily.

**Writing & structure.** Number agreement, run-ons, awkward titles, sections noticeably less polished
than others. Keep copyedit notes light and grouped — don't drown the science in grammar.

---

## Lens 2 — Technical / domain

This is where the review earns trust. Judge the *method*, not just the prose, against what a
practitioner in the field would actually do.

### Generic technical critique (any field)

- **Is the baseline a strawman?** The most damaging methodological flaw. Ask: does anyone actually
  deploy the baseline being beaten? A 95% improvement over a system nobody uses is not a result.
- **Does the metric measure the right thing — and can it be gamed?** A metric that a trivial/degenerate
  system scores well on is not evidence of quality. Demand that the *outcome of interest* be measured,
  not a convenient proxy.
- **Missing baselines / ablations.** Is the obvious prior method compared against? Is each component's
  contribution isolated? Are key hyperparameters swept?
- **Do the numbers smell like a bug?** Implausibly low (or perfect) numbers for a competent baseline
  usually mean the *measurement* is broken, not that the task is hard. Name the most likely bug.
- **Circular / leaky evaluation.** Is "ground truth" derived from the very system under test? Is there
  train/test leakage? Is the proxy label independent of the method?
- **Scalability / cost honesty.** Are complexity and runtime characterized? Is an O(N²) step sold as
  cheap? Does the efficiency metric ignore a cost the method actually incurs?

### RAG / IR / dense-retrieval deep dive

Domain knowledge for the most common paper type this skill sees. Use what's relevant.

**Retrieval quality must be measured with relevance metrics.** Recall@k, nDCG, MRR against real
relevance judgments. A paper that reports only *diversity* (e.g. mean pairwise similarity / redundancy
of the top-K) has not shown better retrieval — diversity is trivially maximized by retrieving
unrelated documents. Diversity gains must be shown *not* to cost relevance. Where possible, also
measure **downstream answer quality** (faithfulness/correctness), since that's what RAG exists for.

**ANN indexes are the real baseline, not brute force.** Production retrieval does not exhaustively scan
(`IndexFlatIP`); it uses approximate-nearest-neighbour indexes — **IVF** (inverted file) and **HNSW**
(graph) — which already give sub-linear search at high recall. Any "we reduce search cost vs. a full
scan" claim must benchmark against IVF/HNSW, reported on the field-standard **recall-vs-compute (or
recall-vs-QPS)** curve. Note: routing a query to its single nearest centroid/cluster *is* IVF with
`nprobe = 1`; multi-probe / soft routing (top-p clusters) is the standard recall mitigation, and the
`nprobe=1` recall loss at cluster boundaries is a known, expected phenomenon to engage rather than
downplay.

**Diversification has a canonical method: MMR.** Maximal Marginal Relevance (Carbonell & Goldstein,
SIGIR 1998) and DPP-based methods discount redundancy *within the per-query candidate set*, keeping the
penalty relevance-aware. Any new redundancy/diversity penalty must be positioned against MMR and
ideally benchmarked against it. A *query-independent, corpus-global* penalty risks suppressing a
document that is exactly what the query wants merely because it resembles a frequent corpus pattern.

**Embedding-model pitfalls.**
- **The bge query-instruction prefix.** `bge-*-en-v1.5` expects *queries* prefixed with
  `"Represent this sentence for searching relevant passages:"` (documents get no prefix). Omitting it
  collapses retrieval quality — the single most common cause of implausibly low Hit Rates with bge.
- **Model–task fit.** A *paraphrase*-tuned or *multilingual* model on an English retrieval task is
  suboptimal; retrieval-tuned English encoders (`bge-*-en`, `e5-*`, `all-mpnet-base-v2`) are stronger,
  and paraphrase models inflate similarity (distorting any similarity-based statistic).
- **Cosine vs. inner product.** `IndexFlatIP` equals cosine only if *both* document and query vectors
  are L2-normalized. Papers often state only the query is normalized — flag it.

**Chunking is first-order.** Whether retrieval operates over whole documents or chunks (and the chunk
size) strongly affects recall and intra-list redundancy. If unspecified, that's a gap.

---

## Recurring high-value defect patterns

A short list of the issues that, in practice, most often turn out to be the *real* story. Look for
these first:

1. **Strawman baseline** — beating a system no one deploys (esp. brute-force scan vs. ANN).
2. **Wrong/gameable metric** — measuring a proxy (diversity, category match) instead of the outcome
   (relevance, answer quality).
3. **Claim contradicts own data** — abstract says "no significant loss"; a table shows a significant
   loss; a 0/0 result sold as "maintained accuracy"; a non-significant difference sold as "outperforms".
4. **Eval bug masquerading as a finding** — implausible baseline numbers (missing bge prefix,
   normalization mismatch, label mismatch).
5. **Misattributed citation** — a real number cited to the wrong paper.
6. **Vacuous significance test** — p-values on a deterministic quantity, or strong significance
   language on n≈20.
7. **Circular evaluation** — ground truth derived from the system under test.
8. **Unbounded/uncalibrated knob** — a "soft" penalty whose magnitude dwarfs the score scale, making
   it a hard switch in disguise.
