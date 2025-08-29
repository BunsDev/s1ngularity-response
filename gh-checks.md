# How to review GitHub logs for s1ngularity-repository-* creations

## A) Personal GitHub account (Security log UI)
- [ ] Sign in to GitHub.
- [ ]	Open Settings → Security log (direct path: https://github.com/settings/security-log).
- [ ]	In the Filter events search box:
  •	**Type**: Created repository
  •	**Then add a free-text term**: s1ngularity-repository
  •	**Optionally bound by date**: use the date pickers to focus on Aug 26–29, 2025.
- [ ]	Review any matching rows. Click an entry to see details (timestamp, IP/actor, repo name).
- [ ]	**If you find one**:
  - [ ]	Immediately make the repo Private (or delete if it’s the attacker’s exfil repo and you’ve preserved evidence).
  - [ ]	Capture the event details (timestamp, IP, repo value) for your incident notes.

### Quick cross-check (personal account)
- [ ]	Go to Your profile
- [ ]	→ Repositories and search s1ngularity-repository in “Find a repository…” box
- [ ]	Spot any lingering repos the UI search turns up.

---

## B) GitHub Organization (Audit log UI)

You need to be an org owner to view the audit log.

- [ ]	Go to the organization’s home page.
- [ ]	Open Settings → Audit log (path looks like /organizations/<org>/settings/audit-log).
- [ ]	In the Query box, use:
  - [ ]	Action filter: action:repo.create
  - [ ]	Date range: created:2025-08-26..2025-08-29
  - [ ]	Press Enter.
- [ ]	Scan the results for repo names that contain s1ngularity-repository-.
  - [ ]	Click any entry to view full details (actor, repo, IP, created_at).
- [ ]	Record positives and take remediation:
  - [ ]	Revert repo to Private, lock down access, and check for unwanted forks.
  - [ ]	Rotate credentials for the actor shown (they’re likely compromised).

- [ ] **Optional**: add a free-text contains filter

> Some enterprise tenants support free-text alongside qualifiers. Try appending s1ngularity-repository in the search box after the qualifiers if your UI permits it; otherwise just visually scan the repo field in the results list.

---

## C) Command line (Org audit log via gh + jq)

> Works for organizations (not personal security logs). Requires gh (authenticated) and jq. Search for creations in the incident window, then grep for the name pattern: `ORG="<your-org>"`

# Pull audit log entries for repo.create in the date window

```bash
gh api \
  -H "Accept: application/vnd.github+json" \
  "/orgs/$ORG/audit-log" \
  -f phrase='action:repo.create created:2025-08-26..2025-08-29' \
  --paginate \
| jq -r '.[] | select(.repo != null) | [.created_at, .actor, .repo, .action] | @tsv' \
| grep -i 's1ngularity-repository'
```
Pretty report output (TSV to CSV-ish):

```bash
gh api \
  -H "Accept: application/vnd.github+json" \
  "/orgs/$ORG/audit-log" \
  -f phrase='action:repo.create created:2025-08-26..2025-08-29' \
  --paginate \
| jq -r '
  .[] 
  | select(.repo != null and (.repo | test("s1ngularity-repository"; "i")))
  | ["time="+.created_at, "actor="+.actor, "repo="+.repo, "action="+.action]
  | @tsv
'
```

> Tip: If your org uses SSO or multiple enterprises, run the command under an owner-privileged gh login: `gh auth login --scopes admin:org,read:org`

---

## D) What to do if you find entries
- [ ]	Re-private or delete the malicious repo (after preserving evidence).
- [ ]	Audit forks: open the repo’s Forks tab; remove unknown forks or file a GitHub takedown.
- [ ]	Rotate the actor’s tokens (GitHub PAT/OAuth/SSH), then npm and any other exposed keys.
- [ ]	Review org audit log for adjacent events (more repo.create/rename, deploy keys added, app installs).
- [ ]	Document timestamps, actors, IPs, repos for incident records.
