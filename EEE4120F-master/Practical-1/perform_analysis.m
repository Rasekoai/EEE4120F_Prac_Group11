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

% DONE:
% Implement manual 2D convolution using Sobel Operator(Gx and Gy)
% output - Convolved image result (grayscale)
% Call the images into the code as arrays
%========================================================================

% Convolution Function
function processed_image = my_conv2(image, Gx, Gy)
    % No padding on processed image so processed image is smaller than
    % original by 1 pixel "frame"
    processed_image = zeros(size(image)-2);
    
    % Get the dimensions of the processed image (we know this before we
    % start convolving depending on the type of padding that we choose
    % beforehand)
    [num_rows, num_columns] = size(processed_image);
    
    % Convolution of both Gx and Gy as well as summation of magnitudes is
    % done in this for-loop
    for r = 1:num_rows                   % Pixel row position on processed image
        for c = 1:num_columns            % Pixel column position of processed image
            image_pixel_row    = r+1;    % "Same pixel" but its row position on the original image
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
end

%% ========================================================================
%  PART 2: Built-in 2D Convolution Implementation
%  ========================================================================
%   
% REQUIREMENT: You MUST use the built-in conv2 function

% DONE: Use conv2 to perform 2D convolution
% output - Convolved image result (grayscale)
function output_matrix = inbuilt_conv2(image, Gx, Gy) % pass image and operators
    % applying the conv2 for the sobel kernels
	Gx_out = conv2(image, Gx, "valid");
	Gy_out = conv2(image, Gy, "valid");

	output_matrix =  abs(Gx_out) + abs(Gy_out);       % calculating magnitude
end

%% ========================================================================
%  PART 3: Testing and Analysis
%  ========================================================================
%
% Compare the performance of manual 2D convolution (my_conv2) with MATLAB's
% built-in conv2 function (inbuilt_conv2).

function run_analysis()
    % Tells MATLAB to look in the directory containing this code for a
    % directory called "sample_images", go into it and create a library of 
    % anything that ends with a .png extension. Creates something like
    % images(1) = 'house.png' etc. 
    images = dir('sample_images/*.png');
    image_sizes_numeric = zeros(length(images),1);                           % Extract numeric size from filenames

    for i = 1:length(images)                               %________________
        name = images(i).name;                             %                \
                                                           %                 \
        % Extract number between '_' and 'x'               %                  |
        tokens = regexp(name, '_(\d+)x', 'tokens');        %                  |
        image_sizes_numeric(i) = str2double(tokens{1});    %                  |---- All of this is just to reorder the files in "images" in numerical order rather than alphabetical order
    end                                                    %                  |
                                                           %                  |
    [~, sort_idx] = sort(image_sizes_numeric);             %                 /
    images = images(sort_idx);                             %________________/
                                                           %
    Gx = [-1 0 1; -2 0 2; -1 0 1];
    Gy = [1 2 1; 0 0 0; -1 -2 -1];
    
    % Run multiple times for stable timing
    num_runs=5;

    % Storage arrays. Gonna use this to store all the data.
    image_names  = {};
    image_sizes  = [];
    time_manual  = [];
    time_builtin = [];
    speedup      = [];
    max_error    = [];
    
    % Go to all images in the sample_images folder and do what is in this for-loop
    for i = 1:length(images)
        % Creates the PATH to the image and stores it in a variable, which we need when we want to call the image. Essentially something like:
        % "C:\Users\Student\Documents\GitHub\EEE4120F_Prac_Group11\EEE4120F-master\Practical-1\sample_images\image_128x128.png"
        filename = fullfile(images(i).folder, images(i).name);
        img = imread(filename);                                              % Converts the image into a matrix of values
        if size(img,3) == 3                                                  % Checks if the image is greyscaled or in colour
            img = rgb2gray(img);
        end
        img = double(img);                                                   % Avoids overflow if the pixel values were obtained in uint8
        fprintf('\nProcessing %s\n', images(i).name);                        % Newline, print a Processing image [current image's name] message, newline
    
        %% ---- Manual Timing ----
        tic;                                                                 % Start timing the Manual convolution
        for r = 1:num_runs                                                   % Do this 5 times for validity (w.r.t timing). Note that we assume that the for loop overhead is significantly smaller than the algorithm overhead.
            manual_result = my_conv2(img, Gx, Gy);                           % Get the manual convolution result. Gonna be the same result each iteration
        end
        Tmanual = toc / num_runs;                                            % Gets the average execution time for the manual convolution
    
        %% ---- Built-in Timing ----
        tic;                                                                 % Start timing the inbuilt convolution function
        for r = 1:num_runs                                                   % Do this 5 times for validity (w.r.t timing). Note that we assume that the for loop overhead is significantly smaller than the algorithm overhead
            builtin_result = inbuilt_conv2(img, Gx, Gy);                     % Get the built-in convolution result. Gonna be the same result each iteration
        end
        Tbuiltin = toc / num_runs;                                           % Gets the average execution time for the in-built convolution
    
        %% ---- Speedup ----
        S = Tmanual / Tbuiltin;                                              % Gives the speed up from the manual to the built-in algorithm
    
        %% ---- Correctness Check ----
        % manual_result(:) converts the matrix to a into a single-column vector. Therefore, this line
        % gives the difference between the built-in and the manual result at every pixel and gives us
        % a magnitude. This result is a column vector. max() gives the maximum value in this column 
        % ector and abs() simply gives us the magnitude of the difference since we don't care about the sign.
        err = max(abs(manual_result(:) - builtin_result(:)));
    
        %% ---- Store Results ----
        image_names{i} = images(i).name;
        image_sizes(i) = numel(img);
        time_manual(i) = Tmanual;
        time_builtin(i) = Tbuiltin;
        speedup(i) = S;
        max_error(i) = err;
    
        %% ---- Optional Visualization ----
        figure;
        subplot(1,2,1);
        % imshow(I, []) displays the grayscale image I, scaling the image based on the range of pixel 
        % values in I. imshow displays the minimum value in I as black and the maximum value as white
        imshow(img, []);
        title('Original');
    
        subplot(1,2,2);
        imshow(manual_result, []);
        title('Manual Sobel');
    
    end
    
    %% ---- Display Table ----
    % Tabulates the results
    Results = table(image_names', image_sizes', time_manual', time_builtin', speedup', max_error', 'VariableNames', {'Image','Pixels','T_Manual','T_Builtin','Speedup','MaxError'});
    
    disp(Results);                                                           % Shows the table
    
    %% ---- Plot Timing ----
    figure;
    plot(image_sizes, time_manual, '-o');
    hold on;
    plot(image_sizes, time_builtin, '-o');
    xlabel('Number of Pixels');
    ylabel('Execution Time (s)');
    legend('Manual','Built-in');
    title('Execution Time Comparison');
    grid on;
    
    %% ---- Plot Speedup ----
    figure;
    plot(image_sizes, speedup, '-o');
    xlabel('Number of Pixels');
    ylabel('Speedup (T_manual / T_builtin)');
    title('Speedup vs Image Size');
    grid on;

end

run_analysis()