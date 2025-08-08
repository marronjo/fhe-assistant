# FHE Setup Guide 🛠️

**Copy-paste ready configurations for AI-assisted FHE development with Foundry and Hardhat**

This guide provides exact configurations and commands to set up FHE development with Foundry or Hardhat, optimized for AI CLI tools like Claude, Gemini, and OpenAI Codex. All examples are tested and ready to use.

## 🤖 AI-Powered Development Setup

**Quick AI Setup Commands:**

```bash
# 1. Clone FHE assistant for AI context
git clone https://github.com/fhenixprotocol/fhe-assistant.git

# 2. Set up your FHE project with AI guidance
claude --file fhe-assistant/docs/setup-guide.md "Help me set up a new FHE project with Foundry"

# 3. AI-assisted contract generation
claude --file fhe-assistant/docs/core-patterns.md \
      --file fhe-assistant/contracts/calculator.sol \
      "Create a new FHE contract that does [your functionality]"
```

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

# 🤖 Set up AI workspace
mkdir ai-context
cd ai-context
git clone https://github.com/fhenixprotocol/fhe-assistant.git
cd ..

# Create AI development script
cat > ai-dev.sh << 'EOF'
#!/bin/bash
# AI-Assisted FHE Development Helper
echo "Starting AI-assisted FHE development..."
claude --file ai-context/fhe-assistant/docs/core-patterns.md \
      --file ai-context/fhe-assistant/docs/security-checklist.md \
      "$@"
EOF
chmod +x ai-dev.sh
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

### 3. AI-Optimized Contract Template

Create `src/MyFHEContract.sol` (designed for AI learning):

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@fhenixprotocol/contracts/FHE.sol";

/**
 * @title MyFHEContract - AI Template
 * @notice Template contract demonstrating FHE patterns for AI learning
 * @dev This contract serves as a reference for AI code generation
 * 
 * Key FHE Patterns Demonstrated:
 * 1. Proper imports and pragma
 * 2. FHE.allow() for return values  
 * 3. FHE.allowThis() for storage
 * 4. FHE.select() for conditionals
 * 5. Event emission for transparency
 */
