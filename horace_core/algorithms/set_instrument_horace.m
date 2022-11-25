function varargout=set_instrument_horace(filename,instrument,varargin)
% Change the instrument in a file or set of files containing a Horace data object
%
%   >> set_instrument_horace (file, instrument)
%
% The altered object is written to the same file.
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%
%   instrument  Instrument object, or array of objects with number of elements
%               equal to the number of
%               runs contributing to the runs stored in sqw object(s).
%
%              If the instrument is any empty object, then the instrument
%              is set to the default empty structure.
%
% *OR*
%   inst_func      Function handle to generate instrument object or structure
%                  Must be of the form
%                       inst = my_func (p1, p2, ...)
%                  where p1,p2, ... are parameters to be passed to the
%                  instrument definition function, in this case called my_func,
%                  which in this example will be passed as @my_func.
%
%   arg1, arg2,...  Arguments to be provided to the instrument function.
%                  The arguments must be:
%                   - scalars, row vectors (which can be numerical, logical,
%                     structure, cell array or object), or character strings.
%                   - Multiple arguments can be passed, one for each run that
%                     constitutes the sqw object, by having one row per run
%                     i.e
%                       scalar      ---->   column vector (nrun elements)
%                       row vector  ---->   2D array (nrun rows)
%                       string      ---->   cell array of strings
%
%                  Certain arguments win the sqw object can be referred to by
%                  special strings;
%                       '-efix'     ---->   use value of fixed energy in the
%                                           header block of the sqw object
% Output:
%-------
%  varargout   if present tries to load and returns the sqw objects from
%              the files, for which the instrument and/or sample has been set.
%              Will fail if the sqw objects are too big to fit memory.
%

% Original author: T.G.Perring
%
out = set_instrument(filename,instrument,varargin{:});
for i=1:nargout
    varargout{i} = out{i};
end
