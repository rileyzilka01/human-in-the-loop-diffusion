#!/bin/bash

# running instructions
# ./convert.sh {model} {dataset_name} {output_name}

# example run
# ./convert.sh hitl_hgd hitl_test hitl_test_converted

TERMINAL_PIDS=()

echo "Converting dataset into learning data..."
gnome-terminal --title "convert_terminal" -- bash -c '
exec -a convert_terminal
echo "Starting conversion process..."
source hitld_venv/bin/activate

input_path="$(pwd)/kinova-diffusion/data"
output_path="$(pwd)/hitl-diffusion/hitl-diffusion/data"

cd hitl-diffusion
python scripts/convert_real_robot_data.py "$1" "$2" "$3" "$input_path" "$output_path"

echo
echo "Process finished. Press enter to close..."
read
' -- "$@" &
TERMINAL_PIDS+=($!)

echo "All terminals started."
echo "Press 'k' and Enter in this terminal to kill the terminal."

# Wait for user input for kill command
while true; do
    read -n1 -s key
    if [[ "$key" == "k" ]]; then
        echo -e "\nKilling terminal..."
        # Kill all terminal process groups
		pkill -9 -f "convert_terminal"

        echo "All processes terminated."
        exit 0
    fi
done