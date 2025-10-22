#!/bin/bash

# Kernel Development Context Project Setup Script
# This script initializes a new project to provide context files for kernel development

set -e

echo "🚀 Initializing Kernel Development Context Project..."

# Initialize git repository
if [ ! -d .git ]; then
    echo "📦 Initializing git repository..."
    git init
    echo "✓ Git repository initialized"
else
    echo "⚠️  Git repository already exists, skipping initialization"
fi

# Create CLAUDE.md
echo "📝 Creating CLAUDE.md..."
cat > CLAUDE.md << 'EOF'
# Kernel Development Context Project

## Purpose

This project provides structured context files to help Claude (and other AI assistants) bootstrap kernel development projects or assist with existing kernel work. Kernel development is complex and multifaceted - each subsystem has its own conventions, tools, and workflows. This project aims to capture that knowledge in a structured, reusable format.

## Why This Exists

Starting kernel development from scratch requires understanding:
- Build systems and toolchains
- Boot mechanisms (QEMU, real hardware, etc.)
- Debugging approaches (GDB, KGDB, printk, ftrace, etc.)
- Subsystem-specific conventions and requirements
- Testing frameworks and methodologies
- Common pitfalls and gotchas

While the basics of building and booting are common across all kernel work, each subsystem (networking, filesystems, drivers, schedulers, memory management, etc.) has unique characteristics. This project provides the context needed to work effectively in any area.

## Project Structure

```
kernel-dev-context/
├── CLAUDE.md                 # This file - project overview
├── README.md                 # User-facing documentation
├── common/                   # Common kernel development practices
│   ├── building.md          # How to build the kernel
│   ├── booting.md           # Boot methods (QEMU, hardware, etc.)
│   ├── debugging.md         # Debugging techniques and tools
│   ├── testing.md           # Testing frameworks and approaches
│   └── workflow.md          # Development workflow and best practices
├── subsystems/              # Subsystem-specific context
│   ├── networking/          # Network stack development
│   ├── filesystems/         # Filesystem development
│   ├── drivers/             # Device driver development
│   ├── mm/                  # Memory management
│   ├── scheduler/           # Process scheduler
│   ├── security/            # Security subsystems (SELinux, etc.)
│   └── ...                  # Other subsystems as needed
├── tools/                   # Tool-specific guides
│   ├── git-workflow.md      # Kernel git workflow
│   ├── patch-submission.md  # How to submit patches
│   └── code-style.md        # Kernel coding style
└── templates/               # Project templates
    ├── driver-skeleton/     # Basic driver template
    ├── module-skeleton/     # Basic module template
    └── subsystem-guide/     # Template for new subsystem guides
```

## How to Use This Project

### For Starting New Projects

1. Identify which subsystem(s) you'll be working with
2. Read the common context files (building, booting, debugging)
3. Read the subsystem-specific context files
4. Use templates as starting points for your code

### For Existing Projects

1. Identify which context files are relevant
2. Provide them to Claude along with your existing code
3. Claude will have the necessary background to assist effectively

### For Contributing

This project is meant to grow over time. Contributions should:
- Be accurate and well-tested
- Include practical examples where possible
- Reference official kernel documentation when appropriate
- Be subsystem-specific when conventions differ from general kernel practice

## Context File Format

Each context file should follow this general structure:

```markdown
# [Topic Name]

## Overview
Brief description of what this covers

## Key Concepts
Important concepts and terminology

## Common Patterns
Typical code patterns and idioms

## Tools and Commands
Specific tools and how to use them

## Gotchas
Common mistakes and how to avoid them

## Examples
Practical examples

## References
Links to official documentation and resources
```

## Current Status

This project is in its initial setup phase. The basic structure is defined, but content needs to be created for each area.

## Next Steps

1. Create the directory structure
2. Populate common/ with fundamental kernel development practices
3. Begin adding subsystem-specific guides, starting with the most common areas
4. Create useful templates
5. Add practical examples throughout

## License

[To be determined - likely GPLv2 to match kernel licensing]
EOF
echo "✓ CLAUDE.md created"

# Create README.md
echo "📝 Creating README.md..."
cat > README.md << 'EOF'
# Kernel Development Context Files

A collection of structured context files to accelerate kernel development with AI assistance.

## What is this?

This repository contains documentation and context files specifically designed to help AI assistants (like Claude) effectively assist with Linux kernel development. Each file provides the background knowledge, conventions, and practical information needed to work in different areas of the kernel.

## Quick Start

Browse the `common/` directory for general kernel development information, then dive into specific `subsystems/` for area-specific guidance.

## Why Context Files?

AI assistants are powerful tools for development, but they work best with clear context. Kernel development is particularly complex, with:
- Decades of accumulated conventions
- Subsystem-specific requirements
- Complex build and test environments
- Unique debugging approaches

These files provide that context in a structured, reusable way.

## Contributing

Contributions welcome! Please ensure your additions are:
- Accurate and tested
- Well-structured and clear
- Referenced to official documentation where appropriate

## Getting Started with Kernel Development

If you're new to kernel development, start with:
1. `common/building.md` - Learn how to build the kernel
2. `common/booting.md` - Learn how to boot your kernel
3. `common/debugging.md` - Learn debugging fundamentals
4. Choose a subsystem guide based on your interests

## Project Status

This project is in active development. Check back frequently for new content!
EOF
echo "✓ README.md created"

# Create basic directory structure
echo "📁 Creating directory structure..."
mkdir -p common
mkdir -p subsystems/{networking,filesystems,drivers,mm,scheduler,security}
mkdir -p tools
mkdir -p templates/{driver-skeleton,module-skeleton,subsystem-guide}

echo "✓ Directory structure created"

# Create placeholder files
echo "📄 Creating placeholder files..."

# Common placeholders
touch common/building.md
touch common/booting.md
touch common/debugging.md
touch common/testing.md
touch common/workflow.md

# Tools placeholders
touch tools/git-workflow.md
touch tools/patch-submission.md
touch tools/code-style.md

echo "✓ Placeholder files created"

# Create .gitignore
echo "📝 Creating .gitignore..."
cat > .gitignore << 'EOF'
# Editor files
*~
*.swp
*.swo
.vscode/
.idea/
*.sublime-*

# OS files
.DS_Store
Thumbs.db

# Build artifacts (if we add examples)
*.o
*.ko
*.mod.c
.*.cmd
modules.order
Module.symvers

# Temporary files
*.tmp
EOF
echo "✓ .gitignore created"

# Initial git commit
echo "💾 Creating initial commit..."
git add .
git commit -m "Initial project setup

- Add CLAUDE.md with project purpose and structure
- Add README.md for user-facing documentation
- Create basic directory structure for common/, subsystems/, tools/, and templates/
- Add placeholder files for initial content
- Add .gitignore"

echo ""
echo "✅ Kernel Development Context Project initialized successfully!"
echo ""
echo "📋 Next steps:"
echo "   1. Start populating common/ with fundamental kernel dev practices"
echo "   2. Add subsystem-specific guides as needed"
echo "   3. Create useful templates in templates/"
echo "   4. Add practical examples throughout"
echo ""
echo "🎯 Project structure:"
tree -L 2 -a 2>/dev/null || find . -maxdepth 2 -not -path '*/\.git/*' | sort
echo ""
echo "🚀 Ready to start documenting kernel development context!"
EOF
