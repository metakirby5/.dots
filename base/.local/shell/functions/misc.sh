#!/usr/bin/env bash

DEPS_DIR=~/.local/deps

# Try to dump all dependencies to their respective files
dump-leaves() {
    for dest in "$DEPS_DIR"/*; do
        local m="$(basename "$dest")"

        if which "$m" &>/dev/null ||\
                [ "$m" == "AppStore" -a "$(uname)" == "Darwin" ]; then
            echo "Dumping $m leaves to $dest..."
            local leaves="$(${m}-leaves 2>/dev/null)"
            [ "$leaves" ] && echo "$leaves" > "$dest" ||\
                echo "    ${m}-leaves FAILED!"

        else
            echo "$m not found, skipping..."
        fi
    done
}

# Try to install all dependencies to their respective files
install-leaves() {
    local NORM="\033[0m"
    local RED="\033[0;31m"
    local GREEN="\033[0;32m"
    local YELLOW="\033[0;33m"

    declare -A INSTALLERS
    INSTALLERS=(
        [AppStore]="cat <(echo 'Install the following...')"
        [brew]="brew bundle --file=-"
        [pip]="xargs pip install --upgrade"
        [npm]="xargs npm install -g"
    )

    for src in "$DEPS_DIR"/*; do
        echo
        local m="$(basename "$src")"
        local reqs="$(comm -23 "$src" <(${m}-leaves 2>/dev/null) \
            | sed 's/^/    /')"

        if which "$m" &>/dev/null ||\
                [ "$m" == "AppStore" -a "$(uname)" == "Darwin" ]; then
            if [ "$reqs" ]; then
                echo -e "${GREEN}Installing $m leaves with \`${INSTALLERS[$m]}\`...$NORM"
                eval echo "$reqs" | ${INSTALLERS[$m]}
            else
                echo -e "${GREEN}$m up to date!$NORM"
            fi
        else
            echo -e "${YELLOW}$m not found, skipping...${NORM}"
        fi
    done

}

# cd with smart ... handling
cd() {
    local num=0
    if [ -z "$(tr -d . <<< "$1")" ]; then
        num="$(wc -c <<< "$1")"
    fi

    if [ $num -gt 3 ]; then
        command cd "..$(printf '%0.s/..' $(seq 1 $(($num - 3))))"
    else
        command cd "$@"
    fi
}

# Touch with script shebang
touchx() {
    [ ! "$1" ] && return 1
    cat <<< "${2:-#!/usr/bin/env bash}" > "$1"
    chmod +x "$1"
}

# Shortcut to awk a field
field() {
    awk "{ print \$$1 }"
}

# Urgent bell when task finishes
remind() {
    eval "$@"
    echo -en "\a"
}

# Urgent bell + say when task finishes
remind-say() {
    remind "$@"
    say -- "Finished $@."
}
