#!/bin/sh
# 挂载存活判定单元测试：真实查 mounts/mountinfo + 三态判定 + 元模块分支
# 用法：sh tests/mount-unit.sh
set -u
BASE=/tmp/qcm
ROOT=$BASE/root
MOD=$BASE/mod
PASS=0; FAIL=0
ok()  { PASS=$((PASS+1)); printf '  ok   %s\n' "$1"; }
bad() { FAIL=$((FAIL+1)); printf '  FAIL %s\n' "$1"; }
chk() { if [ "$2" = "$3" ]; then ok "$1"; else bad "$1（期望 $3，实际 $2）"; fi; }

SRC=$(cd "$(dirname "$0")/.." && pwd)

setup() {
    rm -rf "$BASE"
    mkdir -p "$BASE/data" "$BASE/adb/modules" "$MOD" "$ROOT/vendor/etc"
    ln -s "$SRC/lib" "$MOD/lib"
    mkdir -p "$MOD/files/vendor/etc"
    printf 'rewritten\n' >"$MOD/files/vendor/etc/a.xml"
    printf 'rewritten\n' >"$MOD/files/vendor/etc/b.xml"
    printf '/vendor/etc/a.xml\n/vendor/etc/b.xml\n' >"$BASE/data/mounts.list"
    : >"$BASE/proc.mounts"
    : >"$BASE/proc.mountinfo"
    : >"$BASE/data/state.conf"
}

alive() {
    SD_DATA=$BASE/data MODDIR=$MOD SD_ROOT=$ROOT SD_PS=$ROOT/ps \
    SD_ADB=$BASE/adb SD_PROC_MOUNTS=$BASE/proc.mounts SD_MOUNTINFO=$BASE/proc.mountinfo \
    sh -c '. "$MODDIR/lib/qc.sh"; sd_mounts_alive' 2>/dev/null
    echo "rc=$?"
}

state() {
    SD_DATA=$BASE/data MODDIR=$MOD SD_ROOT=$ROOT SD_PS=$ROOT/ps \
    SD_ADB=$BASE/adb SD_PROC_MOUNTS=$BASE/proc.mounts SD_MOUNTINFO=$BASE/proc.mountinfo \
    sh -c '. "$MODDIR/lib/qc.sh"; qc_overrides_state' 2>/dev/null
}

echo "[1] 仅内容一致但未实际挂载（不再误报存活）"
setup
printf 'rewritten\n' >"$ROOT/vendor/etc/a.xml"
printf 'rewritten\n' >"$ROOT/vendor/etc/b.xml"
chk "未挂载判定为 no" "$(state)" "no"
chk "sd_mounts_alive 返回 1" "$(alive | tail -1)" "rc=1"

echo "[2] 全部目标都在 proc/mounts 中"
setup
printf '/dev/block /vendor/etc/a.xml ext4 ro 0 0\n' >"$BASE/proc.mounts"
printf '/dev/block /vendor/etc/b.xml ext4 ro 0 0\n' >>"$BASE/proc.mounts"
chk "全挂上判定为 yes" "$(state)" "yes"
chk "sd_mounts_alive 返回 0" "$(alive | tail -1)" "rc=0"

echo "[3] 仅部分目标挂载（三态 partial）"
setup
printf '/dev/block /vendor/etc/a.xml ext4 ro 0 0\n' >"$BASE/proc.mounts"
chk "部分挂载判定为 partial" "$(state)" "partial"
chk "sd_mounts_alive 返回 0" "$(alive | tail -1)" "rc=0"

echo "[4] mountinfo root 字段命中覆盖层目录"
setup
printf '10 1 0:1 %s/files/vendor/etc/a.xml /vendor/etc/a.xml ro - tmpfs tmpfs rw\n' "$MOD" >"$BASE/proc.mountinfo"
chk "mountinfo 命中判定为 partial" "$(state)" "partial"

echo "[5] 元模块（NoMount）：nm.list 与 system 目录俱在"
setup
mkdir -p "$BASE/adb/modules/meta-nomount" "$MOD/system/vendor/etc"
printf '/vendor/etc/a.xml\n' >"$BASE/data/nm.list"
chk "nomount 判定为 yes" "$(state)" "yes"
: >"$BASE/data/nm.list"
chk "nomount 但 nm.list 为空判定为 no" "$(state)" "no"

echo "[6] 空清单与 overrides_off=1"
setup
: >"$BASE/data/mounts.list"
chk "空清单返回 no" "$(state)" "no"
setup
printf '/dev/block /vendor/etc/a.xml ext4 ro 0 0\n/dev/block /vendor/etc/b.xml ext4 ro 0 0\n' >"$BASE/proc.mounts"
printf 'overrides_off=1\n' >"$BASE/data/state.conf"
chk "overrides_off=1 返回 no" "$(state)" "no"

echo
echo "结果：通过 $PASS，失败 $FAIL"
[ "$FAIL" -eq 0 ]
