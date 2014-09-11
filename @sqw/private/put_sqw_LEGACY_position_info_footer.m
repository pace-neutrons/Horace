function put_sqw_LEGACY_position_info_footer (S)



%==================================================================================================
function [mess, position] = put_sqw_LEGACY_file_footer (fid, position_info_location, data_type)
% Write final entry to sqw file: location of position information in the file and data_type
%
%   >> [mess, position] = put_sqw_file_footer (fid, position_info_location, data_type)
%
% Input:
% ------
%   fid                     File identifier of output file (opened for binary writing)
%   position_info_location  Position of the position information block
%   data_type               Type of sqw data contained in the file:
%                               type 'b'    fields: filename,...,uoffset,...,dax,s,e
%                               type 'b+'   fields: filename,...,uoffset,...,dax,s,e,npix
%                               type 'a'    fields: filename,...,uoffset,...,dax,s,e,npix,urange,pix
%                               type 'a-'   fields: filename,...,uoffset,...,dax,s,e,npix,urange
%
% Output:
% -------
%   mess                    Message if there was a problem writing; otherwise mess=''
%   position                Position of the file footer in the file


% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)

mess = '';
position = ftell(fid);

try
    % Position of position information block
    fwrite(fid,position_info_location,'float64');
    
    % Data type (last entry)
    % (Note that the length of the data type is written last, so that it can be
    % discovered by going to the end of the file and then backing up 4 bytes)
    n=length(data_type);
    fwrite(fid,data_type,'char*1');
    fwrite(fid,n,'int32');              % write length of data_type
    
catch
    mess='Unable to write footer block to file';
end



%==================================================================================================
function [mess, position] = put_sqw_LEGACY_position_info (fid, position_in, update)
% Write the positions of the various key data blocks in the sqw file
%
%   >> [mess, position] = put_sqw_position_info (fid, position_in, update)
%
% Input:
% ------
%   fid             File identifier of output file (opened for binary writing)
%   position_in     Structure which must contain (at least) the fields listed below
%   update          If false, then write the field 'position_info' as stored in position_in
%                   If true, then update position_info as the current position in the file
%
% Output:
% -------
%   mess            Message if there was a problem writing; otherwise mess=''
%   position        Position structure with field position_info updated to the
%                  true value determined in this function
%
%
% Fields written to file are: 
% ---------------------------
%   position.main_header    start of main_header block (=[] if not written)
%   position.header         start of each header block (column vector, length main_header.nfiles)
%                          (=[] if not written)
%   position.detpar         start of detector parameter block (=[] if not written)
%   position.data           start of data block
%   position.s              position of array s
%   position.e              position of array e
%   position.npix           position of array npix (=[] if npix not written)
%   position.urange         position of array urange (=[] if urange not written)
%   position.pix            position of array pix  (=[] if pix not written)
%   position.instrument     start of header instrument blocks (=[] if not written in the file)
%   position.sample         start of header sample blocks (=[] if not written in the file)
%   position.position_info  start of the position block


% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)

mess = '';
position=position_in;
if update
    position.position_info=ftell(fid);
end

try
    put_variable_to_binfile(fid,position)
catch
    mess='Unable to write position information to file';
end
