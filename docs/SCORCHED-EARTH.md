# Scorched Earth Protocol Specification

## Overview

Scorched Earth is a key material destruction protocol. When triggered, it irreversibly destroys all encryption keys, making all personality data permanently unrecoverable. The device appears to have been factory-reset.

## Trigger Mechanisms

| Trigger | Activation |
|---------|------------|
| Scorched Earth PIN | User enters the designated PIN at the unlock screen |
| Inactivity timeout | Device not unlocked within N days (configurable, default 14) |
| Physical tamper | Chassis intrusion detection, SIM removal (configurable) |
| Remote signal | Authenticated signal via P2P swarm (requires pre-configured key) |
| USB forensic detection | Device detects connection to known forensic tools (Cellebrite, GrayKey) |

## Destruction Sequence

1. **Key zeroization**: All personality encryption keys are overwritten with zeros, then the memory pages are explicitly wiped via `zeroize`. This takes milliseconds.

2. **Salt destruction**: The device salt used for key derivation is destroyed. Even if a PIN is later provided, the key cannot be re-derived without the salt.

3. **Metadata scrub**: Any metadata that could reveal the number of personalities, their sizes, or their last-active timestamps is overwritten.

4. **Storage randomization**: The encrypted personality volumes are overwritten with random data. Since they were already indistinguishable from random data (ChaCha20-Poly1305 output is uniformly random), this step is optional but provides defense-in-depth.

5. **Factory reset appearance**: The device boots to a standard Android setup wizard. To a forensic analyst, the device appears to have been factory-reset by the user — a normal, non-suspicious action.

## Indistinguishability from Factory Reset

The post-Scorched-Earth state must be indistinguishable from a genuine factory reset:
- Same boot sequence
- Same setup wizard
- Same partition layout
- No residual PlausiDenOS artifacts in accessible storage
- NAND/flash wear patterns are the only potential indicator, and these are ambiguous (could indicate normal use patterns)

## Irreversibility

Scorched Earth is intentionally irreversible. There is no recovery mechanism. This is a feature — if recovery were possible, an adversary with sufficient resources could also recover. The user must understand this before configuring Scorched Earth triggers.

## Legal Considerations

Triggering Scorched Earth after a device has been seized under a court order may constitute destruction of evidence in some jurisdictions. Users must evaluate their legal situation. The inactivity timeout and USB forensic detection triggers are designed to activate before seizure, not after.

The remote signal trigger raises additional legal questions — is it the user or a third party destroying the data? The protocol is designed so that only the user can configure the remote trigger key, but the signal can be sent by a trusted contact.
