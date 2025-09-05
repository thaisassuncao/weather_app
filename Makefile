IMAGE ?= weather_app
PORT  ?= 3000
CONTAINER_NAME ?= weather_app
SECRET_KEY_BASE ?= $(shell ruby -e 'require "securerandom"; print SecureRandom.hex(64)')

.PHONY: build run up stop

build:
	docker build -t $(IMAGE) .

run:
	docker run --rm --name $(CONTAINER_NAME) -p $(PORT):3000 -e SECRET_KEY_BASE=$(SECRET_KEY_BASE) $(IMAGE)

up: build run

stop: 
	docker rm -f $(CONTAINER_NAME)
