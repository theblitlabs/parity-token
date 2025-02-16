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

1. **Clone the repository with submodules:**

   ```bash
   git clone --recursive https://github.com/parity-token/parity-token.git
   cd parity-token
   ```

   If you've already cloned the repository without `--recursive`, run:
   ```bash
   make install
   ```
   This will initialize and update all required submodules.

2. **Dependencies:**
   The project uses git submodules for dependency management:
   - `forge-std`: Foundry's standard library for testing and scripting
   - `openzeppelin-contracts`: OpenZeppelin's secure contract library

   Dependencies are pinned to specific commits for reproducible builds.

3. **Updating Dependencies:**
   To update all dependencies to their latest versions:
   ```bash
   make update
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

The project includes a Makefile for common operations. Here are the main commands:

### Development

```shell
# Build the project
$ make build

# Run tests
$ make test

# Run tests with gas reporting
$ make test-gas

# Format code
$ make format

# Clean build artifacts
$ make clean
```

### Deployment

```shell
# Start local node
$ make anvil

# Deploy to local network
$ make deploy-local

# Deploy to Sepolia testnet
$ make deploy-sepolia

# Transfer tokens
$ make transfer RECIPIENT=0x... AMOUNT=1000
```

Note: For testnet deployments, ensure your `.env` file is properly configured with `SEPOLIA_RPC_URL` and `PRIVATE_KEY`.

## Development

This project uses [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) for dependency management, ensuring reproducible builds and consistent development environments.

### Dependency Management

1. **After Pulling Changes:**
   Always run after pulling changes that modify submodules:
   ```bash
   make install
   ```

2. **Working with Dependencies:**
   - Update all: `make update`
   - View status: `git submodule status`

3. **Committing Changes:**
   - Submodule changes need to be committed separately
   - Always test after updating dependencies
   - Verify builds are reproducible

### Development Workflow

1. **Local Development:**
   ```bash
   # Start local node
   make anvil
   
   # Deploy locally
   make deploy-local
   ```

2. **Testing:**
   ```bash
   # Run all tests
   make test
   
   # Run with gas reporting
   make test-gas
   ```

3. **Code Quality:**
   ```bash
   # Format code
   make format
   
   # Build and check sizes
   make build
   ```

## Best Practices & Security

### Security Considerations
- **Secure Credentials:** Never commit your `.env` file or expose private keys
- **Audited Dependencies:** Using OpenZeppelin's audited contracts
- **Automated Verification:** Etherscan verification in deployment process
- **Reproducible Builds:** Dependencies pinned via git submodules

### Development Guidelines
- **Testing:** Write comprehensive tests for all new features
- **Gas Optimization:** Monitor gas usage with `make test-gas`
- **Code Style:** Use `make format` before committing
- **Dependencies:** Document any new dependencies added

### CI/CD Pipeline
- Automated testing on pull requests
- Security analysis with Slither
- Gas usage monitoring
- Testnet deployment verification

## Contributing

Contributions are welcome! Please open an issue or submit a pull request if you have any enhancements or bug fixes.

## License

This project is licensed under the MIT License.
