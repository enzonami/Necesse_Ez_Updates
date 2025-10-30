#!/bin/bash
# =============================================
### Automatic Updates For BitRust Factions | Necesse
### BitRust Network - Click-to-Install Necesse Mods
### AUTO-DOWNLOADS & UNZIPS from the latest Respo
# =============================================

BRAND="BitRust Network"
GAME="Necesse"
VERSION="v1.0"
MOD_DIR="$HOME/.config/Necesse/mods"
DOWNLOAD_URL="https://github.com/enzonami/BitRust/archive/refs/heads/main.zip"
ZIP_FILE="BitRust-main.zip"
SCRIPT="$(basename "$0")"

find_steam_content() {
    if [[ -d "$HOME/.local/share/Steam/steamapps/workshop/content" ]] ||
       [[ -d "$HOME/.steam/steam/steamapps/workshop/content" ]] ||
       [[ -d "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/workshop/content" ]]; then
        echo "found"
    else
        echo "not found"
    fi
}

STEAM_STATUS="$(find_steam_content)"

clear
cat <<'EOF'
__________.__  __ __________                __   
\______   \__|/  |\______   \__ __  _______/  |_ 
 |    |  _/  \   __\       _/  |  \/  ___/\   __\
 |    |   \  ||  | |    |   \  |  /\___ \  |  |  
 |______  /__||__| |____|_  /____//____  > |__|  
        \/                \/           \/
Crafted by Enzonami|https://discord.gg/ZF3brDDsW7             
EOF
echo
echo -e "     \033[91mBitRust Network - Necesse Mod Installer\033[0m"
echo
echo -e "     \033[2mPress Enter to continue...\033[0m"
read -r

clear
echo -e "\033[91m██████████████████████████████████████████████████████████████\033[0m"
echo -e "\033[91m█░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█\033[0m"
echo -e "\033[91m█░▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀█\033[0m"
echo -e "\033[91m█░  $BRAND - $GAME Mod Installer  █\033[0m"
echo -e "\033[91m█░▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀█\033[0m"
echo -e "\033[91m█░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█\033[0m"
echo

printf " Detected: \033[96mMod Folder\033[0m: found  \033[96mWorkshop Cache (ALL GAMES)\033[0m: $STEAM_STATUS\n\n"

printf " Action: "
printf "\033[92m[1]\033[0m Install Mods  "
printf "\033[96m[2]\033[0m Open Folder  "
[[ "$STEAM_STATUS" == "found" ]] && printf "\033[93m[3]\033[0m Clear ALL Workshop  "
printf "\033[91m[4]\033[0m Exit"
echo
echo
read -p " Choose [1-4]: " choice

case "$choice" in
    1)
        echo -e "\n[INFO] Downloading latest mods from GitHub..."
        curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL" 2>/dev/null || { echo "[ERROR] Download failed!"; read; exit 1; }

        echo "[INFO] Unzipping mods..."
        unzip -q "$ZIP_FILE" || { echo "[ERROR] Unzip failed!"; read; exit 1; }
        rm "$ZIP_FILE"

        echo "[INFO] Installing mods from BitRust-main..."
        if [[ -d "BitRust-main/mods" ]]; then
            cp -f BitRust-main/mods/* "$MOD_DIR/" 2>/dev/null
            echo "[OK] Mods installed from BitRust-main/mods"
        else
            echo "[WARNING] No mods folder. Copying all files..."
            cp -f BitRust-main/* "$MOD_DIR/" 2>/dev/null
        fi

        rm -rf BitRust-main

        clear
        echo "╔══════════════════════════════════════════╗"
        echo "║     INSTALL COMPLETE                     ║"
        echo "║  Latest mods downloaded & installed!     ║"
        echo "║  Restart $GAME to load mods!             ║"
        echo "╚══════════════════════════════════════════╝"
        read -p "Press Enter..."
        ;;
    2)
        xdg-open "$MOD_DIR" 2>/dev/null || open "$MOD_DIR" 2>/dev/null || echo "Path: $MOD_DIR"
        read -p "Press Enter..."
        ;;
    3)
        if [[ "$STEAM_STATUS" != "found" ]]; then
            echo "[ERROR] Steam Workshop not found!"
            read -p "Press Enter..."
            exit
        fi
        echo -e "\033[93m[WARNING] This will DELETE ALL Steam Workshop mods for ALL games!\033[0m"
        read -p " Continue? [y/N]: " ans
        [[ ! "$ans" =~ ^[Yy]$ ]] && exit

        STEAM_CONTENT_DIR=""
        [[ -d "$HOME/.local/share/Steam/steamapps/workshop/content" ]] && STEAM_CONTENT_DIR="$HOME/.local/share/Steam/steamapps/workshop/content"
        [[ -z "$STEAM_CONTENT_DIR" && -d "$HOME/.steam/steam/steamapps/workshop/content" ]] && STEAM_CONTENT_DIR="$HOME/.steam/steam/steamapps/workshop/content"
        [[ -z "$STEAM_CONTENT_DIR" && -d "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/workshop/content" ]] && STEAM_CONTENT_DIR="$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/workshop/content"

        echo "[INFO] Clearing ALL Workshop content..."
        rm -rf "$STEAM_CONTENT_DIR"/* 2>/dev/null
        mkdir -p "$STEAM_CONTENT_DIR"
        echo "[OK] All Workshop content cleared!"
        read -p "Press Enter..."
        ;;
    4)
        clear
        echo -e "\033[91m██████████████████████████████████████████████████████████████\033[0m"
        echo -e "\033[91m█░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█\033[0m"
        echo -e "\033[91m█░▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀█\033[0m"
        echo -e "\033[91m█░  Thanks for using $BRAND!  █\033[0m"
        echo -e "\033[91m█░▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀█\033[0m"
        echo -e "\033[91m█░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█\033[0m"
        echo
        echo -e "     \033[2mGoodbye!\033[0m"
        read -p "     Press Enter to exit..."
        clear
        exit
        ;;
    *) echo "Invalid." ; read ; exit ;;
esac