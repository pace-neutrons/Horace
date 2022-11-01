function [data, merge_data] = distribute(w, nWorkers)
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
