declare -A MANAGERS
MANAGERS=(
    [brew]=~/.Brewfile
    [pip]=~/.pipfile
    [npm]=~/.npmfile
)

# Try to record all dependencies in their respective files
dump-leaves() {
    for m in "${!MANAGERS[@]}"; do
        if which "$m" &>/dev/null; then
            echo "Dumping $m leaves to ${MANAGERS[$m]}..."
            local leaves="$(${m}-leaves 2>/dev/null)"
            [ "$leaves" ] && echo "$leaves" > "${MANAGERS[$m]}" ||\
                echo "    ${m}-leaves FAILED!"
        else
            echo "$m not found, skipping..."
        fi
    done

    # Specially handle OSX App Store
    if [ "$(uname)" == "Darwin" ]; then
        echo "Dumping App Store leaves to ~/.appstorefile..."
        appstore-leaves > ~/.appstorefile
    else
        echo "App Store not found, skipping..."
    fi
}

# Try to install all dependencies in their respective files
install-leaves() {
    local NORM="\033[0m"
    local RED="\033[0;31m"
    local GREEN="\033[0;32m"
    local YELLOW="\033[0;33m"

    declare -A INSTALLERS
    INSTALLERS=(
        [brew]="brew bundle --global"
        [pip]="xargs pip install --upgrade < ${MANAGERS[pip]}"
        [npm]="xargs npm install -g < ${MANAGERS[npm]}"
    )

    for m in "${!INSTALLERS[@]}"; do
        echo
        if which "$m" &>/dev/null; then
            if [ -f "${MANAGERS[$m]}" ]; then
                echo -e "${GREEN}\
Installing $m leaves with \`${INSTALLERS[$m]}\`...$NORM"
                eval ${INSTALLERS[$m]}
            else
                echo -e "${RED}\
Leaf file ${MANAGERS[$m]} not found, skipping...${NORM}"
            fi
        else
            echo -e "${YELLOW}$m not found, skipping...${NORM}"
        fi
    done

    # Specially handle OSX App Store
    if [ "$(uname)" == "Darwin" ]; then
        echo
        local reqs="$(comm -23 ~/.appstorefile <(appstore-leaves) |\
            sed 's/^/    /')"
        if [ "$reqs" ]; then
            echo -e "${YELLOW}For App Store, install the following:${NORM}"
            echo "$reqs"
        else
            echo -e "${GREEN}App Store up to date!${NORM}"
        fi
    else
        echo "${YELLOW}App Store not found, skipping${NORM}..."
    fi
}

# Urgent bell when task finishes
remind() {
    eval "$@"
    echo -en "\a"
}

remind-say() {
    remind "$@"
    say -- "Finished $@."
}
