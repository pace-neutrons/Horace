function [mess, header, position] = get_sqw_header_samp (fid, header)
% Read the sample fields in the header block.
%
%   >> [mess, header, position] = get_sqw_header_samp (fid, header)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   header      Header block: single data structure (if single spe file) or
%              cell array of structures, one per spe file
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%   header      Header block with the sample field updated for each data set
%   position    Position of the start of the header sample block
%
%
% Fields read from file are:
% --------------------------
%   header.sample   Instrument description (scalar structure or object)


% Original author: T.G.Perring
%
% $Revision: 791 $ ($Date: 2013-11-15 22:54:46 +0000 (Fri, 15 Nov 2013) $)

mess = '';
position = ftell(fid);

try
    block_descr=get_variable_from_binfile(fid);
    if block_descr.version==1
        nfiles=block_descr.nfiles;
        all_same=block_descr.all_same;
    else
        error('Unrecognised block format')
    end
    
    if nfiles==1
        header.sample = get_variable_from_binfile(fid);
        
    elseif nfiles>1
        if all_same
            sample = get_variable_from_binfile(fid);
            for i=1:nfiles
                header{i}.sample=sample;
            end
        else
            for i=1:nfiles
                header{i}.sample = get_variable_from_binfile(fid);
            end
        end
    end
catch
    mess = 'Unable to read header sample information from file';
end
