import ray
import torch
import time
import logging
from python_ml_project_template.models.classifier import ClassifierInferenceModule


# Simple ray job that parallelizes 20 different jobst that consumer 1 GPU each, putting a 1GB tensor on each GPU.

@ray.remote(num_gpus=1)
def f():
    x = torch.rand(1024, 1024).cuda()

    print("STARTING THE JOB!")
    model = ClassifierInferenceModule(None)

    # Wait for 30s. This is to simulate a job that takes a while to finish.
    time.sleep(5)

    return x.sum()



if __name__ == "__main__":
    ray.init()
    # Start 30 tasks in parallel.
    print("Starting 30 tasks on the head unit...")
    result_ids = [f.remote() for _ in range(30)]
    results = ray.get(result_ids)
    print("Results are", results)
    print("The sum of results is", sum(results))
    ray.shutdown()