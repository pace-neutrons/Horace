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
%   instrument  Instrument object or structure, or array of objects or
%              structures, with number of elements equal to the number of
%              runs contributing to the sqw object(s).
%               If the instrument is any empty object, then the instrument
%              is set to the default empty structure.

% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)
if nargout > 0
    varargout = set_instr_or_sample_horace_(filename,'-instrument',instrument,varargin{:});
else
    set_instr_or_sample_horace_(filename,'-instrument',instrument,varargin{:});
end
