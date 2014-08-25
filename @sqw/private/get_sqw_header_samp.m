function [mess, header, pos_start] = get_sqw_header_samp (fid, fmt_ver, header)
% Read the sample fields in the header block.
%
%   >> [mess, header, position] = get_sqw_header_samp (fid, header)
%
% Input:
% ------
%   fid         File pointer to (already open) binary file
%   fmt_ver         Version of file format e.g. appversion('-v3')
%   header      Header block: single data structure (if single spe file) or
%              cell array of structures, one per spe file
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%   header      Header block with the sample field updated for each data set
%   pos_start   Position of the start of the header sample block
%
%
% Fields read from file are:
% --------------------------
%   header.sample   Instrument description (scalar structure or object)


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess = '';
pos_start = ftell(fid);

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
