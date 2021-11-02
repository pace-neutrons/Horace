function [ldrs,sqw_type] = get_file_loaders(filelist)
% Return list of file loaders corresponding to the list of the provided
% files
% 
% Input: 
% filelist --  list of the files to get loaders for
%
% Outputs:
% ldrs     -- cellarray of sqw file loaders, responsible for loading each
%             input file
% sqw_type -- logical array of filelist size, containing true if
%             correspondent file is sqw file or false if it is dnd file
%

if ischar(filelist) || isstring(filelist)
    filelist = {filelist}; % Single file
end
%
n_files = numel(filelist);
ldrs = cell(n_files,1);
sqw_type = false(n_files,1);
for i=1:n_files
    ldrs{i} = sqw_formats_factory.instance().get_loader(filelist{i});
    sqw_type(i) = ldrs{i}.sqw_type;
end

