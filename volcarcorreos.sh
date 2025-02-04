#!/bin/bash

# Archivo de entrada y salida
EMAILS_FILE="emails_extracted.txt"  # Asegúrate de que el archivo de texto tenga un correo por línea
OUTPUT_CSV="emails.csv"

# Verificar si el archivo de entrada existe
if [[ ! -f "$EMAILS_FILE" ]]; then
    echo "❌ Error: El archivo $EMAILS_FILE no existe."
    exit 1
fi

# Crear el archivo CSV con encabezado
echo "Email" > "$OUTPUT_CSV"

# Leer cada línea del archivo y agregarla al CSV
while IFS= read -r email; do
    echo "$email" >> "$OUTPUT_CSV"
done < "$EMAILS_FILE"

echo "✅ Los correos han sido convertidos a CSV en: $OUTPUT_CSV"