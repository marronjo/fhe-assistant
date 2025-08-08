# Foundry Basics 🔨

**Essential Foundry commands for AI-assisted FHE development**

This document covers the most commonly used Foundry commands for FHE smart contract development, optimized for AI CLI tools like Claude, Gemini, and OpenAI Codex. For advanced Foundry features, refer to the [official Foundry documentation](https://book.getfoundry.sh/).

## 🤖 AI-Powered Foundry Commands

**Quick AI assistance for Foundry issues:**

```bash
# AI-assisted debugging
claude --file docs/foundry-basics.md "My forge build is failing with this error: [paste error]"

# AI-assisted testing
claude --file docs/testing-guide.md "My FHE tests are failing. Help debug: [paste test output]"

# AI-assisted deployment
claude --file docs/setup-guide.md "Help me deploy this FHE contract to CoFHE: [paste contract]"
```

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

## 🚨 AI-Assisted Troubleshooting

### 🤖 Common AI + Foundry Issues

**When AI-generated code has Foundry issues:**

```bash
# AI-generated contract won't compile
claude --file docs/core-patterns.md \
      "Fix this FHE contract compilation error: [paste error]"

# AI-generated tests are failing
claude --file docs/testing-guide.md \
      "Debug these failing FHE tests: [paste test output]"

# AI-suggested commands not working
claude --file docs/foundry-basics.md \
      "This foundry command isn't working: [paste command and error]"
```

### 🔨 Standard Troubleshooting Commands

### AI-Specific Common Issues

```bash
# AI generated invalid import paths
# Fix: Check remappings and update imports
forge remappings
# Then ask AI: "Fix import paths in this contract using these remappings"

# AI forgot vm.warp() in tests
# Fix: Add timing to AI-generated tests
claude --file docs/testing-guide.md \
      "Add proper vm.warp() timing to these FHE tests: [paste tests]"

# AI used wrong FHE patterns
# Fix: Reference core patterns
claude --file docs/core-patterns.md \
      "Fix FHE pattern violations in this contract: [paste contract]"

# Standard troubleshooting
forge clean && forge build  # Clear cache and rebuild
forge --version             # Check version
foundryup                   # Update Foundry

# Debug with maximum verbosity
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

## ⚡ AI + Performance Tips

### 🤖 Optimizing AI-Generated Code

```bash
# Ask AI to optimize gas usage
claude --file docs/core-patterns.md \
      "Optimize this FHE contract for gas efficiency: [paste contract]"

# AI-assisted performance analysis
claude --file src/YourContract.sol \
      "Analyze gas usage and suggest FHE optimizations"

# Generate gas-optimized tests
claude --file docs/testing-guide.md \
      "Create gas optimization tests for this FHE contract: [paste contract]"
```

### 🔨 Standard Performance Tips

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

## 📚 AI-Enhanced Help & Documentation

### 🤖 AI-First Support Strategy

**Try AI assistance before consulting docs:**

```bash
# General Foundry + FHE help
claude --file docs/foundry-basics.md \
      --file docs/core-patterns.md \
      "I'm having trouble with [specific issue]. Help me debug."

# Command-specific help with AI context
claude "Explain this Foundry command for FHE development: forge [command]"

# Error-specific help
claude --file docs/foundry-basics.md \
      "Decode this Foundry error in FHE context: [paste error]"
```

### 📁 Traditional Help Resources

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

## 🚀 AI-Powered Development Workflow

### 🤖 Complete AI + Foundry FHE Workflow

```bash
# 1. AI-assisted project setup
claude --file docs/setup-guide.md "Set up new FHE project with Foundry"

# 2. AI-generated contract development
claude --file docs/core-patterns.md \
      --file contracts/calculator.sol \
      "Build encrypted [your_feature] contract"

# 3. AI-generated comprehensive tests
claude --file docs/testing-guide.md \
      --file src/YourContract.sol \
      "Generate complete test suite"

# 4. Standard Foundry build and test
forge build
forge test -vvv

# 5. AI security review
claude --file docs/security-checklist.md \
      --file src/YourContract.sol \
      "Security review against FHE checklist"

# 6. AI-assisted deployment
claude --file docs/setup-guide.md \
      "Help deploy to CoFHE with verification"

# 7. AI-powered maintenance
claude --file docs/ --file src/ "Review and suggest improvements"
```

### 🎯 AI Troubleshooting Decision Tree

```
Issue occurs → Try AI assistance first → 
  │
  ├─ If resolved → Continue development
  │
  └─ If not resolved → Consult official docs →
      │
      ├─ If resolved → Update AI with solution
      │
      └─ If not resolved → Ask community + share AI analysis
```

**Community Support Template:**
```
💬 "Foundry + FHE Issue - AI analysis included

Issue: [describe problem]
AI Analysis: [paste AI response]
Foundry Version: [forge --version]
Error Output: [paste relevant errors]
Code: [link or paste relevant code]

Looking for: [specific help needed]"
```

---

**🤖 Guard Rails**: This document covers essential Foundry commands for AI-assisted FHE development. For advanced Foundry features, combine AI assistance with the [official Foundry documentation](https://book.getfoundry.sh/).

**🎯 AI + Foundry Formula**: Core Patterns + Working Examples + AI Assistance + Foundry Tools = Efficient FHE Development

*Missing a commonly used command? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help improve this reference.*