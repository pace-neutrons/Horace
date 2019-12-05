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


% Original author: T.G.Perring
%
% $Revision:: 1757 ($Date:: 2019-12-05 14:56:06 +0000 (Thu, 5 Dec 2019) $)

if nargout > 0
    varargout = set_instr_or_sample_horace_(filename,'-sample',sample,varargin{:});
else
    set_instr_or_sample_horace_(filename,'-sample',sample,varargin{:});
end

