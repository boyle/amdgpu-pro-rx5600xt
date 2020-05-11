# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit git-r3 cmake

EGIT_REPO_URI="https://gitlab.freedesktop.org/tomstdenis/umr.git"
EGIT_BRANCH="master"

DESCRIPTION="User Mode Register Debugger for AMDGPU Hardware="
HOMEPAGE="https://gitlab.freedesktop.org/tomstdenis/umr"
#SRC_URI="git@gitlab.freedesktop.org:tomstdenis/umr.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

DEPEND="
	>=x11-libs/libpciaccess-0.16
	>=sys-libs/ncurses-6.2-r1
	x11-libs/libdrm
	"
RDEPEND="${DEPEND}"
BDEPEND=">=sys-devel/llvm-9.0.0"

PATCHES=(
	"${FILESDIR}/cmake.patch"
)
