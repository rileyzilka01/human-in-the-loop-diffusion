#!/bin/bash

# running instructions
# ./eval.sh {algorithm} {task} {id_number} {seed} {gpu} {server}
# server is 0 or 1, 1 is for remote, just need to change ip in hitl-diffusion

# example run
# ./eval.sh hitl hitl_test 0001 0 0 0

TERMINAL_PIDS=()

echo "Converting dataset into learning data..."
gnome-terminal --title "eval_terminal" -- bash -c '
exec -a eval_terminal
echo "Starting evaluation for $2..."
source hitld_venv/bin/activate

cd hitl-diffusion
echo "Current Directory in Shell: $(pwd)"
bash scripts/eval_policy.sh "$1" "$2" "$3" "$4" "$5" "$6"

echo
echo "Process finished. Press enter to close..."
read
' -- "$@" &
TERMINAL_PIDS+=($!)

echo "Starting sam3 live server for segmentation..."
gnome-terminal --title "seg_server" -- bash -c '
exec -a seg_server
echo "Starting segmentation server..."
source hitld_venv/bin/activate
cd sam3-live
python3 live/server.py

echo
echo "Process finished. Press enter to close..."
read
' -- "$@" &
TERMINAL_PIDS+=($!)

echo "Starting docker container for robot interaction and recording..."
gnome-terminal --title "kinova_container" -- bash -c '
source hitld_venv/bin/activate
cd kinova-diffusion/
xhost +
docker compose up -d
echo "Buffering container startup..."
sleep 1

restart="false"
if [ "$2" == "restart" ]; then
  echo "Deleting current data for this dataset, needs sudo permissions"
  sudo rm -rf "data/$1"
fi

docker exec -it kinova-diffusion bash -ic "python3 scripts/inference.py $6 && tmux attach"
echo "User exited the container tmux session. Finishing host script..."
docker compose down
' -- "$@" &
TERMINAL_PIDS+=($!)

echo "All terminals started."
echo "Press 'k' and Enter in this terminal to kill the terminal and docker container."

# Wait for user input for kill command
while true; do
    read -n1 -s key
    if [[ "$key" == "k" ]]; then
        echo -e "\nKilling terminal and docker container..."

        # Kill all terminal process groups
		pkill -9 -f "eval_terminal"
        pkill -9 -f "python3 live/server.py"

        # Stop Docker container
        cd kinova-diffusion
        docker compose down
        cd ..
        echo "All processes terminated."
        exit 0
    fi
done