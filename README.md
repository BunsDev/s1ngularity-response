# s1ngularity-response
Defense against the dark arts to restore user credentials and ensure comprehensive safety response.

## Overview
The S1ngularity attack was a supply-chain attack targeting the Nx build tool (versions 20.9.0-20.12.0 and 21.5.0-21.8.0) that occurred on August 26-27, 2025. Malicious versions automatically created public GitHub repositories named `s1ngularity-repository-*` containing stolen credentials including GitHub tokens, npm tokens, cloud keys, SSH keys, and API keys.

## Quick Response Checklist
- [ ] Check for malicious Nx versions: `npm ls nx`
- [ ] Scan for rogue GitHub repositories: `scripts/check-github-repos.sh`
- [ ] Remove malicious packages: `scripts/cleanup-nx.sh`
- [ ] Revoke all credentials: `scripts/revoke-credentials.sh`
- [ ] Secure affected repositories: `scripts/secure-repos.sh`
- [ ] Monitor for ongoing threats

## Scripts Directory
- **`scripts/detection/`** - Scripts to identify exposure
- **`scripts/cleanup/`** - Scripts to remove malicious code
- **`scripts/credentials/`** - Scripts to revoke and rotate credentials
- **`scripts/monitoring/`** - Scripts for ongoing security monitoring

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

## Resources
- [S1ngularity Scanner](https://github.com/GitGuardian/s1ngularity-scanner)
- [HasMySecretLeaked](https://www.gitguardian.com/hasmysecretleaked)
- [Semgrep's Security Alert](https://semgrep.dev/blog/2025/security-alert-nx-compromised-to-steal-wallets-and-credentials)
- [Responding to the S1ngularity Attack](https://blog.dedevs.club/responding-to-the-s1ngularity-attack-tips-and-solutions)

## Emergency Contact
If you discover active compromise, immediately:
1. Disconnect from network
2. Run the emergency response script: `scripts/emergency-response.sh`
3. Contact your security team