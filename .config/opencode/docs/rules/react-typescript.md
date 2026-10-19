# React / TypeScript Rules

Load this file before writing or editing React/TypeScript code (.ts, .tsx, .jsx).

**Precedence:** the project's own conventions override these rules; these rules fill gaps the project doesn't specify. When existing project code conflicts (e.g., it uses enums or `any`), follow the project.

## Logic & Effects

- Default to event-driven triggers (event handlers, callbacks, subscriptions) instead of `useEffect`. Use effects only to sync with external systems outside React (DOM APIs, third-party widgets, websockets, analytics).
- Never mirror props into state or compute derivable values in `useEffect` — derive during render.
- Never chain fetch → setState in `useEffect` manually; use the project's data layer (React Query/SWR/server actions) when available.

## Control Flow

- Prefer lookup maps (`Record<K, V>` objects or `Map`) of configs/handlers/renderers over long `if-else` chains or `switch` on values.

## TypeScript

- No `any`. Escape hatch only in truly generic utility code, with a comment explaining why; otherwise use precise types, generics, or `unknown` + narrowing.
- No TypeScript `enum`. Use `as const` frozen objects with `typeof` / `(typeof X)[keyof typeof X]` derived types.
- Shared/reusable utility functions go into the shared utils module (e.g. `lib/utils.ts`), never duplicated inline in components.
- Use `import type` for type-only imports.

## State & Hooks

- Minimum number of states: derive what can be computed from existing state/props instead of storing it.
- Consolidate related state into a single object or custom hook; don't split one concern across many `useState` calls.
- Don't call the same hook multiple times for the same purpose — extract repeated logic into a custom hook and call it once.
- Colocate state as close to its usage as possible; lift only when sharing is required.

## UI & Styling

- Always compose UI from the project's custom components (shadcn/ui primitives) — never raw `<button>`/etc. when a component exists.
- Styling uses design tokens only: Tailwind classes backed by the theme config or shadcn tokens. No arbitrary values like `text-[10px]`, `w-[137px]` — extend the token/theme config instead.
- Variants come from `cva` (or the component library's variant API), not ad-hoc template strings.

## Clean Code (additional)

- Prefer composition (`children`, slot props) over prop drilling; Context only for genuinely global concerns (theme, auth).
- Every async/data view handles loading, error, and empty states explicitly.
- Components do one thing; split when a component exceeds ~150 lines or mixes data fetching with presentation.
- Extract reusable logic (not just JSX) into custom hooks under a hooks directory.
- Validate external data at boundaries with the project's schema lib (e.g. zod) when present.
- Memoize (`useMemo`/`useCallback`/`memo`) only for measured performance problems or referential-stability requirements — not by default.
- Before creating a new component, check the project's existing convention for component files (`ComponentName.tsx` directly vs `ComponentName/index.tsx` folder style) and follow it.
