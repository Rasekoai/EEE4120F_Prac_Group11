CC=mpicc
CFLAGS=-O3 -Wno-unused-result
CFLAGS_DEBUG=-g -Wno-unused-result

INPUT_DIR=input
OUTPUT_DIR=output

# Number of processes (override with make run_all NP=4)
NP=4

# All input files energy4 through energy10
INPUTS=$(wildcard $(INPUT_DIR)/energy[1-9]*)

all: wariara_freights_route_mpi wariara_freights_route_mpi_debug

.PHONY: clean run run_debug run_all run_speedup analyse

clean:
	rm -rf wariara_freights_route_mpi wariara_freights_route_mpi_debug *~ *.o

wariara_freights_route_mpi: wariara_freights_route_mpi.c
	$(CC) $(CFLAGS) $< -o wariara_freights_route_mpi

wariara_freights_route_mpi_debug: wariara_freights_route_mpi.c
	$(CC) $(CFLAGS_DEBUG) $< -o wariara_freights_route_mpi_debug

# Run a single input file
# Usage: make run INPUT=input/energy8
run: wariara_freights_route_mpi
	mpirun --oversubscribe --use-hwthread-cpus -np $(NP) ./wariara_freights_route_mpi -i $(INPUT) -o $(OUTPUT_DIR)/$(notdir $(INPUT))_output.txt

# Run all input files energy4 through energy10
run_all: wariara_freights_route_mpi
	@for f in $(INPUTS); do \
		echo "Running $$f ..."; \
		mpirun --oversubscribe --use-hwthread-cpus -np $(NP) ./wariara_freights_route_mpi -i $$f -o $(OUTPUT_DIR)/$$(basename $$f)_output.txt; \
	done

run_debug: wariara_freights_route_mpi_debug
	mpirun --oversubscribe --use-hwthread-cpus -np $(NP) ./wariara_freights_route_mpi_debug -i $(INPUT) -o $(OUTPUT_DIR)/$(notdir $(INPUT))_output.txt

# Run all inputs for all processor counts (for speedup analysis)
# Usage: make run_speedup
run_speedup: wariara_freights_route_mpi
	@mkdir -p $(OUTPUT_DIR)/p1 $(OUTPUT_DIR)/p2 $(OUTPUT_DIR)/p4 $(OUTPUT_DIR)/p8
	@for p in 1 2 4 8; do \
		echo "=== Running with $$p processes ==="; \
		for f in $(INPUTS); do \
			echo "  Running $$f ..."; \
			for run in 1 2 3 4 5; do \
				mpirun --oversubscribe --use-hwthread-cpus -np $$p ./wariara_freights_route_mpi -i $$f -o $(OUTPUT_DIR)/p$$p/$$(basename $$f)_run$$run.txt; \
			done; \
		done; \
	done

# Run everything and plot speedup graphs
# Usage make analyse
analyse: run_speedup
	python3 plot_speedup.py
