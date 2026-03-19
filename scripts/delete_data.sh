#!/bin/bash

# running instructions
# ./delete_data.sh {dataset}

# example run
# ./delete_data.sh hitl_block

echo "Deleting recorded data"
sudo rm -rf kinova-diffusion/data/$1