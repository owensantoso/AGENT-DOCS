# Current state

Updated: 2026-09-01 JST

## True now

- The static-first content architecture is implemented.
- The dating pack contains 31 canonical concepts, 468 aliases, and 496 output variants.
- All aliases and outputs have stable identities and provenance fields.
- Maximum Copium is enabled with a permanent disclaimer for every ordinary rejection concept.
- Direct “I'm not interested” and “I have a partner” inputs both have Maximum Copium output.
- The English normalizer passes all 22 defined cases and quote-wrap/idempotence properties across the full alias corpus.
- The matcher passes 78/78 golden cases and 70/70 adversarial cases.
- The share generator creates 496 static result pages and 496 PNG cards.
- The engine has no runtime network primitive or hosted-model dependency.
- The packet is configured for a future static Vercel deployment and `subtext.owensantoso.com`.

## Not built yet

- The polished Vite/React translator UI.
- Interactive tone and direction controls.
- Browser-local Canvas/SVG exact-message card preview.
- Public deployment or custom-domain DNS attachment.
- Human approval of every proposed content variant.
- Final brand-name decision.

## Next implementation slice

Build the UI only. Reuse the current matcher, source model, privacy rules, share-route manifest, and verification suite.

Acceptance gate:

- the two-way translator feels immediate on phone and desktop;
- the premise is understood without explanation;
- Maximum Copium is clearly funny and its disclaimer remains visible without dominating the page;
- several Group Chat/Copium results are worth sharing;
- the full check remains green;
- no runtime API is introduced.
