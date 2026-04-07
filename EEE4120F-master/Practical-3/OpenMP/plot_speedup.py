import os
import matplotlib.pyplot as plt

# ============================================================
# Configuration
# ============================================================
OUTPUT_DIR = "output"
PROCS = [1, 2, 4, 8]
INPUTS = [f"energy{i}" for i in range(4, 11)]  # energy4 to energy10
RUNS = [1, 2, 3, 4, 5]  # number of runs to average

# ============================================================
# Read and average T_comp, T_init, T_total across runs
# ============================================================
data = {}  # data[input][procs] = {t_comp, t_init, t_total}

for inp in INPUTS:
    data[inp] = {}
    for p in PROCS:
        totals = {"t_comp": [], "t_init": [], "t_total": []}

        for run in RUNS:
            filepath = os.path.join(OUTPUT_DIR, f"p{p}", f"{inp}_run{run}.txt")
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

        # Average the runs
        data[inp][p] = {
            key: sum(vals) / len(vals) if vals else None
            for key, vals in totals.items()
        }


# ============================================================
# Calculate Speedup: S = T(p=1) / T(p=P)
# ============================================================
def calc_speedup(inp, key):
    baseline = data[inp][1].get(key)
    speedups = []
    for p in PROCS:
        t = data[inp][p].get(key)
        if baseline and t:
            speedups.append(baseline / t)
        else:
            speedups.append(float('nan'))
    return speedups

# ============================================================
# Calculate Efficiency: E = Speedup / P
# ============================================================
def calc_efficiency(inp, key):
    speedups = calc_speedup(inp, key)
    return [s / p if s == s else float('nan')  # s == s is False for nan
            for s, p in zip(speedups, PROCS)]

# ============================================================
# Plot — 2x2 grid: top row speedup, bottom row efficiency
# ============================================================
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("OpenMP Speedup & Efficiency Analysis (Averaged over 5 runs)", fontsize=14, fontweight="bold")

colors = plt.cm.tab10.colors

for col, (key, label) in enumerate(zip(["t_comp", "t_total"], ["T_comp", "T_total"])):

    # --- Speedup (top row) ---
    ax = axes[0][col]
    for i, inp in enumerate(INPUTS):
        speedups = calc_speedup(inp, key)
        ax.plot(PROCS, speedups, marker='o', label=inp, color=colors[i])
    ax.plot(PROCS, PROCS, 'k--', label="Ideal", linewidth=1.2)
    ax.set_title(f"{label} Speedup")
    ax.set_xlabel("Number of Processors")
    ax.set_ylabel("Speedup  S = T₁ / Tₚ")
    ax.set_xticks(PROCS)
    ax.legend(fontsize=8)
    ax.grid(True, linestyle='--', alpha=0.5)

    # --- Efficiency (bottom row) ---
    ax = axes[1][col]
    for i, inp in enumerate(INPUTS):
        efficiency = calc_efficiency(inp, key)
        ax.plot(PROCS, efficiency, marker='s', label=inp, color=colors[i])
    ax.axhline(y=1.0, color='k', linestyle='--', linewidth=1.2, label="Ideal")
    ax.set_title(f"{label} Efficiency")
    ax.set_xlabel("Number of Processors")
    ax.set_ylabel("Efficiency  E = S / P")
    ax.set_xticks(PROCS)
    ax.legend(fontsize=8)
    ax.grid(True, linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig("speedup_efficiency_graphs.png", dpi=150)
plt.show()
print("\nSaved speedup_efficiency_graphs.png")