contract MyFHEContract {
    // State storage example
    mapping(address => euint32) private userValues;
    mapping(address => bool) public hasValue;
    
    // Events for AI to learn proper logging
    event OperationCompleted(address indexed user, string operation);
    event ValueStored(address indexed user);
    
    constructor() {
        // Constructor can be empty for basic contracts
    }
    
    /**
     * @notice Basic FHE operation - AI learning template
     * @param a First operand (plaintext, will be encrypted)
     * @param b Second operand (plaintext, will be encrypted)
     * @return result Encrypted sum accessible to caller
     * 
     * @dev AI Pattern: Always FHE.allow() before returning encrypted values
     */
    function basicOperation(uint32 a, uint32 b) external returns (euint32) {
        // Convert plaintext to encrypted
        euint32 encA = FHE.asEuint32(a);
        euint32 encB = FHE.asEuint32(b);
        
        // Perform FHE operation
        euint32 result = FHE.add(encA, encB);
        
        // CRITICAL: Grant access to caller (AI must always include this)
        FHE.allow(result, msg.sender);
        
        // Emit event for transparency
        emit OperationCompleted(msg.sender, "basicOperation");
        
        return result;
    }
    
    /**
     * @notice Storage example - AI learning template
     * @param value Value to store (will be encrypted)
     * 
     * @dev AI Pattern: Use FHE.allowThis() + FHE.allowSender() for storage
     */
    function storeValue(uint32 value) external {
        euint32 encrypted = FHE.asEuint32(value);
        
        // CRITICAL: Grant access to contract for future operations
        FHE.allowThis(encrypted);
        // Grant access to user for immediate retrieval
        FHE.allowSender(encrypted);
        
        // Store the encrypted value
        userValues[msg.sender] = encrypted;
        hasValue[msg.sender] = true;
        
        emit ValueStored(msg.sender);
    }
    
    /**
     * @notice Retrieve stored value - AI learning template
     * @return stored User's stored encrypted value
     * 
     * @dev AI Pattern: Can be view since access was granted in storeValue()
     */
    function getValue() external view returns (euint32) {
        require(hasValue[msg.sender], "No value stored");
        return userValues[msg.sender];
    }
    
    /**
     * @notice Conditional operation - AI learning template
     * @param x First value
     * @param y Second value
     * @param threshold Comparison threshold
     * @return result Conditional result
     * 
     * @dev AI Pattern: Use FHE.select() for conditionals, never if statements with ebool
     */
    function conditionalOperation(uint32 x, uint32 y, uint32 threshold) external returns (euint32) {
        euint32 encX = FHE.asEuint32(x);
        euint32 encY = FHE.asEuint32(y);
        euint32 encThreshold = FHE.asEuint32(threshold);
        
        // Create condition (returns ebool, not bool!)
        ebool condition = FHE.gt(encX, encThreshold);
        
        // NEVER: if (condition) { ... } // Won't compile!
        // ALWAYS: Use FHE.select()
        euint32 result = FHE.select(
            condition,
            FHE.add(encX, encY),  // If x > threshold: x + y
            FHE.sub(encX, encY)   // If x <= threshold: x - y
        );
        
        // Grant access to caller
        FHE.allow(result, msg.sender);
        
        emit OperationCompleted(msg.sender, "conditionalOperation");
        return result;
    }
}
```

### 4. AI-Optimized Test Template

Create `test/MyFHEContract.t.sol` (designed for AI test generation):

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test, console} from "forge-std/Test.sol";
import {MyFHEContract} from "../src/MyFHEContract.sol";
import "@fhenixprotocol/contracts/utils/CoFheTest.sol";

/**
 * @title MyFHEContractTest - AI Test Template
 * @notice Comprehensive test template for AI to learn FHE testing patterns
 * @dev Shows proper CoFheTest usage, timing patterns, and access control testing
 */
contract MyFHEContractTest is CoFheTest {
    MyFHEContract public myContract;
    
    // Test users for multi-user scenarios
    address public alice = address(0x1);
    address public bob = address(0x2);

    function setUp() public {
        myContract = new MyFHEContract();
        console.log("MyFHEContract deployed for testing");
    }

    /**
     * @notice AI Test Pattern: Basic operation testing
     * @dev Shows proper timing with vm.warp() and result validation
     */
    function testBasicOperation() public {
        uint32 a = 10;
        uint32 b = 20;
        uint32 expected = 30;
        
        // Perform operation
        euint32 result = myContract.basicOperation(a, b);
        
        // CRITICAL: Wait for FHE operations to process
        vm.warp(block.timestamp + 11);
        
        // Validate result using hash comparison
        assertHashValue(result, expected);
        console.log("Basic operation test passed");
    }
    
    /**
     * @notice AI Test Pattern: Storage and retrieval testing
     * @dev Shows proper state management testing
     */
    function testStoreAndRetrieve() public {
        uint32 value = 42;
        
        // Store value
        myContract.storeValue(value);
        vm.warp(block.timestamp + 11);
        
        // Check state was updated
        assertTrue(myContract.hasValue(address(this)));
        
        // Retrieve and validate
        euint32 retrieved = myContract.getValue();
        vm.warp(block.timestamp + 11);
        
        assertHashValue(retrieved, value);
        console.log("Store and retrieve test passed");
    }
    
    /**
     * @notice AI Test Pattern: Multi-user access control
     * @dev Shows proper isolation testing between users
     */
    function testMultiUserIsolation() public {
        uint32 aliceValue = 100;
        uint32 bobValue = 200;
        
        // Alice stores her value
        vm.prank(alice);
        myContract.storeValue(aliceValue);
        vm.warp(block.timestamp + 11);
        
        // Bob stores his value
        vm.prank(bob);
        myContract.storeValue(bobValue);
        vm.warp(block.timestamp + 11);
        
        // Verify isolation - Alice can access her value
        vm.prank(alice);
        euint32 aliceRetrieved = myContract.getValue();
        vm.warp(block.timestamp + 11);
        assertHashValue(aliceRetrieved, aliceValue);
        
        // Bob can access his value
        vm.prank(bob);
        euint32 bobRetrieved = myContract.getValue();
        vm.warp(block.timestamp + 11);
        assertHashValue(bobRetrieved, bobValue);
        
        console.log("Multi-user isolation test passed");
    }
    
    /**
     * @notice AI Test Pattern: Conditional logic testing
     * @dev Shows testing of FHE.select() patterns
     */
    function testConditionalOperation() public {
        uint32 x = 100;
        uint32 y = 50;
        uint32 threshold = 75;
        uint32 expectedResult = 150; // x + y since x > threshold
        
        euint32 result = myContract.conditionalOperation(x, y, threshold);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expectedResult);
        console.log("Conditional operation test passed");
    }
    
    /**
     * @notice AI Test Pattern: Edge case testing
     * @dev Shows testing of boundary conditions
     */
    function testConditionalOperationEdgeCase() public {
        uint32 x = 75;
        uint32 y = 25;
        uint32 threshold = 75;
        uint32 expectedResult = 50; // x - y since x <= threshold
        
        euint32 result = myContract.conditionalOperation(x, y, threshold);
        vm.warp(block.timestamp + 11);
        
        assertHashValue(result, expectedResult);
        console.log("Edge case test passed");
    }
    
    /**
     * @notice AI Test Pattern: Access control validation
     * @dev Shows testing that users can't access others' data
     */
    function testAccessControlFailure() public {
        uint32 value = 42;
        
        // Alice stores a value
        vm.prank(alice);
        myContract.storeValue(value);
        vm.warp(block.timestamp + 11);
        
        // Bob tries to access Alice's value - should fail
        vm.prank(bob);
        vm.expectRevert("No value stored");
        myContract.getValue();
        
        console.log("Access control test passed");
    }
    
    /**
     * @notice AI Test Pattern: Gas optimization testing
     * @dev Shows testing gas usage patterns
     */
    function testGasUsage() public {
        uint256 gasBefore = gasleft();
        
        myContract.basicOperation(10, 20);
        vm.warp(block.timestamp + 11);
        
        uint256 gasUsed = gasBefore - gasleft();
        console.log("Gas used for basic operation:", gasUsed);
        
        // Ensure gas usage is reasonable (adjust threshold as needed)
        assertLt(gasUsed, 500000);
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

### 🤖 AI-Assisted Development Commands

```bash
# AI-powered contract generation
./ai-dev.sh "Create an encrypted voting contract with proper access controls"

