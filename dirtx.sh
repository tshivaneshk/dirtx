#!/bin/bash

# ===============================================
# dirtx CLI Tool - Professional Folder Organizer
# ===============================================
# MIT License
# Copyright (c) 2025 T Shivanesh Kumar
# Licensed under the MIT License. See LICENSE file.
# ===============================================

REPO_URL="https://github.com/<your-username>/dirtx.git"
DAYS_THRESHOLD=0
DRY_RUN=false

# Colors
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

# Categories and extensions
declare -A CATEGORIES
CATEGORIES=(
    ["Images"]="jpg jpeg png gif bmp svg"
    ["Videos"]="mp4 mkv mov avi flv webm"
    ["Audio"]="mp3 wav m4a flac"
    ["PDFs"]="pdf"
    ["Word"]="doc docx"
    ["Excel"]="xls xlsx csv"
    ["PowerPoint"]="ppt pptx"
    ["Compressed"]="zip rar 7z tar gz"
    ["Installers"]="exe msi dmg deb rpm AppImage"
    ["Python"]="py"
    ["Java"]="java"
    ["C"]="c"
    ["C++"]="cpp"
    ["C#"]="cs"
    ["Bash"]="sh"
    ["PHP"]="php"
    ["Ruby"]="rb"
    ["Go"]="go"
    ["WebApps"]="html css js ts json"
    ["Misc"]="crdownload part torrent log ics url"
)

# Summary counters
declare -A SUMMARY
for category in "${!CATEGORIES[@]}"; do
    SUMMARY["$category"]=0
done
SUMMARY["Misc"]=0
TOTAL_MOVED=0

# Banner
banner() {
    echo -e "${CYAN}"
    echo "===================="
    echo "      𝕕𝕚𝕣𝕥𝕩"
    echo "===================="
    echo -e "${RESET}"
}

# Usage
usage() {
    echo "Usage: dirtx [-f <folder>] [-d <days>] [--dry-run] [--update]"
    echo "  -f, --folder    Target folder to organize (default: current folder)"
    echo "  -d, --days      Move files older than N days (default: 0 = all files)"
    echo "  --dry-run       Preview changes without moving files"
    echo "  --update        Update dirtx to the latest version from GitHub"
    exit 1
}

# Auto-update
update_tool() {
    echo -e "${CYAN}Checking for updates...${RESET}"
    TMP_DIR=$(mktemp -d)
    git clone --depth 1 "$REPO_URL" "$TMP_DIR" >/dev/null 2>&1
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}Failed to clone repository. Check your internet connection.${RESET}"
        exit 1
    fi
    cp "$TMP_DIR/dirtx.sh" "$(dirname "$(realpath "$0")")/dirtx.sh"
    chmod +x "$(dirname "$(realpath "$0")")/dirtx.sh"
    rm -rf "$TMP_DIR"
    echo -e "${GREEN}dirtx updated successfully!${RESET}"
    exit 0
}

# Parse CLI arguments
TARGET_FOLDER=""
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -f|--folder) TARGET_FOLDER="$2"; shift ;;
        -d|--days) DAYS_THRESHOLD="$2"; shift ;;
        --dry-run) DRY_RUN=true ;;
        --update) update_tool ;;
        -h|--help) usage ;;
        *) echo -e "${RED}Unknown parameter: $1${RESET}"; usage ;;
    esac
    shift
done

# Default folder
TARGET_FOLDER="${TARGET_FOLDER:-$(pwd)}"

# Validate folder
if [[ ! -d "$TARGET_FOLDER" ]]; then
    echo -e "${RED}Error: Invalid folder path${RESET}"
    usage
fi

