.PHONY: all install build test clean deploy-upgradeable-local deploy-upgradeable-sepolia upgrade-local upgrade-sepolia anvil transfer install-hooks format

# Load environment variables from .env
ifneq (,$(wildcard .env))
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

# Deploy upgradeable contract to local network
deploy-upgradeable-local: build
	@echo "Deploying to local network..."
	forge script script/DeployUpgradeable.s.sol:DeployUpgradeable \
		--rpc-url http://localhost:8545 \
		--broadcast \
		--ffi

# Deploy upgradeable contract to Sepolia
deploy-upgradeable-sepolia: clean build
	@if [ -z "$(SEPOLIA_RPC_URL)" ]; then \
		echo "Error: SEPOLIA_RPC_URL is not set in .env file"; \
		exit 1; \
	fi
	@if [ -z "$(PRIVATE_KEY)" ]; then \
		echo "Error: PRIVATE_KEY is not set in .env file"; \
		exit 1; \
	fi
	@echo "Deploying to Sepolia..."
	@echo "Using RPC URL: $(SEPOLIA_RPC_URL)"
	@echo "Using script: script/DeployUpgradeable.s.sol"
	forge script script/DeployUpgradeable.s.sol:DeployUpgradeable \
		--rpc-url "$(SEPOLIA_RPC_URL)" \
		--private-key "$(PRIVATE_KEY)" \
		--broadcast \
		--chain-id 11155111 \
		$(if $(ETHERSCAN_API_KEY),--verify --etherscan-api-key "$(ETHERSCAN_API_KEY)",) \
		--legacy \
		--ffi \
		-vvvv

# Upgrade contract on local network
upgrade-local: build
	@if [ -z "$(PROXY_ADDRESS)" ]; then \
		echo "Error: PROXY_ADDRESS is not set. Please deploy the contract first"; \
		exit 1; \
	fi
	@if [ -z "$(IMPLEMENTATION_ADDRESS)" ]; then \
		echo "Error: IMPLEMENTATION_ADDRESS is not set. Please deploy the new implementation first"; \
		exit 1; \
	fi
	forge script script/UpgradeToken.s.sol:UpgradeToken \
		--rpc-url http://localhost:8545 \
		--broadcast \
		--ffi

# Upgrade contract on Sepolia
upgrade-sepolia: build
	@if [ -z "$(SEPOLIA_RPC_URL)" ]; then \
		echo "Error: SEPOLIA_RPC_URL is not set in .env file"; \
		exit 1; \
	fi
	@if [ -z "$(PRIVATE_KEY)" ]; then \
		echo "Error: PRIVATE_KEY is not set in .env file"; \
		exit 1; \
	fi
	@if [ -z "$(PROXY_ADDRESS)" ]; then \
		echo "Error: PROXY_ADDRESS is not set. Please deploy the contract first"; \
		exit 1; \
	fi
	@if [ -z "$(IMPLEMENTATION_ADDRESS)" ]; then \
		echo "Error: IMPLEMENTATION_ADDRESS is not set. Please deploy the new implementation first"; \
		exit 1; \
	fi
	forge script script/UpgradeToken.s.sol:UpgradeToken \
		--rpc-url "$(SEPOLIA_RPC_URL)" \
		--private-key "$(PRIVATE_KEY)" \
		--broadcast \
		--chain-id 11155111 \
		$(if $(ETHERSCAN_API_KEY),--verify --etherscan-api-key "$(ETHERSCAN_API_KEY)",) \
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
		--rpc-url http://localhost:8545 \
		--broadcast \
		--ffi

# Transfer tokens on Sepolia (Usage: make transfer-sepolia ADDRESS=0x... AMOUNT=1000)
transfer-sepolia: build
	@if [ -z "$(SEPOLIA_RPC_URL)" ]; then \
		echo "Error: SEPOLIA_RPC_URL is not set in .env file"; \
		exit 1; \
	fi
	@if [ -z "$(PRIVATE_KEY)" ]; then \
		echo "Error: PRIVATE_KEY is not set in .env file"; \
		exit 1; \
	fi
	@if [ -z "$(TOKEN_ADDRESS)" ]; then \
		echo "Error: TOKEN_ADDRESS is not set in .env file"; \
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
	@echo "Transferring $(AMOUNT) tokens to $(ADDRESS)..."
	@echo "Using RPC URL: $(SEPOLIA_RPC_URL)"
	forge script script/Transfer.s.sol:TransferScript \
		--rpc-url "$(SEPOLIA_RPC_URL)" \
		--private-key "$(PRIVATE_KEY)" \
		--broadcast \
		--chain-id 11155111 \
		$(if $(ETHERSCAN_API_KEY),--verify --etherscan-api-key "$(ETHERSCAN_API_KEY)",) \
		--legacy \
		--ffi \
		-vvvv

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
