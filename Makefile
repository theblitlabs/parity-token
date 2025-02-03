.PHONY: all compile deploy balance transfer clean setup help

all: help

setup:
	@npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox dotenv

compile:
	@npx hardhat compile

deploy: compile
	@npx hardhat run scripts/deploy.ts --network sepolia

balance:
	@npx hardhat run scripts/balance.ts --network sepolia

transfer:
	@npx hardhat run scripts/transfer.ts --network sepolia

clean:
	@rm -rf artifacts cache typechain-types

help:
	@echo "Available commands:"
	@echo "  make setup       - Install dependencies"
	@echo "  make compile     - Compile smart contracts"
	@echo "  make deploy      - Deploy to Sepolia network"
	@echo "  make balance     - Check token balances"
	@echo "  make transfer    - Transfer tokens between accounts"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make help        - Show this help message" 