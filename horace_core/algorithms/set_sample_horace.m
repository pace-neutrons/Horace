function varargout=set_sample_horace(filename,sample,varargin)
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
%  varargin    if present, the arguments of the instrument definition function
%
% Ouptut:
%  varargout   if present tries to load and returns the sqw objects from
%              the files, for which the instrument and/or sample has been set.
%              Will fail if the sqw objects are too big to fit memory.
%
% Original author: T.G.Perring
%


if nargout > 0
    out_list = set_instr_or_sample_horace_(filename,'-sample',sample,nargout,varargin{:});
    for i=1:nargout
        varargout{i}=out_list{i};
    end
else
    set_instr_or_sample_horace_(filename,'-sample',sample,0,varargin{:});
end

