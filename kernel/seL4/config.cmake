# PlausiDenOS — seL4 kernel build configuration
#
# Imported by the top-level CMakeLists.txt of a seL4/CAmkES build.
# Sets the kernel features PlausiDenOS relies on for its four
# protection-domain architecture (Brain, Shield, Vault, Android).
#
# Expected invocation:
#   cmake -G Ninja \
#     -DCROSS_COMPILER_PREFIX=aarch64-linux-gnu- \
#     -C plausiden-os.cmake \
#     -DCMAKE_TOOLCHAIN_FILE=${KERNEL_PATH}/gcc.cmake \
#     ${PROJECT_PATH}
#   ninja

include_guard(GLOBAL)

# ── Architecture ────────────────────────────────────────────────
set(KernelSel4Arch                "aarch64"        CACHE STRING "")
set(KernelArch                    "arm"            CACHE STRING "")
set(KernelArmCPU                  "cortex-a78"     CACHE STRING "")

# ── Target platform ────────────────────────────────────────────
# Pixel 10 Pro XL would ship a Tensor G5 (ARMv9). seL4 upstream does
# not ship a Tensor G5 platform definition at the time of writing,
# so PlausiDenOS bootstraps on the closest available in-tree board
# and cross-compiles its own platform overlay. The overlay lives in
# platform.cmake in this directory.
set(KernelPlatform                "plausiden-tensor-g5" CACHE STRING "")

# ── Microkernel features ────────────────────────────────────────
# MCS (Mixed-Criticality Scheduling) is required for the four-PD
# model: each protection domain gets its own scheduling context with
# a budget and period, so a compromised component cannot starve the
# others.
set(KernelIsMCS                   ON   CACHE BOOL   "")
set(KernelRT                      ON   CACHE BOOL   "")
set(KernelHaveFPU                 ON   CACHE BOOL   "")
set(KernelFPU                     "VFP" CACHE STRING "")

# Hypervisor support for the paravirtualized GrapheneOS shim.
set(KernelArmHypervisorSupport    ON   CACHE BOOL   "")
set(KernelArmVtimerUpdateVOffset  ON   CACHE BOOL   "")

# ── Verification posture ────────────────────────────────────────
# Use the verified-config flags so the resulting kernel inherits
# the seL4 verification story. Any feature that would break the
# verification story is disabled here with a clear comment.
set(KernelVerificationBuild       ON   CACHE BOOL   "")
set(KernelBenchmarks              "none" CACHE STRING "")
set(KernelPrinting                OFF  CACHE BOOL   "no kernel prints")
set(KernelDebugBuild              OFF  CACHE BOOL   "no debug in prod")

# ── SMP ─────────────────────────────────────────────────────────
# PlausiDenOS pins each protection domain to a dedicated core where
# possible. Tensor G5 has 9 cores (1+4+4); we expose 4 to seL4 and
# let the boot overlay reserve the rest for the modem / display.
set(KernelMaxNumNodes             "4"  CACHE STRING "")

# ── Memory and capability space sizing ──────────────────────────
set(KernelRootCNodeSizeBits       "14" CACHE STRING "")
set(KernelMaxNumBootinfoUntypedCaps "230" CACHE STRING "")
set(KernelTimeSlice               "5"  CACHE STRING "ms")

# ── CAmkES ──────────────────────────────────────────────────────
# Stack sizes large enough for the thread-local state of each
# protection domain. Vault needs the biggest because of the
# Personality dispatcher's per-call context.
set(CAmkESDefaultStackSize        "16384" CACHE STRING "")
set(CAmkESDefaultHeapSize         "65536" CACHE STRING "")
set(CAmkESNumPreallocatedCaps     "128" CACHE STRING "")
set(CAmkESSupportForEnvironmentVariables OFF CACHE BOOL "")

# ── PlausiDenOS-specific knobs ──────────────────────────────────
# These are read by the top-level plausiden_os.camkes assembly.
set(PLAUSIDEN_ENABLE_DURESS_PIN   ON   CACHE BOOL   "")
set(PLAUSIDEN_ENABLE_SCORCHED_EARTH ON CACHE BOOL   "")
set(PLAUSIDEN_PERSONALITY_COUNT   "5"  CACHE STRING "max personalities")
set(PLAUSIDEN_VAULT_KEY_SLOTS     "8"  CACHE STRING "")
