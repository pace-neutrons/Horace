function x = str_token_to_iarray (string)
% str_token_to_iarray
%   Reads string and converts to integer row array. Valid strings have form
%        single integers: 'mmm', '-mmm'
%       list of integers: 'mmm-nnn', '-mmm-nnn', 'mmm--nnn', '-mmm--nnn'
%   If not a valid integer or integer list, then returns empty array []
%   If the first number in a pair is larger than the second, then a
%   list is created with the higher number first.
%
% e.g.   '34-30' => [34,33,32,31,30]
%      '-12--10' => [-12,-11,-10]
%        '-3--5' => [-3,-4,-5]
%

a = strfind(string,'-');
a = a(find(a>1));        % array of positions of '-', excluding case of position 1
if (length(a)==0)
%    x = str2num(string);
    x = sscanf(string,'%d');
    if isempty(x)
        x = [];
    end
else
%    xlo = str2num(string(1:a(1)-1));
%    xhi = str2num(string(a(1)+1:end));
    xlo = sscanf(string(1:a(1)-1),'%d');
    xhi = sscanf(string(a(1)+1:end),'%d');
    if (~isempty(xlo)&~isempty(xhi))
        x = linspace(xlo,xhi,abs(xhi-xlo)+1);
    else
        x = [];
    end
end
