#!/bin/bash

BERRYPKG_DIR="$HOME/.berrypkg"
BERRYPKG_JAR="$BERRYPKG_DIR/berrypkg.jar"
BERRYPKG_SCRIPTS_DIR="$BERRYPKG_DIR/scripts"
START_SCRIPT="$BERRYPKG_SCRIPTS_DIR/berrypkg"
GITHUB_URL="https://github.com/nozyx12/BerryPKG/releases/download/v1.0/berrypkg-1.0.jar"

GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[0;33m"
NC="\033[0m"

check_java() {
    if ! command -v java &>/dev/null; then
        echo -e "${RED}Java is not installed. Install Java 8 or higher and retry.${NC}"
        exit 1
    fi
}

install_berrypkg() {
    echo -e "${GREEN}Installing BerryPKG ...${NC}"

    check_java

    mkdir -p "$BERRYPKG_DIR" "$BERRYPKG_SCRIPTS_DIR" "$BIN_DIR"

    echo -e "${YELLOW}Downloading BerryPKG v1.0 from GitHub...${NC}"
    curl -L -o "$BERRYPKG_JAR" "$GITHUB_URL"
    if [[ $? -ne 0 ]]; then
        echo -e "${RED}BerryPKG download failed.${NC}"
        exit 1
    fi

    echo -e "${YELLOW}Creating starting script ...${NC}"
    cat <<EOF >"$START_SCRIPT"
#!/bin/bash
if ! command -v java &>/dev/null; then
    echo "Java is not installed. Install Java 8 or higher and retry."
    exit 1
fi
java -jar "$BERRYPKG_JAR" "\$@"
EOF
    chmod +x "$START_SCRIPT"

    if ! grep -q "export PATH=\$PATH:$BERRYPKG_SCRIPTS_DIR" "$HOME/.bashrc"; then
        echo "export PATH=\$PATH:$BERRYPKG_SCRIPTS_DIR" >>"$HOME/.bashrc"
        echo -e "${YELLOW}Adding '$BERRYPKG_SCRIPTS_DIR' to the PATH environment variable.${NC}"
    fi

    echo -e "${GREEN}BerryPKG installation completed successfully !${NC}"
    echo -e "${GREEN}Restart your shell to apply changes.${NC}"
}

uninstall_berrypkg() {
    read -p "Do you really want to uninstall BerryPKG ? (Y/n): " confirm
    if [[ "$confirm" =~ ^[yY](es)?$ ]]; then
        echo -e "${YELLOW}Uninstalling BerryPKG ...${NC}"
        rm -rf "$BERRYPKG_DIR"
        rm -f "$START_SCRIPT"

        sed -i '/export PATH=\$PATH:.*\.berrypkg\/scripts/d' "$HOME/.bashrc"

        echo -e "${GREEN}BerryPKG uninstallation completed successfully !${NC}"
    else
        echo -e "${RED}Uninstallation canceled.${NC}"
    fi
}

show_menu() {
    echo "=== BerryPKG v1.0 | Installer ==="
    echo "1. Install BerryPKG"
    echo "2. Uninstall BerryPKG"
    echo "3. Exit"
    read -p "Choose an option: " choice
    case $choice in
    1) install_berrypkg ;;
    2) uninstall_berrypkg ;;
    3) exit 0 ;;
    *) echo -e "${RED}Invalid option.${NC}" ;;
    esac
}

show_menu
