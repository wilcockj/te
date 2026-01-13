# Paths
ASSETS_DIR := assets
GENERATED_DIR := src/generated

# Compiler
CC := cc
TARGET := te
BUILD_DIR := build

# Find all .c files recursively
SRCS := $(shell find src -name '*.c')
# Object files go in build/
OBJS := $(patsubst src/%.c,$(BUILD_DIR)/%.o,$(SRCS))

# Default flags (debug)
CFLAGS := $(shell pkg-config --cflags lua raylib) -g -Wall -Wextra
LIBS := $(shell pkg-config --libs lua raylib) -lm

# Default target
all: $(BUILD_DIR)/$(TARGET)

# Release build
build: CFLAGS += -O2
build: $(BUILD_DIR)/$(TARGET)

# Link step
$(BUILD_DIR)/$(TARGET): $(OBJS)
	@mkdir -p $(BUILD_DIR)
	$(CC) -o $@ $^ $(LIBS)

# Compile each .c into .o in build/
$(BUILD_DIR)/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) -c $< -o $@ $(CFLAGS)

# Generate headers from assets
GENERATED_HEADERS := $(patsubst $(ASSETS_DIR)/%,$(GENERATED_DIR)/%.h,$(shell find $(ASSETS_DIR) -type f))

$(GENERATED_DIR)/%.h: $(ASSETS_DIR)/%
	@mkdir -p $(dir $@)
	@xxd -i $< >> $@

# Ensure generated headers exist before compiling
$(OBJS): $(GENERATED_HEADERS)

$(TARGET): $(SRCS)
	$(CC) -o $(TARGET) $(SRCS) $(CFLAGS) $(LIBS)

clean:
	rm -rf $(BUILD_DIR) $(GENERATED_DIR)

