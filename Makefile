#!/usr/bin/sh

.PHONY: clean get-deps srcmap build

get-deps:
	@wally install

build:
	@mkdir build
	@rojo build --output build/tinynet.rbxmx

srcmap:
	@rojo sourcemap > sourcemap.json

clean:
	@rm -rf DevPackages
	@rm -rf sourcemap.json
