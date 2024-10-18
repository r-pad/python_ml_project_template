import ray
import torch
import time
import logging


# Simple ray job that parallelizes 20 different jobst that consumer 1 GPU each, putting a 1GB tensor on each GPU.

@ray.remote(num_gpus=1)
def f():
    x = torch.randn(1024, 1024).cuda()

    print("STARTING THE JOB!")

    # Wait for 30s. This is to simulate a job that takes a while to finish.
    time.sleep(5)

    return x.sum()



if __name__ == "__main__":
    ray.init()
    # Start 20 tasks in parallel.
    print("Starting 16 tasks on the head unit...")
    result_ids = [f.remote() for _ in range(1000)]
    results = ray.get(result_ids)
    print("Results are", results)
    print("The sum of results is", sum(results))
    ray.shutdown()