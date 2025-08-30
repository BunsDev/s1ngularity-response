# S1ngularity Attack Response Playbook

## 🚨 Emergency Response
If you suspect active compromise:
```bash
npm run emergency
# or: ./scripts/emergency-response.sh
```

## 1. Identify Possible Exposure

### Quick Check (All-in-One)
```bash
npm run check:all
```

### Individual Checks
- [ ] **Check Nx versions** (20.9.0–20.12.0, 21.5.0–21.8.0 were malicious)
  ```bash
  npm run check:nx
  # or: ./scripts/detection/check-nx-versions.sh
  ```

- [ ] **Review GitHub for rogue repos** named `s1ngularity-repository-*`
  ```bash
  npm run check:repos
  # or: ./scripts/detection/check-github-repos.sh
  ```
  📋 See detailed instructions: [gh-checks.md](./gh-checks.md)

- [ ] **Check local system** for `/tmp/inventory.txt` and `/tmp/inventory.txt.bak`
- [ ] **Check shell persistence** in `~/.bashrc` and `~/.zshrc` for `sudo shutdown -h 0`
  ```bash
  npm run check:local
  # or: ./scripts/detection/check-local-indicators.sh
  ```

## 2. Remove Malicious Package & Code

### Quick Cleanup (All-in-One)
```bash
npm run cleanup:all
```

### Individual Steps
- [ ] **Uninstall malicious Nx** and reinstall safe version (>=21.4.1)
  ```bash
  npm run cleanup:nx
  # or: ./scripts/cleanup/cleanup-nx.sh
  ```

- [ ] **Remove shell persistence** and malicious files
  ```bash
  npm run cleanup:persistence
  # or: ./scripts/cleanup/remove-persistence.sh
  ```

- [ ] **Update VS Code Nx Console** extension to >=18.66.0 (manual step)

## 3. Revoke & Rotate Credentials

### Quick Revocation (All Scripts)
```bash
npm run revoke:all
```

### Individual Steps
- [ ] **GitHub credentials**: PATs, OAuth tokens, SSH keys; enable 2FA
  ```bash
  npm run revoke:github
  # or: ./scripts/credentials/revoke-github.sh
  ```
  📋 See detailed instructions: [gh-revoke.md](./gh-revoke.md)

- [ ] **npm tokens**: revoke and regenerate; enable 2FA for publishing
  ```bash
  npm run revoke:npm
  # or: ./scripts/credentials/revoke-npm.sh
  ```

- [ ] **Cloud & API keys**: AWS/GCP/Azure, third-party APIs (OpenAI, Claude, etc.)
  ```bash
  npm run revoke:cloud
  # or: ./scripts/credentials/revoke-cloud-apis.sh
  ```

- [ ] **Database passwords** and CI/CD tokens (manual process)
- [ ] **Cryptocurrency wallets**: transfer funds to new wallets with fresh keys

## 4. Review and Secure Repositories

- [ ] **Make malicious repos private** and audit commit history
  ```bash
  npm run repos:secure
  # or: ./scripts/secure-repos.sh
  ```

- [ ] **Restore original repository names** (if repos were renamed)
  ```bash
  npm run repos:restore
  # or: ./scripts/restore-names.sh
  ```

- [ ] **Search for unauthorized forks** under attacker accounts
- [ ] **Review GitHub org audit logs** for anomalies (repo renames, key additions)
- [ ] **Remove compromised users** until credentials are rotated

## 5. Verify & Monitor

### Monitoring Scripts
```bash
npm run monitor:all
```

### Individual Steps
- [ ] **Decode `results.b64` files** (Base64 twice) to see stolen data
- [ ] **Run security scanners**:
  ```bash
  npm run monitor:secrets
  # or: ./scripts/monitoring/scan-for-secrets.sh
  ```
  - GitGuardian's S1ngularity Scanner
  - HasMySecretLeaked tool
  - Semgrep rule for malicious Nx versions

- [ ] **Monitor GitHub activity**:
  ```bash
  npm run monitor:github
  # or: ./scripts/monitoring/monitor-github-activity.sh
  ```

- [ ] **Monitor logs** for suspicious logins or API calls

## 6. Long-Term Preventive Measures
- [ ] **Pin dependencies** in lockfiles; avoid unverified 'latest' installs
- [ ] **Require manual approval** for GitHub Actions from forks
- [ ] **Use short-lived OIDC tokens** in CI/CD instead of static tokens
- [ ] **Inventory and regularly rotate** secrets; apply least privilege
- [ ] **Educate developers** on secret management and incident response

---

## Script Reference

| Command | Script | Purpose |
|---------|--------|---------|
| `npm run emergency` | `emergency-response.sh` | Immediate containment and response |
| `npm run check:all` | Multiple detection scripts | Run all exposure checks |
| `npm run cleanup:all` | Multiple cleanup scripts | Remove all malicious code |
| `npm run revoke:all` | Multiple credential scripts | Revoke all credentials |
| `npm run repos:secure` | `secure-repos.sh` | Make repositories private |
| `npm run repos:restore` | `restore-names.sh` | Restore original repo names |
| `npm run monitor:all` | Multiple monitoring scripts | Run all monitoring checks |
