# Contract-fidelity local reconstruction of Next.js CDK order center

> Date: 2026-08-01
>
> Scenario: Web/API/JS reverse engineering and local reconstruction
>
> redaction: The target domain name and port use standard placeholders; credentials, CDK, order identification and private paths only retain categories and do not record the original values.

## Scene classification

Web/API/JS Reverse

## Goal overview

Establish a four-source evidence chain of "entry snapshot, static bundle, runtime page, and public OpenAPI" for a Next.js single-page order center. Without connecting real payments, workers, and inspection services, a runnable local project with the same information architecture, browser request shape, response projection, and order status semantics can be reconstructed.

## Scope Summary (redaction)

- auth_basis: The user provides the entrance and requires analysis and the same local implementation
- network_profile: public entrance and public OpenAPI read-only review; both build and acceptance point to the loopback address
- asset_types: [web, frontend_js, public_openapi, screenshot, local_source]
- fixture_profile: synthetic CDK, synthetic credential, synthetic payment link, deterministic worker/check/payment adapter

## Role

- lead_role: lead
- specialists: [cre, doc]

## Complete execution link

1. Solidify entry HTML, response headers, expose OpenAPI and SHA-256, and reuse existing static packages and browser forensics.
2. Extract routes, request body fields, headers, storage keys, polling cycles, conditional rendering and status vocabularies from the main page bundle.
3. Model the page's internal legacy API and the public v1 API separately, and establish their own serializers to avoid field drift caused by shared DTOs.
4. Calculate desktop geometry, mobile breakpoints, card hierarchy, control states, and copywriting baselines from runtime full-page screenshots, DOM, and CSS.
5. Establish canonical domain model, CDK ledger and deterministic state machine; external capabilities are undertaken through `CHECK_FN`, `PAYMENT_PROVIDER`, `WORKER_GATEWAY` fixture adapters.
6. Reduce credentials and payment links to digest, type, and security hints immediately during request; persistence model does not set source slots.
7. Perform contract testing on single, batch, detail, cancellation, redraw, pagination, dual authentication and OpenAPI documents.
8. Use desktop and mobile browser screenshots to verify the vision; use production builds, interface smoke, secret scans and decompression rechecks to form delivery evidence.

## Evidence chain summary (redaction)

| E-id | source_type | Reusable command mode | Associated conclusion |
|------|-------------|----------------|----------|
| E-001 | network/file | `curl -D headers -o page https://{target_domain}/<entry>; shasum -a 256 page` | Frame entry and timestamp baseline |
| E-002 | frontend_js/openapi | `rg 'sessionStorage|/api/|productType|customerToken' {formatted_chunk}`; `jq '{info,paths,securitySchemes}' openapi.json` | legacy requests, state, browser storage and v1 contracts |
| E-003 | runtime_visual/local_qa | `chromium --headless ...; screenshot + DOMRect`; `npm test && npm run build && BASE_URL=... npm run smoke` | Desktop/mobile geometry, conditional rendering and local contract closed loop |

## Finding/Path Summary

- top_finding: The page's internal legacy API shares business semantics with the public v1 API, but the request fields, authentication entries, and response projections are different. "One domain model and two boundary serializers" are required for reconstruction.
- path_type: callflow
- path_one_liner: form input -> page field mapping -> legacy Route Handler -> canonical service -> fixture adapter/ledger -> legacy serializer -> polling rendering.

## Trampling on pit records

| Problem | Cause | Solution | Time consuming |
|------|------|---------|------|
| Only building interfaces based on route names still results in blank page fields | The response fields of legacy and v1 are not the same DTO | Reverse the serializer from the attribute reading point of the bundle, and do contract testing on the two sets of boundaries | ~45 min |
| The initial form of the page is mixed with the bound form | Many cards, prompts, buttons and lists are rendered conditionally | First solidify the unbound baseline, and then create an interaction matrix according to CDK/order status | ~30 min |
| The batch interface needs to express partial success and ledger consistency at the same time | Promoting a single error into a whole batch of exceptions will lose the item-by-item result semantics of the original page | First parse item by item, and then generate created/duplicate/failed in order within a store mutation, and finally verify the ledger uniformly and place it atomically | ~35 min |
| Document required fields and property names are ambiguous | OpenAPI evolves independently from the internal call surface of the page | Retain canonical fields while identifying compatible alias at the boundary; report single-column ruling basis | ~15 min |
| The visual seems to be close but the vertical errors continue to accumulate | The small deviations of card padding, line-height, and gap are superimposed | Using the complete page height, main column width and key DOMRect as constraints, segment-by-section regression screenshots | ~40 min |
| The fixture prompt copy destroys the first screen of the same product | Implementation instructions are directly mixed into the product UI | UI maintains the forensic baseline, and fixture instructions are placed in README; input still uses deterministic examples | ~15 min |