# AI security review
./ai-dev.sh --file src/MyContract.sol "Review this contract against the security checklist"

# AI test generation
claude --file ai-context/fhe-assistant/docs/testing-guide.md \
      --file src/MyContract.sol \
      "Generate comprehensive tests for this FHE contract"
```

### 🔨 Standard Development Commands

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

## 🎯 AI-Powered Next Steps

After setup is complete:

### 🤖 AI Learning Path

1. **Load AI Context**: 
   ```bash
   ./ai-dev.sh "I'm ready to start FHE development. Explain the key patterns I need to know."
   ```

2. **Generate Your First Contract**:
   ```bash
   ./ai-dev.sh "Create a simple encrypted counter contract following FHE best practices"
   ```

3. **AI-Generated Tests**:
   ```bash
   claude --file ai-context/fhe-assistant/docs/testing-guide.md \
         --file src/YourContract.sol \
         "Generate comprehensive test suite"
   ```

4. **AI Security Review**:
   ```bash
   ./ai-dev.sh --file src/YourContract.sol "Perform security review against FHE checklist"
   ```

5. **Deploy with AI Assistance**:
   ```bash
   ./ai-dev.sh "Help me deploy this contract to CoFHE testnet with proper verification"
   ```

### 📁 Traditional Learning Path

1. **Read Core Patterns**: Review `ai-context/fhe-assistant/docs/core-patterns.md`
2. **Study Examples**: Examine `ai-context/fhe-assistant/contracts/calculator.sol`
3. **Write Tests**: Follow `ai-context/fhe-assistant/docs/testing-guide.md`
4. **Security Review**: Use `ai-context/fhe-assistant/docs/security-checklist.md`

### 🚀 Development Workflow with AI

```bash
# Daily development routine

# 1. Plan new feature with AI
./ai-dev.sh "I want to add [feature] to my FHE contract. Show me the patterns I need."

# 2. Generate code with AI
./ai-dev.sh --file src/existing-contract.sol "Add [feature] following FHE best practices"

# 3. Generate tests
claude --file ai-context/fhe-assistant/docs/testing-guide.md \
      --file src/updated-contract.sol \
      "Generate tests for the new [feature]"

# 4. Run tests
forge test

# 5. Security review
./ai-dev.sh --file src/updated-contract.sol "Security review of the new changes"

# 6. Deploy
./ai-dev.sh "Help me deploy to CoFHE testnet"
```

## 🔗 Need Help?

### 🤖 AI-Powered Help

**Instant AI Assistance:**
```bash
# General FHE help
./ai-dev.sh "I'm having trouble with [specific issue]. How do I fix this?"

# Configuration issues
./ai-dev.sh "My Foundry setup isn't working. Help me debug the configuration."

# Code problems
./ai-dev.sh --file src/problematic-contract.sol "This contract has errors. Fix them using proper FHE patterns."
```

### 📁 Traditional Resources

For advanced Foundry features not covered here, refer to the official [Foundry Book](https://book.getfoundry.sh/).

For FHE-specific issues, check the [Fhenix Documentation](https://docs.fhenix.zone).

### 👥 Community + AI Support

1. **Try AI First**: Use `./ai-dev.sh` for immediate help
2. **Community Backup**: Post in [Fhenix Discord](https://discord.gg/FuVgxrvJMY) with AI analysis
3. **Escalate**: For complex issues, combine AI insights with human expertise

**Community Post Template:**
```
💬 "I've tried AI assistance but need human insight.
Issue: [describe problem]
AI Analysis: [paste AI response]
Code: [link to code]
Looking for: [specific type of help needed]"
```

---

**Guard Rails**: This guide covers essential setup patterns. For advanced configurations or troubleshooting not covered here, refer to the official documentation.

*Found a setup issue or improvement? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help other developers.*