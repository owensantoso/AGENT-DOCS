# Codex implementation prompt

```text
Use this v3 packet as the source of truth for the Rejection Translator project.

First read README.md, AGENTS.md, CURRENT_STATE.md, and DECISIONS.md. Obtain the verified v3 source packet whose SHA-256 is recorded in README.md. Run `npm run check` before changing anything and preserve the passing baseline.

Build the next slice: a polished, mobile-first Vite + TypeScript + React interface that resembles a credible translation product. Do not replace the content model or matcher. Import the existing deterministic engine from src/. Do not add Next.js, a database, user accounts, server functions, runtime AI, or runtime network requests.

The main interface is a two-panel translator:
- Polite rejection ⇄ Blunt thought
- Plain English, Group Chat, Maximum Copium, Corporate for polite_to_blunt
- Kind, Classic, Maximum Euphemism, Corporate for blunt_to_polite

Maximum Copium must remain enabled for ordinary rejection, including direct no and already unavailable. Show the existing Maximum Copium disclaimer close to the output, but keep the page funny rather than turning it into a lecture.

Use deliberate UI states for exact match, fuzzy match, ambiguity choice, context-needed/unknown, unsupported language, too-long input, and severe safety-boundary input. Do not claim to know someone’s true motive.

Add copy, stable-link, navigator.share, and local exact-message image-card actions. Stable links must use generated share routes and never contain raw user input. Exact-message cards must preview locally and use the provided escaping/redaction utilities.

Use Vercel as a static deployment target and preserve vercel.json security headers. Build result-specific pages from the existing static share generator. Keep subtext.owensantoso.com as a proposed production URL only; do not alter DNS or publicly deploy without separate instruction.

Run the production build and `npm run check`. Update CURRENT_STATE.md with exact results, remaining limitations, and the next human acceptance gate.
```
