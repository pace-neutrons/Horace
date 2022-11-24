function [data, merge_data] = distribute(obj, nWorkers, ~)
% Function to split an IX_dataset object between multiple processes.
% Attempts to split objects equally with respect to number of pixels per process.
%
% [obj, merge_data] = distribute(IX_dataset, 1)
%
% Input
% ---------
%   sqw         IX_Dataset object to be split amongst processors
%
%   nWorkers    number of processes to divide final object between
%
% Output
% ---------
%
%   obj         split IX_Dataset object as list of IX_Dataset subobjects each holding a smaller section of the pixels [nWorkers 1]
%
%   merge_data  list of structs containing relevant data to the splitting [nWorkers 1]
%                  nelem      - Number of pixels in first/last bins for merging
%                  nomerge    - Whether bins are split and remerging is necessary
%                  range      - Range in bins from  original IX_Dataset object contained in subobject
%                  pix_range  - Range in pixels from original IX_Dataset object contained in subobject
%

cls = class(obj);
dims = str2double(cls(12));
n = numel(obj.x);
nPer = repmat(floor(n / nWorkers), nWorkers, 1);
nPer(1:mod(n, nWorkers)) = nPer(1:mod(n, nWorkers)) + 1;
points = [0; cumsum(nPer)];

data(1:nWorkers) = obj; % struct('obj', cell(nWorkers,1));
merge_data = struct('nomerge', true, 'nelem', num2cell(nPer));

for i = 1:nWorkers
    data(i).x = obj.x(points(i)+1:points(i+1));
    data(i).signal = obj.signal(points(i)+1:points(i+1));
    data(i).error = obj.error(points(i)+1:points(i+1));
    merge_data(i).range = [points(i)+1,points(i+1)];
    merge_data(i).pix_range = merge_data(i).range;
end

if dims > 1
    for i = 1:nWorkers
        data(i).y = obj.y(points(i)+1:points(i+1));
    end
end
if dims > 2
    for i = 1:nWorkers
        data(i).z = obj.z(points(i)+1:points(i+1));
    end
end


end
