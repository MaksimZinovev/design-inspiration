# Dot-Matrix Agent Status — "Thinking" Display

## What

A canvas design of a pixel-matrix status panel (Tidbyt-style smart display) showing an AI agent's live state: a glowing robot face, a "THINKING..." headline, a voice-activity waveform, and three stats. Styled as a realistic device mockup mounted on a warm wall. Part of the `design-inspiration` dot-matrix family, alongside `dot-matrix-histogram`.

## Design Tokens

**Layout (top → bottom)**

1. Header — boxed page index `01` + `AGENT STATUS` label
2. Headline — `THINKING...` in large dot-matrix type
3. Face — ring of white dots, two glowing orange eyes, 4-dot mouth
4. Waveform — 24 center-aligned dot columns (audio-activity pattern), orange burst in the middle
5. Stats footer — `STEPS 128 │ TOOLS 12 │ MEMORY 98%` with thin dividers

**Style tokens (shared variables)**

| Variable | Value | Role |
| --- | --- | --- |
| `wall` | `#c9b39a` | warm beige wall background |
| `screen` | `#0c0c0f` | device panel black |
| `led` / `led-mid` | `#eaeae7` / `#cfcfcc` | lit dots / secondary text |
| `label` / `dim` | `#8f8f98` / `#5b5b64` | small labels / inactive |
| `unlit` | `#1c1c22` | off dots |
| `accent` | `#ff4d1f` | eyes, waveform burst |
| `font-led` | `Doto` | Google dot-matrix font |

**Details** — 620×620 canvas; 460×460 device, 26px corner radius, `#1e1e24` inner border, layered drop shadows, radial gloss highlight top-left; text glows via soft white shadows.

## How to use

**Edit text** — select and retype. Text nodes are named: `Headline` (status message), `Title`, `Index` (header), `STEPS/TOOLS/MEMORY Label` + `Value` (stats). Keep headlines ≲ 11 characters at 60px, or lower the font size.

**Recolor / restyle globally** — edit the variables above (one change restyles every dot and text). Swap `accent` to change eyes + waveform highlight together.

**Adjust the face** — `Face` frame holds individual ellipses: `Ring Dot *`, `Eye L/R`, `Mouth *`. Move, recolor, or resize for different expressions.

**Adjust the waveform** — `Waveform` → `Col 1…24`, each a vertical stack of 8px dots. Add/remove dots or recolor columns to shape the "activity" pattern.

**Make variants** — duplicate the top frame and change the headline/stats (e.g. `02 SLEEPING...`, `03 ERROR`). Or convert the stats row into a reusable component so all pages stay in sync.

**Export** — use the canvas export (PNG / HTML) for mockups, or code generation for a web implementation.
