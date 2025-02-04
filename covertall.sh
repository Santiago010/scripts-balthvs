#!/bin/bash

# Verificar si jq está instalado
if ! command -v jq &> /dev/null
then
    echo "Error: jq no está instalado. Instálalo con: sudo apt install jq"
    exit 1
fi

# Buscar y procesar cada message_1.json en subcarpetas
find . -type f -name "message_1.json" | while read -r JSON_FILE
do
    TEMP_FILE="${JSON_FILE}_temp"

    echo "🔄 Procesando: $JSON_FILE"

    # Modificar el JSON
    jq ' 
    .messages |= map(
        .content |= ( 
            @text | 
            gsub("â"; "’") | 
            gsub("â"; "“") | 
            gsub("â"; "”") | 
            gsub("â"; "–") | 
            gsub("Ã³"; "ó") | 
            gsub("Ã©"; "é") | 
            gsub("Ã¡"; "á") | 
            gsub("Ã±"; "ñ") | 
            gsub("Ãº"; "ú") | 
            gsub("Ã­"; "í")
        ) |
        .timestamp_ms |= ( 
            tostring | 
            tonumber / 1000 | 
            strftime("%Y-%m-%d %H:%M:%S") 
        )
    )' "$JSON_FILE" > "$TEMP_FILE"

    # Reemplazar el archivo original con el modificado
    mv "$TEMP_FILE" "$JSON_FILE"

    echo "✅ Archivo actualizado correctamente: $JSON_FILE"

done

echo "🚀 Todos los archivos han sido procesados correctamente."