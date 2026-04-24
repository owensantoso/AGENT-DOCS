---
type: feature-spec
id: SPEC-<id>
domain: product
status: draft
created_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
updated_at: "YYYY-MM-DD HH:MM:SS TZ +0000"
owner:
areas: []
related_research: []
related_adrs: []
related_plans: []
related_issues: []
related_sessions: []
---

# <Feature Name> Spec

Use this for product or system requirements. A feature spec explains what should exist and why. It is not an implementation plan.

## Summary

<one paragraph on the feature and user value>

## Problem

- <problem>
- <problem>

## Goals

- <goal>
- <goal>
- <goal>

## Non-goals

- <non-goal>
- <non-goal>

## Users / Actors

- <actor>
- <actor>

## User Stories

- As a <actor>, I want <capability>, so that <benefit>.
- As a <actor>, I want <capability>, so that <benefit>.

Cover the important behavior and edge cases. Do not create a huge user-story list just to look exhaustive.

## User Experience

### Entry points

- <entry point>
- <entry point>

### Primary flow

1. <step>
2. <step>
3. <step>

### Edge behavior

- <edge case>
- <fallback or failure behavior>

## Product decisions

- <locked-in decision>
- <locked-in decision>

## Requirements

- <functional requirement>
- <functional requirement>
- <non-functional requirement if relevant>

## Open questions

- <question that still needs product or architectural resolution>

## Architecture / Data Implications

- <new seam>
- <changed seam>
- <related `AREA-*` doc, if the repo uses architecture areas>

## Test Expectations

- <externally visible behavior that should be tested>
- <module, seam, or flow that should have coverage>
- <prior art for similar tests, if known>

## Validation

- <what must be checked before implementation is considered correct>

## Out Of Scope

- <explicit non-goal>
- <explicit non-goal>

## Paper Trail

| Type | Link / Value | Role |
|---|---|---|
| Research |  | supporting uncertainty or findings |
| ADR |  | durable decision |
| Plan |  | build strategy, when created |
| Issue |  | tracking container, when created |
| Session |  | work receipt |

The spec owns product truth. Plans own execution strategy. Issues own tracking.
