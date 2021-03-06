# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

MULTILIB_COMPAT=( abi_x86_{32,64} )

inherit unpacker multilib-minimal

SUPER_PN='amdgpu-pro'
MY_PV=$(ver_rs 2 '-')

DESCRIPTION="Proprietary OpenCL implementation for AMD GPUs"
HOMEPAGE="https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-navi-linux"
SRC_URI="${SUPER_PN}-${MY_PV}-ubuntu-18.04.tar.xz"

LICENSE="AMD-GPU-PRO-EULA"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RESTRICT="bindist mirror fetch strip"

BDEPEND="dev-util/patchelf"
COMMON=">=virtual/opencl-3"
DEPEND="${COMMON}"
RDEPEND="${COMMON}
	>=x11-libs/libdrm-2.4.1.101
	!media-libs/mesa[opencl]" # Bug #686790

QA_PREBUILT="/opt/amdgpu/lib*/*"

S="${WORKDIR}/${SUPER_PN}-${MY_PV}-ubuntu-18.04"

pkg_nofetch() {
	local pkgver=$(ver_cut 1-2)
	einfo "Please download Radeon Software for Linux version ${pkgver} for Ubuntu 18.04 from"
	einfo "    ${HOMEPAGE}"
	einfo "The archive should then be placed into your distfiles directory."
}

src_unpack() {
	default

	local ids_ver="1.0.0"
	local patchlevel=$(ver_cut 3)
	cd "${S}" || die
	unpack_deb "${S}/libdrm-amdgpu-common_${ids_ver}-${patchlevel}_all.deb"
	multilib_parallel_foreach_abi multilib_src_unpack
}

multilib_src_unpack() {
	local libdrm_amdgpu_amdgpu1="$(ls libdrm-amdgpu-amdgpu1_*_amd64.deb)"
	local libdrm_ver="2.4.100"
	local patchlevel=$(ver_cut 3)
	local deb_abi
	[[ ${ABI} == x86 ]] && deb_abi=i386

	if [ ! -f "${S}/libdrm-amdgpu-amdgpu1_${libdrm_ver}-${patchlevel}_${deb_abi:-${ABI}}.deb" ]; then
		eerror "wrong libdrm version (${libdrm_ver}) in ebuild, try $(ls ${S}/libdrm-amdgpu-amdgpu1_*_${deb_abi:-${ABI}}.deb)"
	fi

	mkdir -p "${BUILD_DIR}" || die
	pushd "${BUILD_DIR}" >/dev/null || die
	unpack_deb "${S}/libgl1-amdgpu-pro-appprofiles_${MY_PV}_all.deb"
	unpack_deb "${S}/opencl-amdgpu-pro-icd_${MY_PV}_${deb_abi:-${ABI}}.deb"
	unpack_deb "${S}/opencl-orca-amdgpu-pro-icd_${MY_PV}_${deb_abi:-${ABI}}.deb"
	unpack_deb "${S}/opencl-amdgpu-pro-comgr_${MY_PV}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/clinfo-amdgpu-pro_${MY_PV}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/libdrm-amdgpu-common_1.0.0-${patchlevel}_all.deb"
	#unpack_deb "${S}/libdrm-amdgpu-amdgpu1_${libdrm_ver}-${patchlevel}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/libdrm-amdgpu-radeon1_${libdrm_ver}-${patchlevel}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/libdrm-amdgpu-utils_${libdrm_ver}-${patchlevel}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/libdrm-amdgpu-dev_${libdrm_ver}-${patchlevel}_${deb_abi:-${ABI}}.deb"
	#unpack_deb "${S}/libdrm2-amdgpu_${libdrm_ver}-${patchlevel}_${deb_abi:-${ABI}}.deb"

# 	unpack_deb "${S}/amdgpu-pro-core_20.10-1048554_all.deb"
# 	unpack_deb "${S}/amdgpu-pro-hwe_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/amdgpu-pro-lib32_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/amdgpu-pro-pin_20.10-1048554_all.deb"
# 	unpack_deb "${S}/amdgpu-pro_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/amf-amdgpu-pro_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/hip-amdgpu-pro_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/libegl1-amdgpu-pro_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/libegl1-amdgpu-pro_20.10-1048554_i386.deb"
# 	unpack_deb "${S}/libgl1-amdgpu-pro-appprofiles_20.10-1048554_all.deb"
# 	unpack_deb "${S}/libgl1-amdgpu-pro-dri_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/libgl1-amdgpu-pro-dri_20.10-1048554_i386.deb"
# 	unpack_deb "${S}/libgl1-amdgpu-pro-ext-hwe_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/libgl1-amdgpu-pro-ext-hwe_20.10-1048554_i386.deb"
# 	unpack_deb "${S}/libgl1-amdgpu-pro-ext_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/libgl1-amdgpu-pro-ext_20.10-1048554_i386.deb"
# 	unpack_deb "${S}/libgl1-amdgpu-pro-glx_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/libgl1-amdgpu-pro-glx_20.10-1048554_i386.deb"
# 	unpack_deb "${S}/libglapi1-amdgpu-pro_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/libglapi1-amdgpu-pro_20.10-1048554_i386.deb"
# 	unpack_deb "${S}/libgles2-amdgpu-pro_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/libgles2-amdgpu-pro_20.10-1048554_i386.deb"
# 	unpack_deb "${S}/libopencl1-amdgpu-pro_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/libopencl1-amdgpu-pro_20.10-1048554_i386.deb"
# 	unpack_deb "${S}/opencl-amdgpu-pro-comgr_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/opencl-amdgpu-pro-dev_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/opencl-amdgpu-pro-icd_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/opencl-amdgpu-pro_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/opencl-orca-amdgpu-pro-icd_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/opencl-orca-amdgpu-pro-icd_20.10-1048554_i386.deb"
# 	unpack_deb "${S}/vulkan-amdgpu-pro_20.10-1048554_amd64.deb"
# 	unpack_deb "${S}/vulkan-amdgpu-pro_20.10-1048554_i386.deb"
	popd >/dev/null || die
}

