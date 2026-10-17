# <<<<<<< threads.py, edition N45b, 29 September 2026 >>>>>>>
# One tool for every thread's posts on the Nexus.
#
# Every thread has three public posts in ~/Needpedia_Nexus/public/:
#   UPDATES-NAME.md    news and requests it has not read yet
#   CROSSREF-NAME.md   history from other threads, no action needed
#   ARCHIVE-NAME.md    everything archived, dated and tagged: read
#                      updates, older cross-reference entries, old
#                      editions of public documents, and reference
#                      entries pointing at private backups
#
# The jobs, each one short terminal command:
#   python3 ~/Threads_private/threads.py setup   NAME         make the three posts if missing
#   python3 ~/Threads_private/threads.py show    NAME         print unread updates (from disk)
#   python3 ~/Threads_private/threads.py update  NAME FILE    add FILE to NAME's updates post
#   python3 ~/Threads_private/threads.py note    NAME FILE    add FILE to NAME's cross-reference post
#   python3 ~/Threads_private/threads.py clear   NAME         move read updates into the archive
#   python3 ~/Threads_private/threads.py archive NAME SOURCE FILE [TAGS...]
#       add FILE in full to NAME's archive. SOURCE is one word saying what
#       it is (PA, POST, PRIVATE, CONTEXT...). TAGS are words after it; if
#       none are given, the file's own first line must be "tags: ...".
#
# TAGS ARE REQUIRED (Tony, 29 September 2026). Every update and note file
# starts with a line like:   tags: nginx, stale-copies, nexus
# Every piece in an archive starts with one searchable line:
#   ----- archived 2026-09-29 | from UPDATES | added 2026-09-28 | tags: nginx -----
# Entries written before tags existed are archived as "tags: untagged".
#
# Cross-reference posts stay short: when a note makes one pass 30 entries,
# its oldest 20 move into the thread's archive.
#
# Safety rules:
#   - Never deletes a file. setup leaves existing posts alone.
#   - update and note refuse a file without a tags line, and refuse text
#     that is already there. update also checks the archive.
#   - archive refuses a file whose text is already in that archive.
#   - clear and cross-reference trimming back up the live post to
#     ~/Threads_private/backups/, write the archive, check it landed, and
#     only then trim the live post.
#   - If anything is missing, it stops, says so, and changes nothing.
#
# For testing only: the settings THREADS_PUBLIC and THREADS_BACKUPS point
# the tool at other folders instead of the real ones.

import datetime
import os
import re
import shutil
import sys

PUBLIC = os.environ.get("THREADS_PUBLIC") or os.path.expanduser("~/Needpedia_Nexus/public")
BACKUPS = os.environ.get("THREADS_BACKUPS") or os.path.expanduser("~/Threads_private/backups")
WEB = "https://nexus.needpedia.org/public/"
MARKER = "== ENTRIES BELOW =="
TODAY = datetime.date.today().isoformat()
NOW = datetime.datetime.now().strftime("%Y-%m-%d_%H%M%S")

XREF_LIMIT = 30   # a cross-reference post may hold this many entries
XREF_MOVE = 20    # when it passes that, this many of the oldest move out
DASHES = "-" * 64

SEP_LINE = re.compile(r"^-{20,}[ \t]*$", re.M)
ENTRY_LINE = re.compile(r"^----- added (\d{4}-\d{2}-\d{2}) -----[ \t]*$", re.M)

UPDATES_HEAD = """# UPDATES - {NAME} THREAD

Public. Nothing sensitive in here, ever.

What this is: news and requests from OTHER threads that thread {NAME}
has not read yet. Anything below the marker line is unread. Read it at
the start of a session, act on it, then Tony clears it into the archive:
{WEB}ARCHIVE-{NAME}.md

How to add (another thread hands Tony a file and this command):
python3 ~/Threads_private/threads.py update {NAME} FILE
The file's first line must be a tags line, like:  tags: nginx, nexus

History that needs no action goes in the cross-reference post instead:
{WEB}CROSSREF-{NAME}.md

Made {TODAY}.

""" + MARKER + "\n"

CROSSREF_HEAD = """# CROSS-REFERENCE - {NAME} THREAD

Public. Nothing sensitive in here, ever.

What this is: a history of things OTHER threads did that may affect
thread {NAME}. No action needed on any entry. Entries are never edited;
a correction goes in a newer dated entry. Anything that needs a response
goes in the updates post instead:
{WEB}UPDATES-{NAME}.md

How to add (the thread that did the thing hands Tony a file and this command):
python3 ~/Threads_private/threads.py note {NAME} FILE
The file's first line must be a tags line, like:  tags: nginx, nexus

Past 30 entries, the oldest 20 move to this thread's archive:
{WEB}ARCHIVE-{NAME}.md

Made {TODAY}.

""" + DASHES + "\n"

