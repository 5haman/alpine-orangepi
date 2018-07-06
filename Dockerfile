FROM ubuntu:16.04

RUN apt-get update \
 && apt-get install -y automake bc binutils bison \
	build-essential curl device-tree-compiler \
	dialog dosfstools flex gcc git initramfs-tools \
	libssl-dev linux-base make parted rsync \
	sudo swig u-boot-tools unzip vim

ENTRYPOINT ["/bin/bash"]
