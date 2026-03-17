# human-in-the-loop-diffusion
This is a repo that installs compiles and runs 3 separate libraries for the HITL-D paper published here but with various new additions like active segmentation for point cloud quality, synthetic data and more


# Running the scripts

The entire end to end outline of this repo follows the steps below
1. Record demonstrations
2. Convert the raw data to formatted policy learning data
3. Train the policy
4. Evaluate the policy

## Installation

The installation script will install all 3 libraries
- hitl-diffusion: the diffusion policy training and eval server
- kinova-diffusion: the ros code and robot code for operating the kinova
- sam3-live: the model for live segmentation on the pointcloud

These are custom libraries which each contain a component of the workflow

Run the following to install, it should take about 20 minutes, at the end it will prompt you for docker information
```bash
./install.sh
```

Once you are installed you can run the following command to get into the workspace for this project
```bash
conda activate hitld
```

## Training

If you want to make new tasks for hitl-diffusion follow the steps
1. fork the repo
2. replace the repo link with yours in the install-core.sh script
3. write tasks in the repository, git push or pull

## Scripts

There are 7 different scripts defined below

1. `record.sh`
	- Launches the appropriate scripts for the user to record demonstrations only and save them to a directory.
	- This will prompt you for a dataset name
2. `record-forward.sh`
	- Runs the entire program end to end from recording demonstrations to evaluation.
	- This will prompt you for a dataset name
3. `convert.sh`
	- Runs the data conversion script which will convert the raw recorded data into workable data the diffusion policy uses.
	- This will prompt you for a dataset name and an output name
4. `convert-forward.sh`
	- Runs the entire program from converting the data all the way to evaluating a trained policy.
	- This will prompt you for a dataset name and an output name
5. `train.sh`
	- Runs the training script to train the diffusion policy
	- This will prompt you for a task name, seed, training number, num epochs to train for
6. `train-forward.sh`
	- Runs the trianing and evaluation
	- This will prompt you for a task name, seed, training number, num epochs to train for
7. `eval.sh`
	- Runs the evaluation
	- This will prompt you for a task name and training number