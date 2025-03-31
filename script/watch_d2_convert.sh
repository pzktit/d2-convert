#!/bin/bash

CONTAINER_NAME="ghcr.io/pzktit/d2-convert"
declare -A file_mtimes
CONVERT_ARGS="$*"

# Funkcja: konwersja D2 → PNG (jeśli mtime się zmienił)
convert_d2_file() {
    local input="$1"
    local base=$(basename "$input" .d2)
    local output="${base}.png"
    local input_name=$(basename "$input")

    # Pobierz czas modyfikacji
    local mtime=$(stat -c %Y "$input")
    local previous_mtime="${file_mtimes[$input]}"

    # Pomijaj, jeśli nie było zmian czasu
    if [[ "$mtime" == "$previous_mtime" ]]; then
#         echo "⏭️  Pomijam: $input (mtime bez zmian)"
        return
    fi

    # Zapisz nowy mtime
    file_mtimes[$input]="$mtime"
    echo "🔁 Konwertuję: $input → $output"

    # Build the actual shell script to pass into the container's bash -c
    local container_script="
COLOR=\$(d2 \"$input_name\" - | rsvg-convert -f png - | convert png:- -format \"%[pixel:p{1,1}]\" info:-) && \
d2 \"$input_name\" - | rsvg-convert -f png - | convert png:- -transparent \"\$COLOR\" $CONVERT_ARGS \"$output\""

    docker run --rm \
        -u "$(id -u):$(id -g)" \
        -v "$PWD":/data \
        -w /data \
        "$CONTAINER_NAME" \
        bash -c "$container_script"

#     docker run --rm \
#         -u $(id -u):$(id -g) \
#         -v "$PWD":/data \
#         -w /data \
#         "$CONTAINER_NAME" \
#         bash -c '\
#             COLOR=$(d2 '"$input_name"' - | rsvg-convert -f png - | convert png:- -format "%[pixel:p{1,1}]" info:-) && \
#             d2 '"$input_name"' - | rsvg-convert -f png - | convert png:- -transparent "$COLOR" -trim +repage '"$output"
}

# Obserwuj tylko *.d2
echo "👀 Obserwuję *.d2 w katalogu: $(pwd)"
inotifywait -m -e modify,close_write --format "%w%f" . |
while read file; do
    if [[ "$file" == *.d2 && -f "$file" ]]; then
        convert_d2_file "$file"
    fi
done
