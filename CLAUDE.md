# CLAUDE.md — Instructions for Claude Code

## IMPORTANT: If this is the first message in a session or context was recently compacted, read this entire file before doing anything else.

## Project: PlausiDen-OS-for-Mobile
Sovereign mobile OS on seL4 microkernel targeting Pixel 10 Pro XL. Four protection domains: Brain (LFI engine), Shield (network defense), Vault (deniable storage), and paravirtualized GrapheneOS.

## CRITICAL DISAMBIGUATION — READ THIS

This repo contains three protection domain crates: `brain-pd`, `shield-pd`, `vault-pd`. These are **NOT** the same as the infrastructure repos with similar names:

| This Repo (Phone OS) | Infrastructure Repo (Servers) |
|---|---|
| **brain-pd/** — LFI engine, data generation decisions | No equivalent infra repo |
| **shield-pd/** — Network packet interception, DNS pollution | **plausiden-shield** — Server monitoring dashboard |
| **vault-pd/** — Deniable encrypted storage, duress PIN | **plausiden-vault** — Vaultwarden, KeePassXC, TOTP |

**Rules:**
- NEVER import plausiden-vault (infra) into vault-pd (OS) or vice versa
- NEVER import plausiden-shield (infra) into shield-pd (OS) or vice versa
- If a task says "vault" or "shield" without specifying, ASK which one
- PD crates target seL4 and should be `no_std` compatible where possible
- Infrastructure repos are normal `std` Rust running on Linux servers

## Architecture
```
PlausiDen-OS-for-Mobile/
├── brain-pd/     # LFI engine, data generation, swarm control, key mgmt
├── shield-pd/    # Network filter, DNS pollution, TLS diversity, forensic detection
├── vault-pd/     # Personalities, deniable volumes, duress PIN, Scorched Earth
├── kernel/       # seL4 config, CAmkES components, boot chain
├── android-shim/ # Thin Kotlin bridge to PDs via Unix socket
└── docs/         # THREAT-MODEL, PERSONALITY-SYSTEM, DURESS-PROTOCOL, SCORCHED-EARTH
```

## Key Specifications
- See docs/PERSONALITY-SYSTEM.md — multiple encrypted personalities
- See docs/DURESS-PROTOCOL.md — duress PIN activates decoy
- See docs/SCORCHED-EARTH.md — irreversible key destruction

## Code Standards
- Rust edition 2024. `gen` is reserved — never use as variable name.
- thiserror for errors. Never unwrap() in library code.
- All crypto: ChaCha20-Poly1305, Argon2id, Ed25519, BLAKE3. No custom crypto.
- zeroize ALL key material after use.
- PD crates should work toward no_std compatibility (seL4 target).

## Narrative Framing
Civil rights tool. Protects journalists, activists, defense attorneys' clients.
NEVER include personal political beliefs or ideology.
