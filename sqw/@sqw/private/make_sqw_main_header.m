function data = make_sqw_main_header
% Make a valid default main header block.
%
% Syntax:
%   >> data = make_sqw_main_header
%
% Output:
% -------
% The default is to create an empty structure, so that the sqw structure neatly
% resembles the old d0d, d1d,...
%
% In the general case, the fields would be:
%
%   data        Structure containing following fields:
%
%   data.filename   Name of sqw file that is being read, excluding path
%   data.filepath   Path to sqw file that is being read, including terminating file separator
%   data.title      Title of sqw data structure
%   data.nfiles     Number of spe files that contribute

% Original author: T.G.Perring
%
% $Revision:: 1751 ($Date:: 2019-06-03 09:47:49 +0100 (Mon, 3 Jun 2019) $)

data = struct([]);  % empty structure    
