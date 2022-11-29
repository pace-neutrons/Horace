function [data, merge_data] = distribute(w, nWorkers, ~)
% Function to split (for parallel distribution) an XYE struct object between multiple processes.
% Attempts to split objects as close as possible to equal with respect to number of data per process.
%
% [obj, merge_data] = distribute(obj, 1)
%
% Input
% ---------
%   obj         XYE Struct object to be split amongst processors
%
%   nWorkers    number of processes to divide final object between
%
% Output
% ---------
%
%   obj         resulting split XYE Struct object as vector [nWorkers x 1]
%               of XYE Struct subobjects each holding a section of the data
%
%   merge_data  vector of structs  [nWorkers x 1] containing data relevant to the
%               re-merging of a split object
%                  nelem      - Number of pixels in first/last bins for merging
%                  nomerge    - Whether bins are split and remerging is necessary
%                  range      - Range in bins from  original XYE Struct object contained in subobject
%                  pix_range  - Range in pixels from original XYE Struct object contained in subobject
%

if isstruct(w)
    n = numel(w.y);
    nPer = repmat(floor(n / nWorkers), nWorkers, 1);
    nPer(1:mod(n, nWorkers)) = nPer(1:mod(n, nWorkers)) + 1;
    points = [0; cumsum(nPer)];
    tmp = cellfun(@(x)(mat2cell(x, 1, nPer)), w.x, 'UniformOutput', false);

    data = struct('x', [], 'y', [], 'e', []);
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

end
