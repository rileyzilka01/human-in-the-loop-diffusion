#!/bin/bash

# running instructions
# ./record.sh {model} {dataset_name} {reset dataset flag}
# reset dataset flag: 'restart' (requires sudo permissions)

# example run
# ./record.sh hitl_hgd hitl_test restart

TERMINAL_PIDS=()

if [ "$1" == "hitl_hgd" ]; then
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
fi

echo "Starting docker container for robot interaction and recording..."
gnome-terminal --title "kinova_container" -- bash -c '
source hitld_venv/bin/activate
cd kinova-diffusion/
xhost +
docker compose up -d
echo "Buffering container startup..."
sleep 1

restart="false"
if [ "$3" == "restart" ]; then
  echo "Deleting current data for this dataset, needs sudo permissions"
  sudo rm -rf "data/$2"
fi

docker exec -it kinova-diffusion bash -ic "python3 scripts/record.py $1 $2 && tmux attach"
echo "User exited the container tmux session. Finishing host script..."
docker compose down
' -- "$@" &
TERMINAL_PIDS+=($!)

echo "All terminals started."
echo "Press 'k' and Enter in this terminal to kill all terminals and containers."

# Wait for user input for kill command
while true; do
    read -n1 -s key
    if [[ "$key" == "k" ]]; then
        echo -e "\nKilling terminals and docker container..."
        # Kill all terminal process groups
        if [ "$1" == "hitl_hgd" ]; then
		    pkill -9 -f "python3 live/server.py"
        fi

        # Stop Docker container
        cd kinova-diffusion
        docker compose down
        cd ..
        echo "All processes terminated."
        exit 0
    fi
done