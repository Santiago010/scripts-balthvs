#!/bin/bash

# Array con los nombres de los archivos CSV a unificar
FILES=("emails_bandsintown.csv" "emails_mixto.csv" "emails_mailchimp1.csv" "emails_mailchimp2.csv" "emails_mailchimp3.csv" "emails_instagram.csv" "emails_bandcamp.csv" "emails-brevo.csv")

# Archivo de salida
OUTPUT_CSV="all-emails-with-origin.csv"

# Verificar que al menos un archivo existe
FOUND=0
for FILE in "${FILES[@]}"; do
    if [[ -f "$FILE" ]]; then
        FOUND=1
        break
    fi
done

if [[ $FOUND -eq 0 ]]; then
    echo "❌ Error: Ninguno de los archivos especificados existe."
    exit 1
fi

# Crear el archivo de salida con encabezados
echo "Email,Origen" > "$OUTPUT_CSV"

# Unir archivos, eliminando encabezados duplicados
for FILE in "${FILES[@]}"; do
    if [[ -f "$FILE" ]]; then
        echo "📂 Procesando: $FILE"
        tail -n +2 "$FILE" | sed 's/^[ \t]*//;s/[ \t]*$//' >> "temp_all_emails.csv"  # Quitar espacios extra
    fi
done

# Ordenar y eliminar líneas en blanco
sort -u "temp_all_emails.csv" | awk -F',' 'NF==2' > "$OUTPUT_CSV"

# Eliminar archivo temporal
rm "temp_all_emails.csv"

echo "✅ Archivos unificados correctamente en: $OUTPUT_CSV"