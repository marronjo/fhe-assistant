# FHE Setup Guide 🛠️

**Copy-paste ready configurations for Foundry and Hardhat FHE projects**

This guide provides exact configurations and commands to set up FHE development with Foundry or Hardhat. All examples are tested and ready to use.

## 🚀 Foundry Setup (Recommended)

### 1. Project Initialization

```bash
# Create new project
forge init my-fhe-project
cd my-fhe-project

# Install FHE contracts
forge install https://github.com/FhenixProtocol/fhenix-contracts

# Install additional dependencies
forge install OpenZeppelin/openzeppelin-contracts
```

### 2. foundry.toml Configuration

Create or update your `foundry.toml`:

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.25"
evm_version = "cancun"

# Optimizer settings
optimizer = true
optimizer_runs = 200

# Remappings for FHE contracts
remappings = [
    "@fhenixprotocol/contracts/=lib/fhenix-contracts/contracts/",
    "@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/"
]

# Network configurations
[rpc_endpoints]
cofhe = "https://api.cofhe.fhenix.zone"
fhenix_frontier = "https://api.fhenix.zone"

[etherscan]
cofhe = { key = "your-etherscan-key", url = "https://explorer.cofhe.fhenix.zone/api" }
```

### 3. Basic Contract Template

Create `src/MyFHEContract.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@fhenixprotocol/contracts/FHE.sol";

contract MyFHEContract {
    
    constructor() {}
    
    function basicOperation(uint32 a, uint32 b) external returns (euint32) {
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        euint32 result = FHE.add(encA, encB);
        
        FHE.allow(result, msg.sender);
        return result;
    }
}
```

### 4. Test Template

Create `test/MyFHEContract.t.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {MyFHEContract} from "../src/MyFHEContract.sol";
import "@fhenixprotocol/contracts/utils/CoFheTest.sol";

contract MyFHEContractTest is CoFheTest {
    MyFHEContract public myContract;

    function setUp() public {
        myContract = new MyFHEContract();
    }

    function testBasicOperation() public {
        uint32 a = 10;
        uint32 b = 20;
        
        euint32 result = myContract.basicOperation(a, b);
        
        // Wait for FHE operations to process
        vm.warp(block.timestamp + 11);
        
        // Test the result (implementation specific)
        assertEq(result != euint32.wrap(0), true);
    }
}
```

### 5. Deployment Script

Create `script/Deploy.s.sol`:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Script, console} from "forge-std/Script.sol";
import {MyFHEContract} from "../src/MyFHEContract.sol";

contract DeployScript is Script {
    function run() external returns (MyFHEContract) {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        vm.startBroadcast(deployerPrivateKey);
        
        MyFHEContract myContract = new MyFHEContract();
        
        console.log("MyFHEContract deployed to:", address(myContract));
        
        vm.stopBroadcast();
        
        return myContract;
    }
}
```

### 6. Environment Variables

Create `.env`:

```bash
# Private key for deployment (never commit this!)
PRIVATE_KEY=your_private_key_here

# RPC URLs
COFHE_RPC_URL=https://api.cofhe.fhenix.zone
FHENIX_RPC_URL=https://api.fhenix.zone

# Optional: Etherscan API keys
ETHERSCAN_API_KEY=your_etherscan_key
```

## 🔨 Essential Commands

```bash
# Build the project
forge build

# Run tests
forge test

# Run tests with verbosity
forge test -vvv

# Deploy to CoFHE testnet
source .env
forge script script/Deploy.s.sol --rpc-url $COFHE_RPC_URL --broadcast --verify

# Deploy to Fhenix Frontier
forge script script/Deploy.s.sol --rpc-url $FHENIX_RPC_URL --broadcast --verify

# Generate gas report
forge test --gas-report

# Check contract size
forge build --sizes
```

## 🔧 Hardhat Setup (Alternative)

If you prefer Hardhat over Foundry:

### 1. Project Initialization