## Toolchain discovery

- The static bundle's attribute read points are better suited for recovering responsive DTOs than the interface path itself.
- The legacy/v1 serializer layer enables page compatibility and public API stability at the same time.
- `fullPage` screenshots should combine the viewport width, total page height and DOMRect; pure pixel similarity will be amplified by font anti-aliasing.
- Batch orders should retain item-by-item created/duplicate/failed; deduplication, capacity deduction, and ledger verification should be placed in the same mutation, and only one atomic file replacement should be performed in the end.
- Secret scans should cover the source code, runtime store, test logs, and final tarball expansion directory, not just the Git working tree.

## Key code/command

```bash
# Static call surface and status fields
rg -n 'customerToken|productType|upiExpiresAt|customerResubmitCount|sessionStorage' {formatted_chunk}

# Expose API structure
jq '{openapi,info,paths:(.paths|keys),security:.components.securitySchemes}' openapi.json

# local quality gate
npm run lint
npm test
npx tsc --noEmit
npm run build
BASE_URL=http://127.0.0.1:{port} npm run smoke
```

## Suggestions for improvements to this package

1. `js-reverse` adds "legacy UI API and public API dual serializer" checklist.
2. Report template adds "Visual Baseline Geometry Table" and "Initial/Binding/Order Status Matrix".
3. The QA template adds batch partial success and atomic disk placement, dual authentication OR, OpenAPI schema/actual response consistency and delivery package expansion scanning.

## Reusable patterns/script snippets

1. **Four-source cross**: Portal snapshot positioning version, static bundle restores the call surface, runtime restores conditional rendering, and OpenAPI restores the public contract.
2. **One core and two projections**: canonical domain keeps the state unified with the ledger, and legacy/public serializer maintains boundary fidelity.
3. **Initial state first, then state matrix**: First lock the unbound home screen, then verify binding, creation, in progress, completion, cancellation, and resubmit.
4. **Request period reduction**: The original input is converted into SHA-256, type and mask immediately after entering the service. The log and store only receive the reduction results.
5. **Second re-inspection of the delivery package**: Extract the compressed package to a new directory, reinstall, test and build to avoid the problem of residual masking of the working directory.

## evolution action

- [ ] Updated routing matrix
- [ ] updated tool-index
- [ ] updated bootstrap-manifest
- [ ] Updated sub-skill documentation
- [x] Added pitfalls record
- [ ] No update required

## environmental information

- OS: macOS
- Tool versions: Node.js 24, Next.js 16.2.12 App Router, React, TypeScript 5.9.3, Chrome/Playwright
- Target platforms/versions: Next.js App Router / React / OpenAPI 3.1

## final acceptance record

- ESLint, TypeScript 5.9.3, Next.js 16.2.12 production build: passed.
- Node test: 8/8 passed.
- HTTP smoke: 15 contract groups passed.
- Playwright: 11 state/viewport screenshots, 10 sets of assertions passed, browser console and page error are both empty.
- The 1440 px initial page and baseline dimensions are the same as 1440×1294; RGB MAE 2.301148, pixel ratio within 5/channel threshold is 0.945085.

## redaction review

- [x] Replace the target domain name with `{target_domain}`
- [x] The original text of CDK, order number, Token, Cookie, JWT and payment link is not written
- [x] The real IP, port and local private path are not written
- [x] Run command using `{port}` with placeholder
- [x] The delivery experience only retains the method, structure and verification model

---
<!-- [Community Contribution] After completion, ask the user whether to PR to the main repository. -->
