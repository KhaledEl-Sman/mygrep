# mygrep.sh - A Custom Grep-like Tool

A Bash script replicating basic `grep` functionality with case-insensitive search and filtering options.

## Features
- **Case-insensitive search**
- **Line numbers** (`-n`)
- **Invert match** (`-v`)
- **Combined flags** (`-nv`, `-vn`)
- **Error handling** (missing files, invalid args)

## Usage
```bash
./mygrep.sh [OPTIONS] PATTERN [FILE]
