function varargout=set_sample_horace(varargin)
% Change the sample in a file or set of files containing a Horace data object
%
%   >> set_sample_horace (file, sample)
%
% The altered object is written to the same file.
%
% Input:
% -----
%   file        File name, or cell array of file names. In latter case, the
%              change is performed on each file
%
%   sample      Sample object (IX_sample object) or structure
%              Note: only a single sample object can be provided. That is,
%              there is a single sample for the entire sqw data set
%               If the sample is any empty object, then the sample is set
%              to the default empty structure.


% Original author: T.G.Perring
%
% $Revision: 791 $ ($Date: 2013-11-15 22:54:46 +0000 (Fri, 15 Nov 2013) $)

if nargin<1 || nargin>2
    error('Check number of input arguments')
elseif nargout>0
    error('No output arguments returned by this function')
end

[varargout,mess] = horace_function_call_method (nargout, @set_sample, '$hor', varargin{:});
if ~isempty(mess), error(mess), end
