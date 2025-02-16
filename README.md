# Parity Token

This repository contains an ERC‑20 token implementation along with deployment and management scripts. The project is built with [Foundry](https://book.getfoundry.sh/) and leverages [OpenZeppelin](https://openzeppelin.com/) contracts for secure and standardized token development.

## Features

- **ERC‑20 Standard Token**: Secure implementation using OpenZeppelin's audited contracts.
- **Deployment Scripts**: Ready-to-use scripts for both local development and testnet (e.g., Sepolia) deployments.
- **Etherscan Verification**: Automatic integration for contract source verification.
- **Environment Management**: Uses environment variables for secure handling of sensitive configurations.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation.html) installed
- An Ethereum wallet with testnet ETH (for deploying to networks like Sepolia)

## Setup & Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/parity-token/parity-token.git
   cd parity-token
   ```

2. **Install dependencies:**

   ```bash
   forge install
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

## Documentation

For detailed Foundry usage, visit: https://book.getfoundry.sh/

## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Local Development Network

```shell
$ anvil
```

### Deploy

To deploy to a network:

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

For Sepolia deployment:

```shell
$ forge script script/Deploy.s.sol:DeployScript --rpc-url $SEPOLIA_RPC_URL --private-key $PRIVATE_KEY --broadcast --verify
```

## Best Practices & Security

- **Secure Credentials:** Never commit your `.env` file or sensitive information like private keys.
- **Audited Contracts:** This token utilizes OpenZeppelin contracts, ensuring adherence to common security best practices.
- **Automated Verification:** Etherscan verification is integrated into the deployment process.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have any enhancements or bug fixes.

## License

This project is licensed under the MIT License.
