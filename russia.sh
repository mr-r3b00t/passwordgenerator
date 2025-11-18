#!/bin/bash

# Generate expanded Russia location wordlist for pentest: CountryYear, RegionYear (federal subjects), CityYear, TownYear
# Expanded to include comprehensive lists: 1 country, ~89 regions (federal subjects), ~100 cities, ~100 towns
# Locations start with uppercase first character (English transliteration)
# Years: last 10 years including current year
# Special chars: common ones based on password analyses (! @ # $ %)
# Prefixes/Suffixes: empty + all combinations of 1-3 length from specials
# Outputs: prefix + base + suffix for each base word, saved to russia_passwords.txt
# Sources: Wikipedia (federal subjects), WorldPopulationReview (cities/towns by pop)
# Multi-threaded: Uses GNU Parallel for parallel generation (one thread per base, auto-detects cores)
# Note: Boroughs omitted due to thousands of districts; focus on major locations. Duplicates possible (e.g., Moscow as region & city)

# Define Russia country
countries=(
    Russia
)

# Expanded regions/federal subjects (~89 from Wikipedia)
regions=(
    "Republic of Adygea"
    "Republic of Bashkortostan"
    "Republic of Buryatia"
    "Republic of Altai"
    "Republic of Dagestan"
    "Republic of Ingushetia"
    "Republic of Kabardino-Balkaria"
    "Republic of Kalmykia"
    "Republic of Karachay-Cherkessia"
    "Republic of Karelia"
    "Komi Republic"
    "Republic of Mari El"
    "Republic of Mordovia"
    "Sakha Republic"
    "Republic of North Ossetia–Alania"
    "Republic of Tatarstan"
    "Republic of Tuva"
    "Udmurt Republic"
    "Republic of Khakassia"
    "Chechen Republic"
    "Chuvash Republic"
    "Altai Krai"
    "Krasnodar Krai"
    "Krasnoyarsk Krai"
    "Primorsky Krai"
    "Stavropol Krai"
    "Khabarovsk Krai"
    "Amur Oblast"
    "Arkhangelsk Oblast"
    "Astrakhan Oblast"
    "Belgorod Oblast"
    "Bryansk Oblast"
    "Vladimir Oblast"
    "Volgograd Oblast"
    "Vologda Oblast"
    "Voronezh Oblast"
    "Ivanovo Oblast"
    "Irkutsk Oblast"
    "Kaliningrad Oblast"
    "Kaluga Oblast"
    "Kamchatka Krai"
    "Kemerovo Oblast"
    "Kirov Oblast"
    "Kostroma Oblast"
    "Kurgan Oblast"
    "Kursk Oblast"
    "Leningrad Oblast"
    "Lipetsk Oblast"
    "Magadan Oblast"
    "Moscow Oblast"
    "Murmansk Oblast"
    "Nizhny Novgorod Oblast"
    "Novgorod Oblast"
    "Novosibirsk Oblast"
    "Omsk Oblast"
    "Orenburg Oblast"
    "Oryol Oblast"
    "Penza Oblast"
    "Perm Krai"
    "Pskov Oblast"
    "Rostov Oblast"
    "Ryazan Oblast"
    "Samara Oblast"
    "Saratov Oblast"
    "Sakhalin Oblast"
    "Sverdlovsk Oblast"
    "Smolensk Oblast"
    "Tambov Oblast"
    "Tver Oblast"
    "Tomsk Oblast"
    "Tula Oblast"
    "Tyumen Oblast"
    "Ulyanovsk Oblast"
    "Chelyabinsk Oblast"
    "Zabaykalsky Krai"
    "Yaroslavl Oblast"
    Moscow
    "Saint Petersburg"
    "Jewish Autonomous Oblast"
    "Nenets Autonomous Okrug"
    "Khanty-Mansi Autonomous Okrug"
    "Chukotka Autonomous Okrug"
    "Yamalo-Nenets Autonomous Okrug"
    "Republic of Crimea"
    Sevastopol
    "Donetsk People's Republic"
    "Luhansk People's Republic"
    "Zaporozhye Oblast"
    "Kherson Oblast"
)

