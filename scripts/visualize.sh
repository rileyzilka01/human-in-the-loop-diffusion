#!/bin/bash

# running instructions
# ./visualize.sh {dataset}

# example run
# ./visualize.sh hitl_block

TERMINAL_PIDS=()

echo "Converting dataset into learning data..."
gnome-terminal --title "visualize_terminal" -- bash -c '
exec -a visualize_terminal
source hitld_venv/bin/activate

python3 hitl-diffusion/visualizer/visualizer/pointcloud.py $1

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
		pkill -9 -f "visualize_terminal"

        echo "All processes terminated."
        exit 0
    fi
done