ARCHIVE_HEAD = """# ARCHIVE - {NAME}

Public. Nothing sensitive in here, ever.

Everything archived for {NAME}, oldest first: read updates, older
cross-reference entries, old editions of public documents, and
reference entries pointing at private files (path, date and tags only,
never their contents). Nothing here needs action.

Every piece starts with one line: the date it was archived, where it
came from, and its tags. Search it on Tony's computer, for example:
grep -n "tags:.*nginx" ~/Needpedia_Nexus/public/ARCHIVE-{NAME}.md
grep -n "archived 2026-09-2" ~/Needpedia_Nexus/public/ARCHIVE-{NAME}.md

Made {TODAY}.
"""


def stop(msg):
    print("STOPPING, nothing changed: " + msg)
    sys.exit(1)


def read(p):
    with open(p, encoding="utf-8") as f:
        return f.read()


def squash(text):
    return re.sub(r"\s+", " ", text).strip()


def paths(name):
    return (os.path.join(PUBLIC, "UPDATES-" + name + ".md"),
            os.path.join(PUBLIC, "CROSSREF-" + name + ".md"),
            os.path.join(PUBLIC, "ARCHIVE-" + name + ".md"))


def old_archive(name):
    return os.path.join(PUBLIC, "UPDATES-" + name + "-ARCHIVE.md")


def check_name(name):
    if not re.fullmatch(r"[A-Z0-9]+", name):
        stop("thread name '" + name + "' should be letters and digits only, like PC or NP1")


def tags_of(text):
    for line in text.splitlines():
        if line.strip():
            m = re.match(r"\s*tags:\s*(\S.*)$", line, re.I)
            return m.group(1).strip() if m else None
    return None


def piece(source, tags, body, extra=""):
    return ("\n----- archived %s | from %s%s | tags: %s -----\n%s\n"
            % (TODAY, source, extra, tags, body.strip()))


def ensure_archive(name):
    arch = paths(name)[2]
    if not os.path.isdir(PUBLIC):
        stop("public folder not found: " + PUBLIC)
    if not os.path.exists(arch):
        with open(arch, "x", encoding="utf-8") as f:
            f.write(ARCHIVE_HEAD.format(NAME=name, TODAY=TODAY))
        print("Made: " + arch)
    return arch


def append_archive(arch, text, bodies):
    with open(arch, "a", encoding="utf-8") as f:
        f.write(text)
    have = squash(read(arch))
    return all(squash(b) in have for b in bodies)


def backup(p):
    os.makedirs(BACKUPS, exist_ok=True)
    shutil.copy2(p, os.path.join(BACKUPS, os.path.basename(p) + ".bak-" + NOW))


def split_entries(text):
    """Returns [(date or None, body)]; text before the first dated line
    (hand-written entries from before the tool) comes back with date None."""
    out = []
    marks = list(ENTRY_LINE.finditer(text))
    first = marks[0].start() if marks else len(text)
    if text[:first].strip():
        out.append((None, text[:first].strip()))
    for i, m in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(text)
        out.append((m.group(1), text[m.end():end].strip()))
    return out


def pieces_for(source, entries):
    text, bodies = "", []
    for date, body in entries:
        if not body:
            continue
        extra = (" | added " + date) if date else ""
        text += piece(source, tags_of(body) or "untagged", body, extra)
        bodies.append(body)
    return text, bodies


def setup(name):
    check_name(name)
    if not os.path.isdir(PUBLIC):
        stop("public folder not found: " + PUBLIC)
    u, c, arch = paths(name)
    for p, head in ((u, UPDATES_HEAD), (c, CROSSREF_HEAD)):
        if os.path.exists(p):
            print("Already exists, left alone: " + p)
            continue
        with open(p, "x", encoding="utf-8") as f:
            f.write(head.format(NAME=name, TODAY=TODAY, WEB=WEB))
        print("Made: " + p)
    if os.path.exists(arch):
        print("Already exists, left alone: " + arch)
    else:
        ensure_archive(name)


def show(name):
    u = paths(name)[0]
    if not os.path.exists(u):
        stop("no updates post for " + name + ": " + u)
    text = read(u)
    if MARKER not in text:
        stop("the marker line is missing from " + u)
    entries = text.split(MARKER, 1)[1]
    if not entries.strip():
        print("No unread updates for " + name + ".")
    else:
        print("UNREAD UPDATES FOR " + name + ":")
        print(entries.strip())


def archive_crossref(name, c):
    skip = "Note added. Archiving skipped, live post untouched: "
    text = read(c)
    sep = SEP_LINE.search(text)
    if not sep:
        print(skip + "no dashed line found in " + c)
        return
    body = text[sep.end():]
    marks = list(ENTRY_LINE.finditer(body))
    if len(marks) <= XREF_LIMIT:
        return
    cut = marks[XREF_MOVE].start()
    moved_text, bodies = pieces_for("CROSSREF", split_entries(body[:cut]))
    kept = body[cut:]
    try:
        backup(c)
        arch = ensure_archive(name)
    except OSError as e:
        print(skip + "backup failed (" + str(e) + ")")
        return
    if not append_archive(arch, moved_text, bodies):
        print(skip + "could not confirm the entries reached " + arch)
        return
    tmp = c + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(text[:sep.end()] + "\n\n" + kept.lstrip("\n"))
    os.replace(tmp, c)
    if squash(kept) not in squash(read(c)):
        print("WARNING: could not confirm the live post kept its newest entries. "
              "Its backup is in " + BACKUPS)
        sys.exit(1)
    print("Cross-reference post passed %d entries. The oldest %d moved to %s"
          % (XREF_LIMIT, XREF_MOVE, WEB + os.path.basename(arch)))


