.PHONY: all install build test clean deploy-local deploy-sepolia anvil transfer install-hooks format

# Load environment variables from .env
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

all: install build test

# Install and update dependencies
install:
	forge install

# Build the project
build:
	forge build

# Run tests
test:
	forge test -vv

# Run tests with gas report
test-gas:
	forge test -vv --gas-report

# Clean build artifacts
clean:
	forge clean

# Start local node
anvil:
	anvil

# Deploy to local network
deploy-local: build
	forge script script/Deploy.s.sol:DeployScript \
		--fork-url http://localhost:8545 \
		--broadcast \
		--ffi

# Deploy to Sepolia
deploy-sepolia: build
	@if [ -z "$$SEPOLIA_RPC_URL" ]; then \
		echo "Error: SEPOLIA_RPC_URL is not set. Please check your .env file"; \
		exit 1; \
	fi
	@if [ -z "$$PRIVATE_KEY" ]; then \
		echo "Error: PRIVATE_KEY is not set. Please check your .env file"; \
		exit 1; \
	fi
	forge script script/Deploy.s.sol:DeployScript \
		--fork-url "$$SEPOLIA_RPC_URL" \
		--private-key "$$PRIVATE_KEY" \
		--broadcast \
		--verify \
		--ffi

# Transfer tokens (Usage: make transfer ADDRESS=0x... AMOUNT=1000)
transfer-local: build
	@if [ -z "$(ADDRESS)" ]; then \
		echo "Error: ADDRESS is required. Usage: make transfer-local ADDRESS=0x... AMOUNT=1000"; \
		exit 1; \
	fi
	@if [ -z "$(AMOUNT)" ]; then \
		echo "Error: AMOUNT is required. Usage: make transfer-local ADDRESS=0x... AMOUNT=1000"; \
		exit 1; \
	fi
	forge script script/Transfer.s.sol:TransferScript \
		--fork-url http://localhost:8545 \
		--broadcast \
		--ffi

# Transfer tokens on Sepolia (Usage: make transfer-sepolia ADDRESS=0x... AMOUNT=1000)
transfer-sepolia: build
	@if [ -z "$$SEPOLIA_RPC_URL" ]; then \
		echo "Error: SEPOLIA_RPC_URL is not set. Please check your .env file"; \
		exit 1; \
	fi
	@if [ -z "$$PRIVATE_KEY" ]; then \
		echo "Error: PRIVATE_KEY is not set. Please check your .env file"; \
		exit 1; \
	fi
	@if [ -z "$(ADDRESS)" ]; then \
		echo "Error: ADDRESS is required. Usage: make transfer-sepolia ADDRESS=0x... AMOUNT=1000"; \
		exit 1; \
	fi
	@if [ -z "$(AMOUNT)" ]; then \
		echo "Error: AMOUNT is required. Usage: make transfer-sepolia ADDRESS=0x... AMOUNT=1000"; \
		exit 1; \
	fi
	forge script script/Transfer.s.sol:TransferScript \
		--fork-url "$$SEPOLIA_RPC_URL" \
		--private-key "$$PRIVATE_KEY" \
		--broadcast \
		--verify \
		--ffi

# Format code
format:
	forge fmt

# Update dependencies to their latest versions
update:
	git submodule update --remote --merge

# Install git hooks
install-hooks:
	@echo "Installing git hooks..."
	@chmod +x .githooks/*
	@git config core.hooksPath .githooks
	@echo "Git hooks installed successfully"
