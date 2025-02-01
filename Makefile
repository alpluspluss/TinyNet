#!/usr/bin/sh

.PHONY: clean get-deps srcmap build

get-deps:
	@wally install

build:
	@rojo build --output tinynet.rbxmx

srcmap:
	@rojo sourcemap > sourcemap.json

clean:
	@rm -rf DevPackages
	@rm -rf sourcemap.json
