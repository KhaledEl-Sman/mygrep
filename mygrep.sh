#!/bin/bash

# Function to display help information
show_help() {
    echo "Usage: $0 [OPTIONS] PATTERN [FILE]"
    echo "Search for PATTERN in FILE (or standard input if no FILE specified)."
    echo "Options:"
    echo "  -n    show line numbers"
    echo "  -v    invert match (select non-matching lines)"
    echo "  --help display this help and exit"
    exit 0
}

# Initialize variables
show_line_numbers=0
invert_match=0
pattern=""
filename=""

# Parse command line options
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -n)
            show_line_numbers=1
            shift
            ;;
        -v)
            invert_match=1
            shift
            ;;
        -nv|-vn)
            show_line_numbers=1
            invert_match=1
            shift
            ;;
        --help)
            show_help
            ;;
        -*)
            echo "Error: Unknown option: $1" >&2
            exit 1
            ;;
        *)
            # First non-option argument is the pattern
            if [[ -z "$pattern" ]]; then
                pattern="$1"
            else
                # Second non-option argument is the filename
                if [[ -z "$filename" ]]; then
                    filename="$1"
                else
                    echo "Error: Too many arguments" >&2
                    exit 1
                fi
            fi
            shift
            ;;
    esac
done

# Validate input - must have pattern and filename can't be the pattern
if [[ -z "$pattern" ]]; then
    echo "Error: Missing search pattern" >&2
    exit 1
fi

# If filename is empty but pattern looks like a filename that exists,
# and the user probably meant to search this file with no pattern
if [[ -z "$filename" && -f "$pattern" ]]; then
    echo "Error: Missing search pattern (did you mean to search file '$pattern'?)" >&2
    exit 1
fi

# If no filename provided, read from stdin
if [[ -z "$filename" ]]; then
    input_source="/dev/stdin"
else
    # Check if file exists
    if [[ ! -f "$filename" ]]; then
        echo "Error: File '$filename' not found" >&2
        exit 1
    fi
    input_source="$filename"
fi

# Perform the search (case-insensitive)
line_number=0
while IFS= read -r line; do
    line_number=$((line_number + 1))
    
    # Convert both to lowercase for case-insensitive comparison
    lower_line=$(echo "$line" | tr '[:upper:]' '[:lower:]')
    lower_pattern=$(echo "$pattern" | tr '[:upper:]' '[:lower:]')
    
    # Check for match
    if [[ "$lower_line" == *"$lower_pattern"* ]]; then
        match=1
    else
        match=0
    fi
    
    # Handle invert match
    if [[ "$invert_match" -eq 1 ]]; then
        match=$((1 - match))
    fi
    
    # Print if matched
    if [[ "$match" -eq 1 ]]; then
        if [[ "$show_line_numbers" -eq 1 ]]; then
            echo "$line_number:$line"
        else
            echo "$line"
        fi
    fi
done < "$input_source"
