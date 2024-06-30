#!/usr/bin/env bash

# From https://github.com/cloudflare/docker/blob/master/contrib/mkimage/busybox-static
set -e

rootfsDir="$1" # First parameter is location where busybox static files will be populated
shift # Equivalent to shift 1, drop the first parameter and move forward one step behind

busybox="$(which busybox 2>/dev/null || true)"
if [ -z "$busybox" ]; then
    echo >&2 'error: busybox: not found'
    echo >&2 '  install it with your distribution "busybox-static" package'
    exit 1
fi
if ! ldd "$busybox" 2>&1 | grep -q 'not a dynamic executable'; then
    echo >&2 "error: '$busybox' appears to be a dynamic executable"
    echo >&2 '  you should install your distribution "busybox-static" package instead'
    exit 1
fi

mkdir -p "$rootfsDir/bin"
rm -f "$rootfsDir/bin/busybox"
cp "$busybox" "$rootfsDir/bin/busybox"

(
    cd "$rootfsDir"

    IFS=$'\n'
    modules=( $(bin/busybox --list-modules) )
    unset IFS

    for module in "${modules[@]}"; do
        mkdir -p "$(dirname "$module")"
        # ln target linkname
        ln -sf /bin/busybox "$module" # Force creation of symlinks
    done
)
