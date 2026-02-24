% =========================================================================
% Practical 1: 2D Convolution Analysis
% =========================================================================
%
% GROUP NUMBER:
%
% MEMBERS:
%   - Member 1 Rasekoai Mokose, MKSRAS001
%   - Member 2 Adedamola Yusuff, YSFADE001


%% ========================================================================
%  PART 1: Manual 2D Convolution Implementation
%  ========================================================================
%
% REQUIREMENT: You may NOT use built-in convolution functions (conv2, imfilter, etc.)

% TODO:
% Implement manual 2D convolution using Sobel Operator(Gx and Gy)
% output - Convolved image result (grayscale)
% Call the images into the code as arrays
%========================================================================

% Gx and Gy are for testing purposes
Gx = [-1 0 1; -2 0 2; -1 0 1];
Gy = [1 2 1; 0 0 0; -1 -2 -1];

% An image for testing purposes
test_image = [2 5 3 6 3; 5 7 2 6 8; 1 2 3 4 5; 6 7 8 9 1; 2 3 4 5 6; 7 8 9 1 2; 3 4 5 6 7; 8 9 1 2 3];

% Convolution Function
function [processed_image, execution_time] = my_conv2(image, Gx, Gy)
    tStart = tic;
    % No padding on processed image so processed image is smaller than original by 1 pixel "frame"
    processed_image = zeros(size(image)-2);
    
    % Get the dimensions of the processed image (we know this before we start convolving
    % depending on the type of padding that we choose beforehand)
    num_rows = height(processed_image);
    num_columns = width(processed_image);
    
    % Convolution of both Gx and Gy as well as summation of magnitudes is
    % done in this for-loop
    
    for r = 1:num_rows                   % Pixel row position on processed image
        for c = 1:num_columns            % Pixel column position of processed image
            image_pixel_row = r+1;       % "Same pixel" but its row position on the original image
            image_pixel_column = c+1;    % "Same pixel" but its column position on the original image
            
            totalGx=0;
            totalGy=0;

            for rG = 1:3                % Position on Gx and Gy
                for cG = 1:3            % Position on Gx and Gy
                    totalGx = Gx(rG,cG)*image(image_pixel_row-2+rG,image_pixel_column-2+cG) + totalGx;  % Gives the horizontal gradient at the current pixel. The math here allows us to go to the adjacent squares while sequentially moving through Gx 
                    totalGy = Gy(rG,cG)*image(image_pixel_row-2+rG,image_pixel_column-2+cG) + totalGy;  % Gives the vertical gradient at the current pixel. The math here allows us to go to the adjacent squares while sequentially moving through Gy
                end
            end
            processed_image(r,c) = abs(totalGx) + abs(totalGy);
        end
    end
    execution_time = toc(tStart);
end

%% ========================================================================
%  PART 2: Built-in 2D Convolution Implementation
%  ========================================================================
%   
% REQUIREMENT: You MUST use the built-in conv2 function

% TODO: Use conv2 to perform 2D convolution
% output - Convolved image result (grayscale)
function [output_matrix, execution_time] = inbuilt_conv2(image, Gx, Gy) % pass image and operators
    tStart = tic;
    % applying the conv2 for the sobel kernels
    Gx_out = conv2(image, Gx, "valid");
    Gy_out = conv2(image, Gy, "valid");

    % calculating magnitude
    output_matrix =  abs(Gx_out) + abs(Gy_out);
    execution_time = toc(tStart);
end

%% ========================================================================
%  PART 3: Testing and Analysis
%  ========================================================================
%
% Compare the performance of manual 2D convolution (my_conv2) with MATLAB's
% built-in conv2 function (inbuilt_conv2).

function run_analysis()

    images = dir('sample_images/*.png');
    num_images = length(images);
    
    % defining the operators inside analysis function
    Gx = [-1 0 1; -2 0 2; -1 0 1];
    Gy = [1 2 1; 0 0 0; -1 -2 -1];

    results = table( ...
    strings(num_images,1), ...
    zeros(num_images,1), ...
    zeros(num_images,1), ...
    zeros(num_images,1), ...
    false(num_images,1), ...
    'VariableNames', {'ImageName','TimeManual','TimeBuiltin','Speedup', 'IsCorrect'});
    
    for i = 1:length(images)
    
        filename = fullfile(images(i).folder, images(i).name);
	img = imread(filename);
    
        img = rgb2gray(img);
    
        [result1,time_manual] = my_conv2(img, Gx, Gy); 
	[result2,time_builtin] = inbuilt_conv2(img, Gx, Gy);

	speedup = time_manual/time_builtin; % speedup = non_optimised/optimised
	
	 % Checks if maximum pixel difference is within tolerance
        tolerance = 1e-10;
	is_correct = max(abs(result1(:) - result2(:))) <= tolerance;

	if ~is_correct
    	warning('Mismatch detected in image %s', images(i).name);

	end

	% store the data
	results.ImageName(i) = string(images(i).name);
	results.TimeManual(i) = time_manual;
	results.TimeBuiltin(i) = time_builtin;
	results.Speedup(i) = speedup;
	results.IsCorrect(i) = is_correct;


	
    
    end

   % plotting the data
 
    figure;
    b = bar([results.TimeManual, results.TimeBuiltin]);
    title('Execution Time: Manual vs Built-in');
    xlabel('Image');
    ylabel('Time (seconds)');
    xticklabels(results.ImageName);
    xtickangle(45);
    legend({'Manual', 'Built-in'});

    disp(results)
    
end

run_analysis();

    % TODO1:
    % Load all the sample images from the 'sample_images' folder
    
    % TODO2:
    % Define edge detection kernels (Sobel kernel)
    
    % TODO3:
    % For each image, perform the following:
    %   a. Measure execution time of my_conv2
    %   b. Measure execution time of inbuilt_conv2
    %   c. Compute speedup ratio
    %   d. Verify output correctness (compare results)
    %   e. Store results (image name, time_manual, time_builtin, speedup)
    %   f. Plot and compare results
    %   g. Visualise the edge detection results(Optional)
    


