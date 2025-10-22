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
