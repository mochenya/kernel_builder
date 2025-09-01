#!/bin/bash
#
# hdjsjfjjwufbeizihfjejzf

export maindir="$(pwd)"
export outside="${maindir}/.."
export susfsdir="${outside}/susfs4ksu"
source "${outside}/$1env"

# Import SukiSU-Ultra
curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s susfs-main
echo "Applying: SukiSU-Ultra"
git add . && git commit -am "drivers: SukiSU-Ultra"
KSU_git_ver=$(cd KernelSU && git rev-list --count HEAD)
KSU_ver=$(($KSU_git_ver + 10000 + 200))

# Clone susfs4ksu
git clone --depth=1 https://gitlab.com/simonpunk/susfs4ksu.git "${susfsdir}"
echo "Cloning: susfs4ksu to ${susfsdir}"
ls -la "${susfsdir}"

patchesdir="$outside/ksu/patches/$(echo $kernel_ver | cut -d. -f1,2)"
suspatchesdir="$outside/ksu/sus_patches/$(echo $kernel_ver | cut -d. -f1,2)"
sukisupatchesdir="$outside/ksu/sukisu_patches/$(echo $kernel_ver | cut -d. -f1,2)"

if [[ -d "$patchesdir" ]]; then
  for patch_file in "$patchesdir"/*.patch ; do
    git am "$patch_file"
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
  for patch_file in "$sukisupatchesdir"/*.patch ; do
    patch -p1 > "$patch_file"
  done
  cp "${susfsdir}/kernel_patches/fs/*" ./fs/
  cp "${susfsdir}/kernel_patches/include/linux/*" ./linux/
  ls -la ./fs/
  ls -la ./linux/
  echo "patching susfs succeeded."
  echo "${defconfig_file}"
  echo "CONFIG_KSU=y" >> "${defconfig_file}"
  echo "CONFIG_KSU_SUSFS_SUS_SU=n" >> "${defconfig_file}"
  echo "CONFIG_KSU_MANUAL_HOOK=y" >> "${defconfig_file}"
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

sed -i "s/\(CONFIG_LOCALVERSION=\)\(.*\)/\1\"-${kernel_name}-SukiSU-${KSU_ver}\"/" "${defconfig_file}"

echo "$(grep 'CONFIG_LOCALVERSION=' ${defconfig_file})"

echo -e " \nincludes SukiSU Ultra, ver ${KSU_ver}" >> banner_append
# echo -e " \nincludes SuSFS-main" >> banner_append

