# fallback strategy

Rewind in sequence when there is no progress on the current path:

1. Rollback from breakpoint to request observation
2. Fallback from source code guessing to runtime evidence
3. Fall back from Node environment repair to page forensics
4. Falling back from deep deobfuscation to the smallest reproducible link
