arch = $(shell uname -m)
dir := $(shell pwd)
name = toolchain-arm64
repo = homemate
tag  = latest
ver  = 3.6

default: all

docker: base ansible homebridge

all: kernel system image

restart: stop boot

build: init system

sd: system image

init:
	@ echo -e "\n=> Building docker toolchain image...\n"
	docker build -t $(name) .

image:
	@ echo -e "\n=> Building sd card image...\n"
	docker run -it --rm --privileged \
		-v $(dir)/bin:/data/bin \
		-v $(dir)/overlay:/data/overlay \
		-v $(dir)/.out:/data/output \
		$(name) /data/bin/image.sh

kernel:
	@ echo -e "\n=> Building kernel/modules...\n"
	docker run -it --rm \
		-v $(dir)/bin:/data/bin \
		-v $(dir)/overlay:/data/overlay \
		-v $(dir)/.out:/data/output \
		-v $(dir)/.cache:/data/build \
		-v $(dir)/config/kernel.config:/data/kernel.config \
		$(name) /data/bin/kernel.sh

system:
	@ echo -e "\n=> Building system...\n"
	docker run -it --rm \
		-v $(dir)/bin:/data/bin \
		-v $(dir)/ansible:/etc/ansible \
		-v $(dir)/overlay:/data/overlay \
		-v $(dir)/.out:/data/output \
		$(name) /data/bin/system.sh

boot:
	@ echo -e "\n=> Starting qemu...\n"
	@ ./bin/boot_qemu.sh

stop:
	@ echo -e "\n=> Stopping qemu...\n"
	killall qemu-system-aarch64 2>/dev/null || true

base:
	curl -o docker/alpine-s6/alpine-minirootfs-$(ver).0-$(arch).tar.gz -SL \
		http://dl-cdn.alpinelinux.org/alpine/v$(ver)/releases/$(arch)/alpine-minirootfs-$(ver).0-$(arch).tar.gz
	docker build --force-rm \
		--build-arg arch=$(arch) \
		--build-arg ver=$(ver) \
		-t $(repo)/alpine-s6:$(ver)-$(arch) \
		docker/alpine-s6
	rm docker/alpine-s6/alpine-minirootfs-$(ver).0-$(arch).tar.gz

ansible:
	docker build --force-rm \
		--build-arg arch=$(arch) \
		--build-arg ver=$(ver) \
		-t $(repo)/ansible:$(tag)-$(arch) \
		docker/ansible

homebridge:
	docker build --force-rm \
		--build-arg arch=$(arch) \
		--build-arg ver=$(ver) \
		-t $(repo)/homebridge:$(tag)-$(arch) \
		docker/homebridge

clean:
	@ echo -e "\n=> Cleaning up...\n"
	make -C .cache/linux clean
	make -C .cache/arm-trusted-firmware clean
	make -C .cache/u-boot clean

.PHONY: docker ansible
