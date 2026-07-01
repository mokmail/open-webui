# bev-mono Blueprint Widgets — Suggested Prompts as Architectural Grid

## Overview

Transform the suggested prompts display in the bev-mono theme from a flat vertical list into a wireframe-style blueprint card grid. The design follows bev-mono's existing philosophy: pure CSS, no JS changes, striking monochrome motion graphics.

## Motivation

The bev-mono theme is built around a black & white, flat, compositor-friendly aesthetic with hairline borders, a drifting grid overlay, and invert-on-hover interactions. The suggested prompts — previously rendered as a plain list — didn't leverage any of this visual language. This enhancement brings them into the theme's identity.

## Design

### Grid Layout

- 3-column grid on desktop (`grid-cols-3`), 2 on tablet, 1 on mobile
- Hairline `gap-px` between cards (uses existing `#e5e5e5` border color)
- Cards are compact and consistently sized via `min-height`

### Card Structure

Each blueprint panel follows a technical drawing composition:

```
┌─╴                        ╷
│  ╎  TITLE (small-caps)   │
│  ╎  subtitle/description │
│  ╎                       │
│  ╎   ── click to use     │
╷                        ╰─╴
```

- **Hairline border:** 1px solid `#d4d4d4`, flat corners (`border-radius: 0` or `--radius-lg: 0.1875rem`)
- **Ruler margin:** 24px-wide left strip with a vertical hairline and horizontal tick marks (top/middle/bottom) drawn via `background: repeating-linear-gradient`
- **Corner brackets:** `::before`/`::after` pseudo-elements drawing L-shaped brackets at top-left and bottom-right corners

### Interaction

- **Hover:** Card border shifts to solid black (`#000`), ruler strip fills solid black, title text weight increases
- **Sheen sweep:** Reuses the existing `bev-mono-sheen` animation across the card on hover

### Container Background

The suggestions wrapper gets the same drifting grid overlay pattern as `html.bev-mono body::after`, but rendered at half scale (23px grid) to create a blueprint-paper substrate behind the cards.

### Motion

- Staggered fade-in-up animation (reuses existing `.waterfall` class in `Suggestions.svelte`)
- Hover sheen uses existing `@keyframes bev-mono-sheen`
- All animations disabled via `@media (prefers-reduced-motion: reduce)`

## Files Changed

### 1. `src/lib/components/chat/Placeholder.svelte`

**Line 254** — Add `className="bev-suggestions-grid"` to the `<Suggestions>` component:

```svelte
<Suggestions
    className="bev-suggestions-grid"
    suggestionPrompts={...}
    inputValue={prompt}
    {onSelect}
/>
```

### 2. `src/app.css`

Append ~50 lines of CSS after the existing bev-mono theme block (after line 1576), scoped to `html.bev-mono .bev-suggestions-grid`:

- Grid container: `display: grid; grid-template-columns: repeat(3, 1fr); gap: 1px;`
- Card base: `position: relative; border: 1px solid #d4d4d4; min-height: 5rem; transition: ...`
- Ruler margin: pseudo-element or background on the card
- Corner brackets: `::before` and `::after` with `content: ''; position: absolute; border-color: #d4d4d4;`
- Hover states: `border-color: #000;`
- Container background: `background-image: ...` with the mini grid pattern
- Animation integration for sheen and waterfall stagger
- `@media (prefers-reduced-motion: reduce)` guard

### 3. `branding/frontend/static/custom.css`

Mirror the same CSS addition after line 734, matching the existing pattern of duplicating bev-mono styles in the branding override.

## What Does NOT Change

- `Suggestions.svelte` — no JS or template changes
- `ChatPlaceholder.svelte` — unaffected (already passes its own `className="grid grid-cols-2"`)
- Any other theme — the changes are scoped to `html.bev-mono`
- Fuse.js filtering, refresh button, flavor system — all unchanged
- Data model, API, backend — untouched

## Key Constraints

1. **Zero JS changes** — the entire enhancement is CSS-only
2. **Theme-scoped** — all selectors prefixed with `html.bev-mono`
3. **Motion accessibility** — `prefers-reduced-motion` disables all animations
4. **Corner radii** — must respect bev-mono's `--radius-*` custom properties (flat/sharp)
5. **No elevation** — use hairline borders, not shadows, consistent with bev-mono's flat philosophy
