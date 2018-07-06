
default: build stop start

restart: stop start

build:
	@ echo "=> Building image..."
	@./bin/mkbase.sh

start:
	@ echo "=> Starting virtual machine..."
	@./bin/qemu_arm.sh

stop:
	@ echo "=> Stopping virtual machine..."
	@killall qemu-system-aarch64 2>/dev/null || true

clean:
	rm -rf .out/*

.PHONY: build
