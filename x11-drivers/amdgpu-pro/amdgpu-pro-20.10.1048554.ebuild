# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{32,64} )
inherit linux-info multilib-build unpacker

DESCRIPTION="AMD proprietary precompiled drivers for RX 560"
HOMEPAGE="https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-10"

REV=${PV%.*}
BUILD=${PV##*.}
ARCHIVE="amdgpu-pro-${REV}-${BUILD}-ubuntu-18.04.tar.xz"

SRC_URI="https://drivers.amd.com/drivers/linux/${ARCHIVE}"

LICENSE="AMD-GPU-PRO-EULA"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="fetch strip"

# The binary blobs include binaries for other open sourced packages, we don't
# want to include those parts, if they are selected, they should come from
# portage.
IUSE="opencl abi_x86_32 +abi_x86_64"
REQUIRED_USE="abi_x86_64"

DEPEND=""  # binary packages installed, no need for dependencies at "build"/install

# =x11-libs/libdrm-2.4.100[video_cards_amdgpu,video_cards_radeon]
# =sys-kernel/amdgpu-dkms-${PV}
RDEPEND="
	=x11-libs/libdrm-2.4.100[video_cards_amdgpu,video_cards_radeon,${MULTILIB_USEDEP}]
	>=sys-devel/llvm-9.0.0[llvm_targets_AMDGPU,${MULTILIB_USEDEP}]
	<sys-devel/llvm-10.0.0
	media-libs/mesa[X,dri3,egl,gbm,gles1,gles2,libglvnd,llvm,opencl,osmesa,vaapi,vdpau,vulcan,vulcan-overlay,wayland,xa,${MULTILIB_USEDEP}]
	media-libs/libglvnd[${MULTILIB_USEDEP}]
	x11-drivers/xf86-video-amdgpu
	>=sys-kernel/linux-firmware-20200316
	opencl? ( app-eselect/eselect-opencl )
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-libs/libXext[${MULTILIB_USEDEP}]
	x11-libs/libXinerama[${MULTILIB_USEDEP}]
	x11-libs/libXrandr[${MULTILIB_USEDEP}]
	x11-libs/libXrender[${MULTILIB_USEDEP}]
	x11-base/xorg-proto
"

S="${WORKDIR}"

# Kernel modules (=m) and enabled CONFIG_*=y
# ... from amdgpu-dkms_5.4.7.53-1048554_all.deb
#DRM_TTM=m
#DRM_AMDGPU=m
#DRM_SCHED=m
# ... DRM_AMD_DC_DCN1_01 flag was removed from the kernel, May 2019(?)
CONFIG_CHECK="
	HSA_AMD
	DRM_TTM DRM_TTM_DMA_PAGE_POOL
	DRM_SCHED
	DRM_AMDGPU DRM_AMDGPU_CIK DRM_AMDGPU_SI DRM_AMDGPU_USERPTR
	DRM_AMD_DC"

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${ARCHIVE}"
	einfo "from ${HOMEPAGE} and place them in DISTDIR directory."
}

pkg_setup() {
	linux-info_pkg_setup
	if kernel_is lt 5 4 7 ; then
		eerror "You must build against 5.4.7.53 or higher kernels."
	fi
}

unpack_deb() {
	echo ">>> Unpacking ${1##*/} to ${PWD}"
	unpack $1
	unpacker ./data.tar*
	rm -f debian-binary {control,data}.tar*
}

