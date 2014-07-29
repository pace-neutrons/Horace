function [mess, position] = put_sqw_header_inst (fid, header)
% Write the instrument fields in the header block.
%
%   >> [mess, position] = put_sqw_header_inst (fid, fmt_ver, header)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   header          Header block: single data structure (if single spe file) or
%                  cell array of structures, one per spe file, which must contain
%                  at least the fields listed below.
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Position of the start of the header instrument block
%
%
% Fields written to file are:
% ---------------------------
%   header.instrument   Instrument description (scalar structure or object)
%
%
% Notes:
% ------
% The field above is unstuctured, in that whatever the structure of the
% contents, it is written in full (however deeply nested, cell array, structures and
% objects). This is to allow the format to evolve but to be reasonably robust in that
% the generic read will do the best that it can.


% Original author: T.G.Perring
%
% $Revision$ ($Date$)

mess='';
position = ftell(fid);

try
    % Description of instrument block format in file
    block_descr=struct('version',1,'nfiles',[],'all_same',false);
    
    if isstruct(header)
        % A single header, as a data structure, so only one instrument
        block_descr.nfiles=1;
        block_descr.all_same=true;
        put_variable_to_binfile(fid,block_descr)
        put_variable_to_binfile(fid,header.instrument)
        
    else
        % Should be a cell array of headers.
        nfiles=numel(header);
        % Determine if the instrument is the same for all datasets
        instrument=header{1}.instrument;
        all_same=true;
        for i=2:nfiles
            if ~isequal(instrument,header{i}.instrument)
                all_same=false;
                break
            end
        end
        % Write instrument block(s)
        block_descr.nfiles=nfiles;
        block_descr.all_same=all_same;
        put_variable_to_binfile(fid,block_descr)
        if all_same
            put_variable_to_binfile(fid,instrument)
        else
            for i=1:nfiles
                put_variable_to_binfile(fid,header{i}.instrument)
            end
        end
    end
    
catch
    mess='Unable to write instrument information in the header to file';
end
