# FHE Assistant 🔐

A comprehensive development assistant for Fully Homomorphic Encryption (FHE) smart contracts on Fhenix. This repository provides patterns, examples, and best practices to help developers build secure and efficient FHE applications.

## 🚀 Quick Start

### For Claude Code Users

This repository is optimized for use with Claude Code. Simply reference this repository in your conversations:

```bash
# Clone the repository
git clone https://github.com/fhenixprotocol/fhe-assistant.git
cd fhe-assistant

# Start Claude Code
claude-code
```

**Usage Examples:**

- "Help me build an encrypted calculator using the FHE patterns"
- "Review my FHE contract against the security checklist"
- "Show me how to set up FHE testing with Foundry"
- "Explain the encrypted auction pattern"

### For Other AI Platforms

Copy and paste the relevant documentation files as context:

1. **Core Concepts**: Use `docs/core-patterns.md` for fundamental FHE understanding
2. **Security Review**: Use `docs/security-checklist.md` for code reviews
3. **Setup Help**: Use `docs/setup-guide.md` for project configuration
4. **Examples**: Reference contract files in `contracts/` for implementation patterns

## 📋 Mental Model

> **"Without FHE.allow() = passing a locked box without the key!"**

This is the core mental model for FHE development. FHE types (euint8, euint32, ebool) are handles pointing to encrypted data. Operations create computation graphs, and results must be explicitly made accessible using `FHE.allow()` or `FHE.allowThis()`.

## 📁 Repository Structure

```
fhe-assistant/
├── docs/
│   ├── core-patterns.md      # Fundamental FHE concepts and patterns
│   ├── security-checklist.md # Code review checklist
│   ├── setup-guide.md        # Foundry/Hardhat configuration
│   ├── testing-guide.md      # CoFheTest patterns
│   ├── fhe-context.md        # Fhenix ecosystem overview
│   └── foundry-basics.md     # Essential Foundry commands
└── contracts/
    ├── calculator.sol        # Basic FHE operations
    ├── fherc20.sol          # Encrypted token patterns
    ├── auction.sol          # Sealed bid auction
    └── test-example.sol     # CoFheTest demonstration
```

## 🎯 Common Use Cases

### Building Your First FHE Contract

1. Start with `docs/setup-guide.md` for project setup
2. Review `docs/core-patterns.md` for mental models
3. Copy patterns from `contracts/calculator.sol`
4. Test using patterns from `docs/testing-guide.md`

### Code Review

Use `docs/security-checklist.md` as a pre-flight checklist:
- ✅ All FHE operations have proper access control
- ✅ No ebool used in if statements
- ✅ Multi-transaction decryption patterns
- ✅ Proper error handling

### Advanced Patterns

- **Encrypted Tokens**: See `contracts/fherc20.sol`
- **Auctions**: See `contracts/auction.sol`
- **Testing**: See `contracts/test-example.sol`

## 🛡️ Security First

FHE development requires different security considerations:

- **Access Control**: FHE operations are NOT view functions
- **Decryption**: Always requires multiple transactions
- **Control Flow**: Use `FHE.select()` instead of if statements
- **Permissions**: Cross-contract calls need explicit permissions

## 🔧 Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Basic Solidity knowledge
- Understanding of encryption concepts

## 📚 Learning Path

1. **Start Here**: `docs/fhe-context.md` - Understand the Fhenix ecosystem
2. **Core Concepts**: `docs/core-patterns.md` - Master FHE mental models
3. **Hands-On**: `contracts/calculator.sol` - Build your first contract
4. **Testing**: `docs/testing-guide.md` - Learn CoFheTest patterns
5. **Advanced**: `contracts/auction.sol` - Complex FHE applications

## 🤝 Community & Support

- **Discord**: [Fhenix Community](https://discord.gg/FuVgxrvJMY)
- **Documentation**: [docs.fhenix.zone](https://docs.fhenix.zone)
- **GitHub**: [Fhenix Protocol](https://github.com/FhenixProtocol)

## 📝 Contributing

We welcome contributions! Please use our issue templates:

- **Assistant Feedback**: Report issues with AI assistant responses
- **Pattern Improvements**: Suggest better FHE patterns

### Guard Rails

This assistant only provides information contained in these files. For topics not covered here, we'll refer you to the official documentation at [docs.fhenix.zone](https://docs.fhenix.zone).

## 🏃‍♂️ Quick Commands

```bash
# Setup new FHE project
forge init my-fhe-project
cd my-fhe-project
forge install https://github.com/FhenixProtocol/fhenix-contracts

# Build and test
forge build
forge test

# Deploy to CoFHE (testnet)
forge script script/Deploy.s.sol --rpc-url https://api.cofhe.fhenix.zone --broadcast
```

## 📄 License

MIT License - see LICENSE file for details.

---

**Remember**: Without `FHE.allow()`, you're passing a locked box without the key! 🔐

*This assistant is community-driven. Found an issue or have a suggestion? [Open an issue](https://github.com/fhenixprotocol/fhe-assistant/issues) to help improve the experience for everyone.*