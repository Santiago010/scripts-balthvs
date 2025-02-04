#!/bin/bash

# Archivo donde guardaremos los correos extraídos
EMAILS_FILE="emails_extracted.txt"

# Limpiar archivo previo para no duplicar correos
> "$EMAILS_FILE"

# Buscar y procesar archivos message_1.json y processed_message_1.json
find . -type f \( -name "message_1.json" -o -name "processed_message_1.json" \) | while read -r JSON_FILE
do
    echo "🔍 Analizando: $JSON_FILE"

    # Extraer y buscar emails en los campos "content"
    jq -r '.messages[].content' "$JSON_FILE" 2>/dev/null | grep -E -o '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b' >> "$EMAILS_FILE"
done

# Eliminar duplicados y ordenar
sort -u -o "$EMAILS_FILE" "$EMAILS_FILE"

echo "✅ Emails extraídos y guardados en: $EMAILS_FILE"