.PHONY: all install build test clean deploy-local deploy-sepolia anvil transfer

all: install build test

# Install dependencies
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
deploy-local:
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url http://localhost:8545 \
		--broadcast \
		--ffi

# Deploy to Sepolia
deploy-sepolia:
	forge script script/Deploy.s.sol:DeployScript \
		--rpc-url ${SEPOLIA_RPC_URL} \
		--private-key ${PRIVATE_KEY} \
		--broadcast \
		--verify

# Transfer tokens (Usage: make transfer RECIPIENT=0x... AMOUNT=1000)
transfer:
	forge script script/Transfer.s.sol:TransferScript \
		--rpc-url http://localhost:8545 \
		--broadcast

# Format code
format:
	forge fmt

# Update dependencies
update:
	forge update 