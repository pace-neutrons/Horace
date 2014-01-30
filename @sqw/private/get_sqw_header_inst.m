function [mess, header, position] = get_sqw_header_inst (fid, header)
% Read the instrument fields in the header block.
%
%   >> [mess, header, position] = get_sqw_header_inst (fid, header)
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
%   header      Header block with the instrument field updated for each data set
%   position    Position of the start of the header instrument block
%
%
% Fields read from file are:
% --------------------------
%   header.instrument   Instrument description (scalar structure or object)

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
        header.instrument = get_variable_from_binfile(fid);
        
    elseif nfiles>1
        if all_same
            instrument = get_variable_from_binfile(fid);
            for i=1:nfiles
                header{i}.instrument=instrument;
            end
        else
            for i=1:nfiles
                header{i}.instrument = get_variable_from_binfile(fid);
            end
        end
    end
catch
    mess = 'Unable to read header instrument information from file';
end
