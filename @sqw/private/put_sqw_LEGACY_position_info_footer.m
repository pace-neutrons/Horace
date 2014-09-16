function [mess, S] = put_sqw_LEGACY_position_info_footer (Sin, newfile, pos_header_arr, wrote_inst_and_samp)
% Update the sqwfile structure and write position and footer information, if required
%
%   >> [mess, S] = put_sqw_LEGACY_position_info_footer (Sin, newfile, pos_header_arr, wrote_inst_and_samp)

% *** Should only ever be called if dat_type is sqw-type, because sample and instrument information 
%     can only be written to such a file. Therefore some of the checks in this function are redundant.


% Original author: T.G.Perring
%
% $Revision: 877 $ ($Date: 2014-06-10 12:35:28 +0100 (Tue, 10 Jun 2014) $)


% Initialise output arguments
S=Sin;


% -------------------------------------------------------------------------------------------------
% Update the file format depending on newfile and wrote_inst_and_samp
% -------------------------------------------------------------------------------------------------
if newfile
    if ~wrote_inst_and_samp
        % - If requested '-v1', will certainly be '-v1' as the inst and sample were ignored
        % - If requested '-v3', then all data written will be '-v1' format, so label as such 
        %   (this was the behaviour of earlier versions of Horace)
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


% -------------------------------------------------------------------------------------------------
% Write position and footer information if '-v3'
% -------------------------------------------------------------------------------------------------
% Return if '-v1'
if S.application.file_format==appversion(1)
    mess='';
    return
end

fid=Sin.fid;
position=S.position;

% Create the legacy position block
% --------------------------------
pos = struct('main_header',[],'header',[],'detpar',[],'data',[],'s',[],'e',[],'npix',[],...
    'urange',[],'pix',[],'instrument',[],'sample',[],'position_info',[]);
if ~isnan(position.main_header), pos.main_header=position.main_header; end
if ~isnan(position.header), pos.header=pos_header_arr; end
if ~isnan(position.detpar), pos.detpar=position.detpar; end
if ~isnan(position.data), pos.data=position.data; end
pos.s=position.s;
pos.e=position.e;
pos.npix=position.npix;
if ~isnan(position.urange), pos.urange=position.urange; end
if ~isnan(position.pix), pos.pix=position.pix; end
if ~isnan(position.instrument), pos.instrument=position.instrument; end
if ~isnan(position.sample), pos.sample=position.sample; end


% Create the footer block
% -----------------------
if S.info.sqw_type
    data_type='a';
else
    data_type='b+';
end


% Get to a suitable location to write the legacy position block
% -------------------------------------------------------------
% If a newfile, then use the current location, as the last I/O action was
% writing the data (if no inst+samp) or the inst+samp. There should have been no
% fseek operations since, so the file position locator is at the next position to write
%
% If not a new file
% - if inst+samp was written, use the current location as again this was the most
%   recent I/O action and there have been no fseek operations since.
% - if no inst+samp was written, then either
%       - there is no inst+sample (because there never was, or we no longer want
%         to keep the current inst+samp), so move to the end of the data section
%       - we want to keep the existing inst+samp, in which case the current location
%         of the position information is a good location.

if ~newfile
    % Get location of position and footer sections in the current file (will need footer location later)
    pos_tmp=ftell(fid);
    fseek(fid,0,'eof');
    [mess, position_info_location, data_type_stored, footer_location] = get_sqw_LEGACY_file_footer (fid);
    if ~isempty(mess), return, end
    if ~strcmpi(data_type,data_type_stored)     % should be OK, but lets catch a logic error
        mess='Stored data type and actual data type mis-match (put_sqw_LEGACY_position_info_footer)';
        return
    end
    fseek(fid,pos_tmp,'bof');   % return to position before this excursion
    
    % If inst+samp written, currently in correct location; if not, move to location where
    % position section is to be written
    if ~wrote_inst_and_samp
        if isnan(position.instrument)
            fseek(fid,position.data_end,'bof');     % end of data section (dont want to keep any existing inst+samp)
        else
            fseek(fid,position_info_location,'bof');% retain existing inst+samp, so use current location
        end
    end
end
pos.position_info=ftell(fid);


% Write data to file
% ------------------
% Write position information
mess = put_sqw_LEGACY_position_info (fid, pos, false);
if ~isempty(mess), return, end

% Write footer
if ~newfile
    % Determine if there is room to add before the end of the file (the footer
    % will have the same length, as the data_type cannot have changed); the footer
    % must always run up to the end of the file.
    if ftell(fid)<footer_location
        fseek(fid,footer_location,'bof');
    end
end
mess = put_sqw_LEGACY_file_footer(fid, pos.position_info, data_type);
if ~isempty(mess), return, end



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
