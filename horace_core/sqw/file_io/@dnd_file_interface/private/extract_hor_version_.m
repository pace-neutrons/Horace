function [ver_struct,mess] = extract_hor_version_(data_stream)
% Cast data stream into Horace application version
%
% Original author: T.G.Perring
%
%
% $Revision:: 1758 ($Date:: 2019-12-16 18:18:50 +0000 (Mon, 16 Dec 2019) $)
%
%
% read application version
% Read header data from file. We require:
% (1) the application name is a valid variable name
% (2) the version to be real and greater or equal to zero
%
% NOTE: The prototype file format ('-v0') is not directly recognised, but is
%       assigned if the first entry is a integer followed by a character string
%       of that length.

ver_struct = struct('version',0,'name','unknown','typestart',0,...
    'uncertain',true,'sqw_type',false,'num_dim','undefined');
mess = [];

n = typecast(data_stream(1:4),'int32');
if n>0 && n<1024   % allow up to 1024 characters in filename if bytes are from
    % Horace version 0;
    name = char(data_stream(4+1:4+n))'; % for modern Hor versions it will be 'Horace'
    % Need to try to catch case of e.g. text file where n is read as a stupidly high number
    if ~isvarname(name) % for Horace v0 it will be filename
        [ok,uncertain] = check_hor_v0(name,data_stream);
        if ok
            ver_struct.name = 'horace';
            ver_struct.typestart = 0;
            ver_struct.sqw_type=true;
            if uncertain
                ver_struct.uncertain = true;
            else
                ver_struct.uncertain = false;
            end
            return
        end
        mess = 'Application name is not valid Matlab variable name';
        return;
    end
    version =typecast(data_stream(4+n+1:4+n+8),'double'); % looks like it is some modern Horace version
    if ~isscalar(version) || version<0 || version>99999999
        mess = ['Application version: ', num2str(version), ' is not allowed version number'];
        return;
    end
    ver_struct.typestart = 4+n+8;
    ver_struct.version = version;
    ver_struct.name = name;
else
    mess='Not Horace binary format';
    return;
end
if n == 6 && strcmp(name,'horace') % it still may be strange file name like file named "horace"
    typestart = ver_struct.typestart;
    sqw_type =   typecast(data_stream(typestart+1:typestart+4),'int32');
    num_dim  = typecast(data_stream(typestart+5:typestart+8),'int32');
    if (sqw_type == 1 || sqw_type == 0) && (num_dim>=0 && num_dim<=4) % some data from version 0 so its probably v0
        ver_struct.sqw_type=logical(sqw_type);
        ver_struct.num_dim=num_dim;
        ver_struct.uncertain = false;
    else % still may be Horace v0 but need to read more data to be sure
        ver_struct.name = 'horace';
        ver_struct.typestart = 0;
        ver_struct.sqw_type=true;
        ver_struct.ver_uncertain = true;
    end
end


function [ok,uncertain] = check_hor_v0(name,data_stream)
% check if header contains filepath
uncertain = false;
[fp,fn,fext] = fileparts(name);
if ~(isempty(fp) && numel(fn)>0 && numel(fext)>0)
    ok = false;
    return
end
nfn = numel(name)+4;
if numel(data_stream)<=nfn+4 % have not read enough to understand if it is Horace
    ok = true;
    uncertain = true;
    return
end
n = typecast(data_stream(nfn+1:nfn+4),'int32');
if n<0 || n >2046 % filepath is too long
    ok = false;
    return
end
if n>0 % otherwise assume Horace for the time being
    if numel(data_stream)<nfn+n+4
        uncertain = true;
        ok = true;   % at this point assume its Horace but need further checks
        return;
    end
    path = char(data_stream(nfn+4+1:nfn+n+4))';
    if isvarname(path ) % filepath contains symbols not in var name so its not
        ok = false;
        return
    end
else
    ok = false;
    return;
end
ok=true;

