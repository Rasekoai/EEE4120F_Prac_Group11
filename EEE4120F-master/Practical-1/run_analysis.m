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
%***************************************************************************************
% padding the image with zeroes before processing
% TODO: 
% a.	padding the image with zeroes before processing

%============================================================
%function padded_image = ZeroPad(image, pad)
%	[rows,cols] = size (image)	% extracting the dimensions of the image
%	padded_image = zeros(rows+2*pad, cols+2*pad) % create large frame filled with zeroes
%	padded_image(pad+1:rows+pad,pad+1:pad+cols) = image	% insert image into frame padded with zeroes
%end
%****************************************************************************************

% Implement manual 2D convolution using Sobel Operator(Gx and Gy)
% output - Convolved image result (grayscale)
%========================================================================
function processed_image = my_conv2(image, Gx, Gy)
    
end

%% ========================================================================
%  PART 2: Built-in 2D Convolution Implementation
%  ========================================================================
%   
% REQUIREMENT: You MUST use the built-in conv2 function

% TODO: Use conv2 to perform 2D convolution
% output - Convolved image result (grayscale)
function output = inbuilt_conv2(image, Gx, Gy, mode) % pass image, operators and mode('same','full', 'valid')
% cast image to double to avoid overflow
	image = double(image) 

% applying the conv2 for the sobel kernels
	Gx_out = conv2(image, Gx, mode);
	Gy_out = conv2(image, Gy, mode);

% clculating magnitude
	output abs(Gx_out) + abs(Gy_out)

end

%% ========================================================================
%  PART 3: Testing and Analysis
%  ========================================================================
%
% Compare the performance of manual 2D convolution (my_conv2) with MATLAB's
% built-in conv2 function (inbuilt_conv2).

function run_analysis()
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
    
    
    
end
