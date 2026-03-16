#!/bin/bash

convert_dir() {
  local SRC_DIR="$1"
  local DEST_DIR="$2"
  local QUALITY="$3"
  local RESIZE="$4"  # opcional: porcentaje de escala (ej: 30)

  find "$SRC_DIR" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) ! -name ".*" | while read -r file; do
    relative_path="${file#$SRC_DIR/}"
    output_dir="$DEST_DIR/$(dirname "$relative_path")"
    mkdir -p "$output_dir"
    output_file="$output_dir/$(basename "${relative_path%.*}.webp")"

    if [ ! -f "$output_file" ]; then
      echo "Convirtiendo: $file → $output_file"
      if [ -n "$RESIZE" ]; then
        orig_width=$(sips -g pixelWidth "$file" | awk '/pixelWidth/{print $2}')
        new_width=$(( orig_width * RESIZE / 100 ))
        cwebp -q "$QUALITY" -resize "$new_width" 0 "$file" -o "$output_file" >/dev/null 2>&1
      else
        cwebp -q "$QUALITY" "$file" -o "$output_file" >/dev/null 2>&1
      fi
    fi
  done
}

convert_dir "./full"          "./webp"                 80
convert_dir "./ilustraciones" "./webp/ilustraciones"   100
convert_dir "./ilustraciones" "./webp/ilustraciones_min" 50 30

echo "Conversión completada."

# Sincronizar con el servidor
SERVER_PATH="/Volumes/sdd/tcgMyL/images/webp"

if [ -d "$SERVER_PATH" ]; then
  echo "Sincronizando con el servidor..."
  rsync -av --update ./webp/ "$SERVER_PATH/"
  echo "Sincronización completada."
else
  echo "⚠️  Servidor no montado. Monta smb://RASPBERRYPI02._smb._tcp.local/sdd antes de sincronizar."
fi
