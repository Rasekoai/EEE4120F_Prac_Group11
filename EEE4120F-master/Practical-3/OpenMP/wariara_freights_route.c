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
//  PART 1: Minimum Energy Consumption Freight Route Optimization using OpenMP
// =========================================================================


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <omp.h>
#include <string.h>
// constants
#define INT_MAX 100000
#define MAX_N 10

// ============================================================================
// Global variables
// ============================================================================

int procs = 1;
int n;
int adj[MAX_N][MAX_N];
int best_cost;
int best_path[MAX_N];
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
  printf("Usage: %s [options]\n", program);
  printf("-p <num>\tNumber of processors/threads to use\n");
  printf("-i <file>\tInput file name\n");
  printf("-o <file>\tOutput file name\n");
  printf("-h \t\tDisplay this help\n");
}

void bnb(int depth, int last, int cost_so_far, int *path, int *visited);

int main(int argc, char **argv){
    
    double t_init_start = gettime();
    int opt;
    int i, j;
    char *input_file = NULL;
    char *output_file = NULL;
    FILE *infile = NULL;
    FILE *outfile = NULL;
    int success_flag = 1; // 1 = good, 0 = error/help encountered
    
    

    while ((opt = getopt(argc, argv, "p:i:o:h")) != -1)
    {
        switch (opt)
        {
            case 'p':
            {
                procs = atoi(optarg);
                break;
            }

            case 'i':
            {
                input_file = optarg;
                break;
            }

            case 'o':
            {
                output_file = optarg;
                break;
            }

            case 'h':
            {
                Usage(argv[0]);
                success_flag = 0; 
                break;
            }

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

    if (!success_flag) return 1;

    

    printf("Running with %d processes/threads on a graph with %d nodes\n", procs, n);

    
    // TODO: compute solution to minimum energy consumption problem here and write to outfile
    best_cost = INT_MAX; // begin with very large cost

    omp_set_num_threads(procs); // set number of threads to use
    double t_init_end = gettime(); // end the initialisation after the processes have been created

    double t_comp_start = gettime();	//begin computation time
    
    /* Parallelise over all choices for the second city.
    * City 0 is always fixed as the start
    * schedule(dynamic, 1) assigns one iteration at a time to threads
    * dynamic scheduling balances the load better than static 
    * for trees that have different sizes */

    #pragma omp parallel for schedule(dynamic, 1)
    for (int second = 1; second < n; second++) {
        int path[MAX_N];
        int visited[MAX_N];
        memset(visited, 0, sizeof(visited));  // Zero out the visited array for this thread 

        path[0] = 0;	// mark city 0 as  a start 
	visited[0] = 1;	 // mark city 0 as visited
        path[1] = second; // add the second city to current path
        visited[second] = 1;	// mark second city as visited

        bnb(2, second, adj[0][second], path, visited); // explore more cities below
    }

    double t_comp_end = gettime();

    /* Write the best path found to the output file.
     * +1 converts from 0-indexed to 1-indexed output so cities are displayed as 1 to N 
     */

    fprintf(outfile, "Best path: ");
    for (int i = 0; i < n; i++)
        fprintf(outfile, "%d ", best_path[i]+1);
    fprintf(outfile, "\nTotal energy: %d kWh\n", best_cost);
    fprintf(outfile, "T_comp: %.6f s\n", t_comp_end - t_comp_start);
    fprintf(outfile, "T_init: %.6f s\n", t_init_end - t_init_start);
    fprintf(outfile, "T_total: %.6f s\n", (t_comp_end - t_comp_start)+(t_init_end - t_init_start)); // elapsed total time
    fclose(infile);
    fclose(outfile);

    

    return 0;
	
}
// ============================================================================
// Branch and Bound impementation with the openMP
// ============================================================================

void bnb(int depth, int last, int cost_so_far, int *path, int *visited)
{
	/* base case: all the cities have been visited */
    if (depth == n) {
	 
	/* only one thread can execute this block at the time to update best_cost and best_path
	 * this prevents race condition
	 */

        #pragma omp critical
        {
            if (cost_so_far < best_cost) {
                best_cost = cost_so_far;	// update best cost
                memcpy(best_path, path, n * sizeof(int)); //save the best path
            }
        }
        return;
    }
	/* Try every city as the next candidate to add to the path */
    for (int next = 0; next < n; next++) {
        if (visited[next]) continue;	 // Skip cities present in the current path
        int new_cost = cost_so_far + adj[last][next];// Calculate the cost from the current city to next 
        if (new_cost >= best_cost) continue; //ignore large costs

        visited[next] = 1;	// mark city as visited
        path[depth] = next;	// place the city in the path
        bnb(depth + 1, next, new_cost, path, visited); //Recurse one level deeper with the updated path and cost
        visited[next] = 0;	//unmark the city
    }
}

