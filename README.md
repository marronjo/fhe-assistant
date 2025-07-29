# FHE Assistant 🔐

**AI Training Materials for Fully Homomorphic Encryption (FHE) Smart Contract Development**

This repository contains curated documentation and examples designed to train AI assistants (Claude, ChatGPT, Gemini, etc.) on FHE development patterns. Feed these materials into your AI assistant to get expert-level FHE guidance.

## 🎯 How to Use This Repository

### Quick Setup for Any AI Assistant

**Step 1: Choose Your Core Files (Essential)**
```
ALWAYS INCLUDE:
📋 docs/core-patterns.md     (15KB) - Mental models & fundamental patterns  
🛡️ docs/security-checklist.md (12KB) - Security review checklist
```

**Step 2: Add Based on Your Task**
```
FOR CODING HELP:
📝 contracts/calculator.sol   (18KB) - Basic FHE operations with extensive comments
🪙 contracts/fherc20.sol     (25KB) - Encrypted token patterns
🏛️ contracts/auction.sol     (22KB) - Advanced sealed bid auction

FOR SETUP/TESTING:
⚙️ docs/setup-guide.md       (8KB)  - Foundry configuration
🧪 docs/testing-guide.md     (14KB) - CoFheTest patterns
🔧 contracts/test-example.sol (20KB) - Complete test demonstrations

FOR CONTEXT/BACKGROUND:
📚 docs/fhe-context.md       (10KB) - Ecosystem overview
⚡ docs/foundry-basics.md    (6KB)  - Essential commands
```

### Token Optimization Strategies

**Minimal Setup (≈27KB):**
- `docs/core-patterns.md` + `docs/security-checklist.md`
- Good for: Understanding FHE concepts, code review, security questions

**Standard Setup (≈45KB):**
- Core files + `contracts/calculator.sol` 
- Good for: Building basic FHE contracts, learning patterns

**Complete Setup (≈130KB):**
- All files
- Good for: Complex projects, advanced patterns, comprehensive understanding

### Platform-Specific Instructions

#### Claude Code
```bash
# Clone the reference materials (one-time setup)
git clone https://github.com/fhenixprotocol/fhe-assistant.git

# In your actual FHE project directory
cd your-fhe-project
claude-code
```
Then reference the materials: *"Use the FHE patterns from `/path/to/fhe-assistant/docs/core-patterns.md` to help me build this contract"*

**Pro tip**: Keep the `fhe-assistant` repo in a standard location like `~/dev/fhe-assistant` so you can always reference it from any project.

#### ChatGPT/Claude/Gemini (Copy-Paste)
1. Copy contents of `docs/core-patterns.md`
2. Paste and say: *"This is FHE reference material. Help me with [your task]"*
3. Add more files as needed for your specific task

#### Advanced: Custom System Prompt
```
You are an expert FHE (Fully Homomorphic Encryption) smart contract developer. 
Key principles:
- "Without FHE.allow() = passing a locked box without the key!"
- FHE types are handles, not actual encrypted data
- Use FHE.select() instead of if statements with ebool
- Multi-transaction decryption is required
- Always use FHE.allowThis() for contract storage

Refer to the provided documentation for specific patterns and examples.
```

## 🔥 Example Prompts

### For Code Generation
```
"I need to build an encrypted voting system. Show me the patterns for:
- Storing encrypted votes 
- Preventing double voting
- Tallying votes privately"
```

### For Code Review  
```
"Review this FHE contract against the security checklist:
[paste your contract code]"
```

### For Learning
```
"Explain how FHE.select() works and why I can't use if statements with ebool"
```

### For Setup Help
```
"Help me configure Foundry for FHE development with proper remappings"
```

## 📊 File Priority Matrix

| Priority | Files | Use Case | Token Cost |
|----------|-------|----------|------------|
| 🔴 **Critical** | `core-patterns.md` + `security-checklist.md` | Understanding FHE, Code review | ~27KB |
| 🟡 **High** | + `calculator.sol` | Building basic contracts | ~45KB |
| 🟢 **Standard** | + `fherc20.sol` OR `auction.sol` | Advanced patterns | ~70KB |
| 🔵 **Complete** | All files | Complex projects, learning | ~130KB |

## 💡 Pro Tips for AI Training

### Effective Context Loading
1. **Start Small**: Begin with `core-patterns.md` only
2. **Add Incrementally**: Include specific files as conversation progresses  
3. **Reference by Name**: Say "use the calculator pattern from calculator.sol"
4. **Refresh Context**: Re-paste core files if AI forgets patterns

### Common AI Prompts
```bash
# Initial training
"This is FHE reference material. I'm building encrypted smart contracts."

# Pattern requests  
"Show me the FHE token transfer pattern"
"How do I handle encrypted comparisons?"
"What's the proper access control pattern?"

# Security review
"Check this contract against the FHE security checklist"

# Debugging
"Why isn't my FHE.allow() working?"
"How do I fix 'access denied' errors?"
```

### Token Management
- **Short Sessions**: Use minimal setup for quick questions
- **Long Sessions**: Front-load all relevant files 
- **Refresh Strategy**: Re-paste core patterns if AI responses degrade
- **File Chunking**: For very long files, paste in sections with clear headers

## 🎯 Core Mental Model

> **"Without FHE.allow() = passing a locked box without the key!"**

The AI assistant must understand this fundamental concept before any FHE development. FHE types are handles, not actual encrypted data.

## 📁 What's Inside

```
📋 docs/core-patterns.md      → FHE mental models & patterns (ESSENTIAL)
🛡️ docs/security-checklist.md → Pre-flight security review (ESSENTIAL)  
⚙️ docs/setup-guide.md        → Foundry/Hardhat configuration
🧪 docs/testing-guide.md      → CoFheTest patterns & best practices
📚 docs/fhe-context.md        → Ecosystem overview & background
⚡ docs/foundry-basics.md     → Essential development commands

📝 contracts/calculator.sol   → Basic FHE operations (START HERE)
🪙 contracts/fherc20.sol      → Encrypted token implementation  
🏛️ contracts/auction.sol      → Sealed bid auction (ADVANCED)
🔧 contracts/test-example.sol → Comprehensive test examples
```

## 🤝 Community Resources

- **Discord**: [Fhenix Community](https://discord.gg/FuVgxrvJMY) - Real-time FHE help
- **Documentation**: [docs.fhenix.zone](https://docs.fhenix.zone) - Official reference
- **GitHub Issues**: Report AI training improvements or pattern issues

## 📄 License

MIT License - Use freely for AI training and development.

---

**🚀 Ready to start?** Copy `docs/core-patterns.md` into your AI assistant and say:
*"This is FHE reference material. Help me build encrypted smart contracts."*