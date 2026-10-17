Hi,

Quick update on where things stand.

## What's done

All five of the "do not ship" checks from our last audit are now closed:

1. **Signup-link spam guard** — the little bridge that lets our greeter bot hand someone a signup link is now rate-limited. If anything tries to hammer it, it gets turned away after a few tries instead of being able to flood us with fake signups.

2. **Welcome-menu lock-down** — the admin screen that edits the welcome menu now has proper tests proving that only a master admin can change it, that a regular signed-in user can't touch it, and that editing it never accidentally creates a second copy.

3. **Quiet-failure visibility** — when the assistant's first-time greeting can't load (bad setting, or the main site is down), it now writes a clear note to the log. Before, it just silently went quiet, which made it hard to tell what was wrong.

4. **Choice-picks-up-where-you-left-off** — when a visitor says "yes I'll use AI" or "no thanks" and then signs up, that choice now carries over to their new account. Tests confirm it sticks and that someone can't overwrite it later by accident.

5. **Test-database setup** — the earlier migration that was skipped in the test environment is now applied, so the tests run against a real, current database.

Everything also got committed and pushed to the three repos (main site, the greeter bot, and the assistant).

## What's tested and green

- 47 tests, 178 checks, zero failures.
- The greeter bot and the assistant both compile with no type errors.
- Live checks confirmed: a brand-new visitor gets their 600,000 free tokens, and a bad/guessed ID is correctly rejected.
- The greeter's "staff wall" (the one-time nudge to sign up) now only shows once per conversation instead of stacking up.

## What's still open / worth knowing

- **Security scanners are noisy.** GitHub's automated dependency check is flagging a long list of old packages on the default branch (mostly in the main site's front-end toolchain). These are pre-existing, not from our recent work, but worth scheduling a cleanup pass so they stop drowning out real alerts.
- **Your two OpenRouter keys** are still configured as you sent them. Nothing has changed there.
- **The "threads" system you described** (handoff prompts, the post-reference/cross-reference work, the bot council) hasn't been started yet — it's the next big piece whenever you're ready to kick it off.

Let me know if you want me to start on the threads system, or if you'd rather we tackle the dependency cleanup first.

Best,
Adnan

---

## Update while you were away (17 October)

Closed the remaining gaps from our last conversation. One letter, seven items:

1. **Florence's first-time greeting** — "FlorenceFirstTime" is now a real prompt type on the main site, seeded by a migration, and the greeter bot fetches it when a visitor arrives with `firsttime=true` (falling back to the old text if the site can't be reached, with a log note). Rails picks the flag up automatically — no template change needed.

2. **Welcome-menu buttons are editable** — "I hate AI" and "I'll use it if it's for a good cause" are no longer hard-coded. Two new columns (defaults keep the current wording), editable in the admin dashboard, shown on the overlay through the same helpers. Existing menus render unchanged until someone edits them.

3. **Adele can create tasks from an email** — the public email page now has a "Create task" button: it prefills the title from the subject and the description from the email body, lets you pick the group and hours, and posts straight to the main site's task API through a small server-side proxy (the token never reaches the browser).

4. **Thread-system starter kit** — `thread-system/` in this repo: the working `threads.py` tool (edition N45b) plus a README covering setup, the three-post layout, the everyday commands, and the anti-URL-caching tricks. Smoke-tested end to end: setup → update → show → clear → archive, duplicate-refusal included. The bot-council piece is deliberately left out, as discussed.

5. **Inbound federation is safe to switch on** — the inbox signature check was broken in a way that always passed (exceptions swallowed, result ignored, wrong request interface, wrong key format). It now fails closed: signer must be the activity's actor, RSA signature verified against the actor's published key, Date within an hour, Digest must match the body, missing/garbage signatures get 401. Seven new tests cover accept and every rejection path. Outbound federation stays switched off until we decide to enable it.

6. **Seed package: Nexus now starts** — both Docker settings files use `NEXUS_DIR` and `HOME` instead of the original author's desktop paths (`docker compose config` validates). The missing `rebuild/` instructions are written: an index plus a full Nexus guide, and START-HERE/MISSING now point at them.

7. **Backups are documented as *not built*** — no backup system exists anywhere in the seed. This is written down in `rebuild/README.md` with a minimal suggested starting point (host snapshots + scheduled `pg_dump`), so nobody assumes it's covered.

### Verified
- Main site: 130 tests, 371 checks. All failures (5F/14E) are the same pre-existing scaffold tests that fail on a clean checkout — confirmed by stashing our changes and re-running. Every test touching our work passes, including the 7 new federation tests.
- Greeter: TypeScript compiles clean.
- vc-email: typecheck clean, lint 0 errors (2 pre-existing warnings), 8/8 tests pass.

### Permissions needed from you
- **Push approval**: everything is committed locally in all four repos (main site, greeter, vc-email, seed). Nothing was pushed — say the word and I'll push, or tell me which repos.
- No other blockers: no keys, tokens or server access were required.

Adnan
