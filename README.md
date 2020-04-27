This is a Gentoo ebuild overlay for AMD [RX 560](https://www.amd.com/en/products/graphics/radeon-rx-560) video card drivers.

The AMD RX 560 requires [amdgpu-pro](https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-10) drivers on Linux.
AMD's amdgpu-pro drivers only support Ubuntu x86 64-bit using the
[Radeon Software for Linux Driver for Ubuntu 18.04.4 HWE](https://www.amd.com/en/support/graphics/radeon-500-series/radeon-rx-500-series/radeon-rx-560).
This ebuild overlay repository re-packages the amdgpu-pro `.deb`s to install into Gentoo system.

The amdgpu-pro driver package is proprietary, though AMD does a good job of open sourcing it's
code into the mainline kernel as the amdgpu kernel driver.
AMD's software development has mostly moved on to the newer AMD
cards now and it seems that the RX 560 does not work with a default amdgpu
kernel driver, mesa, etc.
The RX 560 product page calls out the
[amdgpu-pro revision 20.10](https://drivers.amd.com/drivers/linux/amdgpu-pro-20.10-1048554-ubuntu-18.04.tar.xz) drivers,
released April 16, 2020,
as the ones that should work with this hardware.



Testing OpenGL
--------------

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

Testing OpenCL
--------------

I tested the amdgpu-pro drivers using a clean Ubuntu 18.04.4 desktop and `apt update`-ed as of April 26, 2020.
The OpenCL stress test [`gpustress`](https://github.com/matszpk/clgpustress)
(packaged in this repository) was used to confirm that OpenCL only gave correct results once the amdgpu-pro legacy and PAL OpenCL drivers were installed.

```
tar -Jxvf amdgpu-pro-20.10-1048554-ubuntu-18.04.tar.xz
cd amdgpu-pro-20.10-1048554-ubuntu-18.04
./amdgpu-install --pro -y --opencl=legacy,pal
sudo reboot
gpustress
```

A `gpustress` failure looks like
```
CLGPUStress CLI 0.0.9.4 by Mateusz Szpakowski (matszpk@interia.pl)
...
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

A `gpustress` success looks like
```
TODO
```

Polaris11 Microcode
-------------------

The RX 560 is a [Polaris 11](https://en.wikipedia.org/wiki/Radeon_RX_500_series) architecture.
The current Gentoo `sys-kernel/linux-firmware-20200316` under `/lib/firmware/amdgpu/polaris11_*.bin`
is the same microcode packaged in the `amdgpu-pro`'s `amdgpu-dkms-firmware_X.X.X.X-YYY_all.deb`.
We use the Gentoo `linux-firmware` microcode.

Instructions
------------

1. Download the [driver bundle from AMD](https://drivers.amd.com/drivers/linux/amdgpu-pro-20.10-1048554-ubuntu-18.04.tar.xz)
and place the `.tar.xz` in your Gentoo distfiles directory.

2. Install this ebuild overlay via layman. `layman -a amdgpu-pro-rx560`

3. Emerge the rx560 meta-package. `emerge -vat amdgpu-pro-rx560`
