# `kernel/` — seL4 + CAmkES layer

This directory holds the microkernel and boot configuration for PlausiDenOS. None of the Rust workspace crates (`brain-pd/`, `shield-pd/`, `vault-pd/`) depend on these files directly; they are consumed by the seL4/CAmkES build system at the outer CMake level.

## Layout

| Subdirectory | Contents |
|--------------|----------|
| `seL4/`      | seL4 kernel build configuration (`config.cmake`) + Tensor G5 platform overlay (`platform.cmake`). |
| `camkes/`    | CAmkES component architecture description (ADL) files. One per protection domain plus the top-level `plausiden_os.camkes` assembly and a shared `interfaces.camkes` defining every cross-PD contract. |
| `boot/`      | Boot chain — a U-Boot script that verifies a signed boot envelope before handing off to seL4 at EL2. The device tree source and boot public key live here too (populated at build time). |

## The four protection domains

```
      ┌───────────────────────────────────────────────────────┐
      │                 PlausiDenOS on seL4                   │
      │                                                       │
      │   ┌─────────┐    ┌──────────┐    ┌─────────────────┐  │
      │   │  Brain  │───▶│  Shield  │◀──▶│  Android Shim   │  │
      │   │  (LFI)  │    │ (network)│    │ (paravirt GOS)  │  │
      │   └────┬────┘    └────┬─────┘    └────────┬────────┘  │
      │        │              │                   │           │
      │        └──────────────┼───────────────────┘           │
      │                       ▼                               │
      │                 ┌──────────┐                          │
      │                 │  Vault   │                          │
      │                 │ (storage)│                          │
      │                 └──────────┘                          │
      └───────────────────────────────────────────────────────┘
```

- **Brain** hosts the LFI engine and generates synthetic data. No network, no direct storage. Everything flows through Shield and Vault.
- **Shield** owns every byte on the wire. Only PD with direct network driver access. Runs TLS fingerprint rotation, DNS pollution, forensic-analysis detection.
- **Vault** owns every byte on disk. Only PD with direct flash driver access. Runs the personality system, duress PIN, and Scorched Earth key destruction.
- **Android Shim** is a thin bidirectional channel for the paravirtualized GrapheneOS guest. Translates JSON requests into typed CAmkES RPC calls and returns responses verbatim.

## Threat model

Each PD is assumed compromised in turn. The cross-PD connections in `plausiden_os.camkes` are the complete attack surface: anything not listed there is not reachable across a PD boundary. A hostile Brain still cannot write to flash (must go through Vault). A hostile Shield still cannot read the disk (must go through Vault). A hostile Vault still cannot touch the network (must go through Shield). No single PD can exfiltrate data without at least one other PD's cooperation.

## Build (outline, not operational yet)

Requires an out-of-tree seL4/CAmkES checkout and the ARM GCC cross-toolchain. The commands below are indicative — they will need to be run inside the seL4 project template once the upstream support for the Tensor G5 platform lands.

```bash
# Bring up an seL4/CAmkES workspace and overlay this repo.
repo init -u https://github.com/seL4/camkes-manifest.git
repo sync
cp -r /path/to/PlausiDen-OS-for-Mobile/kernel/* projects/plausiden/

# Configure.
mkdir build && cd build
cmake -G Ninja \
    -DCROSS_COMPILER_PREFIX=aarch64-linux-gnu- \
    -DCMAKE_TOOLCHAIN_FILE=../kernel/gcc.cmake \
    -C ../projects/plausiden/kernel/seL4/config.cmake \
    ..

# Build.
ninja
```

The resulting image lives at `build/images/plausiden-image-arm-tensor-g5`.

## Verification posture

`KernelVerificationBuild` is ON, so the kernel build inherits the seL4 verification story. Anything that would break verification is disabled with a comment in `config.cmake`. PlausiDenOS does not (yet) add its own formal verification on top of the CAmkES composition; that is a research goal tracked in the NSF SaTC grant draft.

## Duress PIN + Scorched Earth

Both are implemented in the Vault PD, not in the kernel itself. The kernel just gives Vault the capability handles it needs to clear its key material synchronously without any scheduling hand-off that could intercept the operation. See `../docs/DURESS-PROTOCOL.md` and `../docs/SCORCHED-EARTH.md` for the user-facing semantics.
