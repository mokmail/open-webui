# bev-mono Blueprint Widgets Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform suggested prompts in the bev-mono theme from a flat list into an architectural blueprint-style card grid, using pure CSS.

**Architecture:** Add `className="bev-suggestions-grid"` to the `<Suggestions>` call in `Placeholder.svelte`, then drive all visual changes via CSS scoped to `html.bev-mono` in `src/app.css` and `branding/frontend/static/custom.css`.

**Tech Stack:** Svelte, Tailwind CSS, plain CSS (custom properties, pseudo-elements, keyframe animations)

## Global Constraints

- Zero JS changes — all visual enhancement is CSS-only
- All new CSS must be scoped to `html.bev-mono` prefix
- Follow bev-mono's flat design language: no box shadows, hairline borders (`1px solid #d4d4d4`), minimal border-radius
- `prefers-reduced-motion` guard for all animations
- Colors must be consistent with the theme (`#000`, `#d4d4d4`, `#e5e5e5`, `#fafafa`, `#a3a3a3`)

---

### Task 1: Add className prop to Placeholder.svelte

**Files:**
- Modify: `src/lib/components/chat/Placeholder.svelte:254`

**Interfaces:**
- Produces: `className="bev-suggestions-grid"` passed to `<Suggestions>` component

- [ ] **Step 1: Edit Placeholder.svelte**

In `src/lib/components/chat/Placeholder.svelte`, at line 254, add `className="bev-suggestions-grid"` to the `<Suggestions>` component:

```svelte
<Suggestions
    className="bev-suggestions-grid"
    suggestionPrompts={atSelectedModel?.info?.meta?.suggestion_prompts ??
        models[selectedModelIdx]?.info?.meta?.suggestion_prompts ??
        $config?.default_prompt_suggestions ??
        []}
    inputValue={prompt}
    {onSelect}
/>
```

- [ ] **Step 2: Verify the change**

Run: `git diff`
Expected: Only the `className="bev-suggestions-grid"` line added

- [ ] **Step 3: Commit**

```bash
git add src/lib/components/chat/Placeholder.svelte
git commit -m "feat(bev-mono): add bev-suggestions-grid className to Placeholder"
```

---

### Task 2: Add blueprint widget CSS to app.css

**Files:**
- Modify: `src/app.css` (append after line 1576)

**Interfaces:**
- Consumes: `html.bev-mono` scope, Suggestions component structure (`div[role="list"]`, `button[role="listitem"]`, `.font-medium`, `.text-xs`)
- Produces: Blueprint card grid CSS

- [ ] **Step 1: Append CSS to app.css**

Append the following block at the end of `src/app.css` (after the final `}` at line 1576):

