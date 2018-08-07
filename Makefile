arch := $(shell uname -m)
dir  := $(shell pwd)
name := toolchain-$(arch)
repo := homemate
tag  := latest
ver  := 3.6

default: sd

docker: base ansible homebridge domoticz

sd: init kernel system image

restart: stop boot

init:
	@ echo -e "\n=> Building docker toolchain image...\n"
	docker build -t $(repo)/toolchain:$(tag)-$(arch) .

image:
	@ echo -e "\n=> Building sd card image...\n"
	docker run -it --rm --privileged \
		-v $(dir)/scripts:/data/bin \
		-v $(dir)/overlay:/data/overlay \
		-v $(dir)/.out:/data/output \
		$(repo)/toolchain:$(tag)-$(arch) /data/bin/image.sh

kernel:
	@ echo -e "\n=> Building kernel/modules...\n"
	docker run -it --rm \
		-v $(dir)/scripts:/data/bin \
		-v $(dir)/overlay:/data/overlay \
		-v $(dir)/patches:/data/patches \
		-v $(dir)/.out:/data/output \
		-v $(dir)/.cache:/data/build \
		-v $(dir)/config/linux/kernel-ok.config:/data/kernel.config \
		$(repo)/toolchain:$(tag)-$(arch) /data/bin/kernel.sh

system:
	@ echo -e "\n=> Building system...\n"
	$(dir)/scripts/service init
	docker run -it --rm \
		-v $(dir)/scripts:/data/bin \
		-v $(dir)/config/ansible:/etc/ansible \
		-v $(dir)/apps/docker:/etc/docker \
		-v $(dir)/overlay:/data/overlay \
		-v $(dir)/.out:/data/output \
		$(repo)/toolchain:$(tag)-$(arch) /data/bin/system.sh

sh:
	docker run -it --rm \
		-v $(dir)/scripts:/data/bin \
		-v $(dir)/config/ansible:/etc/ansible \
		-v $(dir)/apps/docker:/etc/docker \
		-v $(dir)/overlay:/data/overlay \
		-v $(dir)/.cache:/data/build \
		-v $(dir)/.out:/data/output \
		$(repo)/toolchain:$(tag)-$(arch)

boot:
	@ echo -e "\n=> Starting qemu...\n"
	@ ./scripts/boot_qemu.sh

stop:
	@ echo -e "\n=> Stopping qemu...\n"
	killall qemu-system-aarch64 2>/dev/null || true

base:
	curl -o apps/docker/base-alpine/alpine-minirootfs-$(ver).0-$(arch).tar.gz -SL \
		http://dl-cdn.alpinelinux.org/alpine/v$(ver)/releases/$(arch)/alpine-minirootfs-$(ver).0-$(arch).tar.gz
	docker build --force-rm \
		--build-arg arch=$(arch) \
		--build-arg ver=$(ver) \
		-t $(repo)/alpine-s6:$(ver)-$(arch) \
		apps/docker/base-alpine
	rm apps/docker/base-alpine/alpine-minirootfs-$(ver).0-$(arch).tar.gz

ansible:
	docker build --force-rm \
		--build-arg arch=$(arch) \
		--build-arg ver=$(ver) \
		-t $(repo)/ansible:$(tag)-$(arch) \
		apps/docker/ansible

homebridge:
	docker build --force-rm \
		--build-arg arch=$(arch) \
		--build-arg ver=$(ver) \
		-t $(repo)/homebridge:$(tag)-$(arch) \
		apps/docker/homebridge

domoticz:
	docker build --force-rm \
		--build-arg arch=$(arch) \
		--build-arg ver=$(ver) \
		-t $(repo)/domoticz:$(tag)-$(arch) \
		apps/docker/domoticz

clean:
	@ echo -e "\n=> Cleaning up...\n"
	make -C .cache/linux clean
	make -C .cache/arm-trusted-firmware clean
	make -C .cache/u-boot clean
