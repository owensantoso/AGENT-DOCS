---
title: Rejection Translator — Product and Implementation Handoff
document_type: handoff
status: proposed
created_at: 2026-08-31T22:00:00+09:00
updated_at: 2026-08-31T22:00:00+09:00
domain: product
suggested_project_slug: rejection-translator
suggested_branch: handoff/rejection-translator-2026-08-31
---

# Rejection Translator — Product and Implementation Handoff

**Prepared:** 2026-08-31 JST  
**Working product name:** **Subtext**  
**Working tagline:** **Google Translate for things people did not want to say directly.**  
**Alternate brand treatment:** **Closure as a Service™**

This document is a product and architecture proposal created from Owen's ChatGPT conversation. It authorizes this handoff branch and document only. It does not, by itself, authorize creating a separate repository, purchasing a domain, enabling paid inference, or deploying a public site.

## Provenance

Owen proposed a funny, potentially viral website that translates common rejection euphemisms into their supposed blunt meaning, for example:

> “I'm not looking for a relationship right now.”  
> → “I'm not looking for a relationship **with you** right now.”

He then expanded the idea into a two-way translator:

1. **Polite rejection → blunt subtext**
2. **Blunt thought → socially acceptable rejection**

The desired product should:

- feel as immediate and familiar as Google Translate;
- look excessively clean and credible, possibly like a polished SaaS product;
- be funny enough to screenshot and share;
- avoid an open-ended runtime AI bill if it becomes viral;
- preferably work as a static site with no server or database;
- use Agent Continuity documents so future coding agents can resume cleanly.

## Product thesis

The joke is not that the website can read minds. The joke is that it behaves like a highly confident professional translation product while returning the interpretation a brutally honest friend or group chat would give.

The strongest framing is:

> **Not what they definitely meant. What your group chat thinks they meant.**

This framing matters. It preserves the humour without pretending that every polite rejection is a lie or that human motives can be inferred with certainty.

## Core recommendation

**Do not use a runtime LLM for version one.**

Use a curated library of canonical rejection intents, many paraphrases for each intent, a deterministic client-side matcher, and hand-written output variants. AI may be used **offline during development** to generate candidate paraphrases and joke variants, but only reviewed, versioned content is shipped to users.

This gives the product:

- zero inference cost per translation;
- deterministic, repeatable jokes;
- stable share links and screenshots;
- no latency or cold starts;
- no API key or abuse surface;
- no need to send emotionally private pasted text to a third party;
- much tighter editorial control than free-form generation.

A literal hash table containing every possible English sentence is not realistic. A hash table containing **normalized known paraphrases mapped to a small set of canonical meanings**, followed by lightweight fuzzy matching, is realistic and is likely sufficient for the common-phrase-driven joke.

## Why two-way translation is stronger

### Direction A — Euphemism to subtext

The user pastes something they received:

> “I think we are better as friends.”

The site returns:

> “Your romantic application has been closed, but limited spectator access remains available.”

This direction provides recognition, catharsis, and highly shareable results.

### Direction B — Subtext to euphemism

The user types what they actually want to say:

> “I do not find you attractive.”

The site returns:

> “I did not feel the romantic connection I am looking for.”

This direction adds a creative generator and a small amount of genuine utility. It also makes the translator metaphor much clearer: the two “languages” are **Polite** and **Blunt**.

Neither direction should be implemented as a simple reverse lookup of one sentence. Both inputs resolve to a shared canonical concept, then an output renderer chooses an appropriate curated line for the selected direction and tone.

## Product surface

### Main screen

Use a two-panel translation layout.

```text
┌──────────────────────────────────────────────────────────────────┐
│ SUBTEXT                                      Closure as a Service │
│ Translate from what they said to what your group chat heard.     │
├───────────────────────────────┬──────────────────────────────────┤
│ POLITE REJECTION              │ BLUNT SUBTEXT                    │
│                               │                                  │
│ I'm not looking for a         │ I'm not looking for a            │
│ relationship right now.       │ relationship WITH YOU right now. │
│                               │                                  │
│                               │ Confidence: emotionally 97%      │
├───────────────────────────────┴──────────────────────────────────┤
│      Honest      Brutal      Delusional      Corporate           │
│                                                                  │
│  [Copy]  [Share the damage]  [Translate another lie]             │
└──────────────────────────────────────────────────────────────────┘
```

