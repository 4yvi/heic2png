.PHONY: build test app run install clean
build:
	swift build -c release
test:
	swift test
app:
	Scripts/make-app.sh
run: app
	open build/HEIC2PNG.app
install: build
	mkdir -p ~/.local/bin && cp .build/release/heic2png ~/.local/bin/
clean:
	rm -rf .build build
