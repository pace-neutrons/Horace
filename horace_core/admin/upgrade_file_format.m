function upgrade_file_format(filenames,varargin)
% Helper function to update sqw file(s) into new file format version,
% calculating 
%
% The file format is upgraded from any previous version into current
% version
%
% Input:
% filenames -- filename or list of filenames, describing full path to
%              binary sqw files to change
%
%
% Result:
% The file format of the provided files is updated to version 4(currently recent) 

loaders = get_loaders(filenames);
n_inputs = numel(loaders);
%

for i=1:n_inputs   
    ld = loaders{i};
    ld_new = ld.upgrade_file_format();
    ld_new.delete();
    
end

