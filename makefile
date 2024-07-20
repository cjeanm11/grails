# Define variables
SRC_DIR := src
BUILD_DIR := build

# Default to C executable
zig: clean build run

build:
	@rm -rf $(BUILD_DIR) zig-out
	@zig build

run: 
	@./zig-out/bin/zig-build-exe
	@$<

clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR) zig-out *.o a.out

.PHONY: format clean build zig