# amdgpu-pro-20.10-1048554-ubuntu-18.04.tar.xz
# $ ./amdgpu-install --pro -y --opencl=legacy,pal
# ... packages installed by this ebuild marked with
#      . = not proprietary (not installed here)
#      D = dependency from within std gentoo
#      x = always installed
#      c = "use opencl"
#      v = "use vulkan
#      g = "use opengl"
#
# ... installs:
# . amdgpu-core 20.10-1048554 [2,212 B]
# . amdgpu-dkms-firmware 1:5.4.7.53-1048554 [4,445 kB]
# . amdgpu-dkms 1:5.4.7.53-1048554 [5,519 kB]
# D libdrm2-amdgpu 1:2.4.100-1048554 [35.2 kB]
# . libdrm-amdgpu-common 1.0.0-1048554 [4,620 B]
# D libdrm-amdgpu-amdgpu1 1:2.4.100-1048554 [20.7 kB]
# . libdrm-amdgpu-radeon1 1:2.4.100-1048554 [26.1 kB]
# D libllvm9.0-amdgpu 1:9.0-1048554 [13.8 MB]
# D mesa-amdgpu-va-drivers 1:19.3.4-1048554 [2,171 kB]
# D libglapi-amdgpu-mesa 1:19.3.4-1048554 [24.3 kB]
# D libgl1-amdgpu-mesa-dri 1:19.3.4-1048554 [7,132 kB]
# D libdrm2-amdgpu 1:2.4.100-1048554 [37.7 kB]
# D libdrm-amdgpu-amdgpu1 1:2.4.100-1048554 [24.5 kB]
# . libdrm-amdgpu-radeon1 1:2.4.100-1048554 [28.0 kB]
# D libllvm9.0-amdgpu 1:9.0-1048554 [15.6 MB]
# D mesa-amdgpu-va-drivers 1:19.3.4-1048554 [2,089 kB]
# D libglapi-amdgpu-mesa 1:19.3.4-1048554 [24.4 kB]
# D libgl1-amdgpu-mesa-dri 1:19.3.4-1048554 [7,019 kB]
# D libxatracker2-amdgpu 1:19.3.4-1048554 [1,007 kB]
# D libgbm1-amdgpu 1:19.3.4-1048554 [26.5 kB]
# D libegl1-amdgpu-mesa 1:19.3.4-1048554 [104 kB]
# D libegl1-amdgpu-mesa-drivers 1:19.3.4-1048554 [4,624 B]
# D libgles1-amdgpu-mesa 1:19.3.4-1048554 [8,676 B]
# D libgles2-amdgpu-mesa 1:19.3.4-1048554 [12.3 kB]
# D libgl1-amdgpu-mesa-glx 1:19.3.4-1048554 [144 kB]
# D libosmesa6-amdgpu 1:19.3.4-1048554 [3,468 kB]
# D mesa-amdgpu-vdpau-drivers 1:19.3.4-1048554 [2,507 kB]
# . mesa-amdgpu-omx-drivers 1:19.3.4-1048554 [2,182 kB]
# D xserver-xorg-hwe-amdgpu-video-amdgpu 1:19.1.0-1048554 [57.7 kB]
# . gst-omx-amdgpu 1.0.0.1-1048554 [57.9 kB]
# . amdgpu-lib-hwe 20.10-1048554 [2,148 B]
# . amdgpu-hwe 20.10-1048554 [1,972 B]
# D libxatracker2-amdgpu 1:19.3.4-1048554 [868 kB]
# D libgbm1-amdgpu 1:19.3.4-1048554 [27.9 kB]
# D libegl1-amdgpu-mesa 1:19.3.4-1048554 [111 kB]
# D libegl1-amdgpu-mesa-drivers 1:19.3.4-1048554 [4,624 B]
# D libgles1-amdgpu-mesa 1:19.3.4-1048554 [8,612 B]
# D libgles2-amdgpu-mesa 1:19.3.4-1048554 [12.2 kB]
# D libgl1-amdgpu-mesa-glx 1:19.3.4-1048554 [152 kB]
# D libosmesa6-amdgpu 1:19.3.4-1048554 [3,293 kB]
# D mesa-amdgpu-vdpau-drivers 1:19.3.4-1048554 [2,458 kB]
# . amdgpu-lib32 20.10-1048554 [2,108 B]
# x amdgpu-pro-core 20.10-1048554 [5,556 B]
# g libgl1-amdgpu-pro-appprofiles 20.10-1048554 [21.9 kB]
# g libgl1-amdgpu-pro-glx 20.10-1048554 [189 kB]
# x libegl1-amdgpu-pro 20.10-1048554 [27.5 kB]
# x libgles2-amdgpu-pro 20.10-1048554 [19.8 kB]
# x libglapi1-amdgpu-pro 20.10-1048554 [74.6 kB]
# g libgl1-amdgpu-pro-ext-hwe 20.10-1048554 [86.7 kB]
# g libgl1-amdgpu-pro-dri 20.10-1048554 [10.5 MB]
# x amdgpu-pro-hwe 20.10-1048554 [5,340 B]
# g libgl1-amdgpu-pro-glx 20.10-1048554 [192 kB]
# x libegl1-amdgpu-pro 20.10-1048554 [34.4 kB]
# x libgles2-amdgpu-pro 20.10-1048554 [34.8 kB]
# x libglapi1-amdgpu-pro 20.10-1048554 [63.7 kB]
# g libgl1-amdgpu-pro-dri 20.10-1048554 [11.4 MB]
# x amdgpu-pro-lib32 20.10-1048554 [5,360 B]
# c libopencl1-amdgpu-pro 20.10-1048554 [13.3 kB]
# c clinfo-amdgpu-pro 20.10-1048554 [149 kB]
# c opencl-amdgpu-pro-comgr 20.10-1048554 [22.2 MB]
# c opencl-amdgpu-pro-icd 20.10-1048554 [21.4 MB]
# c opencl-orca-amdgpu-pro-icd 20.10-1048554 [29.0 MB]
# v vulkan-amdgpu-pro 20.10-1048554 [6,503 kB]
# v vulkan-amdgpu-pro 20.10-1048554 [6,845 kB]

