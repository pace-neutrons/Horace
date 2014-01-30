function [mess, position] = put_sqw_header_samp (fid, header)
% Write the sample fields in the header block.
%
%   >> [mess, position] = put_sqw_header_samp (fid, header)
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
%   position        Position of the start of the header sample block
%
%
% Fields written to file are:
% ---------------------------
%   header.sample   Sample description (scalar structure or object)
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
% $Revision: 791 $ ($Date: 2013-11-15 22:54:46 +0000 (Fri, 15 Nov 2013) $)

mess='';
position = ftell(fid);

try
    % Description of sample block format in file
    block_descr=struct('version',1,'nfiles',[],'all_same',false);
    
    if isstruct(header)
        % A single header, as a data structure, so only one sample
        block_descr.nfiles=1;
        block_descr.all_same=true;
        put_variable_to_binfile(fid,block_descr)
        put_variable_to_binfile(fid,header.sample)
        
    else
        % Should be a cell array of headers.
        nfiles=numel(header);
        % Determine if the sample is the same for all datasets
        sample=header{1}.sample;
        all_same=true;
        for i=2:nfiles
            if ~isequal(sample,header{i}.sample)
                all_same=false;
                break
            end
        end
        % Write sample block(s)
        block_descr.nfiles=nfiles;
        block_descr.all_same=all_same;
        put_variable_to_binfile(fid,block_descr)
        if all_same
            put_variable_to_binfile(fid,sample)
        else
            for i=1:nfiles
                put_variable_to_binfile(fid,header{i}.sample)
            end
        end
    end
    
catch
    mess='Unable to write sample information in the header to file';
end
