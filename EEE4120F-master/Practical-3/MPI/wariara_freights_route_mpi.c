// =========================================================================
// Practical 3: Minimum Energy Consumption Freight Route Optimization
// =========================================================================
//
// GROUP NUMBER:
//
// MEMBERS:
//   - Member 1 Name, Student Number
//   - Member 2 Name, Student Number

// ========================================================================
//  PART 2: Minimum Energy Consumption Freight Route Optimization using OpenMPI
// =========================================================================


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <string.h>
#include "mpi.h"

#define MAX_N 10
#define INF 100000	// large value for infinity

// ============================================================================
// Global variables
// ============================================================================

int n; // If this is -1, it signals an error/exit
int adj[MAX_N][MAX_N];
int best_cost = INF;		//unknown costs very large
int best_path[MAX_N];		//array to hold the path
double t_comp_start;
double t_comp_end;


// ============================================================================
// Timer: returns time in seconds
// ============================================================================

double gettime()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec / 1000000.0;
}

// ============================================================================
// Usage function
// ============================================================================

void Usage(char *program) {
  printf("Usage: mpirun -np <num> %s [options]\n", program);
  printf("-i <file>\tInput file name\n");
  printf("-o <file>\tOutput file name\n");
  printf("-h \t\tDisplay this help\n");
}

