#!/bin/bash

# Ruta de la carpeta donde están las carpetas a renombrar
DIR="."

# Verificar que la carpeta exista
if [[ ! -d "$DIR" ]]; then
    echo "Error: La carpeta '$DIR' no existe."
    exit 1
fi

# Recorrer todas las carpetas dentro de balthvs
for folder in "$DIR"/*/; do
    # Quitar la última barra "/" al final del nombre
    folder=${folder%/}

    # Obtener solo el nombre de la carpeta (sin la ruta completa)
    folder_name=$(basename "$folder")

    # Extraer la parte antes del "_"
    new_name=$(echo "$folder_name" | cut -d'_' -f1)

    # Si el nuevo nombre es diferente, renombrar la carpeta
    if [[ "$folder_name" != "$new_name" ]]; then
        mv "$folder" "$DIR/$new_name"
        echo "Renombrado: $folder_name ➝ $new_name"
    fi
done

echo "✅ Proceso completado."