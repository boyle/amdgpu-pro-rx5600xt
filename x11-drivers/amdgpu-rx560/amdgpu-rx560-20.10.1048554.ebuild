# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit linux-mod unpacker

DESCRIPTION="AMD open source kernel driver for the RX 560"
HOMEPAGE="https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-10"

REV=${PV%.*}
BUILD=${PV##*.}
ARCHIVE="amdgpu-pro-${REV}-${BUILD}-ubuntu-18.04.tar.xz"
AMDGPU_KVER="5.4.7.53"  # from amdgpu-dkms_5.4.7.53-1048554_all.deb

SRC_URI="https://drivers.amd.com/drivers/linux/${ARCHIVE}"

LICENSE="AMD-GPU-PRO-EULA"
SLOT="0"
KEYWORDS="~amd64"

RESTRICT="fetch strip"

DEPEND=""  # binary packages installed, no need for dependencies at "build"/install
RDEPEND="
	>=sys-kernel/linux-firmware-20200316
"

S="${WORKDIR}"

CONFIG_CHECK="
	!HSA_AMD
	!DRM_TTM
	!DRM_SCHED
	!DRM_AMDGPU
	!DRM_AMD_DC
	MMU_NOTIFIER"

#   modulename(libdir:srcdir:objdir) 
MODULE_NAMES="
	amdgpu(amdgpu:${S}/amd/amdgpu:${S}/amd/amdgpu)
	amd-sched(amdgpu:${S}/scheduler:${S}/scheduler)
	amdttm(amdgpu:${S}/ttm:${S}/ttm)
	amdkcl(amdgpu:${S}/amd/amdkcl:${S}/amd/amdkcl)
"

PATCHES=(
	"${FILESDIR}/Makefile-DRM_VER.patch"
	"${FILESDIR}/drm_debug.patch"
	"${FILESDIR}/mmu_notifier-5.5.patch"
	"${FILESDIR}/ttm-ioremap.patch"
	)

pkg_nofetch() {
	einfo "Please download"
	einfo "  - ${ARCHIVE}"
	einfo "from ${HOMEPAGE} and place them in DISTDIR directory."
}

pkg_setup() {
	linux-mod_pkg_setup
	if kernel_is lt 5 3 0 ; then
		eerror "You must build against 5.3.0 or higher kernels."
	fi
}

unpack_deb() {
	echo ">>> Unpacking ${1##*/} to ${PWD}"
	unpack $1
	unpacker ./data.tar*
	rm -f debian-binary {control,data}.tar*
}

src_unpack() {
	default
	unpack_deb amdgpu-pro-${REV}-${BUILD}-ubuntu-18.04/amdgpu-dkms_${AMDGPU_KVER}-${BUILD}_all.deb
	rm -rf amdgpu-pro-${REV}-${BUILD}-ubuntu-18.04
	rm -rf etc
	mv usr/src/amdgpu-${AMDGPU_KVER}-${BUILD}/* .
	rm -rf usr
}

src_configure() {
	set_arch_to_kernel
	sed -i -e '/^.\/configure/d' -e '/^mkdir /d' -e '/^cp /d' ./pre-build.sh  # skip assumed firmware install
	./pre-build.sh ${KV_FULL}
	export KERNELVER=${KV_FULL}
	econf
}

src_compile() {
	BUILD_TARGETS="clean modules"
	BUILD_PARAMS="-C ${KERNEL_DIR} kdir=${KERNEL_DIR} M=${S}"
	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install
}
