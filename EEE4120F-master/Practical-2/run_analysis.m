% =========================================================================
% Practical 2: Mandelbrot-Set Serial vs Parallel Analysis
% =========================================================================
%
% GROUP NUMBER:
%
% MEMBERS:
%   - Member 1 Adedamola Yusuff, YSFADE001
%   - Member 2 Rasekoai Mokose, MKSRAS001

%% ========================================================================
%  PART 1: Mandelbrot Set Image Plotting and Saving
%  ========================================================================
%
% TODO: Implement Mandelbrot set plotting and saving function
   function mandelbrot_plot(varargin) %Add necessary input arguments
%  ========================================================================
%   PART 1: Mandelbrot Set Image Plotting and Saving
%  ========================================================================
% This function transforms iteration data into a colorful fractal image.

function mandelbrot_plot(iter_counts,colorName, fileName) 

        % Create color palette (256 steps) and force the "prisoner" set to black
        colorMap = feval(colorName, 4096); 
        colorMap(end,:) = [0,0,0]; 

        % Use log scale to compress data and reveal "slow escape" detail near edges
        log_data = log(1 + iter_counts); 
        max_val = max(log_data(:)); 

        % Normalize log data to a 1-256 index range to match the colorMap
        idx = round(1 + (log_data / max_val) * 4095);
	idx = max(1, min(4096, idx));
        
        % Convert the indexed matrix into a truecolor RGB image
        rgb_image = ind2rgb(idx, colorMap); 

        % Create output folder and save the image
        if ~exist('output', 'dir'), mkdir('output'); end
	imwrite(rgb_image, fullfile('output', [fileName, '.bmp']));

end

%% ========================================================================
%  PART 2: Serial Mandelbrot Set Computation
%  ========================================================================`
%
%TODO: Implement serial Mandelbrot set computation function

%function mandelbrot_serial(varargin) %Add necessary input arguments

function [iter_counts] = mandelbrot_serial(W, H, max_iters)
    % This function calculates the Mandelbrot set for a given resolution
    % using nested for-loops (sequential processing).

    X_LIM = [-2.0, 0.5];
    Y_LIM = [-1.2, 1.2];

    % Map pixels to complex plane coordinates
    x_coords = linspace(X_LIM(1), X_LIM(2), W);
    y_coords = linspace(Y_LIM(1), Y_LIM(2), H);


    % Initialize the results matrix
    iter_counts = zeros(H, W);
    
    % NESTED FOR-LOOPS 
    for row = 1:H
        for col = 1:W
            % Define C for this specific pixel
            c_re = x_coords(col);
            c_im = y_coords(row);
            
            % Start Z at 0
            z_re = 0;
            z_im = 0;
            
            % Escape loop for this single point
            count = 0;
            while (count < max_iters) && (z_re^2 + z_im^2 <= 4)
                % z = z^2 + c
                z_re_new = z_re^2 - z_im^2 + c_re;
                z_im = 2 * z_re * z_im + c_im;
                z_re = z_re_new;
                
                count = count + 1;
            end
            
            % Store the result for this pixel
            iter_counts(row, col) = count;
        end
    end
       
end

%  PART 3: Parallel Mandelbrot Set Computation
%  ========================================================================
%
%TODO: Implement parallel Mandelbrot set computation function
%function mandelbrot_parallel(varargin) %Add necessary input arguments

function [iter_counts] = mandelbrot_parallel(W, H, max_iters)
    % Coordinate limits
    X_LIM = [-2.0, 0.5];
    Y_LIM = [-1.2, 1.2];

    % Map pixels to complex plane coordinates
    x_coords = linspace(X_LIM(1), X_LIM(2), W);
    y_coords = linspace(Y_LIM(1), Y_LIM(2), H);

    % Initialise results matrix
    iter_counts = zeros(H, W);

    % Parallel computation - each row distributed across CPU cores
    parfor row = 1:H
        % Local row buffer 
        row_counts = zeros(1, W);

        for col = 1:W
            c_re = x_coords(col);
            c_im = y_coords(row);
            z_re = 0;
            z_im = 0;
            count = 0;

            while (count < max_iters) && (z_re^2 + z_im^2 <= 4)
                z_re_new = z_re^2 - z_im^2 + c_re;
                z_im     = 2 * z_re * z_im + c_im;
                z_re     = z_re_new;
                count    = count + 1;
            end

            row_counts(col) = count;
        end

        iter_counts(row, :) = row_counts;
    end
  

end

%% ========================================================================
%  PART 4: Testing and Analysis
%  ========================================================================
% Compare the performance of serial Mandelbrot set computation
% with parallel Mandelbrot set computation.

function run_analysis()
    %Array conatining all the image sizes to be tested
    image_sizes = [
        [800,600],   %SVGA
        [1280,720],  %HD
        [1920,1080], %Full HD
        [2048,1080], %2K Cinema
        [2560,1440], %2K QHD
        [3840,2160], %4K UHD
        [5120,2880], %5K
        [7680,4320]  %8K UHD
    ]
    max_iterations = 1000; 
    
    % Benchmarking the serial version for all the images

    fprintf('--- Sequential version running---\n');
    for s = 1:size(image_sizes,1)
	    W = image_sizes(s,1);
	    H = image_sizes(s,2);
	    fprintf('Computing %dx%d... ', W, H);
	    tic;
	    iter_counts = mendelbrot_serial(W,H,max_iterations);
	    execution_time_serial = toc;
	    fprintf('Done in %.4f seconds.\n', execution_time_serial);
	    mandelbrot_plot(iter_counts, 'hot', sprintf('mandelbrot_seq_%dx%d', W, H));
	    
    end

    fprintf('---Parallel version running ---\n');
    for s = 1:size(image_sizes,1)
	    W = image_sizes,1);
	    H = image_sizes,2);
            fprintf('Computing %dx%d... ', W, H);
	    tic;
	    iter_counts = mandelbrot_parallel(W,H,max_iterations;
	    execution_time_parallel = toc;
	    fprintf('Done in %.4f seconds.\n', execution_time_parallel);
	    mandelbrot_plot(iter_counts, 'hot', sprintf('mandelbrot_par_%dx%d', W, H));
	    

    %TODO: For each image size, perform the following:
    %   a. Measure execution time of mandelbrot_serial
    %   b. Measure execution time of mandelbrot_parallel
    %   c. Store results (image size, time_serial, time_parallel, speedup)  
    %   d. Plot and save the Mandelbrot set images generated by both methods
    
end

% the following function is for testing purposes

function mandelbrot_plot(iter_counts,colorName, fileName)

        % Create color palette (256 steps) and force the "prisoner" set to black
        colorMap = feval(colorName, 4096);
        colorMap(end,:) = [0,0,0];

        % Use log scale to compress data and reveal "slow escape" detail near edges
        log_data = log(1 + iter_counts);
        max_val = max(log_data(:));

        % Normalize log data to a 1-256 index range to match the colorMap
        idx = round(1 + (log_data / max_val) * 4095);
	idx = max(1, min(4096, idx));

        % Convert the indexed matrix into a truecolor RGB image
        rgb_image = ind2rgb(idx, colorMap);

        % Create output folder and save the image
        if ~exist('output', 'dir'), mkdir('output'); end
	imwrite(rgb_image, fullfile('output', [fileName, '.bmp']));

end