src_unpack() {
	default

	for i in ./amdgpu-pro-${REV}-${BUILD}-ubuntu-18.04/*-pro*.deb; do
		if [[ "$i" == *"opencl"* || "$i" == *"clinfo"* ]] && use !opencl; then
			echo "Skipping $i (opencl)"
			continue
		fi
		if [[ "$i" == *"amf-amdgpu-pro"* ]]; then
			echo "Skipping $i (amf)"
			continue
		fi
		if [[ "$i" == *"hip-amdgpu-pro"* ]]; then
			echo "Skipping $i (hip)"
			continue
		fi
		if [[ "${i:(-9)}" == "_i386.deb" ]] && use !abi_x86_32; then
			echo "Skipping $i (32-bit)"
			continue
		fi
		unpack_deb $i
	done

	cp usr/share/doc/amdgpu-pro-core/copyright AMDGPU-PRO-EULA.txt  # save a sample of AMD's EULA for install
	rm -rf usr/share  # useless automated AMD changelogs and repeated EULA copyright statement (AMD-GPU-PRO-EULA)
	rm -rf etc/apt  # useless Ubuntu specific version pinning

	rm -rf amdgpu-pro-${REV}-${BUILD}-ubuntu-18.04  # clean up after unpacking
}

src_prepare() {
	echo "Replacing ./etc/ld.so.conf.d/10-amdgpu-pro-x86_64.conf -> ${T}/10-amdgpu-pro.conf"
	rm etc/ld.so.conf.d/10-amdgpu-pro-x86_64.conf
	echo "/usr/$(get_libdir)/amdgpu-pro" > "${T}/10-amdgpu-pro.conf" || die
	if use abi_x86_32; then
		echo "/usr/lib32/amdgpu-pro" >> "${T}/10-amdgpu-pro.conf" || die
	fi

#	cat << EOF > "${T}/10-device.conf" || die
#Section "Device"
#	Identifier  "Name of your GPU"
#	Driver      "amdgpu"
#	BusID       "PCI:1:0:0"
#	Option      "DRI"         "3"
#	Option      "AccelMethod" "glamor"
#EndSection
#EOF
#
#	cat << EOF > "${T}/10-screen.conf" || die
#Section "Screen"
#		Identifier      "Your screen name"
#		DefaultDepth    24
#		SubSection      "Display"
#				Depth   24
#		EndSubSection
#EndSection
#EOF
#
#	cat << EOF > "${T}/10-monitor.conf" || die
#Section "Monitor"
#	Identifier   "Your monitor name"
#	VendorName   "The make"
#	ModelName    "The model"
#	Option       "DPMS"   "true" # Might want to turn this off if using an R9 390
#EndSection
#EOF
#
#	if use vulkan ; then
#		cat << EOF > "${T}/amd_icd64.json" || die
#{
#   "file_format_version": "1.0.0",
#	   "ICD": {
#		   "library_path": "/usr/$(get_libdir)/vulkan/vendors/amdgpu-pro/amdvlk64.so",
#		   "abi_versions": "0.9.0"
#	   }
#}
#EOF
#
#		if use abi_x86_32 ; then
#			cat << EOF > "${T}/amd_icd32.json" || die
#{
#   "file_format_version": "1.0.0",
#	   "ICD": {
#		   "library_path": "/usr/lib32/vulkan/vendors/amdgpu-pro/amdvlk32.so",
#		   "abi_versions": "0.9.0"
#	   }
#}
#EOF
#		fi
#	fi

	default
}

#  QA Notice: The following files contain writable and executable sections
#  https://wiki.gentoo.org/wiki/Hardened/GNU_stack_quickstart
#  ... probably nothing to do but report this to AMD and maybe they fix it
export QA_WX_LOAD="usr/lib64/dri/amdgpu_dri.so usr/lib64/amdgpu-pro/libglapi.so.1 usr/lib64/amdgpu-pro/libGL.so.1.2"

src_install() {
	insinto /etc
	doins -r etc/amd

	insinto /etc/ld.so.conf.d
	doins "${T}/10-amdgpu-pro.conf"

	exeinto /usr/$(get_libdir)/amdgpu-pro
	insinto /usr/$(get_libdir)/amdgpu-pro
	for i in opt/amdgpu-pro/lib/x86_64-linux-gnu/*; do
		[ ! -L $i ] && doexe $i
		[   -L $i ] && doins $i
	done
	# TODO lib32

	exeinto /usr/$(get_libdir)/xorg/modules/extensions
	doexe opt/amdgpu-pro/lib/xorg/modules/extensions/libglx.so
	doexe opt/amdgpu-pro/lib/xorg/modules/extensions/libglx-ext-hwe.so
	# TODO lib32

	exeinto /usr/$(get_libdir)/dri
	doexe usr/lib/x86_64-linux-gnu/dri/amdgpu_dri.so
	# TODO lib32

	#insinto /etc/X11/xorg.conf.d
	#doins "${T}/10-screen.conf"
	#doins "${T}/10-monitor.conf"
	#doins "${T}/10-device.conf"

	## Copy the OpenCL libs
	#if use opencl ; then
	#	insinto /etc/OpenCL/vendors
	#	doins etc/OpenCL/vendors/amdocl64.icd
	#	dobin opt/amdgpu-pro/bin/{clinfo,amdgpu-pro-px}
	#	exeinto /usr/$(get_libdir)/OpenCL/vendors/amdgpu-pro
	#	doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libamdocl12cl64.so
	#	doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libamdocl64.so
	#	doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libOpenCL.so.1
	#	dosym libOpenCL.so.1 /usr/$(get_libdir)/OpenCL/vendors/amdgpu-pro/libOpenCL.so

	#	# TODO: Add symlinks to /usr/lib/libamdocl12cl64.so & /usr/lib/libamdocl64.so ?

	#	if use abi_x86_32 ; then
	#		insinto /etc/OpenCL/vendors
	#		doins etc/OpenCL/vendors/amdocl32.icd
	#		exeinto /usr/lib32/OpenCL/vendors/amdgpu-pro
	#		doexe opt/amdgpu-pro/lib/i386-linux-gnu/libamdocl12cl32.so
	#		doexe opt/amdgpu-pro/lib/i386-linux-gnu/libamdocl32.so
	#		doexe opt/amdgpu-pro/lib/i386-linux-gnu/libOpenCL.so.1
	#		dosym libOpenCL.so.1 /usr/lib32/OpenCL/vendors/amdgpu-pro/libOpenCL.so
	#	fi
	#fi

	## Copy the Vulkan libs
	#if use vulkan ; then
	#	insinto /etc/vulkan/icd.d
	#	doins "${T}/amd_icd64.json"
	#	exeinto /usr/$(get_libdir)/vulkan/vendors/amdgpu-pro
	#	doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/amdvlk64.so

	#	if use abi_x86_32 ; then
	#		insinto /etc/vulkan/icd.d
	#		doins "${T}/amd_icd32.json"
	#		exeinto /usr/lib32/vulkan/vendors/amdgpu-pro
	#		doexe opt/amdgpu-pro/lib/i386-linux-gnu/amdvlk32.so
	#	fi
	#fi

	## Copy the OpenGL libs
	##local XORG_VERS=`Xorg -version 2>&1 | awk '/X.Org X Server/ {print $NF}'|sed 's/.\{2\}$//'`

#		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/lib
#		# doexe usr/lib/x86_64-linux-gnu/amdgpu-pro/libdrm_amdgpu.so.1.0.0
#		# dosym libdrm_amdgpu.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libdrm_amdgpu.so.1
#		# dosym libdrm_amdgpu.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libdrm_amdgpu.so
#
#		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libGL.so.1.2
#		dosym libGL.so.1.2 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libGL.so.1
#		dosym libGL.so.1.2 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libGL.so
#
#		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libgbm.so.1.0.0
#		dosym libgbm.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libgbm.so.1
#		dosym libgbm.so.1.0.0 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libgbm.so
#
#		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/gbm
#		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/gbm/gbm_amdgpu.so
#		dosym gbm_amdgpu.so /usr/$(get_libdir)/opengl/amdgpu-pro/gbm/libdummy.so
#		dosym opengl/amdgpu-pro/gbm /usr/$(get_libdir)/gbm
#
#		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/extensions
#		doexe opt/amdgpu-pro/lib/xorg/modules/extensions/libglx.so
#
#		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/modules/drivers
#		doexe opt/amdgpu-pro/lib/xorg/modules/drivers/amdgpu_drv.so
#		doexe opt/amdgpu-pro/lib/xorg/modules/drivers/modesetting_drv.so
#		# # TODO Do we need the amdgpu_drv.la file?
#
#		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/dri
#		doexe usr/lib/x86_64-linux-gnu/dri/amdgpu_dri.so
#		dosym ../opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/$(get_libdir)/dri/amdgpu_dri.so
#		# Hack for libGL.so hardcoded directory path for amdgpu_dri.so
#		#TODO: Do we still need this next line?
#		#dosym ../../opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/$(get_libdir)/x86_64-linux-gnu/dri/amdgpu_dri.so  # Hack to get X to started!
#
#		if use abi_x86_32 ; then
#			exeinto /usr/lib32/opengl/amdgpu-pro/lib
#			# doexe usr/lib/i386-linux-gnu/amdgpu-pro/libdrm_amdgpu.so.1.0.0
#			# dosym libdrm_amdgpu.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libdrm_amdgpu.so.1
#			# dosym libdrm_amdgpu.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libdrm_amdgpu.so
#
#			doexe opt/amdgpu-pro/lib/i386-linux-gnu/libGL.so.1.2
#			dosym libGL.so.1.2 /usr/lib32/opengl/amdgpu-pro/lib/libGL.so.1
#			dosym libGL.so.1.2 /usr/lib32/opengl/amdgpu-pro/lib/libGL.so
#
#			doexe opt/amdgpu-pro/lib/i386-linux-gnu/libgbm.so.1.0.0
#			dosym libgbm.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libgbm.so.1
#			dosym libgbm.so.1.0.0 /usr/lib32/opengl/amdgpu-pro/lib/libgbm.so
#
#			exeinto /usr/lib32/opengl/amdgpu-pro/gbm
#			doexe opt/amdgpu-pro/lib/i386-linux-gnu/gbm/gbm_amdgpu.so
#			dosym gbm_amdgpu.so /usr/lib32/opengl/amdgpu-pro/gbm/libdummy.so
#			dosym opengl/amdgpu-pro/gbm /usr/lib32/gbm
#
#			exeinto /usr/lib32/opengl/amdgpu-pro/dri
#			doexe usr/lib/i386-linux-gnu/dri/amdgpu_dri.so
#			dosym ../opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/lib32/dri/amdgpu_dri.so
#			# Hack for libGL.so hardcoded directory path for amdgpu_dri.so
#			#TODO: Do we still need this next line?
#			#dosym ../../../lib32/opengl/amdgpu-pro/dri/amdgpu_dri.so /usr/$(get_libdir)/i386-linux-gnu/dri/amdgpu_dri.so  # Hack to get X to started!
#		fi
#
#	# Copy the GLESv2 libs
#		exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/lib
#		doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libGLESv2.so.2
#		dosym libGLESv2.so.2 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libGLESv2.so
#
#		if use abi_x86_32 ; then
#			exeinto /usr/lib32/opengl/amdgpu-pro/lib
#			doexe opt/amdgpu-pro/lib/i386-linux-gnu/libGLESv2.so.2
#			dosym libGLESv2.so.2 /usr/lib32/opengl/amdgpu-pro/lib/libGLESv2.so
#		fi
#
#	# Copy the EGL libs
#	exeinto /usr/$(get_libdir)/opengl/amdgpu-pro/lib
#	doexe opt/amdgpu-pro/lib/x86_64-linux-gnu/libEGL.so.1
#	dosym libEGL.so.1 /usr/$(get_libdir)/opengl/amdgpu-pro/lib/libEGL.so
#
#	if use abi_x86_32 ; then
#		exeinto /usr/lib32/opengl/amdgpu-pro/lib
#		doexe opt/amdgpu-pro/lib/i386-linux-gnu/libEGL.so.1
#		dosym libEGL.so.1 /usr/lib32/opengl/amdgpu-pro/lib/libEGL.so
#	fi
}

pkg_prerm() {
	einfo "pkg_prerm"
	if use opengl ; then
		"${ROOT}"/usr/bin/eselect opengl set --use-old xorg-x11
	fi

	if use opencl ; then
		"${ROOT}"/usr/bin/eselect opencl set --use-old mesa
	fi
}

pkg_postinst() {
	einfo "pkg_postinst"
	if use opengl ; then
		"${ROOT}"/usr/bin/eselect opengl set --use-old amdgpu-pro
	fi

	if use opencl ; then
		"${ROOT}"/usr/bin/eselect opencl set --use-old amdgpu-pro
	fi
}