A central swap button changes:

```text
Polite rejection ⇄ Blunt thought
```

### Recommended labels and copy

**Brand:** `SUBTEXT`  
**Descriptor:** `Closure as a Service™`  
**Hero:** `Translate from what they said to what they probably meant.`  
**Safer joke disclaimer:** `Not mind reading. Just rude pattern recognition.`  
**Result eyebrow:** `UNOFFICIAL TRANSLATION`  
**Confidence joke:** `Confidence: 94% based on the group chat`  
**Primary action:** `Translate the cope`  
**Reset action:** `Translate another lie`  
**Share action:** `Share the damage`  
**Unknown-input message:** `Our emotional-damage database has not seen this exact wording yet.`  
**Footer:** `Satire. People are complicated. Your situationship may be worse.`

### Tone modes

The language direction and tone are separate controls.

- **Honest:** clear subtext without trying to be cruel.
- **Brutal:** punchier, screenshot-friendly comedy.
- **Delusional:** absurdly optimistic interpretation.
- **Corporate:** treats dating as recruiting, procurement, or account management.
- **Therapist-approved:** emotionally mature wording that gently ruins the joke.

Version one only needs Honest, Brutal, and Delusional. Corporate is a strong launch-day bonus because it connects naturally to the LinkedIn-translator inspiration.

## Seed translations

### Polite → blunt

| Input | Honest | Brutal / shareable |
|---|---|---|
| I'm not looking for a relationship right now. | I'm not looking for a relationship with you. | Relationship availability may change without notice when a preferred candidate appears. |
| I think we are better as friends. | I do not want a romantic relationship with you. | Your romantic application has been closed. Limited spectator access remains available. |
| I did not feel a spark. | I am not romantically attracted to you. | You passed the technical interview but failed the chemistry round. |
| I am really busy at the moment. | Dating you is not a priority for me. | You are currently ranked below scrolling in bed. |
| I need to focus on myself. | I do not want to continue this relationship. | I am focusing on myself and any unexpectedly attractive applicants. |
| You deserve someone better. | I want to leave without arguing about the real reason. | Specifically, someone other than me. |
| It is not you, it is me. | I do not want to explain why it is you. | It is you, but this meeting has no Q&A section. |
| Let us see where things go. | I want the benefits of ambiguity without commitment. | Your subscription remains on the free trial. |
| I did not see your message. | I saw it but did not prioritise replying. | I saw enough of it to assign the task to Future Me. |
| We should definitely hang out sometime. | I want to end this conversation warmly without making a plan. | “Sometime” has been scheduled for the 32nd of Never. |
| I am just not ready to date. | I am not willing to date you. | Readiness may be restored instantly by a sufficiently hot person. |
| I do not want to ruin our friendship. | I value the friendship more than the romantic possibility. | The friendship has production data. The romance is an unapproved experiment. |

### Blunt → polite

| Input | Polite translation |
|---|---|
| I do not find you attractive. | I did not feel the romantic connection I am looking for. |
| You are boring. | I do not think our personalities clicked in the way I had hoped. |
| You are too poor for the lifestyle I want. | I think we are at different stages in life and may want different futures. |
| I found someone I like more. | I need to be honest that my feelings have shifted and I do not want to lead you on. |
| I want sex, not commitment. | I am not looking for anything serious right now. |
| You are too clingy for me. | I think I need more space than this dynamic allows. |
| I like the attention but do not want you. | I enjoy spending time together, but I cannot offer the kind of relationship you want. |
| I want to keep you as a backup. | I am not ready to put a label on this and would rather see where things go. |
| I do not want to date you, but I do not want to look mean. | You seem lovely, but I do not think we are the right romantic fit. |

These are seed jokes, not immutable final copy. Content quality is the product and should receive human editorial review.

## Canonical concept model

