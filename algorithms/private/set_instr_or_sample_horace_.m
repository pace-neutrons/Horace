function varargout=set_instr_or_sample_horace_(filename,kind,obj_to_set,varargin)
% Change the sample in a file or set of files containing a Horace data object
%
%   >>set_instr_or_sample_horace_(filename,kind,obj_to_set)
%
% The altered object is written to the same file.
%
% Input:
% -----
%   filename     File name, or cell array of file names. In latter case, the
%                 change is performed on each file
%   kind        is it sample or instrument is being set
%
%   obj_to_set Sample object (IX_sample object) or structure or
%              Instrument object, or sqw_object containing both sample and instrument
%              used as a source of instrument and sample information
%              Note: only a single obj_to_set object can be provided. That is,
%              there is a single sample or instrument for the entire sqw data set
%              If the sample is any empty object, then the sample is set
%              to the default empty structure.
%  varargin    if present, the arguments of the instrument definition function


% Original author: T.G.Perring
%
% $Revision:: 1753 ($Date:: 2019-10-24 20:46:14 +0100 (Thu, 24 Oct 2019) $)

if nargin<2
    error('Check number of input arguments')
end
if ~exist('obj_to_set','var')
    obj_to_set = struct();
end
if strcmp(kind,'-sample')
    set_sample = true;
else
    set_sample = false;
end
% get accessor(s), appropriate for the sqw file(s) provided
if ~iscell(filename)
    filename = {filename};
end
n_inputs = numel(filename);

lrds = cellfun(@(x)isa(x,'dnd_file_interface'),filename,'UniformOutput',true);
if any(lrds)
    ex_ldr = filename(lrds);
    filename = filename(~lrds);
    ld = sqw_formats_factory.instance().get_loader(filename);
    ld = {ld{:},ex_ldr{:}};
else
    ld = sqw_formats_factory.instance().get_loader(filename);
end


% upgrade the file to the format, which understands sample and prepare it
% for write operations (if necessary)
for i=1:numel(ld)
    ld{i} = ld{i}.upgrade_file_format();
    if set_sample
        ld{i}.put_samples(obj_to_set,varargin{:});
    else
        ld{i}.put_instruments(obj_to_set,varargin{:});
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
