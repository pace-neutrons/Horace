function [data, mess] = get_sqw_header_opt (fid)
% Read the optional fields in the header block.
%
%   >> [data, mess] = get_sqw_header_opt (fid)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%
% Output:
% -------
%   data            Structure containing fields read from file (details below)
%   mess            Message if there was a problem writing; otherwise mess=''
%
%
% Fields read from the file are: 
%   data.instrument Instrument description
%   data.sample     Sample description
%
% Notes:
% ------
%   The two fields above are unstuctured, in that whatever the structure of the
% contents, it is written in full (however deeply nested, cell array, structures and 
% objects). This is to allow the format to evolve but to be reasonably robust in that
% the generic read will do the best that it can.


% Original author: T.G.Perring
%
% $Revision: 601 $ ($Date: 2012-02-08 14:46:10 +0000 (Wed, 08 Feb 2012) $)

data = [];
mess = '';

try
    data.instrument = get_variable_from_binfile(fid);
    data.sample = get_variable_from_binfile(fid);
catch
    mess = 'Unable to read position information from file';
end
