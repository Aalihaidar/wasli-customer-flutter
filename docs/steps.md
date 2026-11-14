# Project steps

The living checklist of `wasli-customer-flutter`, from the blank template to the final release. Tick a box
(`- [x]`) when the step is done. Steps are added, reworded, reordered or removed as the project evolves; when that
happens, change this file in the same pull request as the work.

Guides used by these steps: [`README.md`](../README.md) (sections 2, 3, 7 and 9), [`github-setup.md`](github-setup.md),
[`environments.md`](environments.md), [`android-signing.md`](android-signing.md),
[`consuming-the-api.md`](consuming-the-api.md).

## How to use this file

- **Order matters.** Phases run top to bottom; inside a phase, steps run top to bottom unless a note says otherwise.
- **Phases follow the backend milestones** (D0 to D4, then the pilot). A phase that depends on a backend release names it.
- **One topic branch per reviewable change**, pull request into `develop`, merged with a merge commit, often
  (`CONTRIBUTING.md`). Tick the box in the same pull request that does the work. The suggested branch name sits at the
  start of each phase.
- When a step is removed because it no longer applies, say why in the pull request.
- **Decide** marks a choice that is not made yet. Settle it before starting the steps below it, then record the answer
  next to the step.
- **Backend** marks a step that waits for a backend release (the contract is the only source of truth for endpoints).
- A step that turns out to be wrong or unnecessary is struck through (`~~text~~`) with a one-line reason, or deleted.

Status legend: `- [x]` done · `- [ ]` to do.

---

## Phase 0: Repository from the template

- [x] Create the repository from `flutter-template` (default branch `develop`, no other branches copied)
- [x] `main` exists on the remote (created by the Bootstrap main workflow)
- [x] Clone with the SSH host alias; `origin` points to `git@github.com-personal:Aalihaidar/wasli-customer-flutter.git`
- [x] Open the folder in the Dev Container; the Husky hooks are registered (`pnpm install` ran)
- [x] Check that the **Labels** workflow created every label (**Actions → Labels**, or `gh label list`); if not, run
  `gh workflow run labels.yml`
- [x] Check that **Bootstrap main** finished without errors
- [x] Check the first Dependabot pull requests (if any) and merge or close them before the scaffold

## Phase 1: Local setup and decisions before the scaffold

- [x] Set the git identity **repository-locally** (never `--global`): `git config --local user.name …` and
  `git config --local user.email …`, then `git config --show-origin --get user.email` must show `.git/config`
- [x] SSH key of the right account: `ssh -T git@github.com-personal` greets `Aalihaidar` (else
  `scripts/pin-ssh-key.sh --key SHA256:…`)
- [x] `gh auth login` inside the container (needed to download the private backend contract)
- [x] `flutter doctor -v` is green for Android and web (Xcode is not expected on Linux)
- [x] **Decided** the platforms: web, Android and iOS folders are created now (web stays the first product target). The
  application ID and the Android flavors are therefore part of the scaffold (Phase 2); the iOS flavors need a Mac
- [x] **Decided** the lint set: `very_good_analysis`
- [x] **Decided** hand-written Riverpod providers and plain Dart 3 classes (sealed classes, records); no `freezed`,
  `equatable` or `riverpod_generator`
- [x] **Decided** golden tests (Arabic and English, light and dark) for the core widgets, added once the theme exists
  (Phase 5)

The other open decisions (hosting, first-load target, map provider, error reporting, copy and brand assets) and the
backend requests are listed at the end of this file.

## Phase 2: Scaffold the Flutter project

Branch: `feat/initial-app`. Everything below goes into one reviewable pull request, in this order.

- [x] `flutter create --org com.alihaidar --project-name wasli_customer --platforms web,android,ios .`
- [x] Application ID `com.alihaidar.wasli.customer`: set the Android `applicationId` and every iOS
  `PRODUCT_BUNDLE_IDENTIFIER` to the same value (keep the `.RunnerTests` suffix; leave the Android `namespace` as
  generated) **before the first commit**. The ID cannot change after the first store upload
