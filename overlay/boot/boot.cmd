part uuid ${devtype} ${devnum}:${bootpart} uuid
setenv verbosity "1"
setenv bootargs console=${console} zram.num_devices=2 net.ifnames=0 panic=1 consoleblank=0 loglevel=${verbosity}
setenv fdtfile sun50i-h5-orangepi-zero-plus.dtb

if load ${devtype} ${devnum}:${bootpart} ${kernel_addr_r} ${prefix}Image; then
  if load ${devtype} ${devnum}:${bootpart} ${fdt_addr_r} ${prefix}dtbs/${fdtfile}; then
    if load ${devtype} ${devnum}:${bootpart} ${ramdisk_addr_r} ${prefix}initramfs-linux.img; then
      booti ${kernel_addr_r} ${ramdisk_addr_r}:${filesize} ${fdt_addr_r};
    fi;
  fi;
fi
