part uuid ${devtype} ${devnum}:${bootpart} uuid
setenv rootdev "/dev/mmcblk0p2"
setenv verbosity "d"
setenv bootargs console=${console} root=${rootdev} rw rootwait panic=10 consoleblank=0 loglevel=${verbosity}
setenv fdtfile sun50i-h5-orangepi-zero-plus.dtb

if load ${devtype} ${devnum}:${bootpart} ${kernel_addr_r} ${prefix}Image; then
  if load ${devtype} ${devnum}:${bootpart} ${fdt_addr_r} ${prefix}dtbs/${fdtfile}; then
    if load ${devtype} ${devnum}:${bootpart} ${ramdisk_addr_r} ${prefix}initramfs-linux.img; then
      booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r};
    else
      booti ${kernel_addr_r} - ${fdt_addr_r};
    fi;
  fi;
fi

# mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "Orange Pi Zero Plus boot script" -d boot.cmd boot.scr
# by Zdenek Brichacek http://blog.brichacek.net