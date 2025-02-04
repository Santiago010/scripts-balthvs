#!/bin/bash

# Archivo CSV de entrada
CSV_FILE="cleaned.csv"  # Asegúrate de que el archivo esté en el mismo directorio

# Nombre de la columna que contiene los correos electrónicos
COLUMN_NAME="Email Address"

# Archivo de salida
OUTPUT_FILE="output.txt"

# Verificar si el archivo CSV existe
if [[ ! -f "$CSV_FILE" ]]; then
    echo "❌ Error: El archivo $CSV_FILE no existe."
    exit 1
fi

# Detectar el delimitador correcto (',' o ';')
DELIMITER=$(head -n 1 "$CSV_FILE" | grep -q ";" && echo ";" || echo ",")

# Extraer la columna y guardar en el archivo de texto
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
        gsub(/^[ \t"]+|[ \t"]+$/, "", $col_index)  # Eliminar comillas y espacios en los valores
        print $col_index
    }
' "$CSV_FILE" > "$OUTPUT_FILE"

echo "✅ Los emails han sido guardados en: $OUTPUT_FILE"