Do not model the corpus as independent sentence pairs. Model it around stable meanings.

Example source record:

```json
{
  "id": "dating.not_attracted",
  "category": "dating",
  "label": "No romantic attraction",
  "description": "The speaker does not feel sufficient romantic or physical attraction.",
  "aliases": {
    "polite": [
      "I did not feel a spark",
      "I did not feel the chemistry",
      "I did not feel a romantic connection",
      "I do not think the vibe was there",
      "Something was missing for me"
    ],
    "blunt": [
      "I am not attracted to you",
      "You are not my type",
      "I do not find you attractive"
    ]
  },
  "keywords": [
    "spark",
    "chemistry",
    "connection",
    "attracted",
    "type",
    "vibe"
  ],
  "outputs": {
    "to_blunt": {
      "honest": [
        "I am not romantically attracted to you."
      ],
      "brutal": [
        "You passed the technical interview but failed the chemistry round.",
        "The résumé was acceptable. The face-to-face stage was not."
      ],
      "delusional": [
        "The spark is delayed due to scheduled maintenance. Try again in six months."
      ],
      "corporate": [
        "Your application met several requirements but did not progress past the chemistry screen."
      ]
    },
    "to_polite": {
      "neutral": [
        "I did not feel the romantic connection I am looking for.",
        "I enjoyed meeting you, but I do not think the chemistry is there for me."
      ]
    }
  },
  "notes": "Satirical interpretations must not be presented as factual mind reading."
}
```

Recommended initial concept IDs include:

```text
dating.not_attracted
dating.friends_only
dating.not_with_you
dating.low_priority_busy
dating.focus_on_self
dating.emotionally_unavailable
dating.wants_casual_only
dating.wants_ambiguity
dating.found_someone_else
dating.unresolved_ex
dating.incompatible_personalities
dating.different_lifestyles
dating.different_finances
dating.different_ambition
dating.too_intense
dating.needs_space
dating.distance
dating.family_or_cultural_mismatch
dating.slow_fade
dating.ghosting
dating.no_second_date
dating.polite_conversation_exit
dating.does_not_want_to_explain
dating.likes_attention_not_commitment
dating.keeps_as_backup
```

## Matching architecture

### Runtime data flow

```text
user input
  ↓
normalization
  ↓
exact alias map
  ↓ no exact match
pattern and containment rules
  ↓ no confident match
fuzzy candidate scoring
  ↓
canonical concept + confidence + alternatives
  ↓
deterministic output renderer
  ↓
result, explanation, and share state
```

### 1. Normalization

Normalize both corpus aliases and user input using exactly the same pure function:

1. Unicode NFKC normalization.
2. Lowercase.
3. Convert smart apostrophes and dashes to simple forms.
4. Normalize whitespace.
5. Remove punctuation that does not affect meaning.
6. Canonicalize common contractions and chat spelling:
   - `i'm`, `im`, `i am`
   - `don't`, `dont`, `do not`
   - `can't`, `cant`, `cannot`
   - `rn`, `right now`
   - `wanna`, `want to`
7. Canonicalize safe synonyms for matching only:
   - `spark`, `chemistry`, `romantic connection`
   - `busy`, `a lot going on`, `no time`
   - `friends`, `friendship`, `platonic`
8. Optionally remove low-information filler such as `honestly`, `really`, and `just`, while retaining phrases whose timing changes the joke.

Example:

```text
“Honestly, I’m just not looking for anything serious rn 😭”
→ “i am not looking for anything serious right now”
```

### 2. Exact alias map

At build time, compile all reviewed aliases into:

```ts
Map<NormalizedPhrase, AliasTarget[]>
```

An alias target should contain:

```ts
type AliasTarget = {
  conceptId: string;
  register: "polite" | "blunt";
  weight: number;
};
```

Most common inputs should resolve here in effectively constant time. Multiple targets are allowed when a phrase is genuinely ambiguous, but collisions must be reported by the content validator rather than silently overwritten.

### 3. Pattern rules

A small rule layer handles common compositional variations without enumerating every sentence.

Examples:

