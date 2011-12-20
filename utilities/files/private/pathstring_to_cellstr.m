function pathcell=pathstring_to_cellstr(pathstring)
% Convert path string into cellstr of paths. Strips leading and trailing whitespace from paths.
%
%   >> pathcell=pathstring_to_cellstr(pathstring)
%
% A pathstring is a list of strings separated by the character pathsep

if ~ischar(pathstring)||size(pathstring,1)>1
    error('Input must be character string')
end
if isempty(pathstring), pathcell=cell(1,0); return, end

k=strfind(pathstring,pathsep);
if ~isempty(k)
    ibeg=[1,k+1];
    iend=[k-1,numel(pathstring)];
    ind=find(iend>=ibeg);
    if ~isempty(ind)
        pathcell=cell(1,numel(ind));
        for i=1:numel(ind)
            pathcell{i}=strtrim(pathstring(ibeg(ind(i)):iend(ind(i))));
        end
    else
        pathcell=cell(1,0);
    end
else
    pathcell={pathstring};  % the string has no separators - simpler to handle separately, although will work in the loop above
end
