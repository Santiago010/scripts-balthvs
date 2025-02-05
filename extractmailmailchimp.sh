#!/bin/bash

# Archivo CSV de entrada
CSV_FILE="cleaned.csv"  # Asegúrate de que el archivo esté en el mismo directorio

# Nombre de la columna que contiene los correos electrónicos
COLUMN_NAME="Email Address"

# Archivos de salida
OUTPUT_TXT="output.txt"
OUTPUT_CSV="emails_mailchimp.csv"

# Verificar si el archivo CSV existe
if [[ ! -f "$CSV_FILE" ]]; then
    echo "❌ Error: El archivo $CSV_FILE no existe."
    exit 1
fi

# Detectar el delimitador correcto (',' o ';')
DELIMITER=$(head -n 1 "$CSV_FILE" | grep -q ";" && echo ";" || echo ",")

# Crear el archivo CSV con encabezados
echo "Email,Origen" > "$OUTPUT_CSV"

# Extraer la columna y procesar los datos
awk -F"$DELIMITER" -v col="$COLUMN_NAME" '
    BEGIN { col_index = -1 }
    NR==1 {
        for (i=1; i<=NF; i++) {
            gsub(/^[ \t"]+|[ \t"]+$/, "", $i)  # Eliminar comillas y espacios
            if ($i == col) col_index=i
        }
        if (col_index == -1) {
            print "❌ Error: No se encontró la columna " col " en el archivo CSV."
            exit 1
        }
    }
    NR>1 && col_index != -1 {
        gsub(/^[ \t"]+|[ \t"]+$/, "", $col_index)  # Limpiar espacios y comillas
        print $col_index > "'"$OUTPUT_TXT"'"  # Guardar en el archivo de texto
        print $col_index ",Mailchimp"  # Guardar en el CSV
    }
' "$CSV_FILE" >> "$OUTPUT_CSV"

echo "✅ Los emails han sido guardados en: $OUTPUT_TXT"
echo "✅ El archivo CSV con origen 'Mailchimp' ha sido generado: $OUTPUT_CSV"