# Top ~100 cities (largest from population data)
cities=(
    Moscow
    "Saint Petersburg"
    Novosibirsk
    Yekaterinburg
    Kazan
    "Nizhniy Novgorod"
    Chelyabinsk
    Omsk
    Krasnoyarsk
    Samara
    Ufa
    Voronezh
    Perm
    "Rostov-na-Donu"
    Krasnodar
    Volgograd
    Tyumen
    Saratov
    Tol"yatti
    Izhevsk
    Irkutsk
    Khabarovsk
    Barnaul
    Ulyanovsk
    Yaroslavl
    Tomsk
    Vladivostok
    Makhachkala
    "Khabarovsk Vtoroy"
    Kemerovo
    Orenburg
    Balashikha
    Novokuznetsk
    Astrakhan
    Penza
    Kirov
    Ryazan"
    Cheboksary
    "Naberezhnyye Chelny"
    Kaliningrad
    Sochi
    Kursk
    Tula
    "Ulan-Ude"
    Tver
    Magnitogorsk
    Belgorod
    Surgut
    Ivanovo
    Bryansk
    Chita
    Stavropol"
    Vladimir
    "Arkhangel'sk"
    Kaluga
    "Nizhny Tagil"
    Podolsk
    Yakutsk
    Smolensk
    Saransk
    Cherepovets
    Vologda
    Orel
    Murmansk
    Kurgan
    Vladikavkaz
    Tambov
    Sterlitamak
    Nal"chik
    Kostroma
    "Komsomolsk-on-Amur"
    Petrozavodsk
    Taganrog
    Nizhnevartovsk
    "Yoshkar-Ola"
    Bratsk
    Novorossiysk
    Dzerzhinsk
    Shakhty
    Orsk
    Syktyvkar
    Nizhnekamsk
    Angarsk
    "Staryy Oskol"
    Groznyy
    Prokop"yevsk
    Zelenograd
    "Velikiy Novgorod"
    Blagoveshchensk
    Biysk
    Khimki
    Pskov
    Rybinsk
    Balakovo
    Severodvinsk
    Syzran"
    Armavir
    Korolyov
    "Yuzhno-Sakhalinsk"
    "Petropavlovsk-Kamchatsky"
    Norilsk
    Zlatoust
    Mytishchi
    Lyubertsy
    Volgodonsk
    Novocherkassk
    Abakan
    Nazran"
    Nakhodka
    Ussuriysk
)