void bnb(int depth, int last, int cost_so_far, int *path, int *visited, int *best_cost, int *best_path);
int main(int argc, char **argv)
{
    int rank, nprocs;
    int opt;
    int i, j;
    char *input_file = NULL;
    char *output_file = NULL;
    FILE *infile = NULL;
    FILE *outfile = NULL;
    int success_flag = 1; // 1 = good, 0 = error/help encountered

    // Initialize MPI
    double t_init_start = gettime(); // begin timing the initialisation time
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);


    if (rank == 0) {
        n = -1; 

        while ((opt = getopt(argc, argv, "i:o:h")) != -1)
        {
            switch (opt)
            {
                case 'i':
                    input_file = optarg;
                    break;

                case 'o':
                    output_file = optarg;
                    break;

                case 'h':
                    Usage(argv[0]);
                    success_flag = 0; 
                    break;

                default:
                    Usage(argv[0]);
                    success_flag = 0;
            }
        }

        
    
        if (success_flag) {
            infile = fopen(input_file, "r");
            if (infile == NULL) {
                fprintf(stderr, "Error: Cannot open input file '%s'\n", input_file);
                perror("");
                success_flag = 0;
            } else {
                
                fscanf(infile, "%d", &n);

                for (i = 1; i < n; i++)
                {
                    for (j = 0; j < i; j++)
                    {
                        fscanf(infile, "%d", &adj[i][j]);
                        adj[j][i] = adj[i][j];
                    }
                }
                fclose(infile);
            }
        }
        if (success_flag) {
            outfile = fopen(output_file, "w");
            if (outfile == NULL) {
                fprintf(stderr, "Error: Cannot open output file '%s'\n", output_file);
                perror("");
                success_flag = 0;
            }
        }

    }

    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);

    
    if (n == -1) {
        MPI_Finalize();
        return 0; 
    }

   MPI_Bcast(&adj[0][0], MAX_N * MAX_N, MPI_INT, 0, MPI_COMM_WORLD);

    double t_init_end = gettime(); // record ending time for initialisation
    printf("Process %d received adjacency matrix:\n", rank);
    for (i = 0; i < n; i++) {
        for (j = 0; j < n; j++) {
            printf("%d ", adj[i][j]);
        }
        printf("\n");
    }
    printf("\n");

        
    // TODO: compute solution to minimum energy consumption problem here and write to output file
    // Be careful on which process rank writes to the output file to avoid conflicts!
    
     t_comp_start = gettime();

    /* the following loop distributes the iterations among the workers avoiding overlap eg for nprocs = 3
     rank 0: visits cities 1,4,7, rank 1: visits cities 2,5,8 while rank 2: visits cities 3,6,9
    */
    	
    for (int second = 1 + rank; second < n; second += nprocs) {
        int path[MAX_N];        // allocate memory large enough to contain all cities and booleans
        int visited[MAX_N];
        memset(visited, 0, sizeof(visited)); //all cities are not visited at start ie all booleans are False

        path[0] = 0;    // starting city is always city 0
        visited[0] = 1; //initial city marked visited
        path[1] = second; // second city in any iteration added to the path
        visited[second] = 1; // city visted

        bnb(2, second, adj[0][second], path, visited, &best_cost, best_path);  //start BnB from city 0 to second, with 2 cities p
    }

    t_comp_end=gettime();

    	
     /* Each process contributes its local best_cost to MPI_Reduce.
   	Process 0 collects all values and stores the minimum as global_best_cost */
        
	int global_best_cost;
        MPI_Allreduce(&best_cost, &global_best_cost, 1, MPI_INT, MPI_MIN, MPI_COMM_WORLD);
    // Each process checks if it owns the best cost, if yes it submits its rank, otherwise submits nprocs
        int my_rank_if_best = (best_cost == global_best_cost) ? rank : nprocs;

    // All processes contribute to MPI_Allreduce, MPI_MIN picks the lowest rank that has the best cost    
	int best_rank;
        MPI_Allreduce(&my_rank_if_best, &best_rank, 1, MPI_INT, MPI_MIN, MPI_COMM_WORLD);

        if (best_rank >= nprocs) best_rank = 0; // If no process found a best, default to process 0

    //The winning process copies its best_path into global_best_path
        int global_best_path[MAX_N];
        if (rank == best_rank)
        memcpy(global_best_path, best_path, n * sizeof(int));

    // winning process broadcasts it to all other processes.
        MPI_Bcast(global_best_path, MAX_N, MPI_INT, best_rank, MPI_COMM_WORLD);

    // Only process 0 writes the results to the output file
	if (rank == 0) {
    		fprintf(outfile, "Best path: ");
    		for (int i = 0; i < n; i++) 
                fprintf(outfile, "%d ", global_best_path[i] + 1); // +1 converts 0-indexed cities to 1-indexed
    		fprintf(outfile, "\nTotal energy: %d kWh\n", global_best_cost);
    		fprintf(outfile, "T_comp: %.6f s\n", t_comp_end - t_comp_start); // elapsed computation time
            fprintf(outfile, "T_init: %.6f s\n", t_init_end - t_init_start); // elapsed initialisation time
            fprintf(outfile, "T_total: %.6f s\n", (t_comp_end - t_comp_start)+(t_init_end - t_init_start)); // elapsed total time
    		fclose(outfile);
    }    


    MPI_Finalize();
    return 0;
}

// ============================================================================
//	Branch and Bound implementation:  Recursively finding the minimum cost path
// ============================================================================ 
    
void bnb(int depth, int last, int cost_so_far, int *path, int *visited, int *best_cost, int *best_path)
{
    // Base case: all cities have been visited
	if (depth == n) {

	// Update best cost and path if current path is cheaper
      	if (cost_so_far < *best_cost) {
            		*best_cost = cost_so_far;
            		memcpy(best_path, path, n * sizeof(int));  // save the best path so far

        	}
            return;
     	}
	// Try every unvisited city as the next step
    for (int next = 0; next < n; next++) {
       	if (visited[next]) continue;	//skip visited cities
       	int new_cost = cost_so_far + adj[last][next];
       	if (new_cost >= *best_cost) continue;// ignore if already worse than best

       	visited[next] = 1;  // mark city as visited
       	path[depth] = next; // add city to the path
       	bnb(depth + 1, next, new_cost, path, visited, best_cost, best_path); // explore deeper
       	visited[next] = 0;	//unmark city
   	}
}
