# Decisions

## D-001 — Runtime translation is deterministic and local

Use reviewed aliases, exact lookup, context gates, and local fuzzy matching. No hosted model is called in the user request path.

## D-002 — Development-time AI is a candidate generator only

AI may propose aliases and jokes offline. Candidates retain model/prompt provenance and require review before entering the production corpus.

## D-003 — Maximum Copium remains available for ordinary rejection

Owen explicitly chose comedy over disabling the mode for direct no and similar ordinary phrases.

Required presentation:

> Maximum Copium is satire, not advice. A no still means no. Do not use a joke translation to ignore boundaries, keep contacting someone, or harass them.

The disclaimer is always shown with the mode. Direct no, already unavailable, and family/cultural mismatch retain Copium variants.

## D-004 — Severe safety/coercion statements are a different input class

Threats, physical abuse, stalking, restraining orders, coercive self-harm threats, minors, and consent/no-contact statements bypass ordinary rejection comedy. This is not a restriction on joking about normal rejection; it prevents unrelated dangerous text from being misclassified as dating banter.

## D-005 — Share links never contain raw pasted messages

Stable result URLs encode concept, mode, and output IDs. Exact-message images are created locally after preview and personal-data redaction.

## D-006 — Result previews are static

Build result-specific HTML and PNG cards for shareable variants. This provides predictable Open Graph/Twitter previews without server rendering or functions.

## D-007 — Deployment target is Vercel

Use a static Vite output and Vercel preview deployments. The intended public URL is `subtext.owensantoso.com`; the provider URL is not part of the brand.

## D-008 — Subtext is a working name

Do not purchase a product-specific domain or present the name as final until the public-launch naming review.
