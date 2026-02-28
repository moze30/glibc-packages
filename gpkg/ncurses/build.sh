TERMUX_PKG_HOMEPAGE=https://invisible-island.net/ncurses/ncurses.html
TERMUX_PKG_DESCRIPTION="System V Release 4.0 curses emulation library"
TERMUX_PKG_LICENSE="MIT"
TERMUX_PKG_MAINTAINER="@termux-pacman"
_PKG_VERSION=6.5
TERMUX_PKG_VERSION=${_PKG_VERSION}
TERMUX_PKG_SRCURL=https://invisible-mirror.net/archives/ncurses/ncurses-${_PKG_VERSION}.tar.gz
# 稳定版 ncurses-6.5.tar.gz 的 SHA256 值（请下载后确认）
TERMUX_PKG_SHA256=136d91bc269a9a5785e5f9e980bc76ab57428f604ce3e5a5a90cebc767971cc6
TERMUX_PKG_DEPENDS="glibc, gcc-libs-glibc"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-root-access
--disable-root-environ
--disable-setuid-environ
--enable-widec
--enable-pc-files
--mandir=$TERMUX_PREFIX/share/man
--with-manpage-format=normal
--with-pkg-config-libdir=$TERMUX_PREFIX/lib/pkgconfig
--with-shared
--with-xterm-kbs=del
--without-ada
--without-cxx-binding
--without-cxx
--without-versioned-syms
--without-stripping
--without-progs
"

termux_step_post_make_install() {
	for lib in ncurses ncurses++ form panel menu; do
		if [ -f $TERMUX_PREFIX/lib/lib${lib}w.so ]; then
			printf "INPUT(-l%sw)\n" "${lib}" > $TERMUX_PREFIX/lib/lib${lib}.so
			ln -svf ${lib}w.pc $TERMUX_PREFIX/lib/pkgconfig/${lib}.pc
		fi
	done

	printf 'INPUT(-lncursesw)\n' > $TERMUX_PREFIX/lib/libcursesw.so
	ln -svf libncurses.so $TERMUX_PREFIX/lib/libcurses.so

	for lib in tic tinfo; do
		if [ -f $TERMUX_PREFIX/lib/libncursesw.so ]; then
			printf "INPUT(libncursesw.so.%s)\n" "${_PKG_VERSION:0:1}" > $TERMUX_PREFIX/lib/lib${lib}.so
			ln -svf libncursesw.so.${TERMUX_PKG_VERSION:0:1} $TERMUX_PREFIX/lib/lib${lib}.so.${_PKG_VERSION:0:1}
			ln -svf ncursesw.pc $TERMUX_PREFIX/lib/pkgconfig/${lib}.pc
		fi
	done

	if [ -d $TERMUX_PREFIX/include/ncursesw ]; then
		mkdir -p $TERMUX_PREFIX/include/ncurses
		for i in $TERMUX_PREFIX/include/ncursesw/*; do
			if [ -e $TERMUX_PREFIX/include/$(basename $i) ]; then
				rm -f $TERMUX_PREFIX/include/$(basename $i)
			fi
			mv ${i} $TERMUX_PREFIX/include
			ln -sf ../${i##*/} $TERMUX_PREFIX/include/ncurses
			ln -sf ../${i##*/} $TERMUX_PREFIX/include/ncursesw
		done
	fi
}
