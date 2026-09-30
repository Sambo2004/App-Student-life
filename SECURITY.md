# Student Life Hub Security Policy

## Security Boundary

Student Life Hub is currently a local-first Flutter application. It does not
provide server accounts, authentication, or end-to-end encrypted sync. Data
stored in a browser or phone can be read by someone who controls that device,
has an unlocked user profile, or has developer access. No software can
honestly guarantee that it is impossible for a determined attacker to access a
compromised device or server.

The project focuses on minimizing accidental exposure, validating untrusted
backup files, avoiding secrets in source control, and securing web hosting.

## Current Protections

- Backup imports reject oversized files and malformed records before changing data.
- Encrypted backups use password-derived Argon2id keys with authenticated AES-256-GCM.
- Runtime failures are recorded only as a local last-error diagnostic; no records are uploaded.
- Invalid backups do not silently overwrite existing data.
- Deployment host, user, and path are supplied through environment variables.
- Secret-like files are ignored by Git.
- Production deployment should use HTTPS, a non-root SSH user, and restricted SSH keys.

## Deployment Requirements

Set these variables in the deployment shell instead of editing `deploy.bat`:

```bat
set DEPLOY_HOST=your-server.example.com
set DEPLOY_USER=deploy
set DEPLOY_PATH=/usr/share/nginx/html
deploy.bat
```

Use a dedicated account with only the permissions required to publish web
files. Do not put passwords, private keys, API keys, or production connection
strings in this repository. Configure HTTPS and the headers in
`nginx-security.conf` on the server.

## Reporting a Vulnerability

Do not publish sensitive reports in a public issue. Contact the maintainer
privately through the project owner or repository security contact, including
reproduction steps, affected version, impact, and a safe fix if known. Do not
include real student records or credentials in a report.

We will acknowledge a valid report within 7 days, investigate it, and publish a
fix or mitigation when practical. Please allow reasonable time for a fix before
public disclosure.

## Supported Versions

| Version | Supported |
| --- | --- |
| Current `main` | Yes |
| Older releases | No |
