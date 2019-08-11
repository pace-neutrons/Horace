function varargout = read_horace(files,varargin)
% Read sqw object from named file or an array of sqw objects from a cell array of file names
%
%   >> w=read_horace(file)   % read named file or cell array of file names
%                             into array of sqw objects or cellarray of sqw/dnd ojects
%Main options:
%   >> w=read_horace(file(s),'-get_dnd') --  read dnd parts of all (dnd and sqw) objects
%                                            only.
%   >> w=read_horace(file(s),'-force_sqw')-- fail if the input file
%                                            contains a dnd object.
% Additional possible options are transferred to sqw or dnd loader directly 
%
% Original author: T.G.Perring
%
% Read sqw/dnd object from a file or array of sqw/dnd objects from a set of files
%
%   >> w=read_horace(file)
%
% Output:
% -------
%   w           sqw/dnd object, or array of sqw/dnd objects if given cell array of
%               file names

% Original author: T.G.Perring
%
%
% $Revision:: 1752 ($Date:: 2019-08-11 23:26:06 +0100 (Sun, 11 Aug 2019) $)
%

% Perform operations
% ------------------
% Check number of arguments
if ~exist('files','var')
    error('SQW_FILE_IO:invalid_argument',...
    'read_horace neads files list to be a first input argument')
end

n_outputs = nargout;
if n_outputs>nargin
    error('SQW_FILE_IO:invalid_argument',...
        'number of output objects requested is bigger then the number of input files provided')
end
%
[ok,mess,get_dnd,force_sqw,argi] = parse_char_options(varargin,{'-get_dnd','-force_sqw'});
if ~ok
    error('SQW_FILE_IO:invalid_argument',mess);
end
%
if get_dnd && force_sqw
    error('SQW_FILE_IO:invalid_argument',...
        'only one option i.e. -get_dnd or -force_sqw can be provided simultaniously');    
end

%
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
            'read_horace: not all input arguments represent filenames')
    end
    %-------------------------------------------------------------------------
    loaders = sqw_formats_factory.instance.get_loader(files);
else
    loaders = files.loaders_list;
end
%
n_inputs = numel(loaders);
if force_sqw
    for i=1:n_inputs
        if ~loaders{i}.sqw_type
            error('SQW_FILE_IO:invalid_argument',...
                'read_horace: File %s contans dnd information but only sqw file requested',...
                fullfile(loaders{i}.filepath,loaders{i}.filename));
        end
    end
end

if n_outputs == 0 % do nothing but the check if all files present and
    return;       % are all sqw has been done
end

n_files2read = n_inputs;
if n_outputs > 1 && n_outputs<n_inputs
    n_files2read  = n_outputs;
end
trez = cell(1,n_files2read);
% Now read data
for i=1:n_files2read
    if get_dnd
        trez{i} = loaders{i}.get_dnd(argi{:});
    else
        trez{i} = loaders{i}.get_sqw(argi{:});
    end
end

varargout = pack_io_outputs(trez,n_inputs,n_outputs);

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
