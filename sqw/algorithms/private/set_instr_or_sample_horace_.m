function varargout=set_instr_or_sample_horace_(filename,kind,obj,varargin)
% Change the sample in a file or set of files containing a Horace data object
%
%   >> set_sample_horace (file, sample)
%
% The altered object is written to the same file.
%
% Input:
% -----
%   file       File name, or cell array of file names. In latter case, the
%              change is performed on each file
%
%   sample     Sample object (IX_sample object) or structure
%              Note: only a single sample object can be provided. That is,
%              there is a single sample for the entire sqw data set
%              If the sample is any empty object, then the sample is set
%              to the default empty structure.


% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)

if nargin<2
    error('Check number of input arguments')
end
if ~exist('obj','var')
    obj = struct();
end
if strcmp(kind,'-sample')
    set_sample = true;
else
    set_sample = false;
end

% get accessor, appropriate for the sqw file provided
if iscell(filename)
    n_inputs = numel(filename);
    ld = cell(1,n_inputs);
    for i=1:n_inputs
        ld{i} = sqw_formats_factory.instance().get_loader(filename{i});
    end
else
    n_inputs = 1;
    ld = {sqw_formats_factory.instance().get_loader(filename)};
    filename = {filename};
end

% upgrade the file to the format, which understands sample and prepare it
% for write operations (if necessary)
for i=1:numel(ld)
    ld{i} = ld{i}.upgrade_file_format();
    if set_sample
        ld{i}.put_samples(obj,varargin{:});
    else
        ld{i}.put_instruments(obj,varargin{:});
    end
end


if nargout > 0
    n_files2read = numel(filename);
    if nargout>1
        n_files2read  = nargout;
    end
    trez = cell(1,n_files2read);
    for i=1:n_files2read
        trez{i} = ld{i}.get_sqw();
    end
    varargout = pack_outputs(trez,n_inputs,nargout);
end
