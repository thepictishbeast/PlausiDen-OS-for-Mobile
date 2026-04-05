# Personality System Specification

## Overview

PlausiDenOS supports multiple encrypted "personalities" — each a complete, independent device environment with its own filesystem, contacts, messages, apps, and behavioral profile. Only one personality is active at a time. Inactive personalities are encrypted and indistinguishable from random data.

## Architecture

```
┌─────────────────────────────────────────┐
│              Vault PD                    │
│                                         │
│  ┌──────────┐ ┌──────────┐ ┌─────────┐ │
│  │ Personal │ │ Decoy    │ │ Work    │ │
│  │ (real)   │ │ (duress) │ │ (alt)   │ │
│  │ ChaCha20 │ │ ChaCha20 │ │ ChaCha20│ │
│  └────┬─────┘ └────┬─────┘ └────┬────┘ │
│       │             │            │      │
│  ┌────▼─────────────▼────────────▼────┐ │
│  │    Deniable Volume Layer           │ │
│  │    (all volumes look like random)  │ │
│  └────────────────┬───────────────────┘ │
└───────────────────┼─────────────────────┘
                    │ mount active only
                    ▼
┌───────────────────────────────────────────┐
│           Android VM (GrapheneOS)         │
│   Sees ONLY the active personality's data │
└───────────────────────────────────────────┘
```

## Personality Contents

Each personality contains:

| Component | Description |
|-----------|-------------|
| Filesystem | Personal files, documents, photos, downloads |
| Contacts | Phone contacts with names, numbers, photos |
| Messages | SMS, messaging app databases |
| Call history | Incoming, outgoing, missed calls with timestamps |
| Browser data | History, cookies, bookmarks, passwords |
| App data | Per-app data directories |
| Location history | GPS traces, WiFi connection history |
| Behavioral profile | Usage patterns fed to Brain PD for synthetic activity |

## LFI-Generated Activity

Brain PD continuously generates activity for ALL personalities, not just the active one. This ensures:

- No personality appears "stale" when activated (a 2-week gap in messages is suspicious)
- Each personality has internally consistent data (contacts referenced in messages exist in the contact list)
- Activity patterns match the personality's behavioral profile (a "work" personality has 9-5 activity)
- A forensic analyst examining any personality sees a believable, lived-in device

## Volume Encryption

Each personality maps to an encrypted volume:

```
volume_key = Argon2id(pin, device_salt, 64 MiB, 3 iterations)
encrypted_data = ChaCha20-Poly1305(volume_key, nonce, plaintext)
```

Properties:
- ChaCha20-Poly1305 output is uniformly random — encrypted volumes are indistinguishable from unallocated space
- No volume headers or magic bytes — there is no structural indicator of how many volumes exist
- Volume sizes are pre-allocated to the full partition — a 1 GB personality and a 10 GB personality occupy the same space on disk
- Decryption with the wrong key produces random data, not an error — the system cannot distinguish "wrong key" from "no volume here"

## Personality Switching

1. User locks the device
2. User enters a PIN at the lock screen
3. Vault PD derives the key from the PIN
4. Vault PD decrypts the corresponding volume
5. Vault PD unmounts the previous personality's filesystem
6. Vault PD mounts the new personality's filesystem
7. Android VM sees the new personality's data

The switch is seamless — Android restarts with the new personality's data loaded. There is no "personality picker" UI. The PIN determines which personality loads.

## Maximum Personalities

Limited by available storage. Each personality requires a pre-allocated volume. With 256 GB storage:
- 2 personalities: ~120 GB each (plus OS overhead)
- 4 personalities: ~60 GB each
- 8 personalities: ~30 GB each

Recommended default: 2 (real + duress decoy). Advanced users can configure more.
