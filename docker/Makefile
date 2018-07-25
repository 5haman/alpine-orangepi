arch = amd64
repo = homemate
tag  = latest
ver  = 3.6

default: all

all: base ansible

base:
	curl -sSL -o alpine-s6/s6.tgz "https://github.com/just-containers/s6-overlay/releases/download/v1.21.4.0/s6-overlay-${arch}.tar.gz"
	docker build --force-rm --pull \
		--build-arg ver=$(ver) \
		-f alpine-s6/Dockerfile \
		-t $(repo)/alpine-s6:$(ver)-$(arch) \
		alpine-s6
	rm s6.tgz

ansible:
	docker build --force-rm \
		--build-arg build=$(arch) \
		--build-arg ver=$(ver) \
		-f ansible/Dockerfile \
		-t $(repo)/ansible:$(tag)-$(arch) \
		ansible


.PHONY: ansible
