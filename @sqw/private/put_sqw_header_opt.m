function mess = put_sqw_header_opt (fid, data)
% Write the optional fields in the header block.
%
%   >> mess = put_sqw_header_opt (fid, data)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   data            Data structure which must contain (at least) the fields listed below
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%
%
% Fields written to file are: 
%   data.instrument Instrument description (scalar structure or object)
%   data.sample     Sample description (scalar structure or object)
%
% Notes:
% ------
%   The two fields above are unstuctured, in that whatever the structure of the
% contents, it is written in full (however deeply nested, cell array, structures and 
% objects). This is to allow the format to evolve but to be reasonably robust in that
% the generic read will do the best that it can.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';

% Skip if fid not open
flname=fopen(fid);
if isempty(flname)
    mess = 'No open file with given file identifier. Skipping write routine';
    return
end

% Write to file
try
    put_variable_to_binfile(fid,data.instrument)
    put_variable_to_binfile(fid,data.sample)
catch
    mess='Unable to write optional header information to file';
end