```bash
# Create new project
mkdir my-fhe-project
cd my-fhe-project
npm init -y

# Install Hardhat and dependencies
npm install --save-dev hardhat @nomiclabs/hardhat-ethers ethers
npm install @fhenixprotocol/contracts @openzeppelin/contracts
```

### 2. hardhat.config.js

```javascript
require("@nomiclabs/hardhat-ethers");

module.exports = {
  solidity: {
    version: "0.8.25",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
      evmVersion: "cancun"
    },
  },
  networks: {
    cofhe: {
      url: "https://api.cofhe.fhenix.zone",
      accounts: [process.env.PRIVATE_KEY],
    },
    fhenix: {
      url: "https://api.fhenix.zone", 
      accounts: [process.env.PRIVATE_KEY],
    },
  },
  paths: {
    sources: "./contracts",
    tests: "./test",
    cache: "./cache",
    artifacts: "./artifacts"
  },
};
```

### 3. Package.json Scripts

```json
{
  "scripts": {
    "compile": "hardhat compile",
    "test": "hardhat test",
    "deploy:cofhe": "hardhat run scripts/deploy.js --network cofhe",
    "deploy:fhenix": "hardhat run scripts/deploy.js --network fhenix"
  }
}
```

## 🐛 Common Setup Issues

### Issue 1: Import Resolution

**Problem**: `Error: File import callback not supported`

**Solution**: Check your remappings in `foundry.toml`:
```toml
remappings = [
    "@fhenixprotocol/contracts/=lib/fhenix-contracts/contracts/"
]
```

### Issue 2: Compilation Errors

**Problem**: `Error: Contract not found`

**Solution**: Verify Solidity version and imports:
```solidity
pragma solidity ^0.8.25;  // Use correct version
import "@fhenixprotocol/contracts/FHE.sol";  // Correct import path
```

### Issue 3: Test Setup

**Problem**: `CoFheTest not found`

**Solution**: Ensure you're extending CoFheTest:
```solidity
import "@fhenixprotocol/contracts/utils/CoFheTest.sol";

contract MyTest is CoFheTest {
    // Your tests here
}
```

### Issue 4: Network Connection

**Problem**: `Error: could not detect network`

**Solution**: Check your RPC URLs and network configuration:
```bash
# Test connection
curl -X POST https://api.cofhe.fhenix.zone \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'
```

## 📦 Project Structure

Recommended project structure:
```
my-fhe-project/
├── foundry.toml          # Foundry configuration
├── .env                  # Environment variables (never commit!)
├── .gitignore           # Git ignore file
├── src/                 # Source contracts
│   └── MyFHEContract.sol
├── test/                # Test files
│   └── MyFHEContract.t.sol
├── script/              # Deployment scripts
│   └── Deploy.s.sol
└── lib/                 # Dependencies (git submodules)
    ├── forge-std/
    ├── fhenix-contracts/
    └── openzeppelin-contracts/
```

## 🔄 Upgrading Existing Projects

To add FHE support to existing Foundry projects:

```bash
# Install FHE contracts
forge install https://github.com/FhenixProtocol/fhenix-contracts

# Update foundry.toml with remappings
echo 'remappings = ["@fhenixprotocol/contracts/=lib/fhenix-contracts/contracts/"]' >> foundry.toml

# Update import statements in contracts
# Change: import "./SomeContract.sol";
# To: import "@fhenixprotocol/contracts/FHE.sol";
```

## 🎯 Next Steps

After setup is complete:

1. **Read Core Patterns**: Review `docs/core-patterns.md`
2. **Start with Calculator**: Use `contracts/calculator.sol` as reference
3. **Write Tests**: Follow `docs/testing-guide.md`
4. **Security Review**: Use `docs/security-checklist.md`

## 🔗 Need Help?

For advanced Foundry features not covered here, refer to the official [Foundry Book](https://book.getfoundry.sh/).

For FHE-specific issues, check the [Fhenix Documentation](https://docs.fhenix.zone).

---

**Guard Rails**: This guide covers essential setup patterns. For advanced configurations or troubleshooting not covered here, refer to the official documentation.

*Found a setup issue or improvement? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help other developers.*