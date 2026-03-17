#!/bin/bash
set -e

# Setup paths and environment
PROJECT_ROOT="$(pwd)"
# Activate the venv
source hitld_venv/bin/activate

# Check for activation
if [[ -z "$VIRTUAL_ENV" ]]; then
  echo "No virtual environment active"
  exit 1
else
  echo "Current venv: $VIRTUAL_ENV"
fi

# --- 3. Install hitl-diffusion ---
echo "Installing hitl-diffusion..."
cd "$PROJECT_ROOT/hitl-diffusion/hitl-diffusion"
# Added --no-build-isolation to ensure it sees the torch installed in CORE
python3 -m pip install -e . --no-build-isolation
cd ..
python3 -m pip install -r requirements.txt
cd "$PROJECT_ROOT"


# Make sure torch is installed
python3 -m pip install torch==2.7.0

# --- 6. Install PyTorch3D (Simplified) ---
echo "Installing PyTorch3D..."
# We use the CUB_HOME and CUDA_HOME exported from your install-cuda.sh
cd hitl-diffusion/third_party/pytorch3d_simplified

export CUB_HOME="/opt/cub"

python3 -m pip install -e . --no-build-isolation
cd ../..

# --- 7. Install necessary packages ---
echo "Installing additional packages..."
python3 -m pip install zarr==2.12.0 wandb ipdb gpustat dm_control omegaconf hydra-core==1.2.0 \
    dill==0.3.5.1 einops==0.4.1 diffusers==0.11.1 numba==0.56.4 moviepy imageio av matplotlib termcolor

# --- 8. Install Visualizer ---
echo "Installing visualizer..."
python3 -m pip install kaleido plotly
cd visualizer && python3 -m pip install -e . --no-build-isolation
cd "$PROJECT_ROOT"

# --- Extra: Sam3 & Docker (From your previous script) ---
echo "Finalizing SAM3 and Docker..."
cd sam3-live && python3 -m pip install -e . && python3 -m pip install -e ".[train,dev]" && python3 -m pip install -r requirements.txt
cd "$PROJECT_ROOT/kinova-diffusion"
docker compose build
docker compose up -d

echo "Build the ros packages."
echo "In a new terminal, execute the following"
echo 'docker exec -it kinova-diffusion bash -c "source /opt/ros/noetic/setup.bash && cd catkin_ws && catkin_make"'
read -p "Press ENTER after verifying the container..."

echo "Installation sequence finished successfully."