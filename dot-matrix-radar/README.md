# Dot-Matrix Job Scorecard — Radar Dial

Visualisation of a job-application "Scoring Results" table (10 scored criteria + 1 unknown) in the dot-matrix device style shared with `dot-matrix-histogram` / `dot-matrix-thinking`. Two artefacts: a static canvas design (`.pen`) and a **parametrised, interactive HTML** version.

## Concept
A LED radar dial: each scoring criterion is a dot on a spoke — **distance from the hub = score (0 center → 10 outer ring)**. Weak criteria collapse toward the center in glowing orange (risk), strong ones sit on the outer white rings. A closed score-line polygon connects all scored dots. The unscored criterion (ONSITE) floats as a ghost dot — unknown distance, outside the polygon. The total (mean of scored criteria) lives in the hub.

## Data encoded
- SALARY 6 · JOB TYPE 10 · SIZE 9 · CULTURE 7 · LOC 7 · ROLES 8 · TECH 9 · **AI 1** · SENIOR 9 · TEAM 8 · ONSITE ?/10
- Total **7.4/10** (mean) in hub · verdict **PROMOTE** badge in header

## Geometry (shared by canvas + HTML)
- Dial 320×320, center (160,160); radius scale `r = RI + score*S` with **RI 44, S 5.6** (outer ring 100)
- Guide rings (dotted) at scores 2.5/5/7.5/10 → r 58/72/86/100; faint spokes from r 54 to each dot
- 11 criteria at angles `-90° + i*(360/11)`; labels rotated radially, **text center on the spoke at radius 135** (all same radius): right half reads outward, left half reads inward (never upside-down)
- Score dots 12px (14px + halo for score ≤5); colors: ≥8 `#eaeae7`, 6–7 `#cfcfcc`, ≤5 `#ff4d1f`, unknown `#3f3f4a`
- Score line: closed SVG polygon through scored dots — canvas: 2px `$led`, soft glow, subtle `#ffffff08` fill, **under** the dots; HTML: same but layered **above** the dots (labels + hub stay on top)
- Hub: total only (`7.4`, 44px glow), centered at (160,150)

## Files
- `dot-matrix-radar-radial-text.pen` — canvas design (open in Pen; labels/score-line included)
- `dot-matrix-radar-radial-text-export.html` — static HTML/CSS export of the canvas design
- `dot-matrix-radar-parametric.html` — **interactive, config-driven version** (see below)
- `dot-matrix-radar.png` — early static preview render (v1 layout, kept for reference)
- `description.md` — this file

## Parametric HTML — view & interact
Open `dot-matrix-radar-parametric.html` in any browser (double-click; no server/build needed). Self-contained: all CSS/JS inline; the only external ref is the Google-Fonts **Doto** stylesheet (offline → system-font fallback, still fully functional).

Two ways to change scores:
1. **Live sliders** in the SCORES panel (0–10 + value + "?" checkbox per criterion). "?" = unknown: slider disables, dot goes ghost, drops out of polygon + total.
2. **Config** — edit the `SCORES` array at the top of the `<script>`: rename criteria, add/remove rows (angle spacing adapts to any count), set defaults, `score: null` for unknown.

Changing a score updates: **(1)** hub total (mean of non-null), **(2)** dot position + color/glow band, **(3)** SVG path points, plus label color for risks. Everything re-renders instantly.

## Editing the canvas design
- Rescore: move a dot along its spoke to `r = 44 + score*5.6`; move its label center on the same ray at radius 135
- Add a criterion: append to the loop order — new spoke, dot, label at the next `(360/n)°` slot
- Restyle globally via shared variables: `wall screen led led-mid label dim unlit accent font-led` (Doto)
