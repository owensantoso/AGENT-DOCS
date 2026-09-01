# Rejection Translator v3 — verified implementation handoff

Prepared: 2026-09-01 JST  
Status: core content model, deterministic matcher, adversarial tests, static share-page generator, and deployment constraints are implemented and verified. This v3 handoff supersedes the implementation details in `../rejection-translator-2026-08-31.md`.

## Product

**Working name:** Subtext  
**Descriptor:** Closure as a Service  
**Proposed production URL:** `subtext.owensantoso.com`

The site translates:

```text
Polite rejection  ⇄  Blunt thought
```

Polite → blunt modes:

```text
Plain English | Group Chat | Maximum Copium | Corporate
```

Blunt → polite modes:

```text
Kind | Classic | Maximum Euphemism | Corporate
```

## Maximum Copium decision

Maximum Copium remains available for ordinary rejection phrases, including direct **no**, **I have a partner**, and family/cultural mismatch concepts.

Example:

```text
I'm not interested.
→ They said no, but bro, that's obviously just denial with punctuation.
```

Every Maximum Copium result carries this notice:

> Maximum Copium is satire, not advice. A no still means no. Do not use a joke translation to ignore boundaries, keep contacting someone, or harass them.

This is a disclaimer, not a ban on jokes about normal rejection. Inputs that are substantively different from ordinary rejection—such as threats, stalking, coercive self-harm threats, minors, physical abuse, consent/no-contact language, and restraining orders—return a literal boundary result instead of entering the comedy engine.

## Implemented fixes

- Draft 2020-12 schema validation;
- 31 concepts split into one source file each;
- stable IDs and provenance for aliases and outputs;
- alias strength and confidence caps;
- observable boundary separated from satirical hypothesis;
- punctuation-aware Unicode normalization;
- non-ASCII preservation for language detection;
- zero-width and bidirectional-control handling;
- polarity, contrast, meta-question, third-person, concrete-plan, and domain-collision gates;
- typo-tolerant local fuzzy matching;
- deliberate ambiguity declarations;
- added direct-no, feelings-changed, you-deserve-better, and already-unavailable concepts;
- broad aliases moved or confidence-capped instead of asserting unsupported motives;
- generated index hydrated into a `Map` to avoid prototype-key hazards;
- HTML/XML escaping and personal-data redaction for share images;
- stable result routes containing no raw pasted text;
- 496 static HTML result pages and 496 1200×630 PNG cards;
- Vercel security headers with `connect-src 'none'`;
- no runtime model, API, database, server function, or network call.

## Verified result

```text
Schema:           pass
Normalization:    22 / 22
Golden matcher:   78 / 78
Adversarial:      70 / 70
Copium policy:     3 / 3
Concepts:         31
Aliases:          468
Outputs:          496
Static routes:    496
Runtime AI:       none
Runtime network:  none
```

The clean source archive and Git patch both reproduced all generated output from an empty directory and passed the complete suite.

## Source packet

The verified packet was produced in the ChatGPT handoff session with these immutable download hashes:

```text
2cb265c6a718c2f7823f120153cfcc206971b7520dc1e4d2f78e763f3caf3bc1  rejection-translator-v3-source-packet.zip
ee5b8463b92a91e35b2291ecd6aa057e6787020d3db4ed1110bb010dd1f875b4  rejection-translator-v3-full-verified.zip
a645733d61a1dc6078d28b368dee9d5c52f5b37c5b79fc5bd358c9473a3efd64  rejection-translator-v3-source.patch
```

The source archive excludes bulky prebuilt cards but regenerates all 496 pages/cards with `npm run build`. The full archive includes them.

## Remaining work

The remaining work is product/UI work:

1. Build the clean two-panel Vite/React interface.
2. Select the strongest 10–15 concepts for the first public prototype.
3. Perform a human editorial pass on the proposed jokes.
4. Wire the existing engine and generated share routes into the UI.
5. Deploy to a private Vercel preview.
6. Attach `subtext.owensantoso.com` only when the prototype is worth sharing.

Read `CURRENT_STATE.md`, `DECISIONS.md`, and `CODEX-PROMPT.md` before implementation.
