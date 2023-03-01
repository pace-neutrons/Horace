function [loop_data, merge_data] = distribute_fit_data(w, nWorkers, split_bins, tobyfit)
% Split up xye structs, IX_Datasets and sqw/dnd objects in w for use in
% parallel jobs.
%
% Inputs
%
%  w          : Cell aray of objects to split
%  nWorkers   : number of workers to distribute data over
%  split_bins : Whether job is allowed to split bins
%  tobyfit    : Tobyfit arrays if present ensure workers have stable montecarlo samples
%
% Outputs
%
%  loop_data  : Distributed data to be sent to workers
%  merge_Data : extra information for the recombination of data
%
loop_data = cell(nWorkers, 1);
merge_data = arrayfun(@(x) struct('nelem', [], 'nomerge', []), zeros(numel(w), nWorkers));

for i=1:nWorkers
    loop_data{i} = struct('w', {cell(numel(w),1)});
end

if ~all(cellfun(@(x) isa(x, 'SQWDnDBase') || ...
                isa(x, 'IX_dataset') || ...
                (isstruct(x) && all(isfield(x, {'x', 'y', 'e'}))), w))
    error('HERBERT:split_data:invalid_argument', ...
          'Unrecognised type: %s, data must be of type struct with xye, or SQWDnDBase, or IX_dataset.', class(w{i}))
end


for i=1:numel(w)
    [data, md] = distribute(w{i}, nWorkers, split_bins);

    for j = 1:numel(md)
        merge_data(i,j).nelem = md(j).nelem;
        merge_data(i,j).nomerge = md(j).nomerge;
        merge_data(i,j).range = md(j).range;
        merge_data(i,j).pix_range = md(j).pix_range;
    end

    for j=1:nWorkers
        loop_data{j}.w{i} = data(j);
    end

end

if exist('tobyfit', 'var')
    a = RandStream.getGlobalStream();
    for i=1:nWorkers
        loop_data{i}.tobyfit_data = tobyfit;
        loop_data{i}.rng = a;
        for k = 1:numel(tobyfit)
            for j = 1:numel(tobyfit{k}.kf)

                pr = merge_data(j,i).pix_range;
                loop_data{i}.tobyfit_data{k}.kf{j}     = tobyfit{k}.kf{j}(pr(1):pr(2));
                loop_data{i}.tobyfit_data{k}.dt{j}     = tobyfit{k}.dt{j}(pr(1):pr(2));
                loop_data{i}.tobyfit_data{k}.dq_mat{j} = tobyfit{k}.dq_mat{j}(:,:,pr(1):pr(2));
                for l=1:4
                    loop_data{i}.tobyfit_data{k}.qw{j}{l} = tobyfit{k}.qw{j}{l}(pr(1):pr(2));
                end
            end
        end
    end
end

end
