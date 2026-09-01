# Session Log Creation Example

Do not copy this file to create a session log and do not generate a document ID
separately. Run:

```bash
agent-continuity docs new session "Session title" --domain repo-health
```

The command writes `repo-health/session-logs/YYYY-MM-DD-session-title.md` with:

- document format v2;
- an RFC 9562 UUID version 7 (UUIDv7) canonical `id`;
- `aliases: []`;
- `status: in_progress` by default;
- exact local creation, update, start, and timezone values; and
- the standard Goal, Timeline, Context read, Changes, Decisions, Verification,
  and Follow-ups sections.

Use `--status completed` only when creating a receipt for work that is already
finished; the command will populate `ended_at`. Update a live session log to
`completed` at closeout through the normal structured-document lifecycle.