def add(name, src, kind):
    u, c, arch = paths(name)
    target = u if kind == "update" else c
    if not os.path.exists(target):
        stop("post not found: " + target
             + "\nMake it first with: python3 ~/Threads_private/threads.py setup " + name)
    src = os.path.expanduser(src)
    if not os.path.isfile(src):
        stop("file not found: " + src)
    body = read(src).strip()
    if not body:
        stop("file is empty: " + src)
    if not tags_of(body):
        stop("the file's first line must be a tags line, like:  tags: nginx, stale-copies")
    current = read(target)
    if kind == "update" and MARKER not in current:
        stop("the marker line is missing from " + target)
    look_in = current
    if kind == "update":
        for p in (arch, old_archive(name)):
            if os.path.exists(p):
                look_in += read(p)
    if squash(body) in squash(look_in):
        stop("this text is already in " + target
             + (" or its archive" if kind == "update" else ""))
    with open(target, "a", encoding="utf-8") as f:
        f.write("\n----- added " + TODAY + " -----\n" + body + "\n")
    if squash(body) not in squash(read(target)):
        print("WARNING: wrote to " + target + " but could not confirm the text is there. Check it.")
        sys.exit(1)
    print("Added to: " + target)
    print("Online at: " + WEB + os.path.basename(target))
    if kind == "note":
        archive_crossref(name, target)


def clear(name):
    u = paths(name)[0]
    if not os.path.exists(u):
        stop("file not found: " + u)
    live = read(u)
    if MARKER not in live:
        stop("the marker line is missing from " + u)
    head, entries = live.split(MARKER, 1)
    if not entries.strip():
        print("Nothing to clear. " + name + " has no unread updates. Nothing changed.")
        return
    try:
        backup(u)
    except OSError as e:
        stop("backup failed (" + str(e) + ")")
    arch = ensure_archive(name)
    text, bodies = pieces_for("UPDATES", split_entries(entries))
    if not append_archive(arch, text, bodies):
        print("STOPPING, nothing emptied: could not confirm the entries reached " + arch)
        print("Live post untouched. Its backup is in " + BACKUPS)
        sys.exit(1)
    tmp = u + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(head + MARKER + "\n")
    os.replace(tmp, u)
    print("Archived and cleared " + name + " on " + TODAY + ", into " + WEB + os.path.basename(arch))
    print("What was moved:")
    print(entries.strip())


def archive_file(name, source, src, tag_words):
    check_name(name)
    if not re.fullmatch(r"[A-Z0-9-]+", source):
        stop("SOURCE should be one word in capitals, like PA, POST or PRIVATE")
    src = os.path.expanduser(src)
    if not os.path.isfile(src):
        stop("file not found: " + src)
    body = read(src).strip()
    if not body:
        stop("file is empty: " + src)
    tags = ", ".join(w.strip(",") for w in tag_words if w.strip(",")) or tags_of(body)
    if not tags:
        stop("no tags: add tag words after the file name, or start the file with a tags line")
    arch = paths(name)[2]
    if os.path.exists(arch) and squash(body) in squash(read(arch)):
        stop("this file's text is already in " + arch)
    arch = ensure_archive(name)
    if not append_archive(arch, piece(source, tags, body, " | file " + os.path.basename(src)), [body]):
        print("WARNING: wrote to " + arch + " but could not confirm the text is there. Check it.")
        sys.exit(1)
    print("Archived " + os.path.basename(src) + " into " + WEB + os.path.basename(arch))


USAGE = """Usage:
  python3 ~/Threads_private/threads.py setup   NAME
  python3 ~/Threads_private/threads.py show    NAME
  python3 ~/Threads_private/threads.py update  NAME FILE
  python3 ~/Threads_private/threads.py note    NAME FILE
  python3 ~/Threads_private/threads.py clear   NAME
  python3 ~/Threads_private/threads.py archive NAME SOURCE FILE [TAGS...]"""


def main():
    args = sys.argv[1:]
    if len(args) < 2:
        print(USAGE)
        sys.exit(1)
    job, name = args[0].lower(), args[1].upper()
    if job == "setup" and len(args) == 2:
        setup(name)
    elif job == "show" and len(args) == 2:
        show(name)
    elif job in ("update", "note") and len(args) == 3:
        add(name, args[2], job)
    elif job == "clear" and len(args) == 2:
        clear(name)
    elif job == "archive" and len(args) >= 4:
        archive_file(name, args[2].upper(), args[3], args[4:])
    else:
        print(USAGE)
        sys.exit(1)


main()
