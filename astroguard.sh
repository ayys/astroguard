#!/bin/bash
# astroguard - A code auditing and streamlining tool for C programs to adhere to NASA JPL's Rule of 10
# Developed for Stellaryx Labs [stellaryxlabs.com]
# Written by Angelina Tsuboi [angelinatsuboi.com]
# Released under MIT License

set -- $GRARGS $@
set -e
set -o pipefail

# Default Values
hidebanner=0
version=0.1
output_file=""

# Default colors
red='\033[0;31m'
green='\033[0;32m'
yellow='\033[0;33m'
blue='\033[0;34m'
magenta='\033[0;35m'
cyan='\033[0;36m'
clear='\033[0m'

banner() {
    if [ $hidebanner == 0 ]; then
    color_text $(cat "./assets/banner.txt") magenta
    fi
}

about() {
    cat "./assets/help.txt"
}

# Adding color to terminal messages
print_color() {
    local text="$1"
    local color="$2"
    echo -e "${color}${text}${clear}"
}

set_output_file() {
    local path="$1"
    local file_ext="${path: -3}"
    if [ "${file_ext,,}" = "txt" ]; then
        output_file="${path}"
    else
        echo "Invalid output file ${path}! Output file must be a text file!"
        exit 1
    fi
}

# Step #1
# Installation Checking
# Checks for the following tools: gcc, gcov, gdb, and glov

installation() {
    print_color "Lauching astroguard 🚀" blue
    print_color "Step 1 > Checking for installations" blue

    if command -v gcc &> /dev/null; then
        echo "GCC is installed."
        # Check GCC version
        gcc_version=$(gcc --version | grep -oP 'gcc \K[^\s]+')
        echo "GCC version: $gcc_version"
    else
        echo "GCC is not installed. Please install GCC before proceeding."
        exit 1
    fi
}

# Step #2
# Compiles the C program
# Compilations settings set to the most pedantic level

compile() {
    # Compile the C file
    gcc –Wall –pedantic –Wtraditional –Wshadow –Wpointer-arith –Wcast-qual –Wcast-align –Wstrict–prototypes –Wmissing–prototypes –Wconversion –std=iso9899:1999" $file_path" -o "$file_name_no_ext"

    # Check if compilation was successful
    if [ $? -eq 0 ]; then
        # Execute the compiled program
        "./$file_name_no_ext"
    else
        echo "Compilation failed."
    fi
}

run() {
    echo "running"
}

while getopts "bBho:" flag; do
  case $flag in
    b)
        hidebanner=1
    ;;
    h)
        about
        exit 1
    ;;
    o)
        set_output_file "$OPTARG"
    ;;
    \?)
        about
        exit 2
    ;;
  esac
done

shift $((OPTIND-1))

file_path="$1"
file_name=$(basename -- "$file_path")
file_name_no_ext="${file_name%.*}"
file_ext="${file_path: -1}"

# Check if a file path is provided
if [ -z "$file_path" ]; then
    echo "Error: File path not provided."
    exit 1
elif [ "${file_ext,,}" != "c" ]; then
    echo "Error: File must be C."
    exit 1
fi

installation
echo $file_ext