```text
I [really|just|honestly] do not think I am ready for [a relationship|anything serious]
I would rather [stay|just be|remain] friends
I have [a lot|too much] going on [right now|at the moment]
```

These should be transparent data-driven token patterns, not an unmaintainable pile of ad hoc regular expressions.

### 4. Fuzzy matching

For unmatched input, score reviewed aliases using a weighted combination of:

- token overlap;
- character trigram similarity;
- important-keyword coverage;
- phrase containment;
- edit distance for short chat-style misspellings;
- penalties for contradictory or missing high-information tokens.

Version one can scan a few thousand aliases in the browser after a short debounce. A precomputed token/trigram inverted index can be added only if profiling shows it is needed.

Recommended confidence behaviour:

```text
high confidence      → translate immediately
medium confidence    → show “Did you mean…?” with the top three concepts
low confidence       → show a funny unknown-state and example phrases
```

Do not invent a false exact interpretation when the top two concepts are close. The ambiguity itself can be part of the joke.

### 5. Deterministic output choice

Do not call `Math.random()` every time the page renders. Hash the stable translation state:

```text
normalized input + concept ID + direction + tone + content version
```

Use that hash to select an output variant. The same input and URL should produce the same joke until the content version deliberately changes.

This makes screenshots reproducible and lets shared links reopen the same result.

## Static build architecture

### Recommended stack

- Vite
- TypeScript
- React, because it is already familiar to Owen and introduces no server requirement
- Zod or JSON Schema for content validation
- Vitest for matcher and corpus tests
- Playwright for a small number of end-to-end and responsive checks
- Plain CSS or CSS Modules; avoid adopting a large design system for one screen

Do not use Next.js or another server-oriented framework for version one. The entire application should compile to static assets.

### Proposed repository

After explicit execution approval, create a new standalone repository, tentatively:

```text
owensantoso/rejection-translator
```

Potential public-facing names can remain separate from the repository slug:

- Subtext
- Closure as a Service
- What They Meant
- Read Between the Lies
- WithYou™

### Proposed repository shape

```text
rejection-translator/
├── README.md
├── AGENTS.md
├── ARCHITECTURE.md
├── CURRENT_STATE.md
├── package.json
├── vite.config.ts
├── src/
│   ├── app/
│   │   ├── App.tsx
│   │   ├── Translator.tsx
│   │   ├── TonePicker.tsx
│   │   ├── ShareActions.tsx
│   │   └── ResultExplanation.tsx
│   ├── matcher/
│   │   ├── normalize.ts
│   │   ├── exact.ts
│   │   ├── patterns.ts
│   │   ├── fuzzy.ts
│   │   ├── confidence.ts
│   │   └── translate.ts
│   ├── rendering/
│   │   ├── deterministicVariant.ts
│   │   └── shareCard.ts
│   ├── content/
│   │   ├── concepts/
│   │   │   ├── not-attracted.json
│   │   │   ├── friends-only.json
│   │   │   └── ...
│   │   ├── schema.ts
│   │   └── compiled-index.generated.json
│   ├── privacy/
│   │   └── shareState.ts
│   └── styles/
│       └── app.css
├── scripts/
│   ├── compile-content.ts
│   ├── validate-content.ts
│   ├── report-collisions.ts
│   └── content-lab/
│       ├── generate-paraphrase-candidates.ts
│       ├── generate-joke-candidates.ts
│       └── README.md
├── tests/
│   ├── normalize.test.ts
│   ├── exact.test.ts
│   ├── fuzzy-golden.test.ts
│   ├── deterministic-output.test.ts
│   ├── content-validation.test.ts
│   └── no-runtime-network.spec.ts
└── public/
    └── social-preview.png
```

The `content-lab` scripts are developer-only. They may call an LLM when credentials are explicitly configured, but they must write candidates to a review queue. They must never modify approved production content automatically.

## Offline AI content factory

AI is useful here, just not in the user request path.

A content-development loop can be:

