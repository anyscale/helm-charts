# Kueue Preemption Demo (anyscale-operator namespace)

Demonstrates a **high-priority Anyscale job preempting a low-priority one**
using [Kueue](https://kueue.sigs.k8s.io/). A low-priority Anyscale job is
running and occupying all available quota; when a high-priority job is
submitted and there is no room for it, Kueue **preempts** (evicts) the
low-priority job to admit the high-priority one. The low-priority job's pods
are deleted and it goes back to waiting in the queue.

This folder contains the Kueue resources plus the Anyscale compute config and
job definitions to reproduce the scenario (see "Anyscale workload yamls" below).

## Workload shape

Each "Ray cluster" is one workload made of 2 pods:

| Pod        | CPU | Memory |
|------------|-----|--------|
| head       | 8   | 32Gi   |
| worker     | 8   | 32Gi   |
| **total**  | 16  | 64Gi   |

The `ClusterQueue` quota is **16 CPU / 64Gi = exactly one workload**, so the
second workload can only be admitted by preempting the first.

## Workload contract (for the workloads you create)

For your pods to be queued and preemptible by Kueue, every pod in a workload
must carry these labels/annotations:

```yaml
metadata:
  labels:
    kueue.x-k8s.io/queue-name: anyscale-lq        # the LocalQueue below
    kueue.x-k8s.io/pod-group-name: <unique-name>  # same for all pods in ONE workload
    kueue.x-k8s.io/priority-class: low-priority    # or high-priority
  annotations:
    kueue.x-k8s.io/pod-group-total-count: "2"     # head + worker
```

Give the low-priority and high-priority workloads **different**
`pod-group-name` values (e.g. `ray-low` and `ray-high`), and request
`cpu: "8"` / `memory: 32Gi` per pod.

## Anyscale workload yamls

With the Anyscale operator, the labels are injected through the compute
config's `advanced_instance_config`. One compute config per priority tier
(swap `low-priority` for `high-priority` in the high variant):

```yaml
# computeconfig_low.yaml
cloud: <your-cloud>
head_node:
  instance_type: 8CPU-32GB
  resources:
    CPU: 0
    GPU: 0
  advanced_instance_config:
    metadata:
      labels:
        kueue.x-k8s.io/queue-name: anyscale-lq
        kueue.x-k8s.io/priority-class: low-priority
worker_nodes:
  - instance_type: 8CPU-32GB
    min_nodes: 1
    max_nodes: 1
    advanced_instance_config:
      metadata:
        labels:
          kueue.x-k8s.io/queue-name: anyscale-lq
          kueue.x-k8s.io/priority-class: low-priority
```

Each job yaml references its compute config:

```yaml
# job_low.yaml
name: kueue-low
image_uri: anyscale/ray:2.55.1-slim-py312-cu129
compute_config: kueue-low
entrypoint: python -c "import time; time.sleep(3600)"
```

## Files (apply in order)

| File                          | Resource                                        |
|-------------------------------|-------------------------------------------------|
| `00-resource-flavor.yaml`     | `ResourceFlavor` default-flavor                 |
| `01-priority-classes.yaml`    | `WorkloadPriorityClass` low / high              |
| `02-cluster-queue.yaml`       | `ClusterQueue` anyscale-cq (quota + preemption) |
| `03-local-queue.yaml`         | `LocalQueue` anyscale-lq                         |

## Capacity note

This demo is sized so the cluster can host **exactly one workload at a time**,
which is what makes preemption fire:

- Each pod requests 8 CPU / 32Gi; each node has ~15.9 CPU / ~62Gi allocatable.
- A node therefore holds **one** such pod (two would need 16 CPU > 15.9).
- With 2 nodes, the cluster runs exactly **one** workload's 2 pods (one per node).
- The `ClusterQueue` quota (16 CPU / 64Gi) is also exactly one workload.

So both physical capacity *and* Kueue quota cap the cluster at one workload.
When a second (higher-priority) workload arrives, Kueue must preempt the
running lower-priority workload to admit it — exactly the behavior being demoed.

## Run the demo

```bash
# 1. Install the queueing resources
kubectl apply -f 00-resource-flavor.yaml \
              -f 01-priority-classes.yaml \
              -f 02-cluster-queue.yaml \
              -f 03-local-queue.yaml

# 2. Confirm the ClusterQueue is Active
kubectl get clusterqueue anyscale-cq -o wide

# 3. Register the compute configs (one per priority tier, see
#    "Anyscale workload yamls" above)
anyscale compute-config create -n kueue-low  -f computeconfig_low.yaml
anyscale compute-config create -n kueue-high -f computeconfig_high.yaml

# 4. Submit the LOW-priority job -> admitted, fills the quota
anyscale job submit -f job_low.yaml
kubectl get workloads -n anyscale-operator
kubectl get pods -n anyscale-operator -L ray.io/node-type

# 5. Submit the HIGH-priority job -> Kueue PREEMPTS the low one
anyscale job submit -f job_high.yaml

# 6. Watch the preemption happen
kubectl get workloads -n anyscale-operator -w
#   ray-low  -> Admitted=false (Preempted/Evicted)
#   ray-high -> Admitted=true

# Inspect why a workload was preempted / is pending
kubectl describe workload -n anyscale-operator
kubectl get events -n anyscale-operator --sort-by=.lastTimestamp | grep -i preempt
```

## Cleanup

```bash
# delete your workloads first, then:
kubectl delete -f 03-local-queue.yaml -f 02-cluster-queue.yaml \
               -f 01-priority-classes.yaml -f 00-resource-flavor.yaml --ignore-not-found
```
