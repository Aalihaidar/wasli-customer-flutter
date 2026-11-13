# Security Policy

## Scope

This repository is the Wasli customer app, used by customers parked at a restaurant to chat, confirm an order and send
it from the car. The app handles personal data of the customer (account contact details, position, car plate, chat
text and voice recordings), so reports about the following are taken seriously:

- Secrets or credentials committed to the repository or its history
- Storage or logging of the customer token, a verification code, a position or chat content outside what the app needs
- A way to see or act on another customer's conversation or order through the app
- A deep link or QR target (`/r/<slug>`) that can run code, change the app's state unexpectedly or leak data
- A GitHub Actions workflow that could allow unauthorized code execution or exfiltration of secrets (for example
  script injection through untrusted input, or an unpinned third-party action)
- A dependency (pub, npm or GitHub Action) with a known critical vulnerability that affects the app

Rules about who may see which conversation or order are enforced by the backend, which has its own repository and
policy. If a report is about the API itself, say so and it will be passed on.

## Supported versions

Only the latest release of the app and the latest commit on `develop` are supported.

## Supply chain

- Every GitHub Action is pinned to a full commit SHA. Workflows run with least-privilege `permissions:` and
  `persist-credentials: false`, and `${{ }}` values reach scripts only through `env:`.
- Dependabot proposes updates weekly with a 7-day cooldown. Pull requests scan every resolved package in
  `pubspec.lock` against the OSV vulnerability database, and `actionlint` and `zizmor` check the workflows.
- The npm dependencies (Husky, commitlint) are locked in `pnpm-lock.yaml`.
- Only public values are compiled into the app (`env/*.json`). Signing keys and deployment credentials live in GitHub
  environment secrets, never in the repository.

## Reporting a vulnerability

**Please do not open an issue or a pull request for a security vulnerability.**

This repository is private. Report the vulnerability directly to the repository owner, through the channel you already
use with them, and not in any issue, pull request or comment. Include:

- A description of the vulnerability and its potential impact
- Steps to reproduce (a minimal example is ideal), using invented data only: never send real customer or restaurant
  data
- A suggested fix, if you have one

Expect an initial response within **5 business days**. Once the report is confirmed, a fix will be prioritized and
released.
