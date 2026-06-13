# RUBRIC.md — CoachLoop acceptance criteria

The build is **done** when every assertion below is **PASS**. Each is a single checkable
claim, graded either by the machine check (`scripts/verify.sh`) or by a one-line manual
observation. This file is the artifact the model grades itself against (Build Day
orchestration criterion); derived from [`SPEC.md`](SPEC.md) §13.

**Deploy target: Vercel.** The canonical live URL for verification is the **Vercel-assigned production URL** (e.g. `https://coachloop.vercel.app`). A custom domain is out of scope for the agent — point `VERIFY_URL` at the Vercel URL; swapping in a custom domain later is the owner's step and doesn't change any assertion.

```bash
# Machine check — non-zero exit on any failure
npm install                                   # once, enables typecheck + lint
VERIFY_URL=https://coachloop.vercel.app bash scripts/verify.sh
```

Status legend: **PASS** / **FAIL** / **PENDING** (not built yet).

---

## A. Deploy & build gates

| ID | Assertion | How graded | Status |
|----|-----------|-----------|--------|
| A1 | The deployed URL returns HTTP 2xx within 15s. | `verify.sh` → `live url` (`curl -fsS`) | PENDING |
| A2 | The app is usable on a mobile viewport (375×812): the hero loop is reachable, no horizontal scroll, tap targets ≥ 40px. | Manual: open `VERIFY_URL` in a phone-sized viewport | PENDING |
| A3 | `npm run typecheck` passes (no type errors). | `verify.sh` → `typecheck` | PENDING |
| A4 | `npm run lint` passes. | `verify.sh` → `lint` | PENDING |
| A5 | The scoring fixture test passes. | `verify.sh` → `test` (`node --test test/scorer.test.mjs`) | **PASS** |

---

## B. Scoring — a seeded transcript returns a valid, evidence-bound score

Graded by `test/scorer.test.mjs` against `test/fixtures/` (seeded Discovery transcript +
golden evaluation), plus a live check once the Opus 4.8 scorer is wired in.

| ID | Assertion | How graded | Status |
|----|-----------|-----------|--------|
| B1 | A seeded transcript yields an evaluation with a `/100` score and a band in {`strong`,`needs_work`,`redo`}. | test: *"score band is a valid value…"* | **PASS** |
| B2 | `score_100` equals `Σ(item_score × weight) ÷ 5` (no arithmetic drift). | test: same as B1 (`computeScore100`) | **PASS** |
| B3 | The band matches the score (`80+`→strong, `60–79`→needs_work, `<60`→redo). | test: `bandFor` assertion | **PASS** |
| B4 | **Every** item score cites a `cite_ts_seconds` that exists in the transcript. | test: *"every score cites a timestamp…"* | **PASS** |
| B5 | **Every** cited quote is real text spoken at that timestamp (no hallucinated citation). | test: *"golden evaluation passes all grader invariants"* (substring grounding) + *"rejects a hallucinated quote…"* | **PASS** |
| B6 | Rubric weights sum to exactly 100. | test: `validateEvaluation` weight-sum check | **PASS** |
| B7 | (Live) The deployed scorer produces B1–B6 for a transcript posted to `/api/score`. | Manual/curl once `/api/score` exists | PENDING |

---

## C. Weakest skill — flagged and clickable

| ID | Assertion | How graded | Status |
|----|-----------|-----------|--------|
| C1 | The flagged weakest skill is the **highest-leverage** item: `max((5 − score) × weight)` (deterministic tie-break). | test: *"weakest skill is the highest-leverage item…"* | **PASS** |
| C2 | The flagged weakness carries a `cite_ts_seconds`, so the UI can deep-link to that moment (clickable). | test: same as C1 | **PASS** |
| C3 | (Live) Tapping the flagged skill jumps the transcript to that timestamp. | Manual on `VERIFY_URL` | PENDING |

---

## D. Drill → scoped re-score with a visible before/after delta

| ID | Assertion | How graded | Status |
|----|-----------|-----------|--------|
| D1 | A drill re-score targets exactly **one** rubric item (the drilled skill) — scoped, not a full re-eval. | test: `validateRescore` item match + weight match | **PASS** |
| D2 | `before_1_5` equals the original call's score for that item (the delta is honest). | test: *"rejects a re-score whose before-score lies…"* | **PASS** |
| D3 | `delta_points_100` equals `(after − before) × weight ÷ 5`. | test: *"rejects a re-score whose delta math is wrong"* + happy-path | **PASS** |
| D4 | A genuine improvement shows a **positive** delta on screen. | test: *"re-score is scoped… correct before/after delta"* | **PASS** |
| D5 | (Live) Completing a voice drill renders the before→after delta for the drilled skill. | Manual on `VERIFY_URL` | PENDING |

---

## E. The gate fails loudly (meta-assertion)

The grader is only useful if a *bad* score is rejected. These prove it.

| ID | Assertion | How graded | Status |
|----|-----------|-----------|--------|
| E1 | A score with a **missing timestamp** is rejected. | test: *"rejects a score with a missing timestamp"* | **PASS** |
| E2 | A citation pointing at a **non-existent timestamp** is rejected. | test: *"rejects a citation pointing at a timestamp not in the transcript"* | **PASS** |
| E3 | A **mismatched band** is rejected. | test: *"rejects a band that does not match the score"* | **PASS** |
| E4 | A **wrong weakest-skill** flag is rejected. | test: *"rejects a wrong weakest-skill flag"* | **PASS** |

> Verified live: blanking one real timestamp in the golden fixture turns the suite red
> (9 pass / 3 fail); restoring it returns 12/12. The gate is not cosmetic.

---

## Current state (2026-06-13)

The **scoring grader and its gate are implemented and green** (sections B, C, D, E — the
product's core logic). The remaining PENDING items (A1–A4, B7, C3, D5) unlock as the app is
built and deployed: install deps (typecheck/lint), wire `/api/score` + the drill, and set
`VERIFY_URL` to the live deployment. `verify.sh` already runs all stages and exits non-zero
until they're green.
