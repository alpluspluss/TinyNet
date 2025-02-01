.PHONY: clean get-deps build

get-deps:
	wally install

build:
	rojo build --output tinynet.rbxmx

src-map:
	rojo sourcemap > sourcemap.json

clean:
	rm -rf DevPackages \
	rm -rf sourcemap.json