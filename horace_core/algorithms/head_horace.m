function varargout=head_horace(files,varargin)
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
if iscell(files)
    n_inputs = numel(files);
    argi = files;
else
    if ischar(files)|| isstring(files)
        argi = {files};
        n_inputs = 1;
    else
        argi = num2cell(files);
        n_inputs = numel(argi);
    end
end
if n_outputs>n_inputs
    error('HORACE:head:invalid_argument',...
        'number of output objects requested is bigger then the number of input files provided')
end
%
all_fnames = cellfun(@ischar,argi,'UniformOutput',true);
all_ldrs    = cellfun(@(x)isa(x,'horace_binfile_interface'),argi,'UniformOutput',true);
if ~any(all_fnames|all_ldrs)
    error('HORACE:head:invalid_argument',...
        'read_sqw: not all input arguments represent filenames or loaders')
end

fnames = argi(all_fnames);
if ~isempty(fnames)
    loaders = sqw_formats_factory.instance.get_loader(fnames);
else
    loaders  = {};
end
if any(all_ldrs)
    loaders = {loaders{:},argi{all_ldrs}};
end

% if ~iscell(loaders)
%     loaders  = {loaders};
% end

if n_outputs==0
    for i=1:n_inputs
        data = loaders{i}.head(varargin{:});
        if loaders{i}.sqw_type
            sqw_display_single(data,npixtot,nfiles,'a');
        else
            npixtot=1;    % *** MUST MAKE GET_SQW RETURN NPIXTOT IF 'b+' TYPE
            data.n_files = 1;
            sqw_display_single(data,npixtot,1,'b+');
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
    vout{i} = loaders{i}.head(varargin{:});
end

if cell_out
    varargout{1} = {vout};
else
    varargout = vout(1:n_outputs);
end
