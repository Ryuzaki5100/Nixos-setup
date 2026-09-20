#!/usr/bin/env bash
set -euo pipefail

# flash-iso.sh — write an ISO to a block device with a live progress bar + ETA.
#
# Usage: flash-iso.sh [ISO_FILE] [TARGET]
#
#   ISO_FILE  path to the .iso to flash
#   TARGET    whole-disk device (/dev/sda) or a mount path (e.g. /mnt/usb)
#
# If arguments are omitted they are prompted for. Run as a normal user; the
# script re-executes itself through sudo.

usage() {
    cat <<'EOF'
Usage: flash-iso.sh [ISO_FILE] [TARGET]

  ISO_FILE  path to the .iso to flash
  TARGET    whole-disk device (/dev/sda) or a mount path (e.g. /mnt/usb)

If arguments are omitted you will be prompted. Run as a normal user; the
script re-executes itself with sudo.
EOF
}

die() { printf '\nError: %s\n' "$*" >&2; exit 1; }

human() { numfmt --to=iec --suffix=B "$1" 2>/dev/null || printf '%s' "$1"; }

fmt_time() {
    local s="${1:-0}"
    printf '%02d:%02d:%02d' "$((s / 3600))" "$(((s % 3600) / 60))" "$((s % 60))"
}

FIFO_DIR=""
cleanup() { [ -n "$FIFO_DIR" ] && rm -rf "$FIFO_DIR"; }
trap cleanup EXIT

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
    usage
    exit 0
fi

if [ "${EUID:-$(id -u)}" -ne 0 ]; then
    exec sudo -- "$0" "$@"
fi

iso="${1:-}"
dev_input="${2:-}"

if [ -z "$iso" ]; then
    read -r -p "ISO file path: " iso
fi
[ -n "$iso" ] || die "no ISO file given."
[ -f "$iso" ] || die "ISO file not found: $iso"
[ -r "$iso" ] || die "ISO file not readable: $iso"
total="$(stat -c%s "$iso")"
[ "$total" -gt 0 ] || die "ISO file is empty: $iso"

if [ -z "$dev_input" ]; then
    printf '\nAvailable disks:\n'
    lsblk -dpno NAME,SIZE,TYPE,MODEL
    printf '\n'
    read -r -p "Target drive (/dev/sdX or mount path): " dev_input
fi
[ -n "$dev_input" ] || die "no target given."

# Resolve the target to a whole-disk device.
dev=""
if [ -b "$dev_input" ]; then
    dev="$dev_input"
elif [ -d "$dev_input" ]; then
    src="$(findmnt -no SOURCE --target "$dev_input" 2>/dev/null || true)"
    [ -n "$src" ] || die "'$dev_input' is not a mounted filesystem."
    dev="$src"
else
    die "not a block device or mount path: $dev_input"
fi

# If a partition was given, step up to its parent disk.
if [ "$(lsblk -dno TYPE "$dev" 2>/dev/null || true)" != "disk" ]; then
    parent="$(lsblk -no PKNAME "$dev" 2>/dev/null | head -n1 || true)"
    [ -n "$parent" ] && dev="/dev/$parent"
fi

[ -b "$dev" ] || die "not a block device: $dev"
[ "$(lsblk -dno TYPE "$dev")" = "disk" ] || die "refusing to write to a non-disk device: $dev"

root_src="$(findmnt -no SOURCE / 2>/dev/null || true)"
root_disk="$(lsblk -no PKNAME "$root_src" 2>/dev/null | head -n1 || true)"
if [ -n "$root_disk" ] && [ "/dev/$root_disk" = "$dev" ]; then
    die "refusing to write to $dev — it holds the running system (/)."
fi

dev_size="$(blockdev --getsize64 "$dev")"
[ "$total" -le "$dev_size" ] || die "ISO ($(human "$total")) is larger than $dev ($(human "$dev_size"))."

model="$(lsblk -dno MODEL "$dev" 2>/dev/null | sed 's/ *$//' || true)"

printf '\n'
printf '  ISO     : %s (%s)\n' "$iso" "$(human "$total")"
printf '  Target  : %s  %s%s\n' "$dev" "$(human "$dev_size")" "${model:+  [$model]}"
printf '\n'
printf '  \033[1;31mALL DATA ON %s WILL BE DESTROYED.\033[0m\n' "$dev"
base="${dev##*/}"
read -r -p "  Type '$base' to confirm: " answer
[ "$answer" = "$base" ] || die "confirmation failed — aborted."

# Unmount anything currently mounted from the target.
while read -r mnt; do
    [ -n "$mnt" ] || continue
    printf 'Unmounting %s ...\n' "$mnt"
    umount "$mnt" || die "failed to unmount $mnt"
done < <(lsblk -pno MOUNTPOINT "$dev")

# Disable any swap sitting on the target.
while read -r part fstype; do
    if [ "$fstype" = "swap" ]; then
        printf 'Disabling swap on %s ...\n' "$part"
        swapoff "$part" 2>/dev/null || true
    fi
done < <(lsblk -pno NAME,FSTYPE "$dev")

flash_with_dd() {
    local bs=4194304 line done=0 pct=0 width=30 filled=0 bar
    local elapsed=0 rate=0 eta=0 rc=0 dd_pid
    FIFO_DIR="$(mktemp -d)"
    local fifo="$FIFO_DIR/progress"
    mkfifo "$fifo"

    dd if="$iso" of="$dev" bs="$bs" status=progress conv=fsync 2>"$fifo" &
    dd_pid=$!

    while IFS= read -r -d $'\r' line; do
        done="${line%% bytes*}"
        [[ "$done" =~ ^[0-9]+$ ]] || continue
        pct=$(( done * 100 / total ))
        elapsed=$(( SECONDS - start_time ))
        rate=0
        eta=0
        if [ "$elapsed" -gt 0 ]; then rate=$(( done / elapsed )); fi
        if [ "$rate" -gt 0 ] && [ "$done" -lt "$total" ]; then
            eta=$(( (total - done) / rate ))
        fi
        filled=$(( pct * width / 100 ))
        bar="$(printf '%*s' "$filled" '' | tr ' ' '#')$(printf '%*s' "$((width - filled))" '' | tr ' ' '-')"
        printf '\r[%s] %3d%%  %s / %s  %s/s  ETA %s   ' \
            "$bar" "$pct" "$(human "$done")" "$(human "$total")" "$(human "$rate")" "$(fmt_time "$eta")"
    done < "$fifo"

    wait "$dd_pid" || rc=$?
    rm -rf "$FIFO_DIR"
    FIFO_DIR=""
    bar="$(printf '%*s' "$width" '' | tr ' ' '#')"
    printf '\r[%s] 100%%  %s / %s  %s/s  ETA 00:00:00   \n' \
        "$bar" "$(human "$total")" "$(human "$total")" "$(human "$rate")"
    return "$rc"
}

printf '\nFlashing %s -> %s\n' "$iso" "$dev"
start_time=$SECONDS

if command -v pv >/dev/null 2>&1; then
    pv -s "$total" -peta "$iso" | dd of="$dev" bs=4M conv=fsync status=none
    printf '\n'
else
    flash_with_dd
fi

sync
printf 'Done in %s. You can safely remove %s.\n' "$(fmt_time "$((SECONDS - start_time))")" "$dev"
