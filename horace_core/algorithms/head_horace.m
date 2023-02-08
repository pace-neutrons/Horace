function varargout=head_horace(fnames_or_loaders,varargin)
% Display a summary of a file or set of files containing sqw information
%
%   >> head_sqw          % Prompts for file and display summary of contents
%   >> head_sqw (file)   % Display summary for named file or for cell array of file names
%
% To return header information in a structure, without displaying to screen:
%
%   >> h = head_horace
%   >> h = head_horace (file)           % Fetch principal header information
%   >> h = head_horace (file,'-full')   % Fetch full header information
%
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, displays
%               summary for each sqw object
%
% Optional keyword:
%   '-full'     Keyword option; if sqw type data in file, then returns all header and the
%              detector information. In fact, it returns the full data structure
%              except for the signal, error and pixel arrays.
%
% Output (optional):
% ------------------
%   h           Structure with header information, or cell array of structures if
%               given a cell array of file names.

% Original author: T.G.Perring
%
% Check number of arguments

n_outputs = nargout;
if iscell(fnames_or_loaders)
    n_inputs = numel(fnames_or_loaders);
    inputs = fnames_or_loaders;
else
    if ischar(fnames_or_loaders)|| isstring(fnames_or_loaders)
        inputs = {fnames_or_loaders};
        n_inputs = 1;
    else
        inputs = num2cell(fnames_or_loaders);
        n_inputs = numel(inputs);
    end
end
if n_outputs>n_inputs
    error('HORACE:head:invalid_argument',...
        'number of output objects requested is bigger then the number of input files provided')
end
%
all_fnames = cellfun(@ischar,inputs,'UniformOutput',true);
all_ldrs    = cellfun(@(x)isa(x,'horace_binfile_interface'),inputs,'UniformOutput',true);
all_obj     = cellfun(@(x)isa(x,'SQWDnDBase'),inputs,'UniformOutput',true);
if ~any(all_fnames|all_ldrs|all_obj)
    error('HORACE:head:invalid_argument',...
        'Not all input arguments represent filenames, sqw/dnd objects or loaders')
end

fnames = inputs(all_fnames);
if ~isempty(fnames)
    loaders = sqw_formats_factory.instance.get_loader(fnames);
else
    loaders  = {};
end
if ~isempty(loaders)
    inputs(all_fnames) = loaders;
end

% if ~iscell(loaders)
%     loaders  = {loaders};
% end

if n_outputs==0
    for i=1:n_inputs
        data = inputs{i}.head(varargin{:});
        if isfield(data,'npixtot')
            sqw_display_single(data,npixtot,nfiles,'a');            
        else
            sqw_display_single(data,1,1,'b+');            
        end
    end
    return
end

cell_out = false;
if n_outputs == 1
    nfi = n_inputs;
    vout = cell(1,nfi);
    if nfi>1
        cell_out  = true;
    end
else
    nfi = min(n_inputs,nargout);
end

for i=1:nfi
    vout{i} = inputs{i}.head(varargin{:});
end

if cell_out
    varargout{1} = vout;
else
    for i=1:nargout
        varargout{i} = vout{i};
    end
end
