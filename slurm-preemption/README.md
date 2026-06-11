# Slurm Preemption Demo (kube-scheduler priority preemption)

Demonstrates **Anyscale workloads preempting a Slurm (Slinky) cluster** using
plain Kubernetes scheduler preemption — no Kueue involved.

**Concept:** Slurm workers run as *scavengers* — `PriorityClass` value **-100**
(below the default 0) with real resource requests sized to hog their node.
Anyscale pods run at value **1000**. When an Anyscale pod doesn't fit anywhere,
kube-scheduler evicts the Slurm worker to make room. When the Anyscale workload
finishes, the Slinky NodeSet controller recreates the worker and it rejoins Slurm.

## Files

| File                         | Purpose                                                          |
|------------------------------|------------------------------------------------------------------|
| `priority-classes.yaml`      | k8s PriorityClasses: `slurm-low` (-100), `anyscale-high` (1000)  |
| `slurm-values.yaml`          | Slurm chart overrides: worker priority class + resource requests |
| `anyscale_computeconfig.yaml`| Anyscale compute config with `priorityClassName: anyscale-high`  |
| `anyscale_job.yaml`          | Anyscale job (head + 1 worker, 8 CPU / 32Gi each)                |
| `create_computeconfig.sh`    | Registers the compute config with Anyscale                       |

## Capacity math (what makes preemption fire)

- Each node: ~15.9 CPU / ~62Gi allocatable.
- Slurm worker requests **12 CPU / 48Gi** → its node cannot also fit an
  8 CPU / 32Gi Anyscale pod.
- The Anyscale job needs 2 such pods (head + worker). One fits on the free
  node; the second fits nowhere → the scheduler **must preempt** the Slurm
  worker (priority -100 < 1000).

## Setup

```bash
# 1. Create the priority classes
kubectl apply -f priority-classes.yaml

# 2. Apply the Slurm overrides (worker becomes preemptible)
helm upgrade slurm oci://ghcr.io/slinkyproject/charts/slurm \
  --version 1.1.0 -n slurm -f slurm-values.yaml

# 3. Verify the slurm worker: priority -100 and real requests
kubectl get pod slurm-worker-slinky-0 -n slurm \
  -o jsonpath='{.spec.priority}{" "}{.spec.containers[?(@.name=="slurmd")].resources.requests}{"\n"}'

# 4. Register the Anyscale compute config
./create_computeconfig.sh
```

## Run the demo

```bash
# Submit the Anyscale job (high priority)
anyscale job submit -f anyscale_job.yaml

# Watch the slurm worker get evicted, then sit Pending until capacity frees
kubectl get pods -n slurm -w

# Confirm the Anyscale pods run at priority 1000
kubectl get pods -n anyscale-operator -o custom-columns='NAME:.metadata.name,PRIORITY:.spec.priority'

# See the preemption events
kubectl get events -A --field-selector reason=Preempted
```

When the job is terminated (`anyscale job terminate ...` or it finishes), the
NodeSet controller's recreated worker pod schedules again and the Slurm node
returns to service.

## Caveats

- Preemption is a **hard kill** for any Slurm jobs running on the evicted
  worker — no drain. Jobs are requeued only if Slurm is configured for it.
- The Slurm chart's `workloadDisruptionProtection` PDB is best-effort against
  scheduler preemption: the scheduler prefers victims whose PDBs allow
  disruption but will violate the PDB if eviction is the only way to place
  the higher-priority pod.
- `slurm-low` uses `preemptionPolicy: Never`, so Slurm workers never evict
  other pods when they (re)schedule — pure scavenger semantics.
