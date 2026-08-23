# FAB-150 step 3 — Release pipeline from CI (unblocks TestFlight before Xcode 27 GA)

**Version:** 1.0 · **Date:** 2026-08-03 · **Status:** Active

**Parent issue:** [FAB-150](../BACKLOG.md) — [Phase 2] App Store release checklist
**Builds on:** FAB-8 (GitHub Actions CI workflow, `.github/workflows/ci.yml`)
**Goal:** Produce a signed, uploadable archive from GitHub Actions, so shipping doesn't depend on which Xcode runs on Fabio's laptop.
**Done when:** A tagged commit produces a TestFlight build without anyone opening Xcode.

> Requirements verified 2026-08-03. Re-check Apple's [upcoming requirements](https://www.developer.apple.com/news/upcoming-requirements/) and the [runner image readme](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md) before acting.

---

## Correcting the record

Earlier FAB-150 plans state that TestFlight is blocked until **Xcode 27 reaches GA**. **That is wrong**, and the error has propagated into `docs/plans/FAB-150-step1a-manifest-and-docs-fixes.md`, `docs/plans/FAB-150-step2-app-store-connect-prep.md`, and `docs/PROJECT_STATUS.md` (via commit `c92d680`). Task 5 below fixes all three.

What's actually true:

- Since **28 April 2026**, App Store Connect requires uploads to be built with **Xcode 26 or later, using the iOS 26 SDK or later**. The floor is Xcode **26**, not 27.
- **GitHub Actions `macos-26` runners are generally available** and ship Xcode 26.x (default moved to 26.6 in July 2026). That satisfies the requirement today.
- Fabio's laptop was never the only build machine. Local toolchain constraints don't gate releases if CI can archive.

The one thing that *is* still true: builds from a **beta** Xcode aren't accepted, so his local Xcode 27 beta can't produce the submittable binary. CI can.

---

## Task 0 — Fabio's manual prerequisites (nobody else can do these)

Both produce secrets that Task 2 and Task 3 consume. Neither needs a working Xcode. Do them in this order — the certificate steps depend on where the private key lives.

### 0a. Create an App Store Connect API key

This authorizes CI to manage provisioning profiles and upload builds without an Apple ID session.

