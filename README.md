This is a Gentoo ebuild overlay for AMD [RX 5600 XT](https://www.amd.com/en/graphics/amd-radeon-rx-5600-series) and possibly the
[RX 560](https://www.amd.com/en/products/graphics/radeon-rx-560) video card drivers.

The AMD RX 5600 XT and RX 560 require [amdgpu-pro](https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-10) drivers on Linux.
AMD's amdgpu-pro drivers only support Ubuntu x86 64-bit using the
[Radeon Software for Linux Driver for Ubuntu 18.04.4 HWE](https://www.amd.com/en/support/graphics/radeon-500-series/radeon-rx-500-series/radeon-rx-560).
This ebuild overlay repository re-packages the amdgpu-pro `.deb`s to install into Gentoo systems.

The amdgpu-pro driver package is proprietary, though AMD does a good job of open sourcing it's
code into the mainline kernel as the amdgpu kernel driver.
AMD's software development has mostly moved on to the newer AMD
cards now and it seems that the RX 560 does not work with a default amdgpu
kernel driver, mesa, etc.
The RX 560 product page calls out the
[amdgpu-pro revision 20.10](https://drivers.amd.com/drivers/linux/amdgpu-pro-20.10-1048554-ubuntu-18.04.tar.xz) drivers,
released April 16, 2020,
as the ones that should work with this hardware.

I had a long battle to get the RX 560 working, but ultimately upgraded to the
RX 5600 XT. It appears that development effort at AMD to support newer linux on
the RX 560 has been discontinued. Development effort now focuses on the RX 5600
XT, leaving the RX 560 dead in the water with a few show stopping bugs that were never fixed.

I do *not* install the amdgpu-pro drivers, but I
do use the amdgpu-pro-opencl implementation since a ROCm (open source) version
is not available as of May 2020.

A Working Configuration (May 2020)
----------------
I am using an RX 5600 XT card.
I do *not* use the core amdgpu-pro OpenGL drivers. The important changes have made it
into kernel 5.6.8. 

The amdgpu-pro-20.10 drivers used a patched 5.4.7 kernel.
The 5.6.8 kernel, after some pretty extensive code
hunting, most closely fits the important kernel patches included in the
amdgpu-pro-20.10 drivers. When the stable kernel branch (versus the 5.6.x development
branch) has integrated these changes, any Linux kernel should be good to go.

On the other hand, the OpenCL drivers provided by AMD in the ROCm OpenCL code
do not support the RX 5600 XT card. I use the amdgpu-pro-opencl packages on top of
the kernel.
This works for now, but it may fall out of sync at some point. It is not a
supported configuration from AMD, but there is no alternative at this time.

I confirmed that I did not have a hardware problem by installing Ubuntu 18.04
with the 20.10-1048554 AMD pro drivers. Everything worked, I got Steam running
and the GPU and OpenCL tests worked.

Finally, I needed tools to prove that Gentoo had (a) a stable GPU, and (b)
could produce valid OpenCL results.

I have installed:

 * sys-kernel/gentoo-sources:5.6.8
 * >=sys-kernel/linux-firmware-20200316 (currently 20201218)
 * dev-util/clinfo
 * dev-libs/pocl [this repository]
 * dev-libs/amdgpu-pro-opencl [this repository]
 * app-benchmarks/clgpustress [this repository]
 * app-benchmarks/gputest [this repository]

```
/usr/src/linux-5.6.8-gentoo $ grep -e AMD -e DRM -e EXTRA_FIRMWARE .config | grep -v -e '^#' | sed '/^$/d'
CONFIG_X86_AMD_PLATFORM_DEVICE=y
CONFIG_CPU_SUP_AMD=y
CONFIG_X86_MCE_AMD=y
CONFIG_PERF_EVENTS_AMD_POWER=y
CONFIG_MICROCODE_AMD=y
CONFIG_AMD_NUMA=y
CONFIG_X86_AMD_FREQ_SENSITIVITY=y
CONFIG_AMD_NB=y
CONFIG_KVM_AMD=y
CONFIG_PATA_AMD=y
CONFIG_DRM=y
CONFIG_DRM_DP_AUX_CHARDEV=y
CONFIG_DRM_KMS_HELPER=y
CONFIG_DRM_KMS_FB_HELPER=y
CONFIG_DRM_FBDEV_EMULATION=y
CONFIG_DRM_FBDEV_OVERALLOC=100
CONFIG_DRM_TTM=y
CONFIG_DRM_TTM_DMA_PAGE_POOL=y
CONFIG_DRM_GEM_SHMEM_HELPER=y
CONFIG_DRM_SCHED=y
CONFIG_DRM_AMDGPU=y
CONFIG_DRM_AMDGPU_USERPTR=y
CONFIG_DRM_AMDGPU_GART_DEBUGFS=y
CONFIG_DRM_AMD_ACP=y
CONFIG_DRM_AMD_DC=y
CONFIG_DRM_AMD_DC_DCN=y
CONFIG_DRM_AMD_DC_HDCP=y
CONFIG_HSA_AMD=y
CONFIG_DRM_VIRTIO_GPU=m
CONFIG_DRM_PANEL=y
CONFIG_DRM_BRIDGE=y
CONFIG_DRM_PANEL_BRIDGE=y
CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y
CONFIG_AMD_IOMMU=y
CONFIG_AMD_IOMMU_V2=y
CONFIG_EXTRA_FIRMWARE="amd-ucode/microcode_amd_fam17h.bin amd/amd_sev_fam17h_model0xh.sbin amdgpu/polaris11_ce.bin amdgpu/polaris11_ce_2.bin amdgpu/polaris11_k_smc.bin amdgpu/polaris11_k2_smc.bin amdgpu/polaris11_k_mc.bin amdgpu/polaris11_mc.bin amdgpu/polaris11_me.bin amdgpu/polaris11_me_2.bin amdgpu/polaris11_mec2.bin amdgpu/polaris11_mec2_2.bin amdgpu/polaris11_mec.bin amdgpu/polaris11_mec_2.bin amdgpu/polaris11_pfp.bin amdgpu/polaris11_pfp_2.bin amdgpu/polaris11_rlc.bin amdgpu/polaris11_sdma1.bin amdgpu/polaris11_sdma.bin amdgpu/polaris11_smc.bin amdgpu/polaris11_smc_sk.bin amdgpu/polaris11_uvd.bin amdgpu/polaris11_vce.bin amdgpu/navi10_asd.bin amdgpu/navi10_ce.bin amdgpu/navi10_gpu_info.bin amdgpu/navi10_me.bin amdgpu/navi10_mec.bin amdgpu/navi10_mec2.bin amdgpu/navi10_pfp.bin amdgpu/navi10_rlc.bin amdgpu/navi10_sdma.bin amdgpu/navi10_sdma1.bin amdgpu/navi10_smc.bin amdgpu/navi10_sos.bin amdgpu/navi10_ta.bin amdgpu/navi10_vcn.bin"
CONFIG_EXTRA_FIRMWARE_DIR="/lib/firmware"
```
It is possible that there are some missing kernel options. I have archived my
kernel configuration, so we can work together to find what is missing, if necessary.


Testing OpenGL
--------------
When it is working correctly `gputest -t fur` from `app-benchmarks/gputest`
gives a clear image, with no
missing blocks, odd holes, or rendering garbage. Most importantly, the display
does not freeze, cause a hard lock up, or reset the GPU.

When there is a GPU lock up, the screen will go wonky colours, but the
mouse may still work.
If GPU reset is enabled in the kernel, the GPU may eventually succeed in
restarting which will cause X to terminate and you end up back at the X login
prompt after a couple of minutes.
If X does not restart, you either need to do a hard reset of the system or
login via SSH to run `/etc/init.d/xdm restart` which will manually restart X
and often successfully reinitializes the GPU.

Failures can be spotted in the `dmesg` output as follows:

The system successfully boots using a frambuffer device to show a nice start up console (`amdgpudrmfb`),
but then fails after logging in as the window manager (Gnome or XFCE) takes over from the login manager. In `dmesg` we see
```
...
[    1.136122] [drm] Initialized amdgpu 3.36.0 20150101 for 0000:01:00.0 on minor 0
...
[ 4827.878788] [drm:amdgpu_dm_atomic_commit_tail] *ERROR* Waiting for fences timed out!
[ 4833.009762] [drm:amdgpu_job_timedout] *ERROR* ring gfx timeout, signaled seq=194368, emitted seq=194371
[ 4833.009765] [drm:amdgpu_job_timedout] *ERROR* Process information: process XXXXXXXXXXXX pid XXXXX thread XXXXXXXXXX:XXX pid XXXXX
[ 4833.009767] amdgpu 0000:01:00.0: GPU reset begin!
[ 4833.717743] amdgpu 0000:01:00.0: GPU BACO reset
[ 4833.825581] amdgpu 0000:01:00.0: GPU reset succeeded, trying to resume
[ 4834.080282] amdgpu 0000:01:00.0: [drm:amdgpu_ring_test_helper] *ERROR* ring comp_1.0.0 test failed (-110)
[ 4834.352710] amdgpu 0000:01:00.0: GPU reset(2) succeeded!
...
```
Sometimes the GPU reset succeeds, other times it does not. If one is quick
`Ctrl-Alt 2` can get you to a text console between failures where you might be
able to restart X and get going again. Otherwise, a reboot is required to reset
the graphics card, which is not possible if the window manager has locked up.
Remote access via SSH can save the day and avoid a hard power off.
This `ring gfx timeout` is a general AMD "GPU hung" error often [reported](https://gitlab.freedesktop.org/search?&search=ring+gfx+timeout).
Suggestions such as adding `immu=pt` to the kernel boot parameters or disabling IOMMU in the BIOS did not change the result.

Most window managers for X are "compositing" using OpenGL. The RX 560 often 
immediately fails after logging in, giving a garbled screen or manages to hobble onwards, but gives
screen tears in 3D graphics and odd text blips across terminals.
[Electron](https://www.electronjs.org/) apps often cause the GPU to crash.
[Steam](https://store.steampowered.com/) crashes when it tries to start up after
showing a mis-coloured (green tinted) initialization dialog.

Ubuntu (5.3.0 kernel) and Gentoo (5.5.11, 4.19.97, 4.14.166) had the same symptoms.
The mainline amdgpu driver in the kernel fails for the AMD RX 560.
The "AMDGPU All-Open" stack provided with the amdgpu-pro download fails in the same manner.

Installing the `amdgpu-pro` drivers gives a clean start up, without repeated failures entering X after login.
There are still occasional small square regions on the screen that are garbled, typically 10x10 pixels or so.
Steam starts up successfully.

This is better but still not great. Eventually, I found the kernel 5.6.8 which gave consistently good results.

Testing OpenCL
--------------

The OpenCL test is nice because we can install a CPU only kernel and check that
the results between GPU and CPU are consistent.

First check that OpenCL is recognized.
```
$ clinfo | grep -e 'Name' -e 'Version'
  Platform Name                                   AMD Accelerated Parallel Processing
  Platform Version                                OpenCL 2.1 AMD-APP (3075.10)
  Platform Name                                   AMD Accelerated Parallel Processing
  Device Name                                     gfx1010
  Device Version                                  OpenCL 2.0 AMD-APP (3075.10)
  Driver Version                                  3075.10 (PAL,LC)
  Device OpenCL C Version                         OpenCL C 2.0
  Device Board Name (AMD)                         AMD Radeon RX 5600 XT
    Platform Name                                 AMD Accelerated Parallel Processing
    Device Name                                   gfx1010
    Platform Name                                 AMD Accelerated Parallel Processing
    Device Name                                   gfx1010
    Platform Name                                 AMD Accelerated Parallel Processing
    Device Name                                   gfx1010
  ICD loader Name                                 OpenCL ICD Loader
  ICD loader Version                              2.2.12
```
On Ubuntu, the device name `gfx1010` is correctly reported as `AMD Radeon RX
5600 XT` which could be fixed with a minor patch to the kernel. I figure it'll
probably be fixed eventually without my intervention and is purely cosmetic.
(For example, in `blender` under Gentoo the OpenCL accelerated rendering
reports `AMD Radeon RX 5600 XT`.)

I tested the amdgpu-pro drivers using a clean Ubuntu 18.04.4 desktop and `apt update`-ed as of April 26, 2020.
The OpenCL stress test [`clgpustress`](https://github.com/matszpk/clgpustress)
(packaged in this repository) was used to confirm that OpenCL only gave correct results once the amdgpu-pro legacy and PAL OpenCL drivers were installed.

```
tar -Jxvf amdgpu-pro-20.10-1048554-ubuntu-18.04.tar.xz
cd amdgpu-pro-20.10-1048554-ubuntu-18.04
./amdgpu-install --pro -y --opencl=legacy,pal
sudo reboot
clgpustress
```

A `clgpustress` failure looks like
```
$ clgpustress -w
CLGPUStress CLI 0.0.9.4 by Mateusz Szpakowski (matszpk@interia.pl)
[...]

Preparing StressTester for
  #0 Clover:Radeon RX 560 Series (POLARIS11, DRM 3.36.0, 5.5.11-gentoo, LLVM 9.0.1)
    SetUp: workSize=1048576, memory=256 MB, workFactor=256, blocksNum=2,
    computeUnits=16, groupSize=256, passIters=32, testType=0,
    inputAndOutput=no
Calibrating Kernel for
  #0 Clover:Radeon RX 560 Series (POLARIS11, DRM 3.36.0, 5.5.11-gentoo, LLVM 9.0.1)...
  Calibration progress: 0% 12% 25% 37% 50% 62% 75% 87% 100%
Kernel calibrated for
  #0 Clover:Radeon RX 560 Series (POLARIS11, DRM 3.36.0, 5.5.11-gentoo, LLVM 9.0.1)
  BestKitersNum: 17, Bandwidth: 83.2844 GB/s, Performance: 1061.88 GFLOPS
Program build log:
  Clover:Radeon RX 560 Series (POLARIS11, DRM 3.36.0, 5.5.11-gentoo, LLVM 9.0.1)
:--------------------

:--------------------
KernelTime: 0.00322312s, itersPerWait: 94

#0 Results for comparison has been generated.
Failed StressTester for
  #0 Clover:Radeon RX 560 Series (POLARIS11, DRM 3.36.0, 5.5.11-gentoo, LLVM 9.0.1):
    Exception happened: FAILED COMPUTATIONS!!!! PASS #1, Elapsed time: 0:00:01.402
Failed #0
```

A `clgpustress` success looks like
```
$ clgpustress -w
CLGPUStress CLI 0.0.9.4 by Mateusz Szpakowski (matszpk@interia.pl)
[...]

Preparing StressTester for
  #0 AMD Accelerated Parallel Processing:gfx1010
    SetUp: workSize=1179648, memory=288 MB, workFactor=256, blocksNum=2,
    computeUnits=18, groupSize=256, passIters=32, testType=0,
    inputAndOutput=no
Calibrating Kernel for
  #0 AMD Accelerated Parallel Processing:gfx1010...
  Calibration progress: 0% 12% 25% 37% 50% 62% 75% 87% 100%
Kernel calibrated for
  #0 AMD Accelerated Parallel Processing:gfx1010
  BestKitersNum: 19, Bandwidth: 231.972 GB/s, Performance: 3305.6 GFLOPS
Program build log:
  AMD Accelerated Parallel Processing:gfx1010
:--------------------

:--------------------
KernelTime: 0.00130184s, itersPerWait: 231

#0 Results for comparison has been generated.
#0 AMD Accelerated Parallel Processing:gfx1010 passed PASS #10
Approx. bandwidth: 109.148 GB/s, Approx. perf: 1555.35 GFLOPS, elapsed: 0:00:00.885
#0 AMD Accelerated Parallel Processing:gfx1010 passed PASS #20
Approx. bandwidth: 120.603 GB/s, Approx. perf: 1718.59 GFLOPS, elapsed: 0:00:01.686
#0 AMD Accelerated Parallel Processing:gfx1010 passed PASS #30
Approx. bandwidth: 120.844 GB/s, Approx. perf: 1722.03 GFLOPS, elapsed: 0:00:02.486
#0 AMD Accelerated Parallel Processing:gfx1010 passed PASS #40
[...]
```

Polaris11 Microcode
-------------------

The RX 560 is a [Polaris 11](https://en.wikipedia.org/wiki/Radeon_RX_500_series) architecture.
The current Gentoo `sys-kernel/linux-firmware-20200316` under `/lib/firmware/amdgpu/polaris11_*.bin`
is the same microcode packaged in the `amdgpu-pro`'s `amdgpu-dkms-firmware_X.X.X.X-YYY_all.deb`.
We use the Gentoo `linux-firmware` microcode.

The RX 5600 XT firmware is also included in the most recent `linux-firmware`
under the `navi` prefix: see `EXTRA_FIRMWARE` in the kernel configuration
above.


Instructions
------------

1. Download the [driver bundle from AMD](https://drivers.amd.com/drivers/linux/amdgpu-pro-20.10-1048554-ubuntu-18.04.tar.xz)
and place the `.tar.xz` in your Gentoo distfiles directory.

2. Install this ebuild overlay `layman -a amdgpu-pro-rx560`

3. Configure and install the 5.6.8 kernel `sys-kernel/gentoo-sources:5.6.8` and most recent `linux-firmware`, as above.

4. Install `dev-libs/amdgpu-pro-opencl` and `dev-util/clinfo`.

5. Test.

6. [Install Steam](https://wiki.gentoo.org/wiki/Steam), render 3D animations
   *faster* with [Blender](https://www.blender.org/) or play with your favorite
   OpenCL code.


