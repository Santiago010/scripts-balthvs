#!/bin/bash

# Archivo CSV de entrada
CSV_FILE="maillist.csv"  # Asegúrate de que el archivo esté en el mismo directorio

# Nombre de la columna que contiene los correos electrónicos
COLUMN_NAME="email"

# Archivo de salida
OUTPUT_FILE="output.txt"

# Verificar si el archivo CSV existe
if [[ ! -f "$CSV_FILE" ]]; then
    echo "❌ Error: El archivo $CSV_FILE no existe."
    exit 1
fi

# Extraer la columna y guardar en el archivo de texto
awk -F',' -v col="$COLUMN_NAME" '
    NR==1 {
        for (i=1; i<=NF; i++) {
            if ($i == col) column=i
        }
        if (!column) {
            print "❌ Error: No se encontró la columna " col " en el archivo CSV."
            exit 1
        }
    }
    NR>1 && column {
        print $column
    }
' "$CSV_FILE" > "$OUTPUT_FILE"

echo "✅ Los emails han sido guardados en: $OUTPUT_FILE"