1. Go to [appstoreconnect.apple.com/access/integrations/api](https://appstoreconnect.apple.com/access/integrations/api) — or App Store Connect → **Users and Access** (top-right menu) → **Integrations** tab → **App Store Connect API**.
2. Click **+** (or **Generate API Key**).
3. **Name:** something identifiable, e.g. `Verso CI Release`.
4. **Access role:** choose **App Manager**. Reasoning: `-allowProvisioningUpdates` needs to create and download provisioning profiles, and the **Developer** role can't. **Admin** also works but grants more than CI needs — App Manager is the smallest role that does the job.
5. Click **Generate**.
6. Click **Download API Key**. You get `AuthKey_XXXXXXXXXX.p8`.

> ⚠️ **The `.p8` downloads exactly once.** There is no second chance — if you lose it, the key must be revoked and replaced. Save it somewhere durable (password manager) before closing the tab.

7. Record two more values from that page:
   - **Key ID** — the 10-character string in the Key ID column (also embedded in the filename).
   - **Issuer ID** — a UUID shown at the top of the page, above the key list. Easy to miss; it is *not* per-key.

You now have: the `.p8` file, the Key ID, the Issuer ID.

### 0b. Create and export the distribution certificate

The goal is a `.p12` containing **both** the certificate and its private key. The private key only ever exists on the Mac that generates the request — so do every step below on the same machine.

**Check first:** you may already have one. [developer.apple.com/account/resources/certificates](https://developer.apple.com/account/resources/certificates) → look for an **Apple Distribution** certificate. If one exists *and* you have its private key in Keychain Access, skip to step 5. If it exists but the private key is gone, revoke it and start at step 1 — a certificate without its private key cannot sign anything.

1. Open **Keychain Access** (Applications → Utilities).
2. Menu bar → **Keychain Access** → **Certificate Assistant** → **Request a Certificate From a Certificate Authority…**
3. Fill in:
   - **User Email Address:** your Apple ID email
   - **Common Name:** something like `Fabio Sasseron`
   - **CA Email Address:** leave blank
   - Select **Saved to disk** (not "Emailed to the CA")
4. Save the `CertificateSigningRequest.certSigningRequest` file. This also silently creates a matching private key in your login keychain — that key is what makes the `.p12` usable, so don't clean it up.
5. Go to [developer.apple.com/account/resources/certificates](https://developer.apple.com/account/resources/certificates) → **+**.
6. Choose **Apple Distribution** (under Software). Not "Apple Development" — that can't sign App Store builds.
7. Upload the `.certSigningRequest` file from step 4 → **Continue** → **Download**. You get `distribution.cer`.
8. **Double-click `distribution.cer`** to install it into Keychain Access.
9. In Keychain Access, select the **login** keychain, then the **My Certificates** tab.

> If the certificate appears under **Certificates** but not **My Certificates**, the private key isn't attached and the export will produce something CI can't sign with. That usually means the CSR was generated on a different Mac. Go back to step 1 on this machine.

10. Find **Apple Distribution: <your name> (TEAMID)**. Expand the disclosure triangle — you should see a private key nested under it.
11. Right-click the certificate → **Export "Apple Distribution: …"** → format **Personal Information Exchange (.p12)**.
12. Set a password when prompted. **Write it down** — it becomes the `DIST_CERT_PASSWORD` secret. macOS may then ask for your *login* password to authorize the export; that's a different thing and isn't stored anywhere.

### 0c. Convert both files to base64 and add the GitHub secrets

GitHub secrets hold text, so the two binary files need encoding. In Terminal:

```bash
base64 -i AuthKey_XXXXXXXXXX.p8 | pbcopy   # paste as ASC_KEY_P8
base64 -i Certificates.p12     | pbcopy   # paste as DIST_CERT_P12
```

Each command puts the encoded text on your clipboard, one at a time.

Add all six at **github.com/whysasse/verso-app → Settings → Secrets and variables → Actions → New repository secret**:

| Secret name | Value |
|---|---|
| `ASC_KEY_ID` | Key ID from 0a step 7 |
| `ASC_ISSUER_ID` | Issuer ID from 0a step 7 |
| `ASC_KEY_P8` | base64 of the `.p8` |
| `DIST_CERT_P12` | base64 of the `.p12` |
| `DIST_CERT_PASSWORD` | the password from 0b step 12 |
| `DEVELOPMENT_TEAM` | your Team ID (same value as in `Secrets.xcconfig`) |

> **Never commit the `.p8`, the `.p12`, or the base64 text.** They aren't covered by the `Secrets.xcconfig` gitignore rule. Keep them outside the repo directory entirely so a stray `git add` can't reach them.

Once these exist, Tasks 2 and 3 are unblocked. Tasks 1, 4, and 5 don't depend on them and can proceed in parallel.

---

## Task 1 — Retarget CI to an Xcode that can actually ship

`.github/workflows/ci.yml` currently pins:

```yaml
runs-on: macos-15
- uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: "latest-stable"
```

On a `macos-15` image, `latest-stable` resolves to an Xcode 16.x — **below Apple's April 2026 floor**. The existing workflow is a perfectly good compile check, but it could never produce an uploadable build.

Move the image to `macos-26`. Pin the Xcode version explicitly rather than using `latest-stable`: GitHub rotates the default (26.5 → 26.6 in July 2026), and a release pipeline that silently changes compiler under you is a bad trade for the convenience. Pick a specific 26.x present on the image and note in a comment why it's pinned.

**Check whether CI is currently green before changing anything.** If it's been passing on `macos-15`/Xcode 16.x, that's strong evidence the codebase compiles far below Swift 6.4 and the move to 26.x is low-risk. If it's red, fix that first — don't build a release pipeline on top of a broken build.

Note on `SwiftSoup 2.13.7`: the floor was raised (`011122c`) to dodge a Swift 6.4 compiler regression. On Xcode 26.x that workaround is inert but harmless. **Leave it.** Reverting it would break Fabio's local beta-Xcode builds.

---

## Task 2 — Signing in CI

Automatic signing as configured today (`CODE_SIGN_STYLE: Automatic`, team from `Secrets.xcconfig`) works locally because Xcode is signed into an Apple ID. CI has no such session. Two viable approaches:

**Preferred: App Store Connect API key + `-allowProvisioningUpdates`.** Modern, no fastlane dependency, and lets automatic signing keep working. `xcodebuild` accepts `-authenticationKeyPath`, `-authenticationKeyID`, `-authenticationKeyIssuerID`, and will create/download profiles as needed.

**Alternative: manual signing** with a pre-created distribution profile committed as a secret. More moving parts and more drift, but fully deterministic. Only choose this if the API key path proves unworkable.

Either way, the **distribution certificate's private key must be in the runner's keychain** — the API key authorizes profile management, not signing itself. That means exporting the distribution certificate as a `.p12` and storing it base64-encoded as a secret, plus a script step that creates a temporary keychain, imports it, and unlocks it. Use a throwaway keychain, not the login keychain, and delete it in an `always()` post step.

Secrets needed (GitHub → Settings → Secrets and variables → Actions):

| Secret | What it is |
|---|---|
| `ASC_KEY_ID` | App Store Connect API key ID |
| `ASC_ISSUER_ID` | API key issuer ID |
| `ASC_KEY_P8` | The `.p8` private key, base64 |
| `DIST_CERT_P12` | Distribution certificate + private key, base64 |
| `DIST_CERT_PASSWORD` | Password used when exporting the `.p12` |
| `DEVELOPMENT_TEAM` | Team ID — CI has no `Secrets.xcconfig` |

**`Secrets.xcconfig` is gitignored, so CI doesn't have it.** `generate-xcodeproj.sh` bootstraps it from the template, which leaves `DEVELOPMENT_TEAM` empty and prints the warning added in step 1. The release job must write a real `Secrets.xcconfig` from secrets before running the generate script. Don't work around this by committing the file or hardcoding the team in `project.yml` — that would undo step 1 deliberately.

**Fabio creates the API key and exports the certificate — see Task 0**, which has the step-by-step. Neither can be done by an agent. Do not attempt to work around missing secrets by generating throwaway credentials or skipping signing; if the secrets aren't present, build what can be built and report the blocker.

---

## Task 3 — Archive, export, upload

A separate workflow (`.github/workflows/release.yml`), triggered by a version tag or `workflow_dispatch` — **not** on every push. Steps:

1. Write `Secrets.xcconfig` from secrets; run `generate-xcodeproj.sh`.
2. Set up keychain and API key.
3. `xcodebuild archive` — scheme `Verso`, configuration `Release`, `-destination "generic/platform=iOS"`, with `-allowProvisioningUpdates` and the authentication flags.
4. `xcodebuild -exportArchive` with an `ExportOptions.plist` (`method: app-store-connect`). Commit that plist to the repo — it's configuration, not a secret.
5. Upload. `xcrun altool --upload-app` works; Apple has been steering toward `notarytool`/Transporter, so check what's current on the runner image rather than assuming.
6. Delete the temporary keychain in an `always()` step.

**Build number must increment per upload** — App Store Connect rejects duplicates. `CURRENT_PROJECT_VERSION` is now a single project-level setting (from step 1's Task 4), so drive it from `github.run_number` or the tag, and confirm the value reaches *both* the app and the extension `Info.plist`. Step 1 made them share a source; verify that still holds in a Release archive, not just Debug.

Expect the first few runs to fail on provisioning specifics. That's normal — budget for iteration rather than treating it as a sign the approach is wrong.

---

## Task 4 — Name the QA gap this creates

Worth stating plainly, because it's the real cost of this approach:

Fabio develops against the **iOS 27 SDK** (Xcode 27 beta). CI would ship against the **iOS 26 SDK**. Those are different binaries, and linking against a different SDK can change system-provided behaviour — control appearance, default animations, layout metrics.

He would be testing something he isn't shipping.

Mitigation: treat the **TestFlight build as the QA artifact**. Install it on a real device and check it there before promoting, rather than signing off from local Debug builds. Worth an explicit line in `docs/BACKLOG.md` under FAB-150 so it isn't forgotten at submission time.

This gap closes on its own once Xcode 27 is GA and local and CI converge.

---

## Task 5 — Fix the propagated error

Correct the "blocked until Xcode 27 GA" claim in:

1. **`docs/PROJECT_STATUS.md`** — the "🔲 Remaining (iOS)" section, added in `c92d680`. Replace with the accurate constraint: the floor is Xcode 26; local beta-Xcode builds aren't submittable; CI on `macos-26` is the path.
2. **`docs/plans/FAB-150-step1a-manifest-and-docs-fixes.md`** — "Explicitly out of scope."
3. **`docs/plans/FAB-150-step2-app-store-connect-prep.md`** — "Why now" and "Out of scope."

Keep the substance of what's still correct in those sections (don't archive locally-built binaries; don't downgrade macOS). Only the *conclusion about timing* changes.

---

## Is this worth doing?

State the trade-off for Fabio rather than assuming the answer.

**Against:** Xcode 27 GA has historically landed alongside the autumn OS releases, plausibly ~2 months out. This is perhaps a day or two of fiddly secrets-and-provisioning work to ship maybe six weeks earlier.

**For:** the pipeline outlives the constraint. Reproducible releases that don't depend on one laptop's toolchain are worth having regardless, and every subsequent release gets cheaper. It also removes a single point of failure that has already cost this project time once.

**Recommendation: do it**, but treat Task 1 as the real checkpoint. If moving CI to `macos-26` shows the codebase compiling cleanly on Xcode 26.x, the rest is well-trodden. If it surfaces compilation problems, that's new information and worth re-deciding on.

---

## Out of scope

Not a substitute for step 2 — metadata, age rating, trader status, screenshots, and the `InAppWebView` fix are all still required, and none of them are affected by how the binary gets built.

Don't set up code signing for the existing `ci.yml` build job. It should stay unsigned and fast; only the release workflow needs secrets.

---

## Sources

- [Apple: SDK minimum requirements](https://www.developer.apple.com/news/upcoming-requirements/) — Xcode 26 / iOS 26 SDK floor from 28 April 2026
- [macos-26 generally available for GitHub-hosted runners](https://github.blog/changelog/2026-02-26-macos-26-is-now-generally-available-for-github-hosted-runners/)
- [macos-26 runner image contents](https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md) — installed Xcode versions
- [Default Xcode on macOS 26 set to 26.6 (2026-07-21)](https://github.com/actions/runner-images/issues/14344)
- [Xcode 27 runner image in public preview](https://github.blog/changelog/2026-07-16-xcode-27-runner-image-now-in-public-preview/)
