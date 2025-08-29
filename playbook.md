## 1. Identify Possible Exposure
- [ ] Check Nx versions (20.9.0–20.12.0, 21.5.0–21.8.0 were malicious).
- [ ] Review GitHub for rogue repos named `s1ngularity-repository-*`.
- [ ] Look for `/tmp/inventory.txt` and `/tmp/inventory.txt.bak` on local system.
- [ ] Check `~/.bashrc` and `~/.zshrc` for `sudo shutdown -h 0`.

## 2. Remove Malicious Package & Code
- [ ] Uninstall malicious Nx versions and reinstall safe version (>=21.4.1).
- [ ] Clear npm cache (`npm cache clean --force`).
- [ ] Update VS Code Nx Console extension to >=18.66.0.

## 3. Revoke & Rotate Credentials
- [ ] Revoke and reissue GitHub PATs, OAuth tokens, and SSH keys; enable 2FA.
- [ ] Revoke and regenerate npm tokens; enable 2FA for publishing.
- [ ] Rotate AWS/GCP/Azure keys and all third-party API keys (OpenAI, Claude, etc.).
- [ ] Change database passwords and rotate CI/CD tokens.
- [ ] Transfer funds from any crypto wallets to new wallets with fresh keys.

## 4. Review and Secure Repositories
- [ ] Set any publicized repos back to private; audit commit history.
- [ ] Search for unauthorized forks under attacker accounts.
- [ ] Review GitHub org audit logs for anomalies (repo renames, key additions).
- [ ] Remove compromised users until credentials are rotated.

## 5. Verify & Monitor
- [ ] Decode any `results.b64` files (Base64 twice) to see stolen data.
- [ ] Run GitGuardian’s S1ngularity Scanner and HasMySecretLeaked tool.
- [ ] Apply Semgrep rule to detect malicious Nx versions.
- [ ] Monitor logs for suspicious logins or API calls.

## 6. Long-Term Preventive Measures
- [ ] Pin dependencies in lockfiles; avoid unverified 'latest' installs.
- [ ] Require manual approval for GitHub Actions from forks.
- [ ] Use short-lived OIDC tokens in CI/CD instead of static tokens.
- [ ] Inventory and regularly rotate secrets; apply least privilege.
- [ ] Educate developers on secret management and incident response.
