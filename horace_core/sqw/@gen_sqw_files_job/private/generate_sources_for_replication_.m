function [spe_files,duplicated_fnames] = generate_sources_for_replication_(spe_files,n_workers)
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

[unique_fnames,~,irec] = unique(spe_files);
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
duplicated_fnames = cell(1,numel(spe_files)-1);
copies_list       = containers.Map(unique_fnames,num2cell(zeros(1,n_unique)));
%
n_spe = 0;
n_duplicate = 1;
for i=1:n_workers
    worker_file_idx     = irec(worker_par_list{i}); % numbers of filename used by this worker
    unique_for_worker   = unique(worker_file_idx);  % how many unique files are there
    for j=1:numel(worker_file_idx)
        f_idx            = worker_file_idx(j);
        is_wkr_unique    = f_idx == unique_for_worker;
        file_name        =  spe_files{f_idx};
        if any(is_wkr_unique) % this is unique file_idx taken first time
            unique_for_worker(is_wkr_unique) = 0;
            n_copies     = copies_list(file_name);
            if n_copies == 0
                copies_list(file_name) = 1;
            else
                duplicated_fnames{n_duplicate} = create_duplicate(file_name,n_copies);
                copies_list(file_name)         = n_copies + 1;
                file_name                      = duplicated_fnames{n_duplicate};
                n_duplicate = n_duplicate+1;                
            end
        else
            file_name = spe_files{n_spe};
        end
        n_spe            = n_spe+1;
        spe_files{n_spe} = file_name;
    end
end
to_trim = cellfun(@isempty,duplicated_fnames);
duplicated_fnames = duplicated_fnames(~to_trim);
end

function  [expanded_f_name,copied] = create_duplicate(unique_fname,n_duplicate)
% Replicate unique files to provide copies to every independent worker.
[fp,fn,fe] = fileparts(unique_fname);
short_fname = sprintf('%s_%d%s',fn,n_duplicate,fe);
expanded_f_name  = fullfile(fp,short_fname);

if is_file(expanded_f_name)
    copied = false;
else
    copied = true;
    copyfile(unique_fname,expanded_f_name,'f');
end
end

