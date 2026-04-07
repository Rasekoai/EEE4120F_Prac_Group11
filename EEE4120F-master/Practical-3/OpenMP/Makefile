CC=gcc
CFLAGS=-O3 -fopenmp -Wno-unused-result
CFLAGS_DEBUG=-g -fopenmp -Wno-unused-result
INPUT_DIR=input
OUTPUT_DIR=output

# Number of threads (override with make run_all PROCS=4)
PROCS=4

# All input files energy4 through energy10
INPUTS=$(wildcard $(INPUT_DIR)/energy[0-9]*)

all: wariara_freights_route wariara_freights_route_debug
	

.PHONY: clean run run_debug run_all run_speedup analyse

clean:
	rm -rf wariara_freights_route wariara_freights_route_debug *~ *.o

wariara_freights_route: wariara_freights_route.c
	$(CC) $(CFLAGS) $< -o wariara_freights_route

wariara_freights_route_debug: wariara_freights_route.c
	$(CC) $(CFLAGS_DEBUG) $< -o wariara_freights_route_debug

# Run a single input file
# Usage: make run INPUT=input/energy8
run: wariara_freights_route
	./wariara_freights_route -p $(PROCS) -i $(INPUT) -o $(OUTPUT_DIR)/$(notdir $(INPUT)).txt

# Run all input files energy4 through energy10
run_all: wariara_freights_route
	@for f in $(INPUTS); do \
		echo "Running $$f ..."; \
		./wariara_freights_route -p $(PROCS) -i $$f -o $(OUTPUT_DIR)/$$(basename $$f).txt; \
	done

run_debug: wariara_freights_route_debug
	./wariara_freights_route_debug -p $(PROCS) -i $(INPUT) -o $(OUTPUT_DIR)/$(notdir $(INPUT)).txt

# Run all inputs for all processor counts (for speedup analysis)
# Usage: make run_speedup
run_speedup: wariara_freights_route
	@mkdir -p $(OUTPUT_DIR)/p1 $(OUTPUT_DIR)/p2 $(OUTPUT_DIR)/p4 $(OUTPUT_DIR)/p8
	@for p in 1 2 4 8; do \
		echo "=== Running with $$p processors ==="; \
		for f in $(INPUTS); do \
			for run in 1 2 3 4 5; do \
				echo "  Running $$f (run $$run) ..."; \
				./wariara_freights_route -p $$p -i $$f -o $(OUTPUT_DIR)/p$$p/$$(basename $$f)_run$$run.txt; \
			done; \
		done; \
	done
# Run everything and plot speedup graphs
# Usage: make analyse
analyse: run_speedup
	python3 plot_speedup.py
