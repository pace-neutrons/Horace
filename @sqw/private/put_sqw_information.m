function [mess, position] = put_sqw_information (S)
% Write the sqwfile header information at the top of an sqw file
%
%   >> [mess, position] = put_sqw_information (fid, S)
%
% Input:
% ------
%   S           sqwfile structure
%
% Output:
% -------
%   mess        Message if there was a problem writing; otherwise mess=''
%   position    Structure with fields:
%                   position.application    start of application block
%                   position.info           start of info block
%                   position.position       start of position block
%                   position.fmt            start of format block


% Original author: T.G.Perring
%
% $Revision: 885 $ ($Date: 2014-07-29 17:35:24 +0100 (Tue, 29 Jul 2014) $)


fid=S.fid;

position_ref = struct('application',ftell(fid),'info',NaN,'position',NaN,'fmt',NaN);
position=position_ref;

fmt_ver=S.application.file_format;

try
    [mess, position.application] = put_sqw_application (fid, S.application);
    if ~isempty(mess), position=position_ref; return, end
        
    [mess, position.info] = put_sqw_info (fid, fmt_ver, S.info);
    if ~isempty(mess), position=position_ref; return, end
    
    [mess, position.position] = put_sqw_position (fid, fmt_ver, S.position);
    if ~isempty(mess), position=position_ref; return, end

    [mess, position.fmt] = put_sqw_fmt (fid, fmt_ver, S.fmt);
    if ~isempty(mess), position=position_ref; return, end
    
catch
    mess='Error writing summary block to file';
    position=position_ref;
end
