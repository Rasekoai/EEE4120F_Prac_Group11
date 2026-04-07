import os
import matplotlib.pyplot as plt

# ============================================================
# Configuration
# ============================================================
OPENMP_DIR = "OpenMP/output"
MPI_DIR = "MPI/output"
PROCS = [1, 2, 4, 8]
INPUTS = [f"energy{i}" for i in range(4, 11)]  # energy4 to energy10
RUNS = [1, 2, 3, 4, 5]

# ============================================================
# Read and average values from output files
# ============================================================
def load_data(base_dir):
    data = {}
    for inp in INPUTS:
        data[inp] = {}
        for p in PROCS:
            totals = {"t_comp": [], "t_init": [], "t_total": []}
            for run in RUNS:
                filepath = os.path.join(base_dir, f"p{p}", f"{inp}_run{run}.txt")
                if not os.path.exists(filepath):
                    print(f"WARNING: Missing file {filepath}")
                    continue
                with open(filepath) as f:
                    for line in f:
                        if "T_comp" in line:
                            totals["t_comp"].append(float(line.split(":")[1].strip().split()[0]))
                        elif "T_init" in line:
                            totals["t_init"].append(float(line.split(":")[1].strip().split()[0]))
                        elif "T_total" in line:
                            totals["t_total"].append(float(line.split(":")[1].strip().split()[0]))
            data[inp][p] = {
                key: sum(vals) / len(vals) if vals else None
                for key, vals in totals.items()
            }
    return data

# ============================================================
# Calculate speedup and efficiency
# ============================================================
def calc_speedup(data, inp, key):
    baseline = data[inp][1].get(key)
    speedups = []
    for p in PROCS:
        t = data[inp][p].get(key)
        speedups.append(baseline / t if baseline and t else float('nan'))
    return speedups

def calc_efficiency(data, inp, key):
    speedups = calc_speedup(data, inp, key)
    return [s / p if s == s else float('nan')  # s == s is False for nan
            for s, p in zip(speedups, PROCS)]

# ============================================================
# Load both datasets
# ============================================================
print("Loading OpenMP data...")
omp_data = load_data(OPENMP_DIR)
print("Loading MPI data...")
mpi_data = load_data(MPI_DIR)

# ============================================================
# Plot: 4 rows x 2 cols
#   Row 0: T_comp  Speedup    (OpenMP | MPI)
#   Row 1: T_comp  Efficiency (OpenMP | MPI)
#   Row 2: T_total Speedup    (OpenMP | MPI)
#   Row 3: T_total Efficiency (OpenMP | MPI)
# ============================================================
fig, axes = plt.subplots(4, 2, figsize=(14, 20))
fig.suptitle("OpenMP vs MPI Speedup & Efficiency Comparison (Averaged over 5 runs)",
             fontsize=14, fontweight="bold")

colors = plt.cm.tab10.colors

configs = [
    # (row, col, dataset, key, plot_type, title)
    (0, 0, omp_data, "t_comp",  "speedup",    "OpenMP — T_comp Speedup"),
    (0, 1, mpi_data, "t_comp",  "speedup",    "MPI — T_comp Speedup"),
    (1, 0, omp_data, "t_comp",  "efficiency", "OpenMP — T_comp Efficiency"),
    (1, 1, mpi_data, "t_comp",  "efficiency", "MPI — T_comp Efficiency"),
    (2, 0, omp_data, "t_total", "speedup",    "OpenMP — T_total Speedup"),
    (2, 1, mpi_data, "t_total", "speedup",    "MPI — T_total Speedup"),
    (3, 0, omp_data, "t_total", "efficiency", "OpenMP — T_total Efficiency"),
    (3, 1, mpi_data, "t_total", "efficiency", "MPI — T_total Efficiency"),
]

for row, col, dataset, key, plot_type, title in configs:
    ax = axes[row][col]
    for i, inp in enumerate(INPUTS):
        if plot_type == "speedup":
            values = calc_speedup(dataset, inp, key)
            marker = 'o'
        else:
            values = calc_efficiency(dataset, inp, key)
            marker = 's'
        ax.plot(PROCS, values, marker=marker, label=inp, color=colors[i])

    # Ideal reference line
    if plot_type == "speedup":
        ax.plot(PROCS, PROCS, 'k--', label="Ideal", linewidth=1.2)
        ax.set_ylabel("Speedup  S = T₁ / Tₚ")
    else:
        ax.axhline(y=1.0, color='k', linestyle='--', linewidth=1.2, label="Ideal")
        ax.set_ylabel("Efficiency  E = S / P")

    ax.set_title(title)
    ax.set_xlabel("Number of Processors")
    ax.set_xticks(PROCS)
    ax.legend(fontsize=8)
    ax.grid(True, linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig("comparison_graphs.png", dpi=150)
plt.show()
print("Saved comparison_graphs.png")