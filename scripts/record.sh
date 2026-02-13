#!/bin/bash
docker-compose up -d myservice
docker exec -it myservice bash -c "python3 scripts/record.py && tmux attach"
echo "User exited the container tmux session. Continuing host script..."