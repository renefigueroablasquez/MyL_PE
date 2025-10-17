#!/bin/bash

# Carpeta origen (donde están las imágenes PNG)
SRC_DIR="./full"

# Carpeta destino (donde se guardarán los WEBP)
DEST_DIR="./webp"

# Calidad de conversión (0-100)
QUALITY=80

# Recorre todos los archivos .png dentro de full y subcarpetas
find "$SRC_DIR" -type f -name "*.png" ! -name ".*" | while read -r file; do
  # Ruta relativa desde SRC_DIR
  relative_path="${file#$SRC_DIR/}"

  # Carpeta donde se guardará el nuevo archivo webp
  output_dir="$DEST_DIR/$(dirname "$relative_path")"
  mkdir -p "$output_dir"

  # Nombre de salida con extensión .webp
  output_file="$output_dir/$(basename "${relative_path%.png}.webp")"

  # Solo convertir si el archivo no existe
  if [ ! -f "$output_file" ]; then
    echo "Convirtiendo: $file → $output_file"
    cwebp -q "$QUALITY" "$file" -o "$output_file" >/dev/null 2>&1
  else
    echo "Ya existe: $output_file, se omite"
  fi
done

echo "Conversión completada."
