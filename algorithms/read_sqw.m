function varargout = read_sqw(varargin)
% Read sqw object from named file or an array of sqw objects from a cell array of file names
%
%   >> w=read_sqw(file)     % read named file or cell array of file names
%                           into array of sqw objects or cellarray of sqw/dnd ojects
%
% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)

% Read sqw object from a file or array of sqw objects from a set of files
%
%   >> w=read_sqw(file)
%
% Need to give first argument as an sqw object to enforce a call to this function.
% Can simply create a dummy object with a call to sqw:
%    e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
% Input:
% -----
%   sqw         Dummy sqw object to enforce the execution of this method.
%               Can simply create a dummy object with a call to sqw:
%                   e.g. >> w = read(sqw,'c:\temp\my_file.sqw')
%
%   file        File name, or cell array of file names. In this case, reads
%               into an array of sqw objects
%
% Output:
% -------
%   w           sqw object, or array of sqw objects if given cell array of
%               file names

% Original author: T.G.Perring
%
% $Revision: 1313 $ ($Date: 2016-11-02 19:42:08 +0000 (Wed, 02 Nov 2016) $)


% Perform operations
% ------------------
% Check number of arguments
if isempty(varargin)
    error('READ_SQW:invalid_argument','read: Check number of input arguments')
end

n_outputs = nargout;
if n_outputs>nargin
    error('READ_SQW:invalid_argument',...
        'number of output objects requested is bigger then the number of input files provided')
end

files = varargin{1};
if iscell(files)
    argi = files;
else
    argi = {files};
end
%
all_fnames = cellfun(@ischar,argi,'UniformOutput',true);
if ~any(all_fnames)
    error('READ_SQW:invalid_argument','read_sqw: not all input arguments represent filenames')
end
%-------------------------------------------------------------------------

n_inputs=numel(argi);
loaders = sqw_formats_factory.instance.get_loader(argi);
if ~iscell(loaders )
    loaders = {loaders};
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
    trez{i} = loaders{i}.get_sqw();
end

varargout = pack_io_outputs(trez,n_inputs,n_outputs);
