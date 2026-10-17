# Thread System — Starter Kit

Plain-file memory system for AI assistants, so any AI (any company) can pick
up where the last session left off. Designed by Anthony Brasher; the full
specification lives in the seed repo under
`needpedia-seed/documents/thread-system/`.

This kit contains:

- `threads.py` — the working tool (edition N45b, 29 Sep 2026). Creates and
  maintains each thread's three public posts, enforces tags, refuses
  duplicates, and never deletes anything.
- This README — how to set it up and how the pieces fit together.

## Concepts (from the spec, in short)

| Piece | What it is |
|---|---|
| **Thread** | One ongoing area of work carried across many AI sessions (job search, website, phone app…). |
| **Handoff prompt** | Short note written at the *end* of a session to start the next one. Never published — may hold private info. |
| **Prompt accomplice (PA)** | Each thread's public notebook: rules, decisions, findings, loose ends. Append-only, no private data. |
| **Botskill posts** | Public posts telling an AI how to work with a specific user. |
| **Updates / Cross-reference** | How threads message each other: unread requests vs. read-only history. |
| **Archive** | Everything old, dated and tagged. Nothing is ever thrown away. |

Each thread has exactly three public posts:

```
UPDATES-NAME.md      news/requests from other threads, not yet read
CROSSREF-NAME.md     history from other threads, no action needed
ARCHIVE-NAME.md      everything archived, dated and tagged
```

## Setup

```sh
# 1. Put the tool somewhere private (it is also safe to run from a repo clone)
cp thread-system/threads.py ~/Threads_private/threads.py

# 2. Create your public post folder (served or copied to your web root)
mkdir -p ~/Needpedia_Nexus/public

# 3. Make a thread's three posts
python3 ~/Threads_private/threads.py setup JOBS
```

Defaults: public posts in `~/Needpedia_Nexus/public`, private backups in
`~/Threads_private/backups`. Override with `THREADS_PUBLIC` and
`THREADS_BACKUPS` (that's how the tests below run without touching either).

## Everyday commands

```sh
python3 threads.py show    JOBS                 # print unread updates
python3 threads.py update  JOBS file.md         # another thread sends a request
python3 threads.py note    JOBS file.md         # another thread leaves history
python3 threads.py clear   JOBS                 # archive everything read
python3 threads.py archive JOBS POST file.md    # archive any file (SOURCE TAGS…)
```

Rules the tool enforces for you:

- Every update/note file starts with a `tags: a, b, c` line. No tags, no add.
- Duplicate text is refused (updates also check the archive).
- Cross-reference posts trim to 30 entries; the oldest 20 move to the archive
  (backed up first, verified, then trimmed).
- Nothing is ever deleted. `setup` leaves existing posts alone.

## Fighting AI URL caching

Four tricks from the spec, in order of convenience:

1. **`Cache-Control: no-cache`** on the served posts — many tools respect it.
2. **Fresh query tag** — append `?s=JOBS45` when handing a URL to the AI so
   it fetches a "new" page.
3. **One address per post, always newest edition** — archive the old copy,
   publish the new one at the same URL, so saved links never break.
4. **Paste fallback** — if the AI can't fetch, print the file in the terminal
   and paste it into the chat.

## Smoke test (no setup required)

```sh
export THREADS_PUBLIC=/tmp/ts-public THREADS_BACKUPS=/tmp/ts-backups
mkdir -p "$THREADS_PUBLIC" "$THREADS_BACKUPS"
printf 'tags: smoke\nhello\n' > /tmp/u.md
python3 threads.py setup SMOKE
python3 threads.py update SMOKE /tmp/u.md
python3 threads.py show SMOKE
python3 threads.py clear SMOKE
```

Expected: three posts created, `hello` added and shown as unread, then
archived on clear. Re-adding the same file must print
`STOPPING, nothing changed` — that's the duplicate guard working.

## Not in this kit (yet)

- **Bot council** — AIs IM-ing each other directly. Explicitly deferred; the
  spec warns a bad setup makes you wait on three AIs per keystroke. The
  updates/cross-reference files are the v1 message bus.
- **Handoff-prompt generator** — handoff prompts stay private files on the
  user's machine; the AI writes one at session end per the spec.
- **Search log** — a per-thread `SEARCHLOG` post; same pattern as UPDATES if
  needed later.
