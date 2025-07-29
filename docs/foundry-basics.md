# Foundry Basics 🔨

**Essential Foundry commands for FHE development**

This document covers the most commonly used Foundry commands for FHE smart contract development. For advanced Foundry features, refer to the [official Foundry documentation](https://book.getfoundry.sh/).

## 🚀 Quick Start Commands

### Project Setup
```bash
# Create new project
forge init my-fhe-project
cd my-fhe-project

# Install FHE contracts
forge install https://github.com/FhenixProtocol/fhenix-contracts

# Install OpenZeppelin (commonly needed)
forge install OpenZeppelin/openzeppelin-contracts

# Update dependencies
forge update
```

### Building & Testing
```bash
# Compile contracts
forge build

# Run all tests
forge test

# Run tests with verbosity (shows console.log output)
forge test -vv
forge test -vvv  # Even more verbose
forge test -vvvv # Maximum verbosity

# Run specific test file
forge test --match-path test/MyContract.t.sol

# Run specific test function
forge test --match-test testSpecificFunction
```

## 🔧 Development Commands

### Code Quality
```bash
# Format code
forge fmt

# Check formatting (CI-friendly)
forge fmt --check

# Generate gas report
forge test --gas-report

# Check contract sizes
forge build --sizes

# Static analysis (if available)
forge inspect MyContract bytecode
forge inspect MyContract abi
```

### Dependency Management
```bash
# List installed dependencies
forge list

# Remove dependency
forge remove dependency-name

# Check for outdated dependencies
forge update --dry-run
```

## 🌐 Network Commands

### CoFHE (Testnet) Deployment
```bash
# Deploy to CoFHE
forge script script/Deploy.s.sol \
  --rpc-url https://api.cofhe.fhenix.zone \
  --broadcast \
  --verify

# Deploy with specific private key
forge script script/Deploy.s.sol \
  --rpc-url https://api.cofhe.fhenix.zone \
  --private-key $PRIVATE_KEY \
  --broadcast
```

### Fhenix Frontier (Mainnet) Deployment
```bash
# Deploy to Fhenix Frontier
forge script script/Deploy.s.sol \
  --rpc-url https://api.fhenix.zone \
  --broadcast \
  --verify \
  --slow  # Use --slow for mainnet
```

### Contract Interaction
```bash
# Call view function
forge call \
  0x... \
  "balanceOf(address)(uint256)" \
  0x1234567890123456789012345678901234567890 \
  --rpc-url https://api.cofhe.fhenix.zone

# Send transaction
forge send \
  0x... \
  "transfer(address,uint256)" \
  0x1234567890123456789012345678901234567890 \
  1000000000000000000 \
  --rpc-url https://api.cofhe.fhenix.zone \
  --private-key $PRIVATE_KEY
```

## 🧪 Testing Commands

### Test Filtering
```bash
# Run tests matching pattern
forge test --match-test "test.*Add.*"

# Run tests NOT matching pattern  
forge test --no-match-test "testFail.*"

# Run tests in specific contract
forge test --match-contract CalculatorTest

# Run tests with specific gas limit
forge test --gas-limit 10000000
```

### Test Output Control
```bash
# Show test results in JSON
forge test --json

# Run tests and show traces for failing tests
forge test --show-traces

# Run single test with maximum verbosity
forge test --match-test testSpecificFunction -vvvv
```

## 📊 Analysis Commands

### Debugging & Investigation
```bash
# Simulate transaction locally
forge run \
  --rpc-url https://api.cofhe.fhenix.zone \
  0x1234567890123456789012345678901234567890

# Get transaction trace
forge debug \
  --rpc-url https://api.cofhe.fhenix.zone \
  0x1234567890123456789012345678901234567890

# Verify contract on explorer
forge verify-contract \
  0x... \
  src/MyContract.sol:MyContract \
  --chain cofhe \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

### Contract Information
```bash
# Get contract ABI
forge inspect MyContract abi

# Get contract bytecode
forge inspect MyContract bytecode

# Get contract storage layout
forge inspect MyContract storage-layout

# Get method identifiers
forge inspect MyContract methods
```

## 🔐 FHE-Specific Patterns

### Testing FHE Contracts
```bash
# Run FHE tests with proper timing
forge test --match-path test/FHE*.t.sol -vvv

# Test specific FHE function
forge test --match-test testEncryptedAdd -vvvv
```

### FHE Contract Deployment
```bash
# Deploy FHE contract with verification
forge script script/DeployFHE.s.sol \
  --rpc-url https://api.cofhe.fhenix.zone \
  --broadcast \
  --verify \
  --legacy  # Sometimes needed for FHE contracts
```

## 🛠️ Configuration Commands

### Environment Setup
```bash
# Initialize .env file
echo "PRIVATE_KEY=your_private_key_here" > .env
echo "COFHE_RPC_URL=https://api.cofhe.fhenix.zone" >> .env

# Source environment variables
source .env

# Check configuration
forge config
```

### Remapping Management
```bash
# Show current remappings
forge remappings

# Generate remappings file
forge remappings > remappings.txt
```

## 📋 Common Workflows

### Development Workflow
```bash
# 1. Write contract
# 2. Write test
forge test --match-test testNewFeature -vvv

# 3. Check formatting
forge fmt --check

# 4. Build and check size
forge build --sizes

# 5. Run full test suite
forge test

# 6. Generate gas report
forge test --gas-report
```

### Deployment Workflow
```bash
# 1. Test locally
forge test

# 2. Deploy to testnet
forge script script/Deploy.s.sol \
  --rpc-url https://api.cofhe.fhenix.zone \
  --broadcast

# 3. Verify contract
forge verify-contract \
  [CONTRACT_ADDRESS] \
  src/MyContract.sol:MyContract \
  --chain cofhe

# 4. Test deployed contract
forge call [CONTRACT_ADDRESS] "someFunction()(uint256)" \
  --rpc-url https://api.cofhe.fhenix.zone
```

## 🚨 Troubleshooting Commands

### Common Issues
```bash
# Clear cache (fixes many issues)
forge clean

# Rebuild from scratch
forge clean && forge build

# Check for version conflicts
forge --version
forge list

# Update to latest
foundryup

# Debug failing test
forge test --match-test testFailingFunction -vvvv --show-traces
```

### Network Issues
```bash
# Test network connectivity
curl -X POST https://api.cofhe.fhenix.zone \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Check gas price
forge estimate --rpc-url https://api.cofhe.fhenix.zone

# Get latest block
forge block latest --rpc-url https://api.cofhe.fhenix.zone
```

## ⚡ Performance Tips

### Faster Testing
```bash
# Run tests in parallel (experimental)
forge test --threads 4

# Skip slow tests during development
forge test --no-match-test "testSlow.*"

# Use faster compilation
export FOUNDRY_OPTIMIZER=false  # For development only
```

### Faster Building
```bash
# Cache builds
export FOUNDRY_CACHE=true

# Use faster EVM version for development
export FOUNDRY_EVM_VERSION=london  # Instead of cancun
```

## 📚 Help & Documentation

### Getting Help
```bash
# General help
forge --help

# Command-specific help
forge test --help
forge script --help
forge build --help

# Version information
forge --version
```

### Configuration Help
```bash
# Show current config
forge config

# Show config for specific profile
forge config --profile production
```

## 🔗 External Resources

For topics not covered in this basic guide:
- **Advanced Foundry Features**: [Foundry Book](https://book.getfoundry.sh/)
- **Scripting**: [Foundry Scripts Documentation](https://book.getfoundry.sh/tutorials/solidity-scripting)
- **Testing**: [Foundry Testing Guide](https://book.getfoundry.sh/forge/tests)
- **Configuration**: [Foundry Configuration](https://book.getfoundry.sh/reference/config/)

---

**Guard Rails**: This document covers essential Foundry commands for FHE development. For advanced Foundry features, deployment strategies, and complex configurations, refer to the official Foundry documentation.

*Missing a commonly used command? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help improve this reference.*