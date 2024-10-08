#!/bin/bash
#SBATCH --job-name=train_model
#SBATCH --output=./.slurm_logs/%j.out
#SBATCH --error=./.slurm_logs/%j.err
#SBATCH --ntasks=1
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=96:00:00
#SBATCH --gres=gpu:1
#SBATCH --mem=16G
#SBATCH --exclude=compute-0-[5,6]
#SBATCH --partition=GPU

# Unset XDG_RUNTIME_DIR to avoid directory issue
unset XDG_RUNTIME_DIR

# Load Singularity module (if needed)
module load singularity

# Env variables.
dockerhub_username=beisner
project_name=python_ml_project_template
scs_username=baeisner

# Get the branch name.
root_dir=$HOME/code/${project_name}

# Compute a good tag for the image, which will be <dockerhub_username>/<project_name>:<branch-name>-scratch.
sanitized_branch_name=$(${root_dir}/cluster/sanitize_branch_name.bash)

# Get the SIF name
sif_name=$HOME/singularity_images/${project_name}_${sanitized_branch_name}-scratch.sif

if [ ! -f ${sif_name} ]; then
    echo "SIF file not found: ${sif_name}"
    echo "You need to run the ./cluster/build_push_sif_seuss.bash script first."
fi

echo "Using SIF name: ${sif_name}"

mkdir -p /scratch/$(whoami)
mkdir -p /scratch/$(whoami)/data
mkdir -p /scratch/$(whoami)/logs

SINGULARITYENV_WANDB_DOCKER_IMAGE=python-ml-project-template \
    SINGULARITYENV_WANDB_API_KEY=$WANDB_API_KEY \
    singularity exec \
    --nv \
    --pwd /opt/$(whoami)/code \
    -B /scratch/$(whoami)/data:/opt/data \
    -B /scratch/$(whoami)/logs:/opt/logs \
    ${sif_name} \
    python scripts/train.py \
    dataset.data_dir=/opt/data \
    log_dir=/opt/logs
