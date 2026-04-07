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
# Print averaged values for verification
# ============================================================
print(f"{'Input':<10} {'P':<5} {'T_comp (avg)':<18} {'T_total (avg)':<18}")
print("-" * 55)
for inp in INPUTS:
    for p in PROCS:
        t_comp = data[inp][p].get("t_comp")
        t_total = data[inp][p].get("t_total")
        print(f"{inp:<10} {p:<5} {t_comp:<18.6f} {t_total:<18.6f}")

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
            speedups.append(None)
    return speedups

# ============================================================
# Plot
# ============================================================
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle("OpenMP Speedup Analysis (Averaged over 5 runs)", fontsize=14, fontweight="bold")

colors = plt.cm.tab10.colors

for ax, key, title in zip(axes, ["t_comp", "t_total"], ["T_comp Speedup", "T_total Speedup"]):
    for i, inp in enumerate(INPUTS):
        speedups = calc_speedup(inp, key)
        ax.plot(PROCS, speedups, marker='o', label=inp, color=colors[i])

    # Ideal speedup line
    ax.plot(PROCS, PROCS, 'k--', label="Ideal", linewidth=1.2)

    ax.set_title(title)
    ax.set_xlabel("Number of Processors")
    ax.set_ylabel("Speedup S = T₁ / Tₚ")
    ax.set_xticks(PROCS)
    ax.legend(fontsize=8)
    ax.grid(True, linestyle='--', alpha=0.5)

plt.tight_layout()
plt.savefig("speedup_graphs.png", dpi=150)
plt.show()
print("\nSaved speedup_graphs.png")