function strout=str_compress(str,subst)
% Trim a string and replace any continuous internal whitespace with a single instance of the substitution string
% Default is to substitute a single space.
%
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
elseif ischar(subst) && size(subst,1)==1
    strout=subst;
    nsub=length(subst);
else
    error('Check substitution string is a row of characters')
end

strout=subst;
while ~isempty(str)
    [tok,str]=strtok(str);
    if ~isempty(tok)
        strout=[strout,tok,subst];
    end
end
strout=strout(1+nsub:end-nsub);
