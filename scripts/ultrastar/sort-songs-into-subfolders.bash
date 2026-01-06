cd /home/chrisleebear/data/songs

# Loop through folders again
for folder in *; do
    # SKIP if not a directory
    [ ! -d "$folder" ] && continue

    # SKIP existing category folders (A-Z, 0-9)
    if [[ "$folder" =~ ^[A-Z]$ ]] || [[ "$folder" == "0-9" ]]; then
        continue
    fi

    # Determine Destination (A, B, or 0-9)
    first_char=$(echo "${folder:0:1}" | tr '[:lower:]' '[:upper:]')
    
    dest=""
    if [[ "$first_char" =~ [0-9] ]]; then
        dest="0-9"
    elif [[ "$first_char" =~ [A-Z] ]]; then
        dest="$first_char"
    else
        echo "Skipping '$folder' (starts with symbol)"
        continue
    fi

    # Ensure destination parent folder exists
    mkdir -p "$dest"

    echo "Merging '$folder' into '$dest/$folder'..."

    # 1. Use RSYNC to merge contents (avoids "Directory not empty" error)
    # This moves files from the root folder into the subfolder
    rsync -a --remove-source-files "$folder/" "$dest/$folder/"

    # 2. Remove the now-empty source folder
    # (rsync moves the files but leaves the empty dir behind)
    rm -d "$folder" 2>/dev/null
done

echo "Done! All folders merged and organized."