- [x] Android flavors `staging` (suffix `.staging`) and `production` with their signing configurations in
  `android/app/build.gradle.kts`, and remove the generated `release { signingConfig … }` block
  (`docs/android-signing.md` section 2)
- [x] `default-flavor: staging` in `pubspec.yaml`, and check that a web run still starts. Until the iOS flavors exist
  (block below, needs a Mac), iOS builds fail because of this setting; `BUILD_IOS` stays off
- [x] Debug-only cleartext exception for `10.0.2.2` and `localhost` in `android/app/src/debug`
  (`docs/consuming-the-api.md` section 5)
- [x] `flutter pub get` (creates `pubspec.lock`, which switches CI to its full checks)
- [x] `scripts/pin-image.sh` (freezes the dev image digest in `docker-compose.yml` and `environment: flutter:` in
  `pubspec.yaml`, refreshes `pubspec.lock`)
- [x] `version: 0.1.0+1` in `pubspec.yaml`
- [x] Strict `analysis_options.yaml` (`strict-casts`, `strict-inference`, `strict-raw-types`, formatter width 120, the
  chosen lint set, `lib/api/**` excluded)
- [ ] Folder structure under `lib/`: `app/`, `core/`, `theme/`, `api/`, `features/` (git does not track empty folders, so
  each one appears with its first file; `app/` and `core/` exist)