```css
/* ============================================================
   bev-mono: blueprint widget grid for suggested prompts
   ============================================================ */

html.bev-mono .bev-suggestions-grid {
	display: grid !important;
	grid-template-columns: repeat(1, 1fr);
	gap: 1px;
	padding: 1px;
	max-height: none !important;
	overflow: visible !important;
	background-image:
		linear-gradient(#d4d4d4 0.5px, transparent 0.5px),
		linear-gradient(90deg, #d4d4d4 0.5px, transparent 0.5px);
	background-size: 23px 23px;
	background-color: #fafafa;
}

@media (min-width: 640px) {
	html.bev-mono .bev-suggestions-grid {
		grid-template-columns: repeat(2, 1fr);
	}
}

@media (min-width: 1024px) {
	html.bev-mono .bev-suggestions-grid {
		grid-template-columns: repeat(3, 1fr);
	}
}

html.bev-mono .bev-suggestions-grid button[role="listitem"] {
	position: relative;
	overflow: hidden;
	flex: none !important;
	width: auto !important;
	border: 1px solid #d4d4d4;
	border-radius: 0;
	min-height: 3.75rem;
	padding: 0.625rem 0.75rem 0.625rem 1.75rem;
	margin: 0;
	background: #ffffff;
	transition: border-color 0.18s ease, background-color 0.18s ease;
}

/* Ruler margin: vertical hairline with tick marks */
html.bev-mono .bev-suggestions-grid button[role="listitem"]::before {
	content: '';
	position: absolute;
	top: 0;
	left: 0;
	bottom: 0;
	width: 1.25rem;
	background:
		linear-gradient(#d4d4d4, #d4d4d4) center 0 / 1px 100% no-repeat,
		linear-gradient(#d4d4d4, #d4d4d4) 2px 0.5rem / calc(100% - 4px) 1px no-repeat,
		linear-gradient(#d4d4d4, #d4d4d4) 2px 50% / calc(100% - 4px) 1px no-repeat,
		linear-gradient(#d4d4d4, #d4d4d4) 2px calc(100% - 0.5rem) / calc(100% - 4px) 1px no-repeat;
	transition: background-color 0.18s ease;
	pointer-events: none;
}

/* Bottom-right corner bracket */
html.bev-mono .bev-suggestions-grid button[role="listitem"]::after {
	content: '';
	position: absolute;
	bottom: 5px;
	right: 5px;
	width: 8px;
	height: 8px;
	border-bottom: 1.5px solid #a3a3a3;
	border-right: 1.5px solid #a3a3a3;
	opacity: 0.6;
	transition: opacity 0.18s ease, border-color 0.18s ease;
	pointer-events: none;
}

/* Title text: small-caps, technical feel */
html.bev-mono .bev-suggestions-grid button[role="listitem"] .font-medium {
	font-size: 0.75rem;
	font-weight: 700;
	text-transform: uppercase;
	letter-spacing: 0.05em;
	color: #404040;
	transition: color 0.18s ease;
}

/* Subtitle text */
html.bev-mono .bev-suggestions-grid button[role="listitem"] .text-xs {
	font-size: 0.6875rem;
	color: #a3a3a3;
	font-weight: 400;
}

/* Hover: black border, ruler fills solid, title darkens */
html.bev-mono .bev-suggestions-grid button[role="listitem"]:hover {
	border-color: #000000;
}

html.bev-mono .bev-suggestions-grid button[role="listitem"]:hover::before {
	background-color: #000000;
	background-image:
		linear-gradient(#ffffff, #ffffff) center 0 / 1px 100% no-repeat,
		linear-gradient(#ffffff, #ffffff) 2px 0.5rem / calc(100% - 4px) 1px no-repeat,
		linear-gradient(#ffffff, #ffffff) 2px 50% / calc(100% - 4px) 1px no-repeat,
		linear-gradient(#ffffff, #ffffff) 2px calc(100% - 0.5rem) / calc(100% - 4px) 1px no-repeat;
}

html.bev-mono .bev-suggestions-grid button[role="listitem"]:hover::after {
	opacity: 1;
	border-color: #000000;
}

html.bev-mono .bev-suggestions-grid button[role="listitem"]:hover .font-medium {
	color: #000000;
}

html.bev-mono .bev-suggestions-grid button[role="listitem"]:hover .text-xs {
	color: #525252;
}

/* Reduce gap between header row and grid */
html.bev-mono .bev-suggestions-grid + .bev-suggestions-grid {
	margin-top: 0;
}

html.bev-mono .bev-suggestions-grid .waterfall {
	opacity: 0;
	animation: fadeInUp 200ms ease forwards;
}

/* Reduced motion */
@media (prefers-reduced-motion: reduce) {
	html.bev-mono .bev-suggestions-grid .waterfall {
		animation: none !important;
		opacity: 1;
	}
}
```

- [ ] **Step 2: Verify the CSS**

Run: `wc -l src/app.css` then `tail -5 src/app.css`
Expected: File is ~1670 lines, the last lines are the reduced-motion media query block

- [ ] **Step 3: Commit**

```bash
git add src/app.css
git commit -m "feat(bev-mono): add blueprint widget grid CSS for suggested prompts"
```

---

### Task 3: Mirror CSS to branding override

**Files:**
- Modify: `branding/frontend/static/custom.css` (append after line 734)

**Interfaces:**
- Mirror of Task 2 — same CSS block appended after the existing bev-mono block

- [ ] **Step 1: Append identical CSS to custom.css**

Append the exact same CSS block from Task 2 Step 1 at the end of `branding/frontend/static/custom.css` (after line 734, the final `}`).

- [ ] **Step 2: Verify**

Run: `wc -l branding/frontend/static/custom.css`
Expected: File is ~810 lines

- [ ] **Step 3: Commit**

```bash
git add branding/frontend/static/custom.css
git commit -m "feat(bev-mono): mirror blueprint widget CSS to branding override"
```

---

### Task 4: Full verification

- [ ] **Step 1: Verify all changes**

Run: `git log --oneline -5`
Expected: 3 commits for Tasks 1-3

Run: `git diff HEAD~3 --stat`
Expected: 3 files changed:
- `src/lib/components/chat/Placeholder.svelte` (1 insertion)
- `src/app.css` (~80 lines)
- `branding/frontend/static/custom.css` (~80 lines)

- [ ] **Step 2: Check for syntax errors**

Run: `npx svelte-check --tsconfig ./tsconfig.json 2>&1 | tail -20`

Expected: No errors related to these changes (CSS-only changes should not affect Svelte checks)

- [ ] **Step 3: Review final state**

Read the tail of `src/app.css` and `branding/frontend/static/custom.css` to confirm the CSS block is properly terminated.

```bash
git diff HEAD~3
```
Expected: Clean diff with the 3 changes described above, no stray characters or syntax issues.
