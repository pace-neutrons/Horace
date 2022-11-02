function [data, merge_data] = distribute(w, nWorkers, ~)
% Function to split an XYE struct object between multiple processes.
% Attempts to split objects equally with respect to number of pixels per process.
%
% [obj, merge_data] = split_sqw(sqw, 'nWorkers', 1, 'split_bins', true)
%
% Input
% ---------
%   sqw         XYE Struct object to be split amongst processors
%
%   nWorkers    number of processes to divide final object between
%
%   split_bins  whether bins are allowed to be split (in the case of sqw objects)
%
% Output
% ---------
%
%   obj         split XYE Struct object as list of XYE Struct subobjects each holding a smaller section of the pixels [nWorkers 1]
%
%   merge_data  list of structs containing relevant data to the splitting [nWorkers 1]
%                  nelem      - Number of pixels in first/last bins for merging
%                  nomerge    - Whether bins are split and remerging is necessary
%                  range      - Range in bins from  original XYE Struct object contained in subobject
%                  pix_range  - Range in pixels from original XYE Struct object contained in subobject
%

n = numel(w.y);
nPer = repmat(floor(n / nWorkers), nWorkers, 1);
nPer(1:mod(n, nWorkers)) = nPer(1:mod(n, nWorkers)) + 1;
points = [0; cumsum(nPer)];
tmp = cellfun(@(x)(mat2cell(x, 1, nPer)), w.x(:), 'UniformOutput', false);

data = struct('x', [], 'y', [], 'e', [], 'nomerge', repmat({true}, nWorkers, 1));
merge_data = struct('nomerge', true, 'nelem', num2cell(nPer));

for i=1:nWorkers
    tmp2 = cellfun(@(x) x(i), tmp, 'UniformOutput', false);
    data(i).x = tmp2{1};
    data(i).y = w.y(points(i)+1:points(i+1));
    data(i).e = w.e(points(i)+1:points(i+1));
    merge_data(i).range = [points(i)+1,points(i+1)];
    merge_data(i).pix_range = merge_data(i).range;
end

end
