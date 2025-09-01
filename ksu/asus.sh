#!/bin/bash
#
# hdjsjfjjwufbeizihfjejzf

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s susfs-main
git add . && git commit -am "drivers: SukiSU-Ultra"
KSU_git_ver=$(cd KernelSU && git rev-list --count HEAD)
KSU_ver=$(($KSU_git_ver + 10000 + 200))

patchesdir="$outside/ksu/patches/$(echo $kernel_ver | cut -d. -f1,2)"
suspatchesdir="$outside/ksu/sus_patches/$(echo $kernel_ver | cut -d. -f1,2)"

if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    git am "$patch_file"
  done
else
  echo "patching ksu failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

if [[ -d "$suspatchesdir" ]]; then
  for patch_file in "$suspatchesdir"/*.patch ; do
    git am "$patch_file"
  done
  echo "CONFIG_KSU_SUSFS=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_SUS_PATH=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_SUS_MOUNT=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_SUS_OVERLAYFS=n" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_TRY_UMOUNT=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_ENABLE_LOG=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y" >> “${defconfig_file}”
  echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> “${defconfig_file}”
else
  echo "patching ksu susfs failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-SukiSU-${KSU_ver}\"/" "${defconfig_file}"

echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"

echo -e " \nincludes SukiSU Ultra, ver ${KSU_ver}" >> banner_append
# echo -e " \nincludes SuSFS-main" >> banner_append

