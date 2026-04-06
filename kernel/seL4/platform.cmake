# PlausiDenOS — Tensor G5 platform overlay for seL4
#
# Defines the hardware layout for the Pixel 10 Pro XL target.
# Because seL4 upstream does not ship a Tensor G5 board file at
# the time of writing, PlausiDenOS bundles its own platform
# definition here and layers it on top of the nearest in-tree
# platform.
#
# This file is intentionally independent of the seL4 kernel tree
# so it can be audited without pulling the entire seL4 source base.

include_guard(GLOBAL)

# ── Device tree ─────────────────────────────────────────────────
# The boot chain supplies a flattened device tree produced from
# the upstream Tensor G5 DTS plus the PlausiDenOS overlays in
# ../boot/dts/*.dtsi.
set(PLAUSIDEN_DEVICE_TREE_SOURCE
    "${CMAKE_CURRENT_LIST_DIR}/../boot/dts/pixel10-pro-xl.dts"
    CACHE FILEPATH "Device tree source")

# ── Kernel physical memory layout ───────────────────────────────
# Tensor G5 address space as observed on the reference hardware.
# Ranges are defined as (start, size) pairs in the device tree;
# we expose a few key ranges here for the protection-domain
# allocator to reference directly.
set(PLAUSIDEN_DRAM_BASE       "0x80000000" CACHE STRING "")
set(PLAUSIDEN_DRAM_SIZE       "0x200000000" CACHE STRING "8 GiB")

set(PLAUSIDEN_KERNEL_VADDR    "0xFFFFFF8080000000" CACHE STRING "")
set(PLAUSIDEN_KERNEL_PADDR    "0x80000000"          CACHE STRING "")

set(PLAUSIDEN_UART0_PADDR     "0x11000000" CACHE STRING "debug UART")
set(PLAUSIDEN_GIC_DIST_PADDR  "0x12000000" CACHE STRING "GICv3 distributor")
set(PLAUSIDEN_GIC_REDIST_PADDR "0x12100000" CACHE STRING "GICv3 redistributor")

# ── CPU topology ────────────────────────────────────────────────
# seL4 sees four cores. The remaining Tensor G5 cores are reserved
# for the modem and display subsystems, which PlausiDenOS does not
# currently expose as seL4 domains.
set(PLAUSIDEN_CPU_COUNT "4" CACHE STRING "")
set(PLAUSIDEN_CPU_FREQ_HZ "2400000000" CACHE STRING "2.4 GHz nominal")

# ── Boot chain assumptions ──────────────────────────────────────
# PlausiDenOS expects the device bootloader to hand off with:
# - Caches disabled
# - MMU disabled
# - EL2 (hypervisor) entry
# - DTB pointer in x0
# - Kernel ELF at PLAUSIDEN_KERNEL_PADDR
set(PLAUSIDEN_BOOT_HANDOFF_EL "2" CACHE STRING "")

# ── Security ───────────────────────────────────────────────────
# Disable the Android Verified Boot chain's vendor locked-bootloader
# enforcement, because PlausiDenOS replaces Android's chain entirely.
# The user's trust model now depends on an auditable signed boot
# envelope verified by the U-Boot fragment in ../boot/uboot.cfg.
set(PLAUSIDEN_AVB_LEGACY      OFF CACHE BOOL "")
set(PLAUSIDEN_SIGNED_BOOT     ON  CACHE BOOL "")
set(PLAUSIDEN_BOOT_PUBKEY
    "${CMAKE_CURRENT_LIST_DIR}/../boot/bootkey.pub"
    CACHE FILEPATH "")
