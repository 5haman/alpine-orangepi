dir := $(shell pwd)
name = toolchain-arm64

default: sd

sd: kernel system image

restart: stop boot

build: init system

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
		-v $(dir)/conf:/data/kernel.config \
		$(name) /data/bin/kernel.sh
		#-v $(dir)/config/kernel.config:/data/kernel.config \

system:
	@ echo -e "\n=> Building system...\n"
	@docker run -it --rm \
		-v $(dir)/bin:/data/bin \
		-v $(dir)/overlay:/data/overlay \
		-v $(dir)/.out:/data/output \
		$(name) /data/bin/system.sh

boot:
	@ echo -e "\n=> Starting qemu...\n"
	@ ./bin/boot_qemu.sh

stop:
	@ echo -e "\n=> Stopping qemu...\n"
	killall qemu-system-aarch64 2>/dev/null || true

clean:
	@ echo -e "\n=> Cleaning up...\n"
	make -C .cache/linux clean
	make -C .cache/arm-trusted-firmware clean
	make -C .cache/u-boot clean

.PHONY: boot docker kernel