# Next ~100 towns (mid-sized from population data)
towns=(
    Berezniki
    Salavat
    Miass
    Rubtsovsk
    Kovrov
    Kolomna
    Maykop
    Pyatigorsk
    Kamyshin
    Derbent
    Nevinnomyssk
    Krasnogorsk
    Murom
    Bataysk
    "Sergiyev Posad"
    Novoshakhtinsk
    Noyabrsk
    Kyzyl
    Achinsk
    Seversk
    Novokuybyshevsk
    Yelets
    Arzamas
    Obninsk
    Elista
    Pushkino
    Mezhdurechensk
    "Leninsk-Kuznetsky"
    Sarapul
    Yessentuki
    Kaspiysk
    Noginsk
    Ukhta
    Serov
    Votkinsk
    "Velikiye Luki"
    Michurinsk
    Novotroitsk
    Zelenodolsk
    Solikamsk
    Berdsk
    Ramenskoye
    Domodedovo
    Magadan
    Glazov
    Zheleznogorsk
    Kansk
    "Novyy Urengoy"
    Gatchina
    Sarov
    Voskresensk
    Kuznetsk
    Gubkin
    Kineshma
    Yeysk
    Reutov
    Azov
    Buzuluk
    Balashov
    Yurga
    "Kirovo-Chepetsk"
    Kropotkin
    Klin
    "Khanty-Mansiysk"
    Vyborg
    Troitsk
    Bor
    Shadrinsk
    Belovo
    "Mineralnye Vody"
    "Anzhero-Sudzhensk"
    Birobidzhan
    Lobnya
    Chapayevsk
    Georgiyevsk
    Chernogorsk
    Minusinsk
    Mikhaylovsk
    Yelabuga
    Dubna
    Vorkuta
    Novoaltaysk
    Asbest
    Beloretsk
    Belogorsk
    Gukovo
    Tuymazy
    Stupino
    Kstovo
    Ishimbay
    Kungur
    Zelenogorsk
    Borisoglebsk
    Ishim
    "Naro-Fominsk"
    Donskoy
    Polevskoy
    "Leninogorsk"
    "Slavyansk-na-Kubani"
    Tuapse
    Labinsk
    Kumertau
    Sibay
    Buynaksk
    Klintsy
    Chistopol"
    Rzhev
    Revda
    Tikhoretsk
    Neryungri
    Aleksin
    Sunzha
    Meleuz
    Dmitrov
    Lesosibirsk
    Svobodnyy
    Chekhov
    Shchekino
    Pavlovo
    Kotlas
    Belebey
    Iskitim
    "Verkhnyaya Pyshma"
    Vsevolozhsk
    Apatity
    Mikhaylovka
    Anapa
    Ivanteyevka
    Shuya
    Tikhvin
    Kogalym
    Krymsk
    "Gorno-Altaysk"
    Vidnoye
    Vyksa
    Liski
    Krasnokamensk
    Volzhsk
    Izberbash
    Fryazino
    Lytkarino
    Gelendzhik
    Nyagan
    Belorechensk
    "Vyshniy Volochek"
    Buguruslan
    Solnechnogorsk
    Livny
    Cheremkhovo
    Kirishi
    Krasnokamsk
    Beryozovsky
)

# No boroughs for Russia (thousands of districts); omitted to keep manageable

# Function to generate all combinations of given length from special_chars
generate_combos() {
    local length=$1
    local special_chars=( '!' '@' '#' '$' '%' )  # Define here for safety
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
    # Countries
    for country in "${countries[@]}"; do
        bases+=("${country}${year}")
    done
    # Regions (federal subjects)
    for region in "${regions[@]}"; do
        bases+=("${region}${year}")
    done
    # Cities
    for city in "${cities[@]}"; do
        bases+=("${city}${year}")
    done
    # Towns
    for town in "${towns[@]}"; do
        bases+=("${town}${year}")
    done
    # Boroughs omitted
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
rm -f russia_passwords.txt

# Multi-threaded generation using GNU Parallel (defaults to nproc threads)
num_bases=${#bases[@]}
printf "Generating %d expanded Russia location bases in parallel (%d threads)...\n" "$num_bases" "$(nproc)" >&2
parallel -j$(nproc) --bar generate_for_base {} ::: "${bases[@]}" >> russia_passwords.txt
expected_entries=$(( num_bases * 156 * 156 ))
printf "\nDone. Saved to russia_passwords.txt (%d expected entries)\n" "$expected_entries" >&2

# Quick verification
if [ -f russia_passwords.txt ] && [ -s russia_passwords.txt ]; then
    entry_count=$(wc -l < russia_passwords.txt)
    printf "Verified: %d entries generated.\n" "$entry_count" >&2
    # Specific check for example: Moscow2025!
    if grep -qF "Moscow2025!" russia_passwords.txt; then
        printf "Verified: Moscow2025! present.\n" >&2
    else
        printf "Warning: Moscow2025! missing—investigate further.\n" >&2
    fi
else
    printf "Error: russia_passwords.txt is empty or missing. Check GNU Parallel installation and permissions.\n" >&2
fi
