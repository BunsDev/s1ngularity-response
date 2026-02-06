# How to review GitHub logs for s1ngularity-repository-* creations

## Quick Start (Automated)
Run the automated script to check for malicious repositories:
```bash
npm run check:repos
# or: ./scripts/detection/check-github-repos.sh
```

This script will:
- Scan all your repositories for the `s1ngularity-repository-*` pattern
- Create a list of affected repositories for further action
- Provide links to each repository for manual review

## 🔍 Event-Based Detection
Use GitHub Events API to detect repository renames and public events:
```bash
npm run detect:events
# or: ./scripts/detection/detect-renames-events.sh [csv_file]
```

This script will:
- Analyze recent GitHub events for repository renames
- Detect repositories made public with s1ngularity patterns
- Cross-reference with CSV data to show original repository names
- Provide restoration guidance

### Usage Examples
```bash
# Use default CSV file (events/rename-events.csv)
./scripts/detection/detect-renames-events.sh

# Use specific CSV file
./scripts/detection/detect-renames-events.sh events/rename-bunsdev.csv
./scripts/detection/detect-renames-events.sh events/rename-soulswap.csv
```

## A) Personal GitHub account (Security log UI)
- [ ] Sign in to GitHub.
- [ ]	Open Settings → Security Log
  - [ ]	[/settings/security-log](https://github.com/settings/security-log)
- [ ]	In the Filter events search box:
  - [ ] **Type**: Created repository
  - [ ] **Then add a free-text term**: s1ngularity-repository
  - [ ] **(Optionally) bound by date**: use the date pickers to focus on Aug 26–29, 2025.
- [ ]	Review any matching rows
  - [ ]	Click an entry to see details (timestamp, IP/actor, repo name).
- [ ]	**If you find one**:
  - [ ]	Immediately make the repo Private (or delete if it's the attacker's exfil repo and you've preserved evidence).
  - [ ]	Capture the event details (timestamp, IP, repo value) for your incident notes.

### Quick cross-check (personal account)
- [ ]	Go to Your profile
- [ ]	→ Repositories and search s1ngularity-repository in "Find a repository…" box
- [ ]	Spot any lingering repos the UI search turns up.

---

## B) GitHub Organization (Audit log UI)

You need to be an org owner to view the audit log.

- [ ]	Go to the organization's home page.
- [ ]	Open Settings → Audit log
  - Path looks like `/organizations/<org>/settings/audit-log`
- [ ]	In the Query box, use:
  - [ ]	Action filter: action:repo.create
  - [ ]	Date range: created:2025-08-26..2025-08-29
  - [ ]	Press Enter.
- [ ]	Scan the results for repo names that contain s1ngularity-repository-.
  - [ ]	Click any entry to view full details (actor, repo, IP, created_at).
- [ ]	Record positives and take remediation:
  - [ ]	Revert repo to Private, lock down access, and check for unwanted forks.
  - [ ]	Rotate credentials for the actor shown (they're likely compromised).

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
### Automated Response
If malicious repositories are found, use these scripts for quick remediation:

```bash
# Make repositories private immediately
npm run repos:secure
# or: ./scripts/repos/secure-repos.sh

# Restore original repository names using CSV data
npm run repos:restore
# or: ./scripts/repos/restore-repos.sh <csv_file>

# Monitor for ongoing suspicious activity
npm run monitor:github
# or: ./scripts/monitoring/monitor-github-activity.sh
```

### Manual Steps
- [ ]	Re-private or delete the malicious repo (after preserving evidence).
- [ ]	Audit forks: open the repo's Forks tab; remove unknown forks or file a GitHub takedown.
- [ ]	Rotate the actor's tokens (GitHub PAT/OAuth/SSH), then npm and any other exposed keys.
  ```bash
  npm run revoke:all
  # or individual scripts: revoke:github, revoke:npm, revoke:cloud
  ```
- [ ]	Review org audit log for adjacent events (more repo.create/rename, deploy keys added, app installs).
- [ ]	Document timestamps, actors, IPs, repos for incident records.
