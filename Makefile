
default: build stop start

restart: stop start

build:
	@ echo "=> Building image..."
	@./mkbase.sh

start:
	@ echo "=> Starting virtual machine..."
	@./qemu_arm.sh

stop:
	@ echo "=> Stopping virtual machine..."
	@killall qemu-system-aarch64 2>/dev/null || true

clean:
	rm -rf output/*