1. A human writes a canonical concept and five trusted seed phrases.
2. An offline script asks a cheap model for many paraphrase candidates.
3. Normalize and automatically deduplicate candidates.
4. Flag aliases that collide with another concept.
5. A human accepts, edits, or rejects each candidate.
6. Commit only reviewed aliases and output variants.
7. The static build compiles them into the runtime index.

This achieves most of the linguistic coverage benefit of an LLM while paying only during content creation. It also lets ChatGPT, Codex, or another model help expand the corpus without being part of production infrastructure.

## Optional runtime AI fallback

A runtime fallback should be considered only after launch data or deliberate testing shows that the deterministic matcher fails too often.

If added, it must be:

- disabled by default during the first public launch;
- invoked only below the local match threshold;
- behind a server-side Worker so no provider key reaches the browser;
- rate-limited by IP/session and protected against automated abuse;
- constrained to classify into existing canonical concepts first;
- allowed to generate free text only as a secondary, clearly marked experiment;
- protected by a hard daily request or spend ceiling;
- cached by normalized input hash where privacy policy permits;
- designed to fail closed to the static experience when the budget is exhausted.

### Cost snapshot as of 2026-08-31

Official prices checked while preparing this handoff:

| Option | Published unit price | Example at 150 input + 40 output tokens |
|---|---:|---:|
| No runtime model | $0 | $0 per translation |
| Cloudflare Workers AI — `@cf/ibm-granite/granite-4.0-h-micro` | $0.017/M input, $0.11/M output | about $0.00000695 each, or about $0.70 per 100,000 calls |
| Gemini 2.5 Flash-Lite standard | $0.10/M input, $0.40/M output | about $0.000031 each, or about $3.10 per 100,000 calls |

Cloudflare Workers AI also advertises 10,000 Neurons per day at no charge and charges $0.011 per 1,000 Neurons above that allocation on Workers Paid. Actual billed usage depends on the chosen model and token counts.

Official sources:

- https://developers.cloudflare.com/workers-ai/platform/pricing/
- https://developers.cloudflare.com/workers-ai/models/granite-4.0-h-micro/
- https://ai.google.dev/gemini-api/docs/pricing

Among the hosted models checked for this handoff, the Cloudflare Granite micro model has the lowest published token-equivalent price. That is not a claim that it is the cheapest model offered by every provider in the world, nor that it will produce the best jokes. It should be quality-tested against the classification task before adoption.

The absolute cheapest runtime inference remains **no hosted inference**. A tiny model could technically run in the visitor's browser with no server-side inference bill, but the model download, mobile performance, first-load latency, and inconsistent device support are bad trade-offs for a fast viral joke site.

## Hosting and ongoing cost

Deploy the static build without any Pages Functions.

Cloudflare Pages currently states that requests to static assets are free and unlimited on both free and paid plans. The Free plan also currently permits 500 builds per month and up to 20,000 site files, far beyond this project's expected needs.

Official sources:

- https://developers.cloudflare.com/pages/functions/pricing/
- https://developers.cloudflare.com/pages/platform/limits/

Therefore the initial variable architecture is:

```text
browser → CDN-hosted HTML/CSS/JS/JSON → browser
```

No database, server function, API, queue, or object storage is required.

A custom domain may still have an annual registration cost. That should be the only necessary recurring expense for the static launch unless optional analytics or AI fallback is deliberately enabled.

## Privacy model

The privacy story is a product advantage:

> **Your rejection stays between you and your browser. Unfortunately, the emotional damage does too.**

Requirements:

1. User-entered text remains in browser memory by default.
2. Do not transmit raw translation inputs to analytics.
3. Do not store input in `localStorage` unless the user explicitly saves history.
4. Shared URLs should prefer canonical concept IDs, direction, tone, and deterministic variant IDs rather than raw private messages.
5. If a user explicitly asks to include their original text in a share card, make that choice visible before generating it.
6. Do not let query strings containing raw input leak into page-view analytics or referrer headers.
7. The no-runtime-network Playwright test should fail if translation causes an unexpected request.

## Sharing and viral loop

The site needs to produce an artefact, not merely a result.

### Version-one sharing

