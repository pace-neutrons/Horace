function [mess, S] = put_sqw_LEGACY_position_info_footer (Sin, newfile, wrote_inst_and_samp)

fid=Sin.fid;


% Update the file format depending on newfile and wrote_inst_and_samp
S=Sin;
if newfile
    if ~wrote_inst_and_samp
        % If requested '-v1', will certainly be '-v1' as the inst and sample were ignored
        % If requested '-v3', then all data written will be '-v1' format, so label
        % as such (this was the behaviour of earlier versions of Horace)
        S.application.file_format=appversion(1);
    end
else
    if wrote_inst_and_samp
        % By definition must be '-v3' file, even if file started as '-v1'
        % If '-v3', then setting the inst and sample to empty does not reduce the format number
        % as there will be some bytes that must be ignored.
        S.application.file_format=appversion(3);
    end
end


% Create the legacy position block
position=S.position;

pos = struct('main_header',[],'header',[],'detpar',[],'data',[],'s',[],'e',[],'npix',[],...
    'urange',[],'pix',[],'instrument',[],'sample',[],'position_info',[]);
if ~isnan(position.main_header), pos.main_header=position.main_header; end
if ~isnan(position.header), pos.header=position.header; end
if ~isnan(position.detpar), pos.detpar=position.detpar; end
pos.s=position.s;
pos.e=position.e;
pos.npix=position.npix;
if ~isnan(position.urange), pos.urange=position.urange; end
if ~isnan(position.pix), pos.pix=position.pix; end
if ~isnan(position.instrument), pos.instrument=position.instrument; end
if ~isnan(position.sample), pos.sample=position.sample; end
pos.position_info=0;    % dummy value to ensure correct space in file; will be updated later.


% Create the footer block
if S.info.sqw_type
    data_type='a';
else
    data_type='b+';
end


% Write data to file
if newfile
    % Can write straight to file
    [mess, position] = put_sqw_LEGACY_position_info (fid, position, true);
    if ~isempty(mess), return, end
    mess=put_sqw_LEGACY_file_footer(fid,position.position_info, data_type);
    if ~isempty(mess), return, end
    
else
    % Determine
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
