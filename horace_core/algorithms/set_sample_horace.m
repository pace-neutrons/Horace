function varargout=set_sample_horace(filename,sample)
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
%
% Ouptut:
%  varargout   if present tries to load and returns the sqw objects from
%              the files, for which the instrument and/or sample has been set.
%              Will fail if the sqw objects are too big to fit memory.
%
% Original author: T.G.Perring
%


out = set_sample(filename,sample);
for i=1:nargout
    varargout{i} = out{i};
end
