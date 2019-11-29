function strout=str_compress(str,subst)
% Trim a string or cellarray of strings and substitute internal whitespace
%
%   >> strout=str_compress(str)
%   >> strout=str_compress(str,subst)
%
% Input:
% ------
%   str     String, or cell array of strings
%   subst   Character string  to replace continuous internal whitespace
%           If not given, substitute a single space
%
% Output:
% -------
%   strout  Output string or cell array of strings
%
% EXAMPLES
%   >> str='   hello    mister   man ';
%   >> strout=str_compress(str)
%           'hello mister man'
%
%   >> str='  10     20     0.001 ';
%   >> strout=str_compress(str,',')
%           '10,20,0.001

if nargin==1
    subst=' ';
    nsub=1;
elseif ischar(subst) && size(subst,1)==1 && size(subst,2)>0
    nsub=length(subst);
else
    error('Check substitution string is a row of characters')
end

if ischar(str)
    if size(str,1)~=1
        error('Input is not a character string or cell array of character strings')
    end
    strout=str_compress_single(str,subst,nsub);
elseif iscellstr(str)
    strout=cell(size(str));
    for i=1:numel(str)
        if size(str{i},1)~=1
            error('Input is not a character string or cell array of character strings')
        end
        strout{i}=str_compress_single(str{i},subst,nsub);
    end
else
    error('Check input is a string or cell array of strings')
end

%------------------------------------------------------------------------------
function strout=str_compress_single(str,subst,nsub)
strout=subst;
while ~isempty(str)
    [tok,str]=strtok(str);
    if ~isempty(tok)
        strout=[strout,tok,subst];
    end
end
strout=strout(1+nsub:end-nsub);
