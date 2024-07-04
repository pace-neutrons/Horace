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
    restore_empty = true;
else
    restore_empty = false;
end

[spe_files_str,is_string] = cellfun(@to_char,spe_files,'UniformOutput',false);
is_string = [is_string(:)];
if any(is_string)
end

[unique_fnames,unique_fname_idx] = unique(spe_files_str);
if numel(unique_fnames) == numel(spe_files)
    % nothing to do. all filenames are already unique
    return;
end
if numel(unique_fnames) < n_workers % Replication is necessary
end

end


function [in,is_string] = to_char(in)
is_string = false;
if isstring(in)
    in = char(in);
    is_string = true;
elseif isempty(in)
    in = '';
end
end