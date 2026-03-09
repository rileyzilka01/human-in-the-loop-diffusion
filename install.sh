#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/install-scripts/install-core.sh"
source "$SCRIPT_DIR/install-scripts/install-cuda.sh"
source "$SCRIPT_DIR/install-scripts/install-requirements.sh"