# Already-organized check
is_already_organized() {
    local folder="$1"
    local loose_files=0
    for file in "$folder"/*; do
        [[ -f "$file" ]] || continue
        basename_file=$(basename "$file")
        # Skip category folders themselves
        for cat in "${!CATEGORIES[@]}"; do
            [[ "$basename_file" == "$cat" ]] && continue 2
        done
        ext="${basename_file##*.}"
        ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')
        matched=false
        for category in "${!CATEGORIES[@]}"; do
            for e in ${CATEGORIES[$category]}; do
                if [[ "$ext_lower" == "$e" ]]; then
                    parent_folder=$(basename "$(dirname "$file")")
                    [[ "$parent_folder" == "$category" ]] && matched=true
                    break
                fi
            done
            [[ $matched == true ]] && break
        done
        [[ $matched == false ]] && loose_files=$((loose_files+1))
    done
    [[ $loose_files -eq 0 ]] && return 0 || return 1
}

# Banner
banner

if is_already_organized "$TARGET_FOLDER"; then
    echo -e "${CYAN}All files are already organized!${RESET}"
    exit 0
fi

echo -e "${CYAN}Organizing folder -> $TARGET_FOLDER${RESET}"
[[ $DAYS_THRESHOLD -gt 0 ]] && echo -e "${CYAN}Only moving files older than $DAYS_THRESHOLD day(s)${RESET}"
[[ $DRY_RUN == true ]] && echo -e "${YELLOW}[DRY RUN] No files will be moved${RESET}"

# Process files
shopt -s nullglob
for file in "$TARGET_FOLDER"/*; do
    [[ -f "$file" ]] || continue
    filename=$(basename "$file")
    parent_folder=$(basename "$(dirname "$file")")

    # Skip category folders themselves
    skip=false
    for cat in "${!CATEGORIES[@]}"; do
        [[ "$filename" == "$cat" ]] && skip=true && break
    done
    $skip && continue

    ext="${filename##*.}"
    ext_lower=$(echo "$ext" | tr '[:upper:]' '[:lower:]')

    # Skip files already in correct category folder
    matched=false
    for category in "${!CATEGORIES[@]}"; do
        for e in ${CATEGORIES[$category]}; do
            if [[ "$ext_lower" == "$e" ]]; then
                dest="$TARGET_FOLDER/$category"
                [[ "$parent_folder" == "$category" ]] && matched=true && break
                # Move file
                if [[ $DRY_RUN == true ]]; then
                    echo -e "${YELLOW}[DRY RUN] $filename -> $category${RESET}"
                    SUMMARY["$category"]=$((SUMMARY["$category"] + 1))
                    TOTAL_MOVED=$((TOTAL_MOVED + 1))
                    matched=true
                    break
                fi
                mkdir -p "$dest"
                mv "$file" "$dest/"
                echo -e "${GREEN}dirtx: $filename -> $category${RESET}"
                SUMMARY["$category"]=$((SUMMARY["$category"] + 1))
                TOTAL_MOVED=$((TOTAL_MOVED + 1))
                matched=true
                break
            fi
        done
        [[ $matched == true ]] && break
    done

    # Handle Misc
    if [[ $matched == false ]]; then
        dest="$TARGET_FOLDER/Misc"
        [[ "$parent_folder" == "Misc" ]] && continue
        if [[ $DRY_RUN == true ]]; then
            echo -e "${YELLOW}[DRY RUN] $filename -> Misc${RESET}"
            SUMMARY["Misc"]=$((SUMMARY["Misc"] + 1))
            TOTAL_MOVED=$((TOTAL_MOVED + 1))
            continue
        fi
        mkdir -p "$dest"
        mv "$file" "$dest/"
        echo -e "${GREEN}dirtx: $filename -> Misc${RESET}"
        SUMMARY["Misc"]=$((SUMMARY["Misc"] + 1))
        TOTAL_MOVED=$((TOTAL_MOVED + 1))
    fi
done

# Summary
echo ""
if [[ $TOTAL_MOVED -eq 0 ]]; then
    echo -e "${CYAN}All files are already organized!${RESET}"
else
    echo -e "${CYAN}===================== dirtx Summary =====================${RESET}"
    printf "%-15s | %s\n" "Category" "Files Moved"
    echo "-----------------|-------------"
    for category in "${!SUMMARY[@]}"; do
        count=${SUMMARY[$category]}
        if [[ $count -gt 0 ]]; then
            printf "${GREEN}%-15s | %d${RESET}\n" "$category" "$count"
        else
            printf "${YELLOW}%-15s | %d${RESET}\n" "$category" "$count"
        fi
    done
    echo -e "${CYAN}=========================================================${RESET}"
fi