multilib_src_install() {
	local dir_abi short_abi libdir
	[[ ${ABI} == x86 ]] && dir_abi=i386-linux-gnu && short_abi=32
	[[ ${ABI} == amd64 ]] && dir_abi=x86_64-linux-gnu && short_abi=64

	#into "/opt/amdgpu"
	#patchelf --set-rpath '$ORIGIN' "opt/${SUPER_PN}/lib/${dir_abi}"/libamdocl-orca${short_abi}.so || die "Failed to fix library rpath"
	#libdir="opt/${SUPER_PN}/lib/${dir_abi}"
	#for i in libamdocl-orca${short_abi}.so libamd_comgr.so libamdocl12cl${short_abi}.so libamdocl${short_abi}.so; do
	#	patchelf --set-soname $i ${libdir}/$i || die "Failed to fix library soname"
	#	#mv ${libdir}/$i ${libdir}/$i
	#done
	#rm -rf "opt/amdgpu/lib/${dir_abi}/pkgconfig"
	dolib.so "opt/${SUPER_PN}/lib/${dir_abi}"/*
	#dolib.so "opt/amdgpu/lib/${dir_abi}"/*

	#dobin "opt/amdgpu/bin"/*
	#dobin "opt/amdgpu-pro/bin"/*

	insinto /etc/OpenCL/vendors
	#echo "/opt/amdgpu/$(get_libdir)/libamdocl${short_abi}.so" \
	echo "libamdocl${short_abi}.so" \
		> "${T}/${SUPER_PN}-${ABI}.icd" || die "Failed to generate ICD file for ABI ${ABI}"
	#echo "/opt/amdgpu/$(get_libdir)/libamdocl-orca${short_abi}.so" \
	echo "libamdocl-orca${short_abi}.so" \
		> "${T}/${SUPER_PN}-orca-${ABI}.icd" || die "Failed to generate ICD file for ABI ${ABI}"
	doins "${T}/${SUPER_PN}-${ABI}.icd"
	doins "${T}/${SUPER_PN}-orca-${ABI}.icd"

	insinto /etc/amd
	doins etc/amd/amdapfxx.blb
}

multilib_src_install_all() {
	insinto "/opt/amdgpu"
	#doins -r opt/amdgpu/share
}

pkg_postinst() {
	if [[ -z "${REPLACING_VERSIONS}" ]]; then
		ewarn "Using proprietary OpenCL libraries together with the Open Source amdgpu"
		ewarn "stack is not officially supported by AMD. Do not ask them for support"
		ewarn "in case of problems with this package."
		ewarn ""
		ewarn "If installed, the AMDGPU-Pro driver stack will collide with this package."
		elog ""
	fi

	elog "This package is now deprecated on amd64 in favour of dev-libs/rocm-opencl-runtime for"
	elog "GFX8 (Fiji, Polaris 10) and GFX9 (Vega 10, Vega 7nm). ROCM does not support Navi cards."
	elog "For GFX10 (Navi) cards, the amdgpu-pro-opencl package is the only OpenCL option."
}
