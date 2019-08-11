function C=path2cell(pathstr)
% Create a cell array of directories from a Matlab path string
%
%   >> C = path2cell (pathstr)
%
% Input:
% ------
%   pathstr     Matlab path string e.g. as created using genpath
%
% Output:
% -------
%   C           Cell array of strings, one element per entry in pathstr


if is_string(pathstr)
    % Seems that sometimes the path ends with the pathsep, sometimes not
    if ~isempty(pathstr) && pathstr(end:end)==pathsep
        pathstr=pathstr(1:end-1);
    end
else
    error('Input argument must be a character string')
end

ind=strfind(pathstr,pathsep);
if isempty(ind)
    if isempty(pathstr)
        C=cell(1,0);
    else
        C={pathstr};
    end
else
    n=numel(ind)+1;
    C=cell(1,n);
    C{1}=pathstr(1:ind(1)-1);
    for i=2:n-1
        C{i}=pathstr(ind(i-1)+1:ind(i)-1);
    end
    C{n}=pathstr(ind(n-1)+1:end);
end
