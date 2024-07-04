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
unique_fnames = unique_filenames(spe_files);


end
