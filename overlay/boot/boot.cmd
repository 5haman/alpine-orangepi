setenv dtbs boot/orangepi-zero-plus.dtb
setenv kernel boot/vmlinux
setenv ramdisk boot/ramdisk.img

part uuid ${devtype} ${devnum}:${bootpart} uuid
setenv bootargs console=${console} panic=1 loglevel=0 zram.num_devices=2 net.ifnames=0

load ${devtype} ${devnum}:${bootpart} ${kernel_addr_r} ${prefix}${kernel}
load ${devtype} ${devnum}:${bootpart} ${fdt_addr_r} ${prefix}${dtbs}
load ${devtype} ${devnum}:${bootpart} ${ramdisk_addr_r} ${prefix}${ramdisk}
booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r}
