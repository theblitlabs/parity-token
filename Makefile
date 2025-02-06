.PHONY: all compile deploy balance transfer clean setup help

all: help

setup:
	@npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox @nomicfoundation/hardhat-verify @typechain/ethers-v6 @typechain/hardhat @types/chai @types/mocha @types/node chai mocha ts-node typescript

compile:
	@npx hardhat compile

deploy: compile
	@npx hardhat run scripts/deploy.ts --network sepolia

balance:
	@npx hardhat run scripts/balance.ts --network sepolia --address $(ADDRESS)

transfer:
	@npx hardhat run scripts/transfer.ts --network sepolia --address $(ADDRESS) --amount $(AMOUNT)

clean:
	@rm -rf artifacts cache typechain-types

help:
	@echo "Available commands:"
	@echo "  make setup       - Install dependencies"
	@echo "  make compile     - Compile smart contracts"
	@echo "  make deploy      - Deploy to Sepolia network"
	@echo "  make balance ADDRESS=0x... - Check token balance"
	@echo "  make transfer ADDRESS=0x... AMOUNT=100 - Transfer tokens"
	@echo "  make clean       - Clean build artifacts"
	@echo "  make help        - Show this help message" 