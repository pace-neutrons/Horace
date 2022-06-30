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
    if nargin == 1
        subst = ' ';
    end

    if iscellstr(str) || isstring(str)
        splt = cellfun(@(x)(split(strip(x))), str, 'UniformOutput', false);
        strout = cellfun(@(x)(strjoin(x, subst)), splt, 'UniformOutput', false);
    else
        splt = split(strip(str));
        strout = strjoin(splt, subst);
    end

end
