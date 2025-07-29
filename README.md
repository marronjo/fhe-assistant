# FHE AI Assistant 🔐

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
```

**⚡ Inject files ONCE at conversation start:**
```bash
# Essential FHE knowledge (minimal context)
claude --file ../fhe-assistant/docs/core-patterns.md "help me understand FHE access control"

# Standard setup for building contracts
claude --file ../fhe-assistant/docs/core-patterns.md \
      --file ../fhe-assistant/contracts/calculator.sol \
      "help me build an encrypted calculator"

# Security review setup
claude --file ../fhe-assistant/docs/security-checklist.md \
      --file ../fhe-assistant/docs/core-patterns.md \
      --file src/MyContract.sol \
      "review this FHE contract against the security checklist"

# Load entire directories (all files at once)
claude --file ../fhe-assistant/docs/ "explain all FHE patterns and security considerations"

# Complete context for complex projects  
claude --file ../fhe-assistant/docs/ \
      --file ../fhe-assistant/contracts/ \
      "build me an encrypted voting system"

# Mix specific files and directories
claude --file ../fhe-assistant/docs/core-patterns.md \
      --file ../fhe-assistant/contracts/ \
      "explain the FHERC20 token pattern"
```

**🔑 Key Point: Load files ONCE per conversation** - they stay in context for the entire session!

After initial setup, just chat normally:
```bash
# First message (loads context)
claude --file docs/core-patterns.md "explain FHE access control"

# All subsequent messages in SAME conversation (files already loaded)
"now show me how to implement encrypted transfers"
"review this contract I just wrote"  
"what's wrong with this FHE.select() usage?"
```

**🔄 New conversation = reload files:**
```bash
# Close claude, open new instance
# Files are gone - need to reload for new conversation

claude --file docs/core-patterns.md "help me with a different FHE contract"
```

**Pro tips:**
- Keep `fhe-assistant` in a standard location like `~/dev/fhe-assistant`
- **Context persists within single conversation only**
- Each new Claude instance/conversation requires reloading files
- Keep your most-used file combinations handy for quick reloading

#### Other AI Platforms (ChatGPT, Gemini, DeepSeek, Grok, etc.)

**Basic Setup:**
```
1. Copy docs/core-patterns.md + docs/security-checklist.md (~27KB)
2. Paste and say: "This is FHE reference material. Help me build encrypted smart contracts."
3. Add specific contract examples as needed for your task
```

**Platform-Specific Tips:**
- **File Upload Capable** (Gemini, Claude, etc.): Upload files when available instead of copy-paste
- **Custom Instructions** (ChatGPT): Add FHE principles to your custom instructions for persistence
- **VS Code Extensions** (Cursor, Continue): Clone repo in workspace, reference files directly
- **Mobile/Limited Context**: Use core-patterns.md only, break into chunks if needed

**Universal System Prompt** *(works with any AI platform):*
```
You are an expert FHE smart contract developer. Core principle: "Without FHE.allow() = passing a locked box without the key!"

Key patterns:
- FHE types are handles to encrypted data, not the data itself
- Use FHE.allow() for access control (mandatory for returns)
- Use FHE.allowThis() for contract storage  
- Use FHE.select() for conditionals (no if statements with ebool)
- Multi-transaction decryption required

Always provide working, copy-paste ready code following these FHE patterns.
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