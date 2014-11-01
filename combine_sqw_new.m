function varargout = combine_sqw (varargin)
% Combine a collection of sqw files &/or sqw objects &/or sparse sqw data structures
%
% Create sqw object:
%   >> wout = combine_sqw (s1, s2, s3,...)
%
% Create sqw file:
%   >> combine_sqw (s1, s2, s3,..., outfile)
%
% Input:
% ------
%   s1, s2,...  Data to be combined. Each of s1, s2, s3,... can be one of
%               - sqw file name, or cell array of sqw file names (if a name
%                is empty it is ignored)
%               - sqw object or array of sqw objects (if an object matches
%                the empty sqw object it is ignored)
%               - sparse sqw data structure or array of sparse sqw structures
%                (if an object 
%
%   outfile     [Optional] Full name of output sqw file
%               If not given, then it is assumed that the output will be to
%               an sqw object in memory
%
% Output:
% -------
%   wout        [Optional] sqw object with combined data
%               If not given, then it is assumed that an output file name was given


% Original author: T.G.Perring
%
% $Revision: 880 $ ($Date: 2014-07-16 08:18:58 +0100 (Wed, 16 Jul 2014) $)


% Add dummy sqw object to start of input argument list to guarantee that the 
% sqw method sqw/combine is called

if nargout==0
    combine (sqw, varargin{:});
elseif nargout==1
    varargout{1} = combine (sqw, varargin{:});
else
    error('Check number of output arguments')
end