- [x] Boundary check for the folder rules (`core`, `theme` and `api` never import `features` or `app`; features never
  import each other's `data` or `presentation`; `domain` is pure Dart): `scripts/check-boundaries.sh`, run by the
  pre-commit hook and by the CI job "Folder boundaries"
- [x] Web entry point uses `usePathUrlStrategy()`; plain HTML splash in `web/index.html` (removed by
  `web/flutter_bootstrap.js` once the app runs), correct title, description and manifest. The icons stay the Flutter
  defaults until the logo exists (see "Decisions still open")
- [x] Replace the generated counter app with a minimal placeholder page (`lib/main.dart` only calls `bootstrap()` in
  `app/`) and one passing test in `test/` (the CI test job only runs when `test/` exists)
- [x] `env/staging.json` (public, non-secret values only: `API_BASE_URL`, `CUSTOMER_SITE_URL`); the names listed in
  `.env.example`. `env/production.json` comes with the production hosting (Phase 11), since no production API or site
  exists yet
- [x] `.vscode/launch.json`: `--dart-define=API_BASE_URL=http://localhost:8000/api/v1` for web and
  `http://10.0.2.2:8000/api/v1` for the emulator; keep the web port and hostname arguments
- [x] Quality gates pass locally: `dart format --set-exit-if-changed .`, `flutter analyze --fatal-infos`, `flutter test`
- [ ] Run it: `flutter run -d web-server --web-port 8080` opens in the host browser

### Replace the template files (same branch, or a `chore/` branch right after)

- [x] `.github/CODEOWNERS`: `@alihaidar0` becomes `@Aalihaidar`
- [x] `.github/dependabot.yml`: `assignees` becomes `Aalihaidar`; uncomment the `pub` and `docker-compose` blocks
- [x] `README.md`: `scripts/init-readme.sh --description "…"` (after `pin-image.sh`; pass `--template-release` with the
  template release the project started from), then add the project sections
- [x] `LICENSE`: proprietary, all rights reserved (same text as the restaurant app)
- [x] `SECURITY.md`, `CONTRIBUTING.md`, `.github/CODE_OF_CONDUCT.md`: rewritten for this app
- [x] Delete `CHANGELOG.md` (the changelog is the GitHub Releases page)
- [x] `.github/PULL_REQUEST_TEMPLATE.md`: rewritten for this app (the restaurant repo did the same)
- [x] `package.json` `name` becomes `wasli-customer-flutter`
- [x] `scripts/welcome.sh`: banner title and link
- [x] `.cspell/project-words.txt`: add the project's own words (`wasli`, `fils`, …)
- [x] Delete the template-only files: `.github/workflows/image-contract.yml`, `.github/scripts/check-image-contract.sh`,
  `.github/scripts/check-tool-versions.sh`, `.github/workflows/release.yml`, the `template-guard` and `template-sample`
  jobs of `ci.yml` (and their entries in `CI passed`), and `.github/workflows/bootstrap-main.yml` (`main` exists)
- [x] Keep or trim `docs/` (kept: the template guides stay useful as reference)

### Android signing (deferred by the owner, 2026-11-12)

Not done for the first merge. Pull request builds use the debug key and need no secret, so the PR and its merge are not
blocked. The signed build runs on every push to `develop` or `main` and stops with a message naming the missing secret,
so until this block is done the post-merge **Build** run on `develop` is red (not a required check) and no draft release
"Staging" is created. Do this block before the first signed APK is needed (`docs/android-signing.md` sections 1 and 3).
Create the two GitHub environments with their branch restriction **before** adding any secret: an environment GitHub
creates on the fly from a workflow run has no branch restriction.
**Plan limit (2026-11-13):** environment-scoped secrets and branch restrictions need a paid plan on a private
repository, so decide with the owner how the signing secrets are stored (repository secrets and a `build.yml` change)
before doing this block.

- [ ] Two keystores (staging key and production upload key) in `.signing/` with distinctive aliases, key property files
  `android/key.staging.properties` and `android/key.production.properties` kept local, both keystores and passwords backed
  up in a password manager
- [ ] GitHub environments `staging` (only `develop`) and `production` (only `main`), administrator bypass off, created
  **before** the first workflow that uses them
- [ ] In each environment the secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_PASSWORD`,
  `ANDROID_KEY_ALIAS` and the variable `ANDROID_CERT_SHA256` (the key's public SHA-256 fingerprint)

### Merge

- [x] Commit (Conventional Commits), push, open the pull request into `develop` with the template filled in (PR #1)
- [x] **CI passed** is green; `build.yml` produced the web, APK and App Bundle test builds (staging)
- [x] Merged with **Create a merge commit**
- [ ] The signed staging build succeeds and fills the draft release "Staging"; check the signature with `apksigner`
  (waits for the signing block above)

### iOS flavors (needs a Mac)

Branch: `feat/ios-flavors`. Xcode schemes cannot be created in the Linux container (`docs/environments.md`, "Not set up
yet").

- [ ] **Decide** where this is done (a Mac, or later together with the iOS signing in Phase 12)
- [ ] Xcode schemes and build configurations `staging` and `production`, bundle identifier per flavor
  (`com.alihaidar.wasli.customer` and the `.staging` variant, the same IDs as Android)
- [ ] `flutter build ios --flavor staging` compiles on a Mac; then set the repository variable `BUILD_IOS` to `true`

## Phase 3: GitHub repository settings

**Decided (owner, 2026-11-13): the repository is private and stays on the Free plan (no GitHub Pro).** On a private
repository the Free plan has no rulesets or branch protection, no environment protection rules and no secret scanning or
CodeQL, so only the settings below apply. `develop` and `main` are protected by discipline (topic branch, pull request,
merge commit, the local `pre-push` hook), and **CI passed** is advisory. `.github/rulesets/` stays in the repository,
unused; import it if the plan ever changes (`docs/github-setup.md` section 5). Settings are changed in the GitHub web
interface by the owner; the assistant only reads them with `gh`.

- [x] Settings → General: default branch `develop`; template repository off; merge commits on, squash and rebase off;
  delete head branches on; wiki, projects and discussions off
- [x] Settings → General: "Always suggest updating pull request branches" on (auto-merge stays off: it needs required
  checks, which need a paid plan on a private repository)
- [x] Settings → Actions → General: allow GitHub-created actions plus `raven-actions/actionlint@*`,
  `zizmorcore/zizmor-action@*`, `google/osv-scanner-action/*`; require full-SHA pinning; artifact and log retention 30
  days; workflow permissions read-only and no PR approval by Actions (already so)
- [x] Settings → Advanced Security: dependency graph, Dependabot alerts, Dependabot security updates, grouped security
  updates (secret scanning, push protection, CodeQL and private vulnerability reporting are not available on a private
  Free repository)
- ~~Import the three rulesets~~ not available on the Free plan (private repository); kept in `.github/rulesets/`
- ~~Environments `staging` and `production` restricted to their branch~~ not available on the Free plan; the `staging`
  environment that a CI run created on its own stays unrestricted and holds no secret. Revisit with the Android signing
  block below
- [x] Merge the scaffold pull request with **Create a merge commit** (PR #1) and the first `core/config` pull request
  (PR #2)
- [x] Repository variable `BACKEND_REPO` and secret `BACKEND_READ_TOKEN` (fine-grained, read-only Contents on the
  backend repository only) added by the owner, 2026-11-13, to enable the weekly backend contract check. They cannot be
  read through the API, so the first manual run is the proof (next step)
- [ ] Run **Actions → Backend contract → Run workflow** once: green, summary "no published release yet" while the
  backend's releases are drafts (the workflow reached `develop` with PR #4 and has not run yet). The check stays quiet
  until the backend publishes a release, so a contract pinned by commit raises no issue in the meantime
- [ ] Note the expiry date of `BACKEND_READ_TOKEN` and renew it before then (`docs/consuming-the-api.md` section 4)
- [ ] Watch the Actions minutes (the Free plan includes a monthly quota for private repositories; the web, APK and
  AAB builds run on every pull request)

## Phase 4: Backend contract and generated client (D1, backend v0.1.0)

Branch: `feat/api-client`. Backend: the contract is pinned by commit while the release is a draft.

**Decided (owner, 2026-11-14): the backend keeps `v0.1.0` as a draft until the whole backend is finished, and this app
builds against a pinned commit meanwhile.** A draft has no `openapi.yaml` asset (and no tag), so `scripts/sync-api.sh v0.1.0`
cannot download it, and the weekly contract check sees no published release and stays quiet. The app pins the backend's
`openapi/schema.yaml` at one commit of the backend's `develop` branch with `scripts/sync-api.sh --commit <sha>`; the script
records the full SHA in `api/BACKEND_VERSION`, and a commit never changes, so the pin is as stable as a tag. The same
applies to the later contracts (`v0.2.0`, `v0.3.0`, `v1.0.0`) until the backend publishes its releases. Moving to a
different contract is always a pull request that changes `api/` and `lib/api` together. When the backend publishes a
release with its `openapi.yaml` asset, the pin moves to that tag in a pull request of its own.

- [x] `gh` is logged in for the account that can read the private backend repository
- [x] `api/BACKEND_REPO` with the backend repository (`OWNER/REPO`)
- [x] `flutter pub add dio retrofit json_annotation`
- [x] `flutter pub add --dev build_runner json_serializable retrofit_generator swagger_parser`
- [x] `swagger_parser.yaml` rewritten for `swagger_parser` 2.x (the template's keys belong to the 1.x series) and it can
  generate only this app's endpoints: `operation_filters` excludes the staff paths (`/api/v1/auth/**`, `/api/v1/staff/**`)
  and `prune_unused_models` drops the models only they use. Enums keep an `Unknown` case (`unknown_enum_values: preserve`)
- [x] `scripts/sync-api.sh --commit <sha>` with the sha of the backend `develop` commit that carries the `v0.1.0` contract
  (config, customer accounts, `restaurants/nearby`, `restaurants/{slug}`); it writes `api/openapi.yaml` and
  `api/BACKEND_VERSION`, and `scripts/generate-api.sh` generates `lib/api`. `info.version` in the pinned file reads `0.1.0`
- [x] `lib/api/**` is excluded from analysis (since Phase 2); `flutter analyze --fatal-infos` reports nothing
- [ ] Commit `api/` and `lib/api` together; the **API client is current** job is green
- [ ] Per-endpoint fixtures with invented values taken from the contract examples
- [ ] **Backend:** when the backend publishes `v0.1.0` with its `openapi.yaml` asset, run `scripts/sync-api.sh v0.1.0`
  in a pull request of its own and compare the diff with the commit pin (it should be empty or explained)

## Phase 5: App foundation (`lib/core`, `lib/theme`, `lib/app`)

Each block is its own small pull request (`feat/core-network`, `feat/theme`, …). No product screens yet.

Packages (confirm each when adding): `flutter_riverpod`, `go_router`, `intl`, `uuid`, `flutter_localizations`. Later, only
when their feature starts: `flutter_map`, `latlong2`, `geolocator`, `record`, `flutter_secure_storage`,
`shared_preferences` (non-sensitive settings only, never tokens).

- [ ] `app/`: `bootstrap()`, `ProviderScope`, global error zone, `go_router` with path URLs and a `/r/<slug>` route (slug
  shape validated), app shell, session state (auth, locale, config)
- [x] `core/config`: `AppEnvironment` reads `APP_ENV` (then the flavor); unknown counts as staging; unit tested
- [ ] `core/error`: sealed `Failure`, parser for the one error body (`type`, `errors[].code/detail/attr`), mapping by
  `code` (unknown code and non-JSON body become a generic failure of the HTTP status), with tests
- [ ] `core/network`: Dio factory with timeouts, interceptors for the auth header (`Customer <token>`, never on the
  public endpoints), `X-Request-ID` capture, locale, and **redacted** logging (no tokens, bodies or query strings); GET
  retry with backoff; `429` honours `Retry-After`; a `401` clears the session once
- [ ] `core/storage`: `TokenStore` interface and the interim web implementation (memory first);
  `flutter_secure_storage` implementation for Android and iOS when those targets start; never `shared_preferences` for
  tokens
- [ ] `core/platform`: interfaces (location, audio recorder, secure storage, wake lock, notifications) with web
  implementations as each is needed; shared code never imports `dart:io`
- [ ] `core/format`: money from integer fils (`AED 12.50` / `12.50 د.إ`), UTC to Asia/Dubai, distance, plates, Western
  digits always; unit tested in both languages
- [ ] `core/polling`: lifecycle-aware `Poller` (visible, idle, back-off, `Retry-After`) with tests
- [ ] `core/logging`: logger interface without personal data and a crash-report hook (the service is decided later)
- [ ] Localisation: ARB files `en` and `ar` in `l10n/`, locale controller, RTL, directionality helpers, every label from
  ARB
- [ ] `theme/`: Ink & Mustard tokens, `ColorScheme`, `ThemeExtension`, Rubik subset typography, component themes, light
  and dark
- [ ] Responsive helpers: compact (below 600), medium (600 to 839), expanded (840 and up), content max width 560
- [ ] `core/widgets`: loading, error with request id, empty state, responsive page frame
- [ ] `GET /config` on start (without a token), with the "waking up the server" message after 3 s
- [ ] Repositories in each feature's `data/` map DTOs to domain types; no generated type leaves `data/`
- [ ] Unit and widget tests for each block (money in both languages, error mapping, RTL smoke test)

## Phase 6: Customer account (D1)

Branch per screen group (`feat/account-signup`, …). Domain, data, application and presentation layers for each.

- [ ] Sign-up (full name, email or phone, password, language) with client-side checks for UX only
- [ ] Code screen (six digits, countdown from `code_expires_in_seconds`, resend disabled for
  `resend_available_in_seconds`); `verify` stores the token through `TokenStore`
- [ ] Error handling: `account_exists` (offer sign-in, at sign-up only), `code_invalid`, `code_expired`,
  `too_many_attempts`, `throttled`, `password_*` codes; unverified account goes to the code screen
- [ ] Sign-in with email or phone and password; logout (revokes this device's token and clears the store)
- [ ] Forgot password (code, then new password)
- [ ] Settings: show contacts and verified flags, add the missing contact with a code, language switch
- [ ] A `401` on any customer call clears the session and routes to sign-in, once
- [ ] Tests: notifiers with fakes, a widget test per screen, an integration test sign-up to verified, English and Arabic
  (RTL)

## Phase 7: Start screen and restaurant page (D1)

- [ ] Location permission flow: explain first (in-app sheet in the user's language), then the system prompt; handle denied
  and permanently denied (system settings, QR hint, staging simulate button); never re-prompt in a loop
- [ ] Start screen: map (loaded on demand, deferred import) with the position and a marker per nearby restaurant, bottom
  sheet with logo, name, distance, nearest first; polled with the lifecycle-aware poller
- [ ] Empty state from `nearest` (distance and parking lot) or the message with the QR hint
- [ ] Staging helper "Simulate: I'm at the restaurant" (`source = simulated`), hidden in production
- [ ] `/r/<slug>` route resolves through `GET /restaurants/{slug}`; `404` shows the not-found state
- [ ] **Decide** the map tile provider (OpenStreetMap is for staging only; a keyed provider before the pilot)
- [ ] Voice recording spike with `record` (WAV 16 kHz mono, 30 s): Chrome on Android and Safari on iPhone; report sizes
  and browser problems to the backend
- [ ] **First-load gate:** measure on a mid-range Android phone over mobile data and on an iPhone in Safari, empty and warm
  cache; try the WebAssembly build; record the numbers here and decide whether the entry point stays

## Phase 8: Staging web deploy (when the hosting is decided)

- [ ] Hosting decided (see "Decisions still open"); write the deploy workflow (pinned actions, `contents: read`,
  credentials as environment secrets), staging from `develop`, production from `main`, each with its
  `env/<environment>.json`
- [ ] The host serves `index.html` for unknown paths (path URL strategy, `/r/<slug>`)
- [ ] Security headers on the host (`_headers` or equivalent): strict CSP, no third-party scripts
- [ ] Backend CORS allows the staging origin (`https://wasli-customer-staging.pages.dev` today; change it together with
  the backend and the media bucket CORS rule if the hosting changes)
- [ ] Placeholder or real site live on staging; the release PR path to production written down

## Phase 9: Conversation and order (backend D2, release v0.2.0)

Backend: needs the `v0.2.0` contract. Pin it with a pull request of its own (`/pin-api`), then build. While the release
is a draft, pin the agreed backend commit (Phase 4).

- [ ] Pin `v0.2.0` (or its commit), regenerate `lib/api`, fix what the compiler reports
- [ ] Order channel modelled as a sealed domain type (`car` now; `dineIn` and `delivery` later); no "car" or "parking"
  words in shared code
- [ ] Chat shell: open or resume a conversation, append messages by `seq`, poll `?after_seq=` only while visible, stop 10
  minutes after a result arrives
- [ ] One widget per message kind: `text`, `image`, `order_summary`, `review`, `result`; unknown kinds degrade safely
- [ ] Quick replies: only those of the latest bot message are active
- [ ] Composer: text, send, microphone (record with timer, send or cancel, 30 s max), disabled states (sending, placed,
  assistant unavailable)
- [ ] Send with idempotency: `client_message_id` generated once per action, persisted until acknowledged, the same id on
  retry
- [ ] Position at `ask_car` (QR arrivals ask for location here), accuracy and range checks, `invalid_location` handling
- [ ] Item picker for `ai_available: false` (built from the structured menu, sends item ids and quantities only; the app
  never computes a price)
- [ ] Review card and result cards (accepted with wait time, rejected with reason and note), "Order again"
- [ ] Order status from `GET /orders/{id}`; polling shows what the server decides, the app decides nothing
- [ ] Phone-verification gate before the first order for an email-only customer (**Backend**: needs the agreed error code)
- [ ] Error mapping for the chat codes (`invalid_action_for_state`, `conversation_expired`, `audio_too_large`,
  `audio_too_long`, `unsupported_audio_format`, `ai_unavailable`, `transcription_failed`, `item_unavailable`,
  `outside_parking_lot`)
- [ ] Tests: merge by `seq`, polling rules, retry with the same id, every message kind, composer states, recorder with a
  fake, item picker, RTL smoke test, an integration test sign-up to order placed against a fake server

## Phase 10: Restaurant answers and polish (backend D3 and D4, releases v0.3.0 and v1.0.0)

- [ ] Pin `v0.3.0` (or its commit); accepted and rejected results appear in the chat; show staging to restaurant managers
- [ ] Optional `ready` status when the backend offers it
- [ ] Arabic and English complete, RTL checked on every screen at compact, medium and expanded widths
- [ ] "Pretend I'm 2 km away" in the chat menu (staging only)
- [ ] Wake-up helper, splash, empty and error states reviewed
- [ ] Accessibility pass (contrast, text scaling, screen reader labels, focus order)
- [ ] First-load measurement repeated on the final build; bundle-size budget decided and enforced in CI
- [ ] Pin `v1.0.0` of the contract

## Phase 11: Before the pilot

- [ ] Production hosting, domain and CORS origins; web cookie session if the backend offers it (token storage target)
- [ ] `env/production.json` with the production `API_BASE_URL` and `CUSTOMER_SITE_URL`
- [ ] Token storage hardened on web: strict CSP and security headers on the host, no third-party scripts
- [ ] Keyed map tile provider
- [ ] Error-reporting service chosen and wired without personal data
- [ ] Phone verification and the cash or card question, as agreed with the backend
- [ ] Privacy policy, terms and the font licence text reachable from the app
- [ ] Minimum-version check from `/config` (`min_app_version`)
- [ ] First production release: raise `version:` in `pubspec.yaml`, release pull request `develop` → `main`, test the
  production build, merge, publish the draft release `v<version>`
- [ ] Rollback rehearsed: redeploy the previous release tag

## Phase 12: Mobile apps (near future)

- [ ] The Android and iOS folders, the application ID and the Android flavors exist since Phase 2 and the iOS flavors since
  "iOS flavors (needs a Mac)"; here the apps become real products
- [ ] `flutter_secure_storage` token store, Android backups exclude it, cleared on logout and on `401`
- [ ] Universal links (iOS) and app links (Android) for `/r/<slug>`
- [ ] Release builds obfuscated with split debug info; certificate pinning only with a rotation plan
- [ ] Push notifications; saved car; realtime instead of polling (when the backend offers it)
- [ ] iOS signing (certificates, provisioning, TestFlight) on a macOS runner (`docs/environments.md`, "Not set up yet")
- [ ] Store listings, staged rollouts, Google Play and App Store Connect setup

## Phase 13: Later channels

- [ ] Dine-in ordering: order type from the backend, table QR codes, no location step (`dine_in/` feature)
- [ ] Home delivery: address picker, delivery zone, fee and minimum, more statuses, online payment (`delivery/` feature)
- [ ] Online payment, offers, translated notes

## Decisions still open

- [ ] Hosting of the site and the custom domain (the web cookie session, the image CDN and the email sender need it too)
- [ ] First-load target (proposal: usable in about 4 s on 4G, empty cache) and who measures it
- [ ] Production site name and CORS origin (after the hosting decision)
- [ ] Map tile provider and error-reporting service
- [ ] Bundle-size budget (after the first measurement); certificate pinning (native apps only)
- [ ] Who provides the Arabic UI copy, the logo and the font licence text for the licence page
- [ ] How the app knows it is on staging (proposal: build-time `APP_ENV` or flavor)

## Backend requests (API request issues in the backend repository, with invented example values)

- [ ] Phone verified before the first order for an email-only customer: refusal status and error code, and how the app
  starts the verification (it reuses `me/contact` and `me/contact/verify`)
- [ ] Order type (`car`, `dine_in`, `delivery`) in the conversation and order model, before D2 freezes it
- [ ] Token expiry and rotation, per-device tokens
- [ ] HttpOnly cookie session for the web once a custom domain exists
- [ ] `min_app_version` in `/config` before any native app ships

---

## Routine steps for every change

- [ ] Start from an up-to-date `develop`; one topic branch per change
- [ ] `dart format --set-exit-if-changed .`, `flutter analyze --fatal-infos`, `flutter test` pass
- [ ] Conventional Commit messages; pull request into `develop` with the template filled in; merge commit
- [ ] A change to `api/openapi.yaml` includes the regenerated `lib/api`
- [ ] This file updated when the plan changes
