#!/bin/bash

# running instructions
# ./train.sh {algorithm} {task} {dataset} {id_number} {seed} {gpu}

# example run
# ./train.sh hitl hitl_test hitl_test 0001 0 0

TERMINAL_PIDS=()

echo "Converting dataset into learning data..."
gnome-terminal --title "training_terminal" -- bash -c '
exec -a training_terminal
echo "Starting training for $2..."
source hitld_venv/bin/activate

echo "CTRL+C after your desired number of checkpoints passed to stop training"
echo "$1 $2 $3 $4 $5 $6"
cd hitl-diffusion
echo "Current Directory in Shell: $(pwd)"
bash scripts/train_policy.sh "$1" "$2" "$3" "$4" "$5" "$6"

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
		pkill -9 -f "training_terminal"

        echo "All processes terminated."
        exit 0
    fi
done