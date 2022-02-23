function sqwobj_array=set_instr_or_sample_horace_(filename,kind,obj_to_set,narg,varargin)
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
%  narg        number of aguments to return, i.e. number of sqw files to
%              read
%  varargin    if present, the arguments of the instrument definition function
% 
% Output:
%-------
% sqwobj_array -- cellarray of sqw objects corresponding to input sqw files 
%                 read from the disk if narg>0. Empty if it is 0
%                

% Original author: T.G.Perring
%

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
        ld{i}=ld{i}.put_samples(obj_to_set,varargin{:});
    else
        ld{i}=ld{i}.put_instruments(obj_to_set,varargin{:});
    end
end


if narg > 0
    n_files2read = numel(filename);
    nout = min(n_files2read,narg);
    sqwobj_array = cell(nout,1);
    for i=1:nout
        sqwobj_array{i} = ld{i}.get_sqw();
    end
else
    sqwobj_array={};
end