- Copy result text.
- Copy a stable deep link to a canonical result.
- Use `navigator.share` where available.
- Generate a polished image locally using Canvas or SVG.
- Include the brand, source phrase, translated phrase, direction, and tone.
- Keep the share card legible in messaging apps and vertical social screenshots.

### Suggested card copy

```text
SUBTEXT
Unofficial translation

“I’m just not ready to date.”

→

“Readiness may be restored instantly by a sufficiently hot person.”

Confidence: 96% based on the group chat
subtext.example
```

### Useful viral mechanics after the core works

- Random famous rejection button.
- “Make it more brutal” escalation button.
- Delusional interpretation button.
- Daily featured translation with a stable URL.
- User-submitted phrase queue, reviewed before publication.
- Dating, job rejection, friendship, recruiter, and corporate packs.
- “Translate this screenshot” only as a later opt-in feature; it would introduce OCR, privacy, and possibly model costs.

Do not build accounts, comments, feeds, or a social network. The shareable card is the distribution mechanism.

## Content boundaries

The product can be sharp without becoming an unrestricted insult generator.

- Satire should target awkward social dynamics, avoidance, ambiguity, ego, dating rituals, and corporate language.
- The app may translate user-entered blunt phrases such as “I am not attracted to you,” but should not escalate them into slurs, threats, harassment, or attacks on protected characteristics.
- Do not claim that a translation is the other person's verified motive.
- Avoid generating diagnoses or pretending to assess mental illness.
- Keep the primary result funny; place the grounding disclaimer in the interface without turning the entire product into a lecture.

## Quality and validation rules

### Corpus checks

The build must fail on:

- duplicate concept IDs;
- invalid direction or tone names;
- an approved alias that normalizes to an empty string;
- an exact alias collision that lacks an explicit ambiguity declaration;
- a concept with no polite or blunt aliases;
- a concept with no output for a required launch mode;
- duplicate outputs after normalization;
- generated content accidentally committed to the approved directory without review metadata.

### Matcher tests

Maintain a golden dataset containing:

- exact common phrases;
- punctuation and capitalisation variants;
- common contractions and chat spelling;
- small typos;
- paraphrases expected to fuzzy-match;
- deliberately ambiguous inputs;
- unrelated inputs that must remain unknown.

Each golden case should assert the expected canonical concept, accepted confidence range, and direction.

### Product invariants

- Translation works with JavaScript only in the browser and no server API.
- The same stable state produces the same output variant.
- Unknown inputs never silently become a confidently wrong translation.
- Swapping direction retains the underlying canonical concept when appropriate.
- No user message is transmitted as part of ordinary translation.
- The interface remains usable on a narrow mobile viewport.

## Delivery plan

### Slice 0 — content and joke validation

Build a static visual prototype with about twelve canonical concepts and the seed jokes in this handoff.

Acceptance gate:

- Owen confirms the visual tone, brand direction, and whether the funniest primary interaction is Polite → Blunt, Blunt → Polite, or both equally prominent.
- At least ten people can understand the premise without an explanation.
- Several results are genuinely screenshot-worthy.

### Slice 1 — zero-runtime-cost MVP

Implement:

- two-panel translator;
- direction swap;
- Honest, Brutal, and Delusional modes;
- normalization;
- exact alias lookup;
- lightweight fuzzy matching;
- medium-confidence suggestions;
- deterministic result variants;
- at least twenty-five canonical dating concepts;
- at least 300 reviewed aliases total;
- at least three reviewed outputs per required concept/mode where relevant;
- share text and stable links;
- locally generated share card;
- responsive and keyboard-accessible UI;
- static deployment configuration;
- no runtime network dependency.

### Slice 2 — corpus tooling and launch polish

Implement:

- offline paraphrase candidate generator;
- candidate review queue;
- duplicate/collision reporting;
- content coverage dashboard;
- random examples;
- social preview metadata;
- privacy-safe page-view analytics only if desired;
- dating-copy editorial pass;
- job/recruiter pack design, but not necessarily full implementation.

### Slice 3 — evidence-based fallback decision

Before adding runtime AI, deliberately test a corpus of unseen phrases and measure:

