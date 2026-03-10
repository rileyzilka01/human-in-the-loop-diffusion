#!/bin/bash

if [ ! -d "hitl-diffusion" ]; then
	git clone https://github.com/rileyzilka01/hitl-diffusion.git
	echo "hitl-diffusion cloned successfully"
fi

rm -rf hitl-diffusion/.git

if [ ! -d "sam3-live" ]; then
	git clone https://github.com/rileyzilka01/sam3-live.git
	echo "sam3-live cloned successfully"
fi

rm -rf sam3-live/.git

if [ ! -d "kinova-diffusion" ]; then
	git clone https://github.com/rileyzilka01/kinova-diffusion.git
	echo "kinova-diffusion cloned successfully"
fi

rm -rf kinova-diffusion/.git

# Install python3.11 and create venv if it doesn't exist
sudo apt install python3.10 -y
sudo apt install python3.10-venv -y
sudo apt install python3.10-dev -y

if [ ! -d "hitld_venv" ]; then
    python3.10 -m venv hitld_venv
else
    echo "hitld_venv already created"
fi

# Activate the venv
source hitld_venv/bin/activate

# Check for activation
if [[ -z "$VIRTUAL_ENV" ]]; then
  echo "No virtual environment active"
  exit 1
else
  echo "Current venv: $VIRTUAL_ENV"
fi


echo "Installing torch, torchvision and torchaudio..."

python3 -m pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121