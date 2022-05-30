function [loaders,is_sqw_type] = get_loaders(files)
% function accepts a string or cellarray of strings, describing full path
% to a sqw file or sequence of sqw files and returns list of loaders
% suitable for loading these files.
%
% Returns:
% loaders cellarray of initilized loaders for all unput files
% If requested
% is_sqw_type  -- logical array, with number of elements equal to number of
%                 loaders, containing true if the loader is the loader for
%                 sqw file and false otherwise
%
if ~exist('files','var')
    error('SQW_FILE_IO:invalid_argument',...
    'input file or list of input files is missing')
end


loaders_provided = false;
if ~iscell(files) % may be in strange way ivoked from a class. TODO: OOP violation!
    if is_sqw_input_struct(files)
        loaders_provided = true;
    else
        files = {files};
    end
end
%
if ~loaders_provided
    all_fnames = cellfun(@ischar,files,'UniformOutput',true);
    if ~any(all_fnames)
        error('SQW_FILE_IO:invalid_argument',...
            'not all input arguments represent filenames')
    end
    %-------------------------------------------------------------------------
    loaders = sqw_formats_factory.instance.get_loader(files);
else
    loaders = files.loaders_list;
end
if nargout > 1
    is_sqw_type = false(1,numel(loaders));
    for i=1:numel(loaders)
        is_sqw_type(i) = loaders{i}.sqw_type();
    end
end

function is = is_sqw_input_struct(obj)
% check if object appears to be legacy input Horace structure geneated by
% sqw object accessors
%
if ~isstruct(obj)
    is = false;
    return;
end
fnames = fieldnames(obj);
if all(ismember({'source_is_file','data','sqw_type','ndims','loaders_list'},fnames))
    is = true;
else
    is = false;
end

