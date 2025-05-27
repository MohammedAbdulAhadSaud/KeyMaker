#!/bin/bash

read -p "Enter the word (include special characters if needed): " word
read -p "Enter the output filename (without extension): " filename

if [[ -z "$word" || -z "$filename" ]]; then
    echo "Word and filename must not be empty."
    exit 1
fi

output_dir="$HOME/Wordlists"
mkdir -p "$output_dir"  # Create output directory if it doesn't exist
output_file="$output_dir/$filename.txt"
> "$output_file"  # Clear output file if it exists

function generate_case_combinations {
    local input="$1"
    local output=()
    local length=${#input}

    for ((i=0; i < (1 << length); i++)); do
        local combination=""
        for ((j=0; j < length; j++)); do
            char="${input:j:1}"
            if [[ "$char" =~ [a-zA-Z] ]]; then
                if (( (i & (1 << j)) )); then
                    combination+="${char^^}"
                else
                    combination+="${char,,}"
                fi
            else
                combination+="$char"
            fi
        done
        output+=("$combination")
    done

    declare -A special_chars=( ['!']='@' ['#']='$' ['&']='and' )
    declare -A leetspeak=( ['a']='4' ['A']='4' ['e']='3' ['E']='3' ['i']='1' ['I']='1' ['o']='0' ['O']='0' ['s']='5' ['S']='5' ['t']='7' ['T']='7' )

    for original in "${output[@]}"; do
        echo "$original" >> "$output_file"

        variant="$original"
        for k in "${!special_chars[@]}"; do
            variant="${variant//$k/${special_chars[$k]}}"
        done
        [[ "$variant" != "$original" ]] && echo "$variant" >> "$output_file"

        leet_variant="$original"
        for k in "${!leetspeak[@]}"; do
            leet_variant="${leet_variant//${k}/${leetspeak[$k]}}"
        done
        [[ "$leet_variant" != "$original" ]] && echo "$leet_variant" >> "$output_file"

        for addon in "" "123" "!" "2024" "@" "_" "-01" "_01"; do
            echo "${original}${addon}" >> "$output_file"
            echo "${addon}${original}" >> "$output_file"
        done
    done
}

generate_case_combinations "$word"

sort -u "$output_file" -o "$output_file"

echo "Wordlist saved to $output_file"
echo "Total unique combinations: $(wc -l < "$output_file")"
