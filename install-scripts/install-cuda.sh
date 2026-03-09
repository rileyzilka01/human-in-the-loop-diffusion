#!/bin/bash

set -e

# Activate the venv
source hitld_venv/bin/activate

# Check for activation
if [[ -z "$VIRTUAL_ENV" ]]; then
  echo "No virtual environment active"
  exit 1
else
  echo "Current venv: $VIRTUAL_ENV"
fi

CUDA_VERSION="12.1"
CUB_PATH="/opt/cub"
CUDA_HOME=/usr/local/cuda-$CUDA_VERSION
BASHRC="$HOME/.bashrc"

echo "--- Starting CUDA & CUB Setup ---"

# 1. Install CUDA Toolkit (Idempotent)
if ! dpkg -l | grep -q "cuda-toolkit-12-1"; then
    echo "Installing CUDA Toolkit $CUDA_VERSION..."
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb
    sudo dpkg -i cuda-keyring_1.0-1_all.deb
    sudo apt-get update
    sudo apt-get install -y cuda-toolkit-12-1
else
    echo "[Checked] CUDA Toolkit 12.1 already installed."
fi

# 2. Install NVIDIA CUB (Idempotent)
if [ ! -d "$CUB_PATH" ]; then
    echo "Cloning CUB library to $CUB_PATH..."
    sudo git clone https://github.com/NVIDIA/cub.git "$CUB_PATH"
else
    echo "[Checked] CUB already exists at $CUB_PATH."
fi

# 3. Setup Symlinks
sudo ln -sfn /usr/local/cuda-$CUDA_VERSION /usr/local/cuda

# 4. Add Environment Variables to .bashrc (Idempotent)
if ! grep -q "export CUB_HOME=$CUB_PATH" "$BASHRC"; then
    echo "Writing environment variables to $BASHRC..."
    cat << EOF >> "$BASHRC"

# --- CUDA and CUB for PyTorch3D ---
export CUB_HOME=$CUB_PATH
export CUDA_HOME=/usr/local/cuda-$CUDA_VERSION
export PATH=\$CUDA_HOME/bin:\$PATH
export LD_LIBRARY_PATH=\$CUDA_HOME/lib64:\$LD_LIBRARY_PATH
export FORCE_CUDA=1
export TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6+PTX 8.9"
# ----------------------------------
EOF
else
    echo "[Checked] Environment variables already present in $BASHRC."
fi

# 5. Export variables for the CURRENT session
# Since this script is 'sourced' by your main script, these 
# will be available to install-requirements.sh immediately.
export CUB_HOME="$CUB_PATH"
export CUDA_HOME="/usr/local/cuda-$CUDA_VERSION"
export PATH="$CUDA_HOME/bin:$PATH"
export LD_LIBRARY_PATH="$CUDA_HOME/lib64:$LD_LIBRARY_PATH"
export FORCE_CUDA=1
export TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6+PTX 8.9"

echo "--- CUDA & CUB Setup Complete ---"