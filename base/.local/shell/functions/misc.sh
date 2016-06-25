# Urgent bell when task finishes
remind() {
    eval "$@"
    echo -en "\a"
}

remind-say() {
    remind "$@"
    say -- "Finished $@."
}

# Try to record all dependencies in their respective files
dump-leaves() {
    declare -A MANAGERS
    MANAGERS=(
        [brew]=~/.Brewfile
        [pip]=~/.pipfile
        [npm]=~/.npmfile
    )

    for m in "${!MANAGERS[@]}"; do
        echo "Dumping $m..."
        leaves="$(${m}-leaves 2>/dev/null)"
        [ "$leaves" ] && echo "$leaves" > "${MANAGERS[$m]}"
    done
}
