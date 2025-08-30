# s1ngularity-response
Defense against the dark arts to restore user credentials and ensure comprehensive safety response.

## Overview
The S1ngularity attack was a supply-chain attack targeting the Nx build tool (versions 20.9.0-20.12.0 and 21.5.0-21.8.0) that occurred on August 26-27, 2025. Malicious versions automatically created public GitHub repositories named `s1ngularity-repository-*` containing stolen credentials including GitHub tokens, npm tokens, cloud keys, SSH keys, and API keys.

## Quick Response
```bash
# Emergency response (immediate containment)
./scripts/emergency-response.sh

# Check for exposure
npm run check:all

# Clean up malicious code
npm run cleanup:all

# Revoke all credentials
npm run revoke:all

# Secure repositories
npm run repos:secure

# Restore original repository names
npm run repos:restore <csv_file>
```

## Available Commands

### Detection & Analysis
- `npm run check:all` - Run all exposure checks
- `npm run check:nx` - Check for malicious Nx versions
- `npm run check:repos` - Scan for rogue GitHub repositories
- `npm run check:local` - Check local system for indicators
- `npm run detect:events` - Detect repository renames via GitHub Events API

### Cleanup
- `npm run cleanup:all` - Remove all malicious code
- `npm run cleanup:nx` - Uninstall malicious Nx versions
- `npm run cleanup:persistence` - Remove shell persistence and malicious files

### Credential Management
- `npm run revoke:all` - Revoke all credentials
- `npm run revoke:github` - Revoke GitHub PATs, OAuth tokens, SSH keys
- `npm run revoke:npm` - Revoke npm authentication tokens
- `npm run revoke:cloud` - Revoke cloud provider and API keys

### Repository Management
- `npm run repos:secure` - Make malicious repositories private
- `npm run repos:restore` - Restore original repository names from CSV data

### Monitoring
- `npm run monitor:all` - Run all monitoring checks
- `npm run monitor:github` - Monitor GitHub activity
- `npm run monitor:secrets` - Scan for exposed secrets

## Scripts Directory Structure
- **`scripts/detection/`** - Scripts to identify exposure and analyze events
- **`scripts/cleanup/`** - Scripts to remove malicious code
- **`scripts/credentials/`** - Scripts to revoke and rotate credentials
- **`scripts/repos/`** - Scripts for repository management and restoration
- **`scripts/monitoring/`** - Scripts for ongoing security monitoring
- **`events/`** - CSV files containing repository rename data

## Event Detection & Repository Restoration
The toolkit includes advanced event detection capabilities:

```bash
# Detect repository renames and public events
npm run detect:events

# Use specific CSV file for lookup
./scripts/detection/detect-renames-events.sh events/rename-bunsdev.csv

# Restore repository names using CSV data
./scripts/repos/restore-repos.sh events/rename-bunsdev.csv
```

## Affected Versions
**Malicious Nx versions:**
- 20.9.0 → 20.12.0
- 21.5.0 → 21.8.0
- Certain @nx/* plugins at 20.9.0 and 21.5.0

**Safe version to install:** `nx@21.4.1`

## Indicators of Compromise
- Public GitHub repos named `s1ngularity-repository-*`
- Files: `/tmp/inventory.txt` or `/tmp/inventory.txt.bak`
- Shell persistence: `grep -H "sudo shutdown -h 0" ~/.bashrc ~/.zshrc`
- Repository renames to malicious patterns
- Unauthorized repository visibility changes

## Documentation
- **[Response Playbook](guides/playbook.md)** - Complete incident response guide
- **[GitHub Checks Guide](guides/gh-checks.md)** - How to review GitHub logs
- **[Credential Revocation Guide](guides/gh-revoke.md)** - GitHub token management

## External Resources
- [S1ngularity Scanner](https://github.com/GitGuardian/s1ngularity-scanner)
- [HasMySecretLeaked](https://www.gitguardian.com/hasmysecretleaked)
- [Semgrep's Security Alert](https://semgrep.dev/blog/2025/security-alert-nx-compromised-to-steal-wallets-and-credentials)
- [Responding to the S1ngularity Attack](https://blog.dedevs.club/responding-to-the-s1ngularity-attack-tips-and-solutions)

## Emergency Response
If you discover active compromise:
1. **Immediate containment**: Run `./scripts/emergency-response.sh`
2. **Disconnect from network** if necessary
3. **Document everything** for incident response
4. **Contact your security team**

## Prevention
- Pin dependencies in lockfiles
- Require manual approval for GitHub Actions from forks
- Use short-lived OIDC tokens in CI/CD
- Regular credential rotation
- Monitor for suspicious repository activity