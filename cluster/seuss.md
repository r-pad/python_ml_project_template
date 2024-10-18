# Running different types of jobs on SEUSS.

## Prerequisites.

1. You need to build/push a SIF to SEUSS. On a LOCAL machine (NOT SEUSS!), you can do this by running:

    ```bash
    ./cluster/build_push_sif_seuss.bash
    ```
    We have to do this because we can't build SIFs on SEUSS for some reason. This will also create one per-branch, and rsync.

2. You need to generate .egg-info files for the package, so that we can mount the codebase dynamically (e.g. without rebuilding the SIF).

    ```bash
    module load anaconda2
    conda create -n python_ml_project_template python=3.9
    source activate python_ml_project_template
    pip install -e ".[develop]"
    ```

    Subsequent singularity commands should bind wherever this is installed to `/opt/rpad/code` inside the container.

## Training.

Run the following command to train a model on SEUSS:

```bash
./cluster/launch_seuss.bash
```

## Running a ray distributed job.

Run the following command to run a ray distributed job on SEUSS:

```bash
python cluster/slurm-launch.py --exp-name test --command "python scripts/simple_ray_job.py" --num-nodes 1 --partition GPU --num-gpus 1
```

This will launch a single node job on the GPU partition with 1 GPU, and spin up a ray cluster on that node (more nodes if you specify `--num-nodes`). It then will parallelize the `simple_ray_job.py` script across the ray cluster (or whatever you want to run).