#!/bin/bash

# Archivo de entrada y salida
EMAILS_FILE="emails_extracted.txt"
TEMP_FILE="emails_temp.txt"

# Convertir todos los correos a minúsculas (sin eliminar duplicados)
awk '{print tolower($0)}' "$EMAILS_FILE" > "$TEMP_FILE"

# Reemplazar el archivo original con la versión en minúsculas
mv "$TEMP_FILE" "$EMAILS_FILE"

echo "✅ Todos los correos han sido convertidos a minúsculas en: $EMAILS_FILE"