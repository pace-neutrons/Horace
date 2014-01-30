function varargout=set_instrument_horace(varargin)
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
% $Revision: 791 $ ($Date: 2013-11-15 22:54:46 +0000 (Fri, 15 Nov 2013) $)

if nargin<1 ||nargin>2
    error('Check number of input arguments')
elseif nargout>0
    error('No output arguments returned by this function')
end

[varargout,mess] = horace_function_call_method (nargout, @set_instrument, '$hor', varargin{:});
if ~isempty(mess), error(mess), end
