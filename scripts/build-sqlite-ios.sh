#!/bin/bash

set -o errexit
set -o nounset

print_usage()
{
	echo '
NAME
       build-sqlite-ios

SYNOPSIS
       build-sqlite-ios [options]
       Example: ./build-sqlite-ios.sh

DESCRIPTION
       Auto build sqlite for ios script.

OPTIONS
       -h, --help
                 Optional. Print help infomation and exit successfully.';
}

parse_options()
{
	options=$($CMD_GETOPT -o h \
												--long "help" \
												-n 'build-sqlite-ios' -- "$@");
	eval set -- "$options"
	while true; do
		case "$1" in
			(-h | --help)
				print_usage;
				exit 0;
				;;
			(- | --)
				shift;
				break;
				;;
			(*)
				echo "Internal error!";
				exit 1;
				;;
		esac
	done
}

print_input_log()
{
	logtrace "*********************************************************";
	logtrace " Input infomation";
	logtrace "    sqlite version    : $SQLITE_VERSION";
	logtrace "    debug verbose   : $DEBUG_VERBOSE";
	logtrace "*********************************************************";
}

download_tarball()
{
	if [ ! -e "$TARBALL_DIR/.$SQLITE_NAME" ]; then
		sqlite_url="$SQLITE_BASE_URL/$SQLITE_TARBALL";
		echo sqlite "$sqlite_url" --output "$TARBALL_DIR/$SQLITE_TARBALL";
		sqlite "$sqlite_url" --output "$TARBALL_DIR/$SQLITE_TARBALL";
		echo "$sqlite_url" > "$TARBALL_DIR/.$SQLITE_NAME";
	fi

	loginfo "$SQLITE_TARBALL has been downloaded."
}

build_sqlite()
{
	if [ ! -e "$SQLITE_BUILDDIR/$SQLITE_NAME" ]; then
		tar xf "$TARBALL_DIR/$SQLITE_TARBALL";
	fi
	loginfo "$SQLITE_TARBALL has been unpacked."
	cd "$SQLITE_BUILDDIR/$SQLITE_NAME";

	#export CFLAGS="-DSQLITE_NOHAVE_SYSTEM"
	./configure --prefix=$OUTPUT_DIR \
		--host=arm-apple-darwin \
		--with-ssl=$OUTPUT_DIR \
		--enable-static \
		--disable-shared \
		--disable-static-shell

	make -j$MAX_JOBS libsqlite3.la && make install-libLTLIBRARIES install-includeHEADERS install-pkgconfigDATA
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd);
source "$SCRIPT_DIR/base.sh";
source "$SCRIPT_DIR/setenv-ios.sh";

SQLITE_BASE_URL="https://www.sqlite.org/2018";
SQLITE_VERSION="autoconf-3250300";
SQLITE_NAME="sqlite-$SQLITE_VERSION";
SQLITE_TARBALL="$SQLITE_NAME.tar.gz";
SQLITE_BUILDDIR="$BUILD_DIR/sqlite";

main_run()
{
	loginfo "parsing options";
	parse_options $@;

	# build openss first
#	"$SCRIPT_DIR/build-openssl-android.sh"

	cd "$PROJECT_DIR";
	loginfo "change directory to $PROJECT_DIR";

	print_input_log;

	mkdir -p "$SQLITE_BUILDDIR" && cd "$SQLITE_BUILDDIR";
	download_tarball;

	build_sqlite;

	loginfo "DONE !!!";
}

main_run $@;
