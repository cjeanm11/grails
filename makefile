# Define variables
SRC_DIR := src
BUILD_DIR := build
CLANG_FORMAT := clang-format
CLANG_FORMAT_FLAGS := -i -style=file

# Default to C executable
run: run-c
cc: zig-cc
c: build run-c
c++: build-c++ run-c
z: build-z run-z
run: run-c

zig:  
	@rm -rf $(BUILD_DIR) zig-out
	@zig build
	@./zig-out/bin/zig-build-exe
	@$<

# Run C executable
run-c:
	@echo "Running C executable..."
	@./${BUILD_DIR}/bin/a.out
	@$<

run-z:
	@echo "Running Zig executable..."
	@./zig-out/bin/zig-build-exe
	@$<

zig-cc:
	@echo "Zig compile C..."
	@mkdir -p $(BUILD_DIR)/bin
	@zig cc ${SRC_DIR}/main.c -o ${BUILD_DIR}/bin/a.out
	@$<

zig-c++:
	@echo "Zig compile C++..."
	@mkdir -p $(BUILD_DIR)/bin
	@zig c++ ${SRC_DIR}/main.cpp -o build/bin/a.out
	@$<

build: build-c

build-c: clean format zig-cc

build-c++: clean format zig-c++

build-z: clean format
	@echo "Zig compile Zig..."
	@zig build

format:
	@echo "formatting..."
	@find $(SRC_DIR) -name "*.c" -exec $(CLANG_FORMAT) $(CLANG_FORMAT_FLAGS) {} \;
	@find $(SRC_DIR) -name "*.cpp" -exec $(CLANG_FORMAT) $(CLANG_FORMAT_FLAGS) {} \;

clean:
	@echo "Cleaning..."
	@rm -rf $(BUILD_DIR) zig-out *.o a.out

.PHONY: run cc c z run run-c run-z zig-cc zig-c++ build build-c build-c++ format clean