- exact-match rate;
- fuzzy correct-match rate;
- ambiguous rate;
- unknown rate;
- human-rated joke quality;
- false-confidence rate.

Only add a hosted fallback when the remaining unknown rate materially harms the experience and cannot be fixed cheaply by expanding reviewed aliases.

## Explicit non-goals for the first version

- General-purpose natural-language understanding.
- A claim to know what another person truly thought.
- User accounts.
- Server database.
- Message history sync.
- Screenshot OCR.
- Real-time community submissions.
- Automatically publishing AI-generated jokes.
- Supporting every language.
- Building all dating, friendship, recruiting, and corporate packs at once.
- Monetisation, subscriptions, or a real SaaS dashboard.

The SaaS styling is the joke. The product itself should remain a tiny static website.

## Definition of done for the first implementation pass

- [ ] A new standalone repository exists only after Owen explicitly approves execution.
- [ ] `AGENTS.md`, `ARCHITECTURE.md`, and `CURRENT_STATE.md` explain the no-runtime-AI invariant.
- [ ] The app builds into static files and runs without a backend.
- [ ] Both translation directions work.
- [ ] Honest, Brutal, and Delusional modes work.
- [ ] The seed corpus is represented as canonical concepts rather than unrelated sentence pairs.
- [ ] Exact aliases are compiled into a normalized lookup map.
- [ ] Fuzzy matching handles representative paraphrases and typos.
- [ ] Ambiguous and unknown inputs have deliberate UI states.
- [ ] Output selection is deterministic.
- [ ] Share text, a stable result URL, and a local image card work.
- [ ] Tests verify normalization, content integrity, golden matching, deterministic output, and no runtime translation requests.
- [ ] The interface is polished on phone and desktop.
- [ ] No provider key, runtime LLM call, database, or paid service is required.
- [ ] `CURRENT_STATE.md` names the next human acceptance gate rather than claiming unreviewed jokes are final.

## Recommended next human acceptance gate

Owen should review:

1. Working name: **Subtext** versus **Closure as a Service**.
2. The balance between “brutally funny” and “obviously satire.”
3. Whether Corporate mode belongs in the launch MVP.
4. The first twelve canonical concepts and outputs.
5. The visual direction: near-literal Google Translate parody versus original clean SaaS styling.
6. Whether the first separate repository should be public from creation or remain private until the initial content pass is strong.

## Copy-paste Codex execution prompt

```text
Read docs/handoffs/rejection-translator-2026-08-31.md on branch handoff/rejection-translator-2026-08-31 in owensantoso/agent-continuity. Treat it as a product and architecture proposal from ChatGPT, not proof that every visual or copy decision has been personally approved by Owen.

Implement only Slice 0 and Slice 1 after explicit repository-creation approval. Create a small static Vite + TypeScript + React site in a new standalone repository. Do not use Next.js, a database, server functions, user accounts, or runtime AI. The core invariant is that translation occurs entirely in the browser from reviewed canonical concepts, aliases, matching rules, and curated outputs.

Model content around canonical meanings shared by both directions. Implement one normalization function, a compiled exact alias map, transparent pattern rules, lightweight fuzzy matching, deliberate ambiguous/unknown states, and deterministic output selection. Seed the app with the handoff's dating examples, then expand to at least 25 concepts and 300 reviewed aliases without automatically publishing unreviewed model output.

Build the two-panel Polite Rejection ↔ Blunt Subtext interface with Honest, Brutal, and Delusional modes, stable share links, copy actions, and a locally generated share card. Preserve privacy: ordinary translation must send no user input over the network, and tests must enforce that invariant.

Add AGENTS.md, ARCHITECTURE.md, CURRENT_STATE.md, content schemas, corpus validation, golden matcher tests, deterministic-output tests, and a no-runtime-network Playwright test. Keep the visual style extremely clean and credible; the contrast between professional translation software and emotionally unserious output is central to the joke.

Run all tests and the production build. Report exact commands, results, limitations, and the next human acceptance gate in CURRENT_STATE.md. Do not deploy publicly, purchase a domain, or enable any paid model without separate approval.
```
