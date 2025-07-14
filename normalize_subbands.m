%--------------------------------------------------------------------------
% Function: normalize_subbands
%
% Description:
%   Normalizes the subband components of a reconstructed image so that their
%   sum matches the dynamic range of the original image.
%
% Inputs:
%   subbands     - 3D array of subband images (HxWxN)
%   originalImg  - original image to match intensity range
%
% Output:
%   subbandsNorm - normalized subbands
%--------------------------------------------------------------------------

function subbandsNorm = normalize_subbands(subbands, originalImg)

subbandsNorm = subbands;
reconstructed = sum(subbands, 3);

origMin = min(originalImg(:));
origMax = max(originalImg(:));
reconMin = min(reconstructed(:));
reconMax = max(reconstructed(:));

if reconMax ~= reconMin
    scaleFactor = (origMax - origMin) / (reconMax - reconMin);
    offset = origMin - reconMin * scaleFactor;
    numBands = size(subbands, 3);
    for i = 1:numBands
        subbandsNorm(:,:,i) = subbands(:,:,i) * scaleFactor + offset / numBands;
    end
end

end
