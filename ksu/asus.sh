#!/bin/bash
#
# hdjsjfjjwufbeizihfjejzf

export maindir="$(pwd)"
export outside="${maindir}/.."
source "${outside}/$1env"

# Import SukiSU-Ultra
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s nongki
echo "Applying: SukiSU-Ultra"

export sukisu_makefile_path="${maindir}/KernelSU/kernel/Makefile"
export sukisu_version_api="$(sed -n 's/^[[:space:]]*KSU_VERSION_API[[:space:]]*:=[[:space:]]*\([^#]*\)/\1/p' ${sukisu_makefile_path} | head -n1)"

git add . && git commit -am "drivers: SukiSU-Ultra ${sukisu_version_api}"
KSU_git_ver=$(cd KernelSU && git rev-list --count HEAD)
KSU_ver=$(($KSU_git_ver + 10000 + 200))

patchesdir="$outside/ksu/patches/$(echo $kernel_ver | cut -d. -f1,2)"
suspatchesdir="$outside/ksu/sus_patches/$(echo $kernel_ver | cut -d. -f1,2)"

if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    git am "$patch_file"
    echo "patch config: ${defconfig_file}"
    echo "CONFIG_KSU=y" >> "${defconfig_file}"
    echo "CONFIG_KSU_MANUAL_HOOK=y" >> "${defconfig_file}"
  done
  echo "patching ksu succeeded."
else
  echo "patching ksu failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

if [[ -d "$suspatchesdir" ]]; then
  for patch_file in "$suspatchesdir"/*.patch ; do
    git am "$patch_file"
  done
  echo "CONFIG_KSU_SUSFS_SUS_SU is not set" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_HAS_MAGIC_MOUNT=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_SUS_PATH=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_SUS_MOUNT=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_KSU_DEFAULT_MOUNT=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_AUTO_ADD_SUS_BIND_MOUNT=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_SUS_KSTAT=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_SUS_OVERLAYFS=n" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_TRY_UMOUNT=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_AUTO_ADD_TRY_UMOUNT_FOR_BIND_MOUNT=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_SPOOF_UNAME=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_ENABLE_LOG=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_HIDE_KSU_SUSFS_SYMBOLS=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_SPOOF_CMDLINE_OR_BOOTCONFIG=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_OPEN_REDIRECT=y" >> "${defconfig_file}"
  cp "${defconfig_file}" defconfig.zip
  echo "patching ksu susfs succeeded."
else
  echo "patching ksu susfs failed, the kernel version you want to patch doesnt have patches here yet"
  exit 1
fi

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-SukiSU-@${sukisu_version_api}\"/" "${defconfig_file}"

echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"

echo -e " \nincludes SukiSU Ultra, ver ${sukisu_version_api}" >> banner_append
# echo -e " \nincludes SuSFS-main" >> banner_append

