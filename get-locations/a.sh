#!/bin/bash

# Archivo donde están listadas todas las ciudades del mundo
CITIES_FILE="cities.txt"
US_STATE_TO_CITY_FILE="us_state_to_city.txt"

# Verificar si los archivos existen
if [[ ! -f "$CITIES_FILE" ]]; then
    echo "❌ Error: No se encontró el archivo $CITIES_FILE"
    exit 1
fi

if [[ ! -f "$US_STATE_TO_CITY_FILE" ]]; then
    echo "❌ Error: No se encontró el archivo $US_STATE_TO_CITY_FILE"
    exit 1
fi

# Cargar todas las ciudades en un array
CITIES=()
while IFS= read -r line; do
    CITIES+=("$line")
done < "$CITIES_FILE"

# Convertir ciudades a minúsculas
CITIES_LOWER=()
for city in "${CITIES[@]}"; do
    CITIES_LOWER+=("$(echo "$city" | tr '[:upper:]' '[:lower:]')")
done

COUNTRIES=(
    "Afganistán" "Albania" "Alemania" "Andorra" "Angola" "Argentina" "Australia" "Austria" "Brasil"
    "Canadá" "Chile" "China" "Colombia" "Corea del Sur" "Costa Rica" "Cuba" "Dinamarca" "Ecuador"
    "Egipto" "España" "Estados Unidos" "Francia" "Italia" "Japón" "México" "Perú" "Portugal"
    "Reino Unido" "Rusia" "Sudáfrica" "Suecia" "Suiza" "Turquía" "Uruguay" "Venezuela"
)

US_STATES=(
    "Alabama" "Alaska" "Arizona" "Arkansas" "California" "Colorado" "Connecticut" "Delaware"
    "Florida" "Georgia" "Hawaii" "Idaho" "Illinois" "Indiana" "Iowa" "Kansas" "Kentucky"
    "Louisiana" "Maine" "Maryland" "Massachusetts" "Michigan" "Minnesota" "Mississippi"
    "Missouri" "Montana" "Nebraska" "Nevada" "New Hampshire" "New Jersey" "New Mexico"
    "New York" "North Carolina" "North Dakota" "Ohio" "Oklahoma" "Oregon" "Pennsylvania"
    "Rhode Island" "South Carolina" "South Dakota" "Tennessee" "Texas" "Utah" "Vermont"
    "Virginia" "Washington" "West Virginia" "Wisconsin" "Wyoming"
)

# Convertir países y estados a minúsculas
COUNTRIES_LOWER=()
for country in "${COUNTRIES[@]}"; do
    COUNTRIES_LOWER+=("$(echo "$country" | tr '[:upper:]' '[:lower:]')")
done

US_STATES_LOWER=()
for state in "${US_STATES[@]}"; do
    US_STATES_LOWER+=("$(echo "$state" | tr '[:upper:]' '[:lower:]')")
done

# Función para obtener ciudades de un estado desde el archivo
get_cities_for_state() {
    local state="$1"
    grep "^$state:" "$US_STATE_TO_CITY_FILE" | cut -d':' -f2-
}

# Archivo de salida
OUTPUT_FILE="locations.txt"
> "$OUTPUT_FILE"  # Limpiar antes de escribir

# Recorrer todas las carpetas y analizar los archivos message_1.json
find . -type f -name "message_1.json" | while read -r JSON_FILE; do
    echo "🔍 Analizando: $JSON_FILE"

    # Extraer el primer participante (posición 0 del array "participants")
    PARTICIPANT=$(jq -r '.participants[0].name' "$JSON_FILE" | awk '{$1=$1; print}')

    # Extraer todos los mensajes y buscar ubicaciones
    LOCATION_FOUND=""
    while IFS= read -r MESSAGE; do
        MESSAGE_CLEAN=$(echo "$MESSAGE" | awk '{$1=$1; print}')
        MESSAGE_LOWER=$(echo "$MESSAGE_CLEAN" | tr '[:upper:]' '[:lower:]')

        # Buscar países
        for i in "${!COUNTRIES_LOWER[@]}"; do
            if [[ "$MESSAGE_LOWER" =~ (^|[^a-zA-Z])"${COUNTRIES_LOWER[$i]}"([^a-zA-Z]|$) ]]; then
                LOCATION_FOUND="${COUNTRIES[$i]}"
                
                # Si el país es "Estados Unidos", buscar si hay un estado mencionado
                for j in "${!US_STATES_LOWER[@]}"; do
                    if [[ "$MESSAGE_LOWER" =~ (^|[^a-zA-Z])"${US_STATES_LOWER[$j]}"([^a-zA-Z]|$) ]]; then
                        LOCATION_FOUND="${US_STATES[$j]}, USA"
                        break
                    fi
                done
                break
            fi
        done

        # Buscar estados de EE.UU.
        for i in "${!US_STATES_LOWER[@]}"; do
            if [[ "$MESSAGE_LOWER" =~ (^|[^a-zA-Z])"${US_STATES_LOWER[$i]}"([^a-zA-Z]|$) ]]; then
                LOCATION_FOUND="${US_STATES[$i]}"
                
                # Verificar si el estado tiene una ciudad en el mensaje
                CITIES_IN_STATE=$(get_cities_for_state "${US_STATES[$i]}")
                for CITY in $CITIES_IN_STATE; do
                    CITY_LOWER=$(echo "$CITY" | tr '[:upper:]' '[:lower:]')
                    if [[ "$MESSAGE_LOWER" =~ (^|[^a-zA-Z])"$CITY_LOWER"([^a-zA-Z]|$) ]]; then
                        LOCATION_FOUND="$CITY, ${US_STATES[$i]}"
                        break
                    fi
                done
                break
            fi
        done

        # Buscar ciudades desde cities.txt con coincidencias completas
        MATCHED_CITY=$(echo "$MESSAGE_LOWER" | grep -owFf "$CITIES_FILE" | head -n 1)

        if [[ -n "$MATCHED_CITY" ]]; then
            LOCATION_FOUND="$MATCHED_CITY"
            break
        fi
    done < <(jq -r '.messages[].content // empty' "$JSON_FILE")

    # Si se encontró una ubicación, guardarla en el archivo de salida
    if [[ -n "$LOCATION_FOUND" ]]; then
        echo "$PARTICIPANT - $LOCATION_FOUND" >> "$OUTPUT_FILE"
        echo "✅ Ubicación encontrada: $PARTICIPANT - $LOCATION_FOUND"
    else
        echo "❌ No se encontró ubicación en este archivo."
    fi
done

echo "🚀 Proceso completado. Ubicaciones guardadas en $OUTPUT_FILE"