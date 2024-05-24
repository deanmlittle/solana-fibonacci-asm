# Solana SDK and toolchain paths
SOLANA_SDK?=$(HOME)/.cache/solana/v1.41
LLVM_DIR?=$(SOLANA_SDK)/platform-tools/llvm
CLANG:=$(LLVM_DIR)/bin/clang
LD:=$(LLVM_DIR)/bin/ld.lld

# Set src/out directory and compiler flags
SRC:=src/fib
OUT:=build
DEPLOY:=deploy
ARCH:=-target sbf -march=bpfel+solana
LDFLAGS:=-shared -z notext --image-base 0x100000000

# Define the target
TARGET:=$(DEPLOY)/fib.so

# Default target
all: $(TARGET)

# Build shared object
$(TARGET): $(OUT)/fib.o ${SRC}/fib.ld
	$(LD) $(LDFLAGS) -T ${SRC}/fib.ld -o $@ $<

# Compile assembly
$(OUT)/fib.o: ${SRC}/fib.s
	mkdir -pv $(OUT)
	$(CLANG) -Os $(ARCH) -c -o $@ $<

# Prepare for deploy
deploy:
	@if [ ! -f $(DEPLOY)/fib_keypair.json ]; then \
		echo "fib_keypair.json does not exist. Creating..."; \
		solana-keygen new --no-bip39-passphrase --outfile $(DEPLOY)/fib_keypair.json; \
	fi

# Cleanup
.PHONY: clean
clean:
	rm -rv $(OUT)

# Deploy rule can be run separately
.PHONY: deploy
