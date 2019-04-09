function varargout=head_horace(varargin)
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
% $Revision:: 1750 ($Date:: 2019-04-09 10:04:04 +0100 (Tue, 9 Apr 2019) $)
% Check number of arguments

if isempty(varargin)
    error('HEAD:invalid_argument','read: Check number of input arguments')
end

[ok,mess,hfull,argi] = parse_char_options(varargin,{'-full'});
if ~ok
    error('HEAD:invalid_argument',mess);
end

n_outputs = nargout;
if iscell(argi{1})
    n_inputs = numel(argi{1});
else
    n_inputs = numel(argi);
end
if n_outputs>n_inputs
    error('HEAD:invalid_argument',...
        'number of output objects requested is bigger then the number of input files provided')
end

files = argi{1};
if iscell(files)
    argi = files;
else
    argi = {files};
end
%
all_fnames = cellfun(@ischar,argi,'UniformOutput',true);
all_ldrs    = cellfun(@(x)isa(x,'dnd_file_interface'),argi,'UniformOutput',true);
if ~any(all_fnames|all_ldrs)
    error('READ_SQW:invalid_argument','read_sqw: not all input arguments represent filenames or loaders')
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
        data = loaders{i}.get_data('-hverbatim');
        if loaders{i}.sqw_type
            npixtot  = loaders{i}.npixels;
            nfiles = loaders{i}.num_contrib_files;
            sqw_display_single_(data,npixtot,nfiles,'a');
        else
            npixtot=1;    % *** MUST MAKE GET_SQW RETURN NPIXTOT IF 'b+' TYPE
            nfiles =1;
            sqw_display_single_(data,npixtot,nfiles ,'b+');
        end
    end
else
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
        if loaders{i}.sqw_type
            if hfull
                data = struct();
                [data.main_header,data.header,data.detpar,data.data] = ...
                    loaders{i}.get_sqw('-legacy','-nopix','-verbatim');
            else
                data         = loaders{i}.get_data('-verbatim','-nopix');
                if isa(data,'data_sqw_dnd')
                    data         = data.get_dnd_data('+'); % + get urange if available
                end
                data.npixels = loaders{i}.npixels;
                data.nfiles  = loaders{i}.num_contrib_files;
            end
        else
            if hfull
                data         = loaders{i}.get_data('-verbatim','-nopix');
            else
                data         = loaders{i}.get_data('-verbatim','-nopix','-head');
            end
            
            
        end
        vout{i} = data;
    end
    if cell_out
        varargout{1} = {vout};
    else
        varargout = vout(1:n_outputs);
    end
end

