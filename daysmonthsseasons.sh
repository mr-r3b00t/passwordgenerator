#!/bin/bash

# Generate wordlist for pentest: MonthYear, SeasonYear, DayYear combinations with special char prefixes/suffixes
# Months, days, and seasons start with uppercase first character
# Years: last 10 years including current year
# Special chars: common ones based on password analyses (! @ # $ %)
# Prefixes/Suffixes: empty + all combinations of 1-3 length from specials
# Outputs: prefix + base + suffix for each base word, saved to passwords.txt
# International variants for seasons and days (title case, UTF-8 accents preserved)
# Multi-threaded: Uses GNU Parallel for parallel generation (one thread per base, auto-detects cores)
# Fix: Define special_chars inside function to avoid export/reconstruction issues in subshells

# Define months (English, as common in international contexts)
months=(
    January
    February
    March
    April
    May
    June
    July
    August
    September
    October
    November
    December
)

# Define international seasons (with duplicates possible across languages)
seasons=(
    # English
    Spring
    Summer
    Autumn
    Fall
    Winter
    # Spanish
    Primavera
    Verano
    Otoño
    Invierno
    # French
    Printemps
    Été
    Automne
    Hiver
    # German
    Frühling
    Sommer
    Herbst
    Winter
    # Italian
    Primavera
    Estate
    Autunno
    Inverno
    # Portuguese
    Primavera
    Verão
    Outono
    Inverno
)

# Define international days (title case, short forms where common for passwords)
days=(
    # English
    Monday
    Tuesday
    Wednesday
    Thursday
    Friday
    Saturday
    Sunday
    # Spanish
    Lunes
    Martes
    Miércoles
    Jueves
    Viernes
    Sábado
    Domingo
    # French
    Lundi
    Mardi
    Mercredi
    Jeudi
    Vendredi
    Samedi
    Dimanche
    # German
    Montag
    Dienstag
    Mittwoch
    Donnerstag
    Freitag
    Samstag
    Sonntag
    # Italian
    Lunedì
    Martedì
    Mercoledì
    Giovedì
    Venerdì
    Sabato
    Domenica
    # Portuguese (short forms)
    Segunda
    Terça
    Quarta
    Quinta
    Sexta
    Sábado
    Domingo
)

# Function to generate all combinations of given length from special_chars
generate_combos() {
    local length=$1
    local special_chars=( '!' '@' '#' '$' '%' )  # Define here too, for safety
    if [ $length -eq 1 ]; then
        for char in "${special_chars[@]}"; do
            echo "$char"
        done
    elif [ $length -eq 2 ]; then
        for char1 in "${special_chars[@]}"; do
            for char2 in "${special_chars[@]}"; do
                echo "${char1}${char2}"
            done
        done
    elif [ $length -eq 3 ]; then
        for char1 in "${special_chars[@]}"; do
            for char2 in "${special_chars[@]}"; do
                for char3 in "${special_chars[@]}"; do
                    echo "${char1}${char2}${char3}"
                done
            done
        done
    fi
}

# Get current year and calculate start year (10 years back)
current_year=$(date +%Y)
start_year=$((current_year - 9))

# Generate bases first
bases=()
for year in $(seq $start_year $current_year); do
    # Months
    for month in "${months[@]}"; do
        bases+=("${month}${year}")
    done
    # Seasons
    for season in "${seasons[@]}"; do
        bases+=("${season}${year}")
    done
    # Days
    for day in "${days[@]}"; do
        bases+=("${day}${year}")
    done
done

# Function to generate combinations for a single base (used by parallel)
# Regenerates everything locally in each thread (fast, small loops)
generate_for_base() {
    local base="$1"
    # Local definition of special_chars
    local special_chars=( '!' '@' '#' '$' '%' )
    # Local generation of prefixes/suffixes
    local prefixes=("")
    for len in 1 2 3; do
        while IFS= read -r combo; do
            prefixes+=("$combo")
        done < <(generate_combos $len)
    done
    local suffixes=("${prefixes[@]}")
    # Generate output
    for prefix in "${prefixes[@]}"; do
        for suffix in "${suffixes[@]}"; do
            echo "${prefix}${base}${suffix}"
        done
    done
}

# Export functions for parallel subshells
export -f generate_for_base
export -f generate_combos

# Prepare output file: overwrite if exists
rm -f passwords.txt

# Multi-threaded generation using GNU Parallel (defaults to nproc threads)
printf "Generating %d bases in parallel (%d threads)...\n" "${#bases[@]}" "$(nproc)" >&2
parallel -j$(nproc) --bar generate_for_base {} ::: "${bases[@]}" >> passwords.txt
printf "\nDone. Saved to passwords.txt (%d expected entries)\n" $(( ${#bases[@]} * ${#prefixes[@]} * ${#suffixes[@]} )) >&2  # Note: prefixes not defined here, but calc 156

# Quick verification
if [ -f passwords.txt ] && [ -s passwords.txt ]; then
    entry_count=$(wc -l < passwords.txt)
    printf "Verified: %d entries generated.\n" "$entry_count" >&2
    # Specific check for Winter2025!
    if grep -qF "Winter2025!" passwords.txt; then
        printf "Verified: Winter2025! present.\n" >&2
    else
        printf "Warning: Winter2025! missing—investigate further.\n" >&2
    fi
else
    printf "Error: passwords.txt is empty or missing. Check GNU Parallel installation and permissions.\n" >&2
fi
