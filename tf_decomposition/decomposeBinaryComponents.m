function components = decomposeBinaryComponents(binaryImage)
    % DECOMPOSEBINARYCOMPONENTS Decomposes a binary image into its connected components
    % Input: binaryImage - 2D binary image (logical or uint8 with 0s and 1s)
    % Output: components - 3D array where each slice components(:,:,k) is a binary
    %                     image of the k-th connected component
    
    % Ensure input is binary
    if ~islogical(binaryImage)
        binaryImage = logical(binaryImage);
    end
    
    % Perform connected component labeling
    [labeledImage, numComponents] = bwlabel(binaryImage, 8);
    
    % Initialize output 3D array
    [rows, cols] = size(binaryImage);
    components = false(rows, cols, numComponents);
    
    % Extract each component into a separate slice
    for k = 1:numComponents
        components(:,:,k) = (labeledImage == k);
    end
end