#!/bin/bash

# Absolute paths
SERVER1_PATH="$HOME/repo/server1"
SERVER2_PATH="$HOME/repo/server2"
INFERENCE_PATH="$HOME/repo/inference"

# Array to store PIDs of the terminals
TERMINAL_PIDS=()

# 1️⃣ Start server1 in a new terminal
gnome-terminal -- bash -c "cd $SERVER1_PATH && python3 server1.py; exec bash" &
TERMINAL_PIDS+=($!)

# 2️⃣ Start server2 in a new terminal
gnome-terminal -- bash -c "cd $SERVER2_PATH && python3 server2.py; exec bash" &
TERMINAL_PIDS+=($!)

# 3️⃣ Start Docker container for inference + tmux
gnome-terminal -- bash -c "cd $INFERENCE_PATH && \
docker-compose up -d myservice && \
docker exec -it myservice bash -c 'python3 scripts/record.py && tmux attach'; exec bash" &
TERMINAL_PIDS+=($!)

echo "All terminals started."
echo "Press 'k' and Enter in this terminal to kill all terminals and containers."

# Wait for user input for kill command
while true; do
    read -n1 -s key
    if [[ "$key" == "k" ]]; then
        echo -e "\nKilling all terminals and Docker container..."
        # Kill all terminal processes
        for pid in "${TERMINAL_PIDS[@]}"; do
            kill $pid 2>/dev/null
        done
        # Stop Docker container
        docker-compose -f $INFERENCE_PATH/docker-compose.yml down
        echo "All processes terminated."
        exit 0
    fi
done