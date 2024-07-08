function [spe_files,file_order,duplicated_fnames] = generate_sources_for_replication_(spe_files,n_workers)
% analyses list of input files and physically duplicates the files
% represented by the same filenames so that each worker would
% have access to unique set of files.
%
% This is gen_sqw_files_job method as method should have
% access and use the same split strategy, as the one actually
% used for distributing rundata between workers.
%
% Inputs:
% spe_files -- cellarray of filenames of different spe files
% (duplicated or not)
% n_workers -- number of workers to split files between.
%
% Ouputs:
% spe_files -- modified spe_files list containing initial spe
%              files and duplicate spe files arranged in such
%              an order so each parallel worker would have
%              access to unique set of input files.
% file_order
%          -- positions of the filenames in the initial order of the
%             files.
%
%
% duplicated_fnames
%            -- list of new filenames containing the list of names
%               produced as copies of existing input files to
%               allow each parallel worker to work with unique
%               source file
%
duplicated_fnames = {};

is_empty = cellfun(@isempty,spe_files);
if any(is_empty)
    spe_files = spe_files(~is_empty);
end

spe_files = cellfun(@char,spe_files,'UniformOutput',false);

[unique_fnames,unique_fname_idx,irec] = unique(spe_files);
if numel(unique_fnames) == numel(spe_files)
    % nothing to do. all filenames are already unique
    return;
end
% this works for any array of n_files length so we use irec array, which
% have lengh of n-files. It also decreases n_workers if there are too few
% data files provided as input.
[n_workers,worker_par_list] = JobDispatcher.split_tasks_indices(irec,n_workers);

%
n_unique = numel(unique_fnames);
duplicated_fnames = cell(1,n_workers-n_unique);
%
worker_idx = worker_par_list{1};
unique_used = ismember(unique_fname_idx,worker_idx);
for i=2:n_workers
    worker_idx = worker_par_list{i};
    unique_used_by_wrks = ismember(unique_fname_idx,worker_idx);
    unique_reused = ismember(unique_used,unique_used_by_wrks);
    if any(unique_reused)
        for j=1:numel(worker_idx)
            if unique_reused(j)
                expanded_f_name = create_duplicate(unique_fname,n_duplicate)
            end
        end
    end
end


% Replicate unique files to provide copies to every independent worker.
if n_unique < n_workers
    exp_fnames = cell(1,n_workers);

    copied_numbers    = containers.Map(1:n_unique,cell(1,n_unique));
    fc = 1;
    for i=1:n_workers
        for j=1:n_unique
            if fc<=n_unique
                exp_fnames{fc} = unique_fnames{j};
            else
                [fp,fn,fe] = fileparts(unique_fnames{j});

                short_fname = sprintf('%s_%d%s',fn,i,fe);
                exp_fnames{fc} = fullfile(fp,short_fname);
                copyfile(unique_fnames{j},exp_fnames{fc},'f');
                copied_numbers(j) = [copied_numbers(j)(:),fc];
            end
            fc = fc+1;
        end
    end
end

for i=1:n_workers
    worker_idx = worker_par_list{i};
    for j=1:numel(worker_idx)

    end
end

end

function expanded_f_name = create_duplicate(unique_fname,n_duplicate)
[fp,fn,fe] = fileparts(unique_fname);
short_fname = sprintf('%s_%d%s',fn,n_duplicate,fe);
expanded_f_name  = fullfile(fp,short_fname);
copyfile(unique_fname,expanded_f_name,'f');

end

