# Parity Token

This repository contains an ERC‑20 token implementation along with deployment and management scripts. The project is built with [Hardhat](https://hardhat.org/) and leverages [OpenZeppelin](https://openzeppelin.com/) contracts for secure and standardized token development.

## Features

- **ERC‑20 Standard Token**: Secure implementation using OpenZeppelin's audited contracts.
- **Deployment Scripts**: Ready-to-use scripts for both local development and testnet (e.g., Sepolia) deployments.
- **Etherscan Verification**: Automatic integration for contract source verification.
- **Utility Scripts**: Built-in scripts for transferring tokens and checking balances.
- **Environment Management**: Uses environment variables for secure handling of sensitive configurations.

## Prerequisites

- **Node.js** v18 or above
- **Yarn** package manager
- An Ethereum wallet with testnet ETH (for deploying to networks like Sepolia)

## Setup & Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/parity-token/parity-token.git
   cd parity-token
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Configure Environment Variables:**
   - Copy the environment template:
     ```bash
     cp .env.example .env
     ```
   - Update `.env` with your credentials:
     ```
     PRIVATE_KEY="your wallet private key"
     RPC_URL="your RPC URL"
     ```

## Deployment

### Local Development Network

Deploy your token contract to a local Hardhat network:

```bash
npx hardhat node
npx hardhat run scripts/deploy.ts --network localhost
```

Alternatively, use the Makefile target:

```bash
make deploy-local
```

### Sepolia Testnet

Deploy your token to the Sepolia testnet:

```bash
npx hardhat run scripts/deploy.ts --network sepolia
```

Or via the Makefile:

```bash
make deploy-sepolia
```

> **Note:** The contract will be automatically verified on Etherscan during a Sepolia deployment if your `ETHERSCAN_API_KEY` is set.

## Usage

### Transferring Tokens

Transfer tokens to a given address:

```bash
npx hardhat run scripts/transfer.ts --network <network> --address 0xYourAddress --amount 100
```

Or using the Makefile:

```bash
make transfer ADDRESS=0xYourAddress AMOUNT=100
```

### Checking Token Balance

Check the balance of a specific address:

```bash
npx hardhat run scripts/balance.ts --network <network> --address 0xYourAddress
```

Or using the Makefile:

```bash
make balance ADDRESS=0xYourAddress
```

## Testing

Make sure all tests pass before deploying:

```bash
npx hardhat test
```

## Best Practices & Security

- **Secure Credentials:** Never commit your `.env` file or sensitive information like mnemonics.
- **Audited Contracts:** This token utilizes OpenZeppelin contracts, ensuring adherence to common security best practices.
- **Automated Verification:** Etherscan verification offers transparency and trust in the deployed smart contract.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have any enhancements or bug fixes.

## License

This project is licensed under the MIT License.
