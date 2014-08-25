function write_sqw_var_char (fid,fmt_ver,ch,nfix)
% Write character string or cell array of strings to open binary file
%
%   >> write_sqw_var_char (fid,fmt_ver,ch)
%   >> write_sqw_var_char (fid,fmt_ver,ch,nfix)
%
% Input:
% ------
%   fid         File identifier
%   fmt_ver     File format (appversion object)
%   ch          Character string or cell array of strings
%
% For fmt_ver>=3.1 (ignored for earlier file format versions)
%   nfix        [optional] fix the length of each string to this value



if fmt_ver>=appversion(3.1)
    % Remove leading and trailing blanks, and turn into character array
    if iscellstr(ch)
        chtmp=char(strtrim(ch));
    else
        chtmp=strtrim(ch);
    end
    % Write to file
    n=size(chtmp);
    if nargin==3
        fwrite(fid,n,'float64');  % write length of string
        fwrite(fid,chtmp,'char*1');
    else
        if n(2)>nfix
            tmp=chtmp(:,nfix);
        elseif n(2)<nfix
            tmp=[chtmp,repmat(' ',n(1),nfix-n(2))];
        else
            tmp=chtmp;
        end
        fwrite(fid,[n(1),nfix],'float64');    % write length of string
        fwrite(fid,tmp,'char*1');
    end
else
    % Horace file formats prior to '-v3.1'
    if iscellstr(ch)
        chtmp=char(ch);     % do not remove blanks, for consistency with earlier Horace versions
    else
        chtmp=ch;
    end
    if size(chtmp,1)==1 || isempty(chtmp)     % character string (or 1x0 or 0x0 array)
        n=numel(chtmp);
    else
        n=size(chtmp);
    end
    fwrite(fid,n,'int32');
    fwrite(fid,chtmp,'char');
end
