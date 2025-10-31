#!/bin/bash
# =============================================
### Automatic Updates For BitRust Factions | Necesse
### BitRust Network - Click-to-Install Necesse Mods
### AUTO-DOWNLOADS & UNZIPS from the latest Repo
# =============================================

BRAND="BitRust Network"
GAME="Necesse"
VERSION="v1.0"
MOD_DIR="$HOME/.config/Necesse/mods"
DOWNLOAD_URL="https://github.com/enzonami/BitRust_Network_Factions/archive/refs/heads/main.zip"
ZIP_FILE="BitRust_Network_Factions-main.zip"

# ──────────────────────────────────────────────
# Detect Steam Workshop content paths
# ──────────────────────────────────────────────
find_steam_content() {
    local paths=(
        "$HOME/.local/share/Steam/steamapps/workshop/content"
        "$HOME/.steam/steam/steamapps/workshop/content"
        "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/workshop/content"
    )
    for path in "${paths[@]}"; do
        [[ -d "$path" ]] && echo "found" && return 0
    done
    echo "not found"
}

STEAM_STATUS="$(find_steam_content)"

# ──────────────────────────────────────────────
# UI: Banner
# ──────────────────────────────────────────────
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
echo -e " \033[91mBitRust Network - Necesse Mod Installer\033[0m"
echo
echo -e " \033[2mPress Enter to continue...\033[0m"
read -r

# ──────────────────────────────────────────────
# UI: Main Menu
# ──────────────────────────────────────────────
clear
echo -e "\033[91m██████████████████████████████████████████████████████████████\033[0m"
echo -e "\033[91m█░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█\033[0m"
echo -e "\033[91m█░▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀█\033[0m"
echo -e "\033[91m█░ $BRAND - $GAME Mod Installer █\033[0m"
echo -e "\033[91m█░▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀█\033[0m"
echo -e "\033[91m█░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█\033[0m"
echo
printf " Detected: \033[96mMod Folder\033[0m: found \033[96mWorkshop Cache (ALL GAMES)\033[0m: $STEAM_STATUS\n\n"
printf " Action: "
printf "\033[92m[1]\033[0m Install Mods "
printf "\033[96m[2]\033[0m Open Folder "
[[ "$STEAM_STATUS" == "found" ]] && printf "\033[93m[3]\033[0m Clear ALL Workshop "
printf "\033[91m[4]\033[0m Exit"
echo
echo
read -p " Choose [1-4]: " choice

# ──────────────────────────────────────────────
# Menu Logic
# ──────────────────────────────────────────────
case "$choice" in
    1)
        echo -e "\n[INFO] Downloading latest mods from GitHub..."
        curl -L -o "$ZIP_FILE" "$DOWNLOAD_URL" --fail --silent --show-error || {
            echo "[ERROR] Download failed! Check internet or URL."
            read -p "Press Enter..."
            exit 1
        }

        echo "[INFO] Unzipping archive..."
        unzip -q "$ZIP_FILE" || {
            echo "[ERROR] Unzip failed! Is 'unzip' installed?"
            read -p "Press Enter..."
            exit 1
        }
        rm -f "$ZIP_FILE"

        EXTRACTED_DIR="BitRust_Network_Factions-main"

        if [[ ! -d "$EXTRACTED_DIR" ]]; then
            echo "[ERROR] Expected folder '$EXTRACTED_DIR' not found after unzip!"
            ls -la
            read -p "Press Enter..."
            exit 1
        fi

        echo "[INFO] Scanning for .jar mods in '$EXTRACTED_DIR'..."

        mapfile -t JAR_FILES < <(find "$EXTRACTED_DIR" -maxdepth 1 -name "*.jar" -type f)

        if [[ ${#JAR_FILES[@]} -eq 0 ]]; then
            echo "[ERROR] No .jar files found in $EXTRACTED_DIR!"
            echo "[DEBUG] Top-level files:"
            ls -la "$EXTRACTED_DIR" | head -10
            rm -rf "$EXTRACTED_DIR"
            read -p "Press Enter..."
            exit 1
        fi

        mkdir -p "$MOD_DIR"

        MOD_COUNT=0
        TORCH_FOUND=false

        for jar in "${JAR_FILES[@]}"; do
            filename=$(basename "$jar")
            cp -f "$jar" "$MOD_DIR/"
            ((MOD_COUNT++))

            if [[ "$filename" == *"torch"* ]] || [[ "$filename" == *"Torch"* ]]; then
                TORCH_FOUND=true
            fi
        done

        echo "[OK] $MOD_COUNT mod(s) installed to '$MOD_DIR'"
        if $TORCH_FOUND; then
            echo "   ✓ torch mod FOUND and installed!"
        else
            echo "   ✗ torch mod NOT found in repo"
        fi

        rm -rf "$EXTRACTED_DIR"

        clear
        cat <<'EOF'
╔══════════════════════════════════════════╗
║           INSTALL COMPLETE               ║
║                                          ║
║  Latest mods downloaded & installed!     ║
║                                          ║
║     Restart Necesse to load mods!        ║
╚══════════════════════════════════════════╝
EOF
        read -p "Press Enter to continue..."
        ;;

    2)
        if command -v xdg-open >/dev/null 2>&1; then
            xdg-open "$MOD_DIR" 2>/dev/null || echo "Opened: $MOD_DIR"
        elif command -v open >/dev/null 2>&1; then
            open "$MOD_DIR" 2>/dev/null || echo "Opened: $MOD_DIR"
        else
            echo "Cannot open folder. Path: $MOD_DIR"
        fi
        read -p "Press Enter..."
        ;;

    3)
        if [[ "$STEAM_STATUS" != "found" ]]; then
            echo "[ERROR] Steam Workshop cache not detected!"
            read -p "Press Enter..."
            exit 1
        fi

        echo -e "\033[93m[WARNING] This will DELETE ALL Steam Workshop mods for ALL games!\033[0m"
        read -p " Continue? [y/N]: " ans
        [[ ! "$ans" =~ ^[Yy]$ ]] && echo "Aborted." && read -p "Press Enter..." && exit 0

        STEAM_CONTENT_DIR=""
        for dir in \
            "$HOME/.local/share/Steam/steamapps/workshop/content" \
            "$HOME/.steam/steam/steamapps/workshop/content" \
            "$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam/steamapps/workshop/content"; do
            [[ -d "$dir" ]] && STEAM_CONTENT_DIR="$dir" && break
        done

        echo "[INFO] Clearing Workshop cache at: $STEAM_CONTENT_DIR"
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
        echo -e "\033[91m█░ Thanks for using $BRAND! █\033[0m"
        echo -e "\033[91m█░▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀▄▀█\033[0m"
        echo -e "\033[91m█░▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓█\033[0m"
        echo
        echo -e " \033[2mGoodbye!\033[0m"
        read -p " Press Enter to exit..."
        clear
        exit 0
        ;;

    *)
        echo "Invalid choice."
        read -p "Press Enter..."
        exit 1
        ;;
esac