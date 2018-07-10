dir := $(shell pwd)
name = toolchain-arm64

default: build boot

restart: stop boot

#all: docker rootfs initramfs boot

build: rootfs initramfs

image:
	@ echo -e "\n=> Building sd card image...\n"

docker:
	@ echo -e "\n=> Building docker toolchain image...\n"
	docker build -t $(name) .

kernel:
	@ echo -e "\n=> Building kernel/modules...\n"
	docker run -it --rm \
		-v $(dir)/.cache:/data/build \
		-v $(dir)/.out:/data/output \
		-v $(dir)/bin/build_kernel.sh:/data/build_kernel.sh \
		-v $(dir)/config/kernel.config:/data/kernel.config \
		$(name) /data/build_kernel.sh

rootfs:
	@ echo -e "\n=> Building rootfs...\n"
	@docker run -it --rm \
		-v $(dir)/.cache:/data/build \
		-v $(dir)/.out:/data/output \
		-v $(dir)/bin:/data/bin \
		-v $(dir)/fs:/data/fs \
		$(name) /data/bin/build_rootfs.sh

initramfs:
	@ echo -e "\n=> Building initramfs...\n"
	@docker run -it --rm \
		-v $(dir)/.cache:/data/build \
		-v $(dir)/.out:/data/output \
		-v $(dir)/bin:/data/bin \
		-v $(dir)/fs:/data/fs \
		$(name) /data/bin/build_initramfs.sh

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

.